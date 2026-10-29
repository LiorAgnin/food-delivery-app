import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/auth_session.dart';
import 'package:food_delivery/application/login.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/auth/auth.dart';
import 'package:food_delivery/domain/failures/api_error.dart';

import '../support/fake_auth_repository.dart';
import '../support/memory_session_store.dart';

void main() {
  ProviderContainer containerOf(FakeAuthRepository auth) {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        sessionStoreProvider.overrideWithValue(MemorySessionStore()),
      ],
    );
    final subscription = container.listen(loginProvider, (_, _) {});
    addTearDown(() {
      subscription.close();
      container.dispose();
    });
    return container;
  }

  test('an invalid phone is rejected before any request', () async {
    final auth = FakeAuthRepository();
    final container = containerOf(auth);
    final login = container.read(loginProvider.notifier);

    login.setPhone('123');
    await login.submitPhone();

    expect(auth.requestedPhones, isEmpty);
    expect(container.read(loginProvider).phase, LoginPhase.phone);
    expect(
      container.read(loginProvider).errorMessage,
      'Enter an Israeli number like 050-123-4567',
    );
  });

  test('a local number requests a code and keeps the dev code', () async {
    final auth = FakeAuthRepository();
    final container = containerOf(auth);
    final login = container.read(loginProvider.notifier);

    login.setPhone('050-123-4567');
    await login.submitPhone();

    expect(auth.requestedPhones, ['+972501234567']);
    final state = container.read(loginProvider);
    expect(state.phase, LoginPhase.code);
    expect(state.e164Phone, '+972501234567');
    expect(state.devCode, '123456');
    expect(state.resendCooldownSeconds, 30);
    expect(state.canResend, isFalse);
  });

  test('the wrong code stays on the code step and does not sign in', () async {
    final auth = FakeAuthRepository(
      verifications: const [
        ApiFailure(ApiError(code: ApiErrorCode.otpInvalid, message: 'Nope')),
      ],
    );
    final container = containerOf(auth);
    final login = container.read(loginProvider.notifier);
    login.setPhone('+972501234567');
    await login.submitPhone();
    login.setCode('000000');
    await login.submitCode();

    final state = container.read(loginProvider);
    expect(state.phase, LoginPhase.code);
    expect(state.errorMessage, 'Wrong code');
    expect(state.failure, LoginFailure.wrongCode);
    expect(container.read(authSessionProvider), isA<SignedOut>());
    expect(auth.submittedCodes.single.code, '000000');
  });

  test('an expired code clears the resend cooldown', () async {
    final auth = FakeAuthRepository(
      verifications: const [
        ApiFailure(ApiError(code: ApiErrorCode.otpExpired, message: 'Expired')),
      ],
    );
    final container = containerOf(auth);
    final login = container.read(loginProvider.notifier);
    login.setPhone('050-123-4567');
    await login.submitPhone();
    login.setCode('123456');
    await login.submitCode();

    final state = container.read(loginProvider);
    expect(state.failure, LoginFailure.expired);
    expect(state.errorMessage, 'This code expired. Send a new one.');
    expect(state.resendCooldownSeconds, 0);
    expect(state.canResend, isTrue);
  });

  test('too many attempts locks verification and starts a cooldown', () async {
    final auth = FakeAuthRepository(
      verifications: const [
        ApiFailure(
          ApiError(code: ApiErrorCode.otpTooManyAttempts, message: 'Slow down'),
        ),
      ],
    );
    final container = containerOf(auth);
    final login = container.read(loginProvider.notifier);
    login.setPhone('050-123-4567');
    await login.submitPhone();
    login.setCode('123456');
    await login.submitCode();

    final state = container.read(loginProvider);
    expect(state.failure, LoginFailure.tooManyAttempts);
    expect(
      state.errorMessage,
      'Too many attempts. Wait before requesting a new code.',
    );
    expect(state.verifyLocked, isTrue);
    expect(state.canVerify, isFalse);
    expect(state.resendCooldownSeconds, 30);
    expect(state.canResend, isFalse);
  });

  test('a network failure can be retried with the same number', () async {
    final auth = FakeAuthRepository(
      requests: const [
        ApiFailure(ApiError(code: ApiErrorCode.network, message: 'Offline')),
        ApiOk(OtpChallenge(expiresInSeconds: 300, devCode: '123456')),
      ],
    );
    final container = containerOf(auth);
    final login = container.read(loginProvider.notifier);
    login.setPhone('050-123-4567');
    await login.submitPhone();

    expect(container.read(loginProvider).failure, LoginFailure.network);
    expect(container.read(loginProvider).errorMessage, 'Offline');
    expect(container.read(loginProvider).phase, LoginPhase.phone);

    await login.retry();

    expect(container.read(loginProvider).phase, LoginPhase.code);
    expect(auth.requestedPhones, ['+972501234567', '+972501234567']);
  });

  test('a valid code stores the session', () async {
    final auth = FakeAuthRepository();
    final container = containerOf(auth);
    final login = container.read(loginProvider.notifier);
    login.setPhone('050-123-4567');
    await login.submitPhone();
    login.setCode('123456');
    await login.submitCode();

    final session = container.read(authSessionProvider);
    expect(session, isA<SignedIn>());
    final signedIn = session as SignedIn;
    expect(signedIn.accessToken, 'jwt');
    expect(signedIn.customer.id, 'c1');
    expect(signedIn.customer.phone, '+972501234567');
    expect(auth.submittedCodes.single.phone, '+972501234567');
    expect(auth.submittedCodes.single.code, '123456');
  });

  test(
    'change number returns to the phone step and keeps what was typed',
    () async {
      final container = containerOf(FakeAuthRepository());
      final login = container.read(loginProvider.notifier);
      login.setPhone('050-123-4567');
      await login.submitPhone();
      login.changeNumber();

      final state = container.read(loginProvider);
      expect(state.phase, LoginPhase.phone);
      expect(state.phoneInput, '050-123-4567');
      expect(state.devCode, isNull);
      expect(state.codeInput, '');
    },
  );

  testWidgets(
    'resend waits out the 30 second cooldown, then uses the same number',
    (tester) async {
      final auth = FakeAuthRepository();
      final container = containerOf(auth);
      final login = container.read(loginProvider.notifier);
      login.setPhone('050-123-4567');
      await login.submitPhone();

      login.setCode('111111');
      await login.resend();
      expect(auth.requestedPhones, ['+972501234567']);
      expect(container.read(loginProvider).codeInput, '111111');

      await tester.pump(const Duration(seconds: 30));
      expect(container.read(loginProvider).canResend, isTrue);
      await login.resend();

      final state = container.read(loginProvider);
      expect(auth.requestedPhones, ['+972501234567', '+972501234567']);
      expect(state.phase, LoginPhase.code);
      expect(state.codeInput, '');
      expect(state.resendCooldownSeconds, 30);

      await tester.pump(const Duration(seconds: 30));
      expect(container.read(loginProvider).resendCooldownSeconds, 0);
      expect(container.read(loginProvider).canResend, isTrue);
    },
  );

  test('a short code is not submitted', () async {
    final auth = FakeAuthRepository();
    final container = containerOf(auth);
    final login = container.read(loginProvider.notifier);
    login.setPhone('050-123-4567');
    await login.submitPhone();
    login.setCode('12345');
    await login.submitCode();

    expect(auth.submittedCodes, isEmpty);
    expect(
      container.read(loginProvider).errorMessage,
      'Enter the 6-digit code',
    );
  });
}
