import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/api_result.dart';
import '../domain/failures/api_error.dart';

part 'api_client.g.dart';

/// One shared HTTP client. Returns [ApiResult] and never throws for
/// transport, timeout, or contract-envelope failures.
final class ApiClient {
  ApiClient({
    required this.httpClient,
    required this.baseUrl,
    required this.readToken,
    this.onUnauthorized,
    this.timeout = const Duration(seconds: 10),
  });

  final http.Client httpClient;
  final String baseUrl;
  final Duration timeout;
  final String? Function() readToken;
  final Future<void> Function()? onUnauthorized;

  Future<ApiResult<T>> get<T>(String path, T Function(Object? json) decode) {
    return _send('GET', path, decode);
  }

  Future<ApiResult<T>> post<T>(
    String path,
    T Function(Object? json) decode, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _send('POST', path, decode, body: body, headers: headers);
  }

  Future<ApiResult<T>> patch<T>(
    String path,
    T Function(Object? json) decode, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _send('PATCH', path, decode, body: body, headers: headers);
  }

  Future<ApiResult<T>> _send<T>(
    String method,
    String path,
    T Function(Object? json) decode, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    final requestHeaders = <String, String>{
      'accept': 'application/json',
      ...?headers,
    };
    final token = readToken();
    if (token != null && token.isNotEmpty) {
      requestHeaders['authorization'] = 'Bearer $token';
    }
    Object? encoded;
    if (body != null) {
      requestHeaders['content-type'] = 'application/json';
      encoded = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await _dispatch(
        method,
        uri,
        requestHeaders,
        encoded,
      ).timeout(timeout);
    } on TimeoutException {
      return _fail(ApiErrorCode.timeout, 'The request timed out');
    } on SocketException {
      return _fail(ApiErrorCode.network, 'Network unavailable');
    } on http.ClientException {
      return _fail(ApiErrorCode.network, 'Network unavailable');
    } on Exception {
      return _fail(ApiErrorCode.unknown, 'Something went wrong');
    }

    return _decodeResponse(response, decode);
  }

  Future<http.Response> _dispatch(
    String method,
    Uri uri,
    Map<String, String> headers,
    Object? body,
  ) {
    return switch (method) {
      'GET' => httpClient.get(uri, headers: headers),
      'POST' => httpClient.post(uri, headers: headers, body: body),
      'PATCH' => httpClient.patch(uri, headers: headers, body: body),
      _ => Future<http.Response>.error(
        ArgumentError.value(method, 'method', 'unsupported'),
      ),
    };
  }

  Future<ApiResult<T>> _decodeResponse<T>(
    http.Response response,
    T Function(Object? json) decode,
  ) async {
    final status = response.statusCode;
    final Object? json;
    try {
      if (response.body.isEmpty) {
        throw const FormatException('Empty body');
      }
      json = jsonDecode(response.body);
    } on FormatException {
      if (status == 401) await onUnauthorized?.call();
      if (status >= 200 && status < 300) {
        return _fail(
          ApiErrorCode.malformed,
          'The response was not valid JSON',
          statusCode: status,
        );
      }
      return _fail(ApiErrorCode.unknown, 'HTTP $status', statusCode: status);
    }

    if (status < 200 || status >= 300) {
      // Any 401 drops the session, including OTP failures: the contract
      // uses 401 for both a dead access token and a bad code.
      if (status == 401) await onUnauthorized?.call();
      return ApiFailure(_envelope(json, status));
    }

    try {
      return ApiOk(decode(json));
    } on FormatException {
      return _fail(
        ApiErrorCode.malformed,
        'The response was not valid JSON',
        statusCode: status,
      );
    } on CheckedFromJsonException {
      return _fail(
        ApiErrorCode.malformed,
        'The response was not valid JSON',
        statusCode: status,
      );
    } on Exception {
      return _fail(
        ApiErrorCode.unknown,
        'Something went wrong',
        statusCode: status,
      );
    }
  }

  ApiError _envelope(Object? json, int status) {
    if (json is Map<String, dynamic>) {
      final error = json['error'];
      if (error is Map<String, dynamic>) {
        final code = error['code'];
        final message = error['message'];
        if (code is String && message is String) {
          return ApiError(
            code: apiErrorCodeFromWire(code),
            message: message,
            details: error['details'],
            statusCode: status,
          );
        }
      }
    }
    return ApiError(
      code: ApiErrorCode.unknown,
      message: 'HTTP $status',
      statusCode: status,
    );
  }

  Uri _uri(String path) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final suffix = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$suffix');
  }

  ApiFailure<T> _fail<T>(
    ApiErrorCode code,
    String message, {
    int? statusCode,
    Object? details,
  }) {
    return ApiFailure(
      ApiError(
        code: code,
        message: message,
        statusCode: statusCode,
        details: details,
      ),
    );
  }
}

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) =>
    throw UnimplementedError('bound in app/bootstrap.dart');
