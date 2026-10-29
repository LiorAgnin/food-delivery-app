import '../api_result.dart';
import '../auth/auth.dart';

abstract interface class AuthRepository {
  Future<ApiResult<OtpChallenge>> requestOtp(String phone);

  Future<ApiResult<VerifiedAuth>> verifyOtp({
    required String phone,
    required String code,
  });
}
