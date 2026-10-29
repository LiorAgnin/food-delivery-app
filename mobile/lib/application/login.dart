import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/api_result.dart';
import '../domain/auth/phone.dart';
import '../domain/failures/api_error.dart';
import 'auth_session.dart';
import 'ports.dart';

part 'login.g.dart';

const invalidPhoneMessage = 'Enter an Israeli number like 050-123-4567';
const wrongCodeMessage = 'Wrong code';
const expiredCodeMessage = 'This code expired. Send a new one.';
const tooManyAttemptsMessage =
    'Too many attempts. Wait before requesting a new code.';
const shortCodeMessage = 'Enter the 6-digit code';
const unreachableMessage = 'Could not reach the server';

const _resendCooldownSeconds = 30;
const _unset = Object();

enum LoginPhase { phone, code }

enum LoginFailure {
  none,
  invalidPhone,
  wrongCode,
  expired,
  tooManyAttempts,
  network,
  rejected,
}

class LoginState {
  const LoginState({
    this.phase = LoginPhase.phone,
    this.phoneInput = '',
    this.e164Phone,
    this.devCode,
    this.codeInput = '',
    this.busy = false,
    this.failure = LoginFailure.none,
    this.errorMessage,
    this.resendCooldownSeconds = 0,
    this.verifyLocked = false,
  });

  final LoginPhase phase;
  final String phoneInput;
  final String? e164Phone;
  final String? devCode;
  final String codeInput;
  final bool busy;
  final LoginFailure failure;
  final String? errorMessage;
  final int resendCooldownSeconds;
  final bool verifyLocked;

  bool get canResend =>
      phase == LoginPhase.code && !busy && resendCooldownSeconds == 0;

  bool get canVerify => phase == LoginPhase.code && !busy && !verifyLocked;

  LoginState copyWith({
    Object? phase = _unset,
    Object? phoneInput = _unset,
    Object? e164Phone = _unset,
    Object? devCode = _unset,
    Object? codeInput = _unset,
    Object? busy = _unset,
    Object? failure = _unset,
    Object? errorMessage = _unset,
    Object? resendCooldownSeconds = _unset,
    Object? verifyLocked = _unset,
  }) {
    return LoginState(
      phase: phase == _unset ? this.phase : phase as LoginPhase,
      phoneInput: phoneInput == _unset ? this.phoneInput : phoneInput as String,
      e164Phone: e164Phone == _unset ? this.e164Phone : e164Phone as String?,
      devCode: devCode == _unset ? this.devCode : devCode as String?,
      codeInput: codeInput == _unset ? this.codeInput : codeInput as String,
      busy: busy == _unset ? this.busy : busy as bool,
      failure: failure == _unset ? this.failure : failure as LoginFailure,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      resendCooldownSeconds: resendCooldownSeconds == _unset
          ? this.resendCooldownSeconds
          : resendCooldownSeconds as int,
      verifyLocked: verifyLocked == _unset
          ? this.verifyLocked
          : verifyLocked as bool,
    );
  }
}

@riverpod
class Login extends _$Login {
  Timer? _cooldownTimer;

  @override
  LoginState build() {
    ref.onDispose(() => _cooldownTimer?.cancel());
    return const LoginState();
  }

  void setPhone(String value) {
    final clear = state.failure == LoginFailure.invalidPhone;
    state = state.copyWith(
      phoneInput: value,
      failure: clear ? LoginFailure.none : state.failure,
      errorMessage: clear ? null : state.errorMessage,
    );
  }

