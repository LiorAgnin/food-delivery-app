import 'package:json_annotation/json_annotation.dart';

import '../../domain/auth/auth.dart';

part 'auth_dto.g.dart';

@JsonSerializable(createToJson: false)
class CustomerDto {
  const CustomerDto({required this.id, required this.phone});

  factory CustomerDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerDtoFromJson(json);

  final String id;
  final String phone;

  Customer toDomain() => Customer(id: id, phone: phone);
}

@JsonSerializable(createToJson: false)
class OtpChallengeDto {
  const OtpChallengeDto({required this.expiresInSeconds, this.devCode});

  factory OtpChallengeDto.fromJson(Map<String, dynamic> json) =>
      _$OtpChallengeDtoFromJson(json);

  final int expiresInSeconds;
  final String? devCode;

  OtpChallenge toDomain() =>
      OtpChallenge(expiresInSeconds: expiresInSeconds, devCode: devCode);
}

@JsonSerializable(createToJson: false)
class VerifiedAuthDto {
  const VerifiedAuthDto({required this.accessToken, required this.customer});

  factory VerifiedAuthDto.fromJson(Map<String, dynamic> json) =>
      _$VerifiedAuthDtoFromJson(json);

  final String accessToken;
  final CustomerDto customer;

  VerifiedAuth toDomain() =>
      VerifiedAuth(accessToken: accessToken, customer: customer.toDomain());
}
