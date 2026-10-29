import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';

@freezed
abstract class Customer with _$Customer {
  const factory Customer({required String id, required String phone}) =
      _Customer;
}

@freezed
abstract class OtpChallenge with _$OtpChallenge {
  const factory OtpChallenge({required int expiresInSeconds, String? devCode}) =
      _OtpChallenge;
}

@freezed
abstract class VerifiedAuth with _$VerifiedAuth {
  const factory VerifiedAuth({
    required String accessToken,
    required Customer customer,
  }) = _VerifiedAuth;
}

/// What the app knows about the signed-in customer.
sealed class AuthSessionState {
  const AuthSessionState();
}

final class SignedOut extends AuthSessionState {
  const SignedOut();
}

final class SignedIn extends AuthSessionState {
  const SignedIn({required this.accessToken, required this.customer});

  final String accessToken;
  final Customer customer;
}
