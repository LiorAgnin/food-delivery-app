// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerDto _$CustomerDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CustomerDto', json, ($checkedConvert) {
      final val = CustomerDto(
        id: $checkedConvert('id', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String),
      );
      return val;
    });

OtpChallengeDto _$OtpChallengeDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OtpChallengeDto', json, ($checkedConvert) {
      final val = OtpChallengeDto(
        expiresInSeconds: $checkedConvert(
          'expiresInSeconds',
          (v) => (v as num).toInt(),
        ),
        devCode: $checkedConvert('devCode', (v) => v as String?),
      );
      return val;
    });

VerifiedAuthDto _$VerifiedAuthDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VerifiedAuthDto', json, ($checkedConvert) {
      final val = VerifiedAuthDto(
        accessToken: $checkedConvert('accessToken', (v) => v as String),
        customer: $checkedConvert(
          'customer',
          (v) => CustomerDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });
