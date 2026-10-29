import '../../domain/api_result.dart';
import '../../domain/auth/auth.dart';
import '../../domain/ports/auth_repository.dart';
import '../api_client.dart';
import '../dto/auth_dto.dart';
import '../json_body.dart';

final class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._client);

  final ApiClient _client;

  @override
  Future<ApiResult<OtpChallenge>> requestOtp(String phone) {
    return _client.post(
      '/auth/otp/request',
      (json) => OtpChallengeDto.fromJson(asJsonMap(json)).toDomain(),
      body: {'phone': phone},
    );
  }

  @override
  Future<ApiResult<VerifiedAuth>> verifyOtp({
    required String phone,
    required String code,
  }) {
    return _client.post(
      '/auth/otp/verify',
      (json) => VerifiedAuthDto.fromJson(asJsonMap(json)).toDomain(),
      body: {'phone': phone, 'code': code},
    );
  }
}