  void setCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 6 ? digits.substring(0, 6) : digits;
    final clear = state.failure == LoginFailure.wrongCode;
    state = state.copyWith(
      codeInput: clipped,
      failure: clear ? LoginFailure.none : state.failure,
      errorMessage: clear ? null : state.errorMessage,
    );
  }

  Future<void> submitPhone() async {
    if (state.busy) return;
    final e164 = normalizeIsraeliPhone(state.phoneInput);
    if (e164 == null) {
      state = state.copyWith(
        failure: LoginFailure.invalidPhone,
        errorMessage: invalidPhoneMessage,
      );
      return;
    }
    await _requestCode(e164, toCodeStep: true);
  }

  Future<void> submitCode() async {
    if (state.busy || state.phase != LoginPhase.code || state.verifyLocked) {
      return;
    }
    final phone = state.e164Phone;
    if (phone == null) return;
    if (state.codeInput.length != 6) {
      state = state.copyWith(
        failure: LoginFailure.rejected,
        errorMessage: shortCodeMessage,
      );
      return;
    }
    state = state.copyWith(
      busy: true,
      failure: LoginFailure.none,
      errorMessage: null,
    );
    final result = await ref
        .read(authRepositoryProvider)
        .verifyOtp(phone: phone, code: state.codeInput);
    if (!ref.mounted) return;
    switch (result) {
      case ApiOk(:final value):
        await ref
            .read(authSessionProvider.notifier)
            .signIn(accessToken: value.accessToken, customer: value.customer);
        if (!ref.mounted) return;
        state = state.copyWith(
          busy: false,
          failure: LoginFailure.none,
          errorMessage: null,
        );
      case ApiFailure(:final error):
        _applyVerifyFailure(error);
    }
  }

  void changeNumber() {
    if (state.busy) return;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    state = LoginState(phoneInput: state.phoneInput);
  }

  Future<void> resend() async {
    if (!state.canResend) return;
    final phone = state.e164Phone;
    if (phone == null) return;
    state = state.copyWith(codeInput: '');
    await _requestCode(phone, toCodeStep: false);
  }

  Future<void> retry() async {
    if (state.failure != LoginFailure.network || state.busy) return;
    if (state.phase == LoginPhase.phone) {
      await submitPhone();
    } else {
      await submitCode();
    }
  }

  Future<void> _requestCode(String e164, {required bool toCodeStep}) async {
    state = state.copyWith(
      busy: true,
      failure: LoginFailure.none,
      errorMessage: null,
    );
    final result = await ref.read(authRepositoryProvider).requestOtp(e164);
    if (!ref.mounted) return;
    switch (result) {
      case ApiOk(:final value):
        state = state.copyWith(
          phase: LoginPhase.code,
          e164Phone: e164,
          devCode: value.devCode,
          busy: false,
          failure: LoginFailure.none,
          errorMessage: null,
          verifyLocked: false,
          codeInput: toCodeStep ? '' : state.codeInput,
        );
        _startCooldown();
      case ApiFailure(:final error):
        final network = _retryable(error.code);
        state = state.copyWith(
          busy: false,
          failure: network ? LoginFailure.network : LoginFailure.rejected,
          errorMessage: _message(error),
        );
    }
  }

  void _applyVerifyFailure(ApiError error) {
    switch (error.code) {
      case ApiErrorCode.otpInvalid:
        state = state.copyWith(
          busy: false,
          failure: LoginFailure.wrongCode,
          errorMessage: wrongCodeMessage,
        );
      case ApiErrorCode.otpExpired:
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
        state = state.copyWith(
          busy: false,
          failure: LoginFailure.expired,
          errorMessage: expiredCodeMessage,
          resendCooldownSeconds: 0,
          verifyLocked: false,
        );
      case ApiErrorCode.otpTooManyAttempts:
        state = state.copyWith(
          busy: false,
          failure: LoginFailure.tooManyAttempts,
          errorMessage: tooManyAttemptsMessage,
          verifyLocked: true,
        );
        _startCooldown();
      default:
        final network = _retryable(error.code);
        state = state.copyWith(
          busy: false,
          failure: network ? LoginFailure.network : LoginFailure.rejected,
          errorMessage: _message(error),
        );
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    state = state.copyWith(resendCooldownSeconds: _resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!ref.mounted) {
        timer.cancel();
        return;
      }
      final left = state.resendCooldownSeconds - 1;
      if (left <= 0) {
        timer.cancel();
        _cooldownTimer = null;
        state = state.copyWith(resendCooldownSeconds: 0);
      } else {
        state = state.copyWith(resendCooldownSeconds: left);
      }
    });
  }

  bool _retryable(ApiErrorCode code) {
    return code == ApiErrorCode.network || code == ApiErrorCode.timeout;
  }

  String _message(ApiError error) {
    if (error.message.isEmpty) return unreachableMessage;
    return error.message;
  }
}
