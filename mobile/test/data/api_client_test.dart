import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/data/api_client.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/failures/api_error.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  ApiClient client(
    Future<http.Response> Function(http.Request request) handler, {
    String? token = 'token',
    Future<void> Function()? onUnauthorized,
    Duration timeout = const Duration(seconds: 10),
  }) {
    return ApiClient(
      httpClient: MockClient(handler),
      baseUrl: 'http://localhost:3000/api/',
      readToken: () => token,
      onUnauthorized: onUnauthorized,
      timeout: timeout,
    );
  }

  ApiError failure(ApiResult<Object?> result) {
    expect(result, isA<ApiFailure<Object?>>());
    return (result as ApiFailure<Object?>).error;
  }

  test('sends the bearer token and decodes a success body', () async {
    final api = client((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), 'http://localhost:3000/api/restaurants');
      expect(request.headers['authorization'], 'Bearer token');
      return http.Response(jsonEncode({'ok': true}), 200);
    });

    final result = await api.get<bool>(
      '/restaurants',
      (json) => json is Map && json['ok'] == true,
    );

    expect(result, isA<ApiOk<bool>>());
    expect((result as ApiOk<bool>).value, isTrue);
  });

  test('omits the header when there is no token', () async {
    final api = client((request) async {
      expect(request.headers.containsKey('authorization'), isFalse);
      return http.Response('{"ok":true}', 200);
    }, token: null);

    final result = await api.get<Object?>('/health', (json) => json);
    expect(result, isA<ApiOk<Object?>>());
  });

  test('maps the contract envelope, including details', () async {
    final api = client((request) async {
      return http.Response(
        jsonEncode({
          'error': {
            'code': 'BELOW_MINIMUM',
            'message': 'Order is below the minimum',
            'details': {'minOrderAgorot': 5000, 'subtotalAgorot': 1000},
          },
        }),
        422,
      );
    });

    final error = failure(await api.post('/orders', (json) => json, body: {}));
    expect(error.code, ApiErrorCode.belowMinimum);
    expect(error.message, 'Order is below the minimum');
    expect(error.statusCode, 422);
    expect(error.details, {'minOrderAgorot': 5000, 'subtotalAgorot': 1000});
  });

  test('a 401 clears the session and keeps the envelope code', () async {
    var cleared = 0;
    final api = client(
      (request) async {
        return http.Response(
          jsonEncode({
            'error': {'code': 'OTP_INVALID', 'message': 'Wrong code'},
          }),
          401,
        );
      },
      onUnauthorized: () async {
        cleared += 1;
      },
    );

    final error = failure(
      await api.post('/auth/otp/verify', (json) => json, body: {}),
    );
    expect(error.code, ApiErrorCode.otpInvalid);
    expect(cleared, 1);
  });

  test('an unrecognized code is unknown', () async {
    final api = client((request) async {
      return http.Response(
        jsonEncode({
          'error': {'code': 'MELTED', 'message': 'nope'},
        }),
        500,
      );
    });

    expect(
      failure(await api.get('/restaurants', (json) => json)).code,
      ApiErrorCode.unknown,
    );
  });

  test('a non-envelope error body is unknown', () async {
    final api = client((request) async => http.Response('nope', 502));
    final error = failure(await api.get('/restaurants', (json) => json));
    expect(error.code, ApiErrorCode.unknown);
    expect(error.message, 'HTTP 502');
  });

  test('bad JSON on success is malformed', () async {
    final api = client((request) async => http.Response('{', 200));
    expect(
      failure(await api.get('/restaurants', (json) => json)).code,
      ApiErrorCode.malformed,
    );
  });

  test('a success body that is not an object is malformed', () async {
    final api = client((request) async => http.Response('[]', 200));
    final result = await api.get<Map<String, dynamic>>('/restaurants', (json) {
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object');
      }
      return json;
    });
    expect(failure(result).code, ApiErrorCode.malformed);
  });

  test('socket and client exceptions are network', () async {
    final socket = client((request) async {
      throw const SocketException('offline');
    });
    expect(
      failure(await socket.get('/restaurants', (json) => json)).code,
      ApiErrorCode.network,
    );

    final clientError = client((request) async {
      throw http.ClientException('failed');
    });
    expect(
      failure(await clientError.get('/restaurants', (json) => json)).code,
      ApiErrorCode.network,
    );
  });

  test('a timeout exception and a hung request are timeout', () async {
    final thrown = client((request) async {
      throw TimeoutException('slow');
    });
    expect(
      failure(await thrown.get('/restaurants', (json) => json)).code,
      ApiErrorCode.timeout,
    );

    final hung = client(
      (request) => Completer<http.Response>().future,
      timeout: const Duration(milliseconds: 20),
    );
    expect(
      failure(await hung.get('/restaurants', (json) => json)).code,
      ApiErrorCode.timeout,
    );
  });

  test('maps every contract code', () async {
    const codes = {
      'VALIDATION_FAILED': ApiErrorCode.validationFailed,
      'UNAUTHORIZED': ApiErrorCode.unauthorized,
      'NOT_FOUND': ApiErrorCode.notFound,
      'INVALID_TRANSITION': ApiErrorCode.invalidTransition,
      'CONCURRENT_UPDATE': ApiErrorCode.concurrentUpdate,
      'IDEMPOTENCY_CONFLICT': ApiErrorCode.idempotencyConflict,
      'RESTAURANT_CLOSED': ApiErrorCode.restaurantClosed,
      'ITEM_UNAVAILABLE': ApiErrorCode.itemUnavailable,
      'ITEM_NOT_IN_RESTAURANT': ApiErrorCode.itemNotInRestaurant,
      'BELOW_MINIMUM': ApiErrorCode.belowMinimum,
      'OTP_INVALID': ApiErrorCode.otpInvalid,
      'OTP_EXPIRED': ApiErrorCode.otpExpired,
      'OTP_TOO_MANY_ATTEMPTS': ApiErrorCode.otpTooManyAttempts,
      'INTERNAL': ApiErrorCode.internal,
    };

    for (final entry in codes.entries) {
      final api = client((request) async {
        return http.Response(
          jsonEncode({
            'error': {'code': entry.key, 'message': entry.key},
          }),
          400,
        );
      });
      expect(
        failure(await api.get('/x', (json) => json)).code,
        entry.value,
        reason: entry.key,
      );
    }
  });
}
