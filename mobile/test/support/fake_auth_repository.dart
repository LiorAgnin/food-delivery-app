import 'dart:async';

import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/auth/auth.dart';
import 'package:food_delivery/domain/ports/auth_repository.dart';

final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    List<ApiResult<OtpChallenge>>? requests,
    List<ApiResult<VerifiedAuth>>? verifications,
  }) : requests = requests ?? const <ApiResult<OtpChallenge>>[],
       verifications = verifications ?? const <ApiResult<VerifiedAuth>>[];

  final List<ApiResult<OtpChallenge>> requests;
  final List<ApiResult<VerifiedAuth>> verifications;
  final List<String> requestedPhones = [];
  final List<({String phone, String code})> submittedCodes = [];

  /// When set, [requestOtp] and [verifyOtp] wait on it after recording the call.
  Completer<void>? blockRequest;

  @override
  Future<ApiResult<OtpChallenge>> requestOtp(String phone) async {
    requestedPhones.add(phone);
    final gate = blockRequest;
    if (gate != null) await gate.future;
    if (requests.isEmpty) {
      return const ApiOk(
        OtpChallenge(expiresInSeconds: 300, devCode: '123456'),
      );
    }
    final index = requestedPhones.length - 1;
    return index < requests.length ? requests[index] : requests.last;
  }

  @override
  Future<ApiResult<VerifiedAuth>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    submittedCodes.add((phone: phone, code: code));
    final gate = blockRequest;
    if (gate != null) await gate.future;
    if (verifications.isEmpty) {
      return ApiOk(
        VerifiedAuth(
          accessToken: 'jwt',
          customer: Customer(id: 'c1', phone: phone),
        ),
      );
    }
    final index = submittedCodes.length - 1;
    return index < verifications.length
        ? verifications[index]
        : verifications.last;
  }
}
