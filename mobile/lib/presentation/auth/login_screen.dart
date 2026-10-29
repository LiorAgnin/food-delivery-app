import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/login.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    ref.listen(loginProvider, (previous, next) {
      final movedToCode =
          next.phase == LoginPhase.code && previous?.phase != LoginPhase.code;
      if (movedToCode && kDebugMode && next.devCode != null) {
        final code = next.devCode!;
        _code.value = TextEditingValue(
          text: code,
          selection: TextSelection.collapsed(offset: code.length),
        );
        ref.read(loginProvider.notifier).setCode(code);
        return;
      }
      if (next.codeInput.isEmpty && _code.text.isNotEmpty) {
        _code.clear();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (state.phase == LoginPhase.phone) ...[
              TextField(
                key: const Key('login_phone_field'),
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumber],
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '050-123-4567',
                ),
                onChanged: (value) =>
                    ref.read(loginProvider.notifier).setPhone(value),
                onSubmitted: (_) {
                  if (!state.busy) {
                    ref.read(loginProvider.notifier).submitPhone();
                  }
                },
              ),
            ] else ...[
              Text('We sent a code to ${state.e164Phone ?? state.phoneInput}'),
              if (kDebugMode && state.devCode != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Dev code: ${state.devCode}',
                  key: const Key('login_dev_code'),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                key: const Key('login_code_field'),
                controller: _code,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Code',
                  counterText: '',
                ),
                onChanged: (value) =>
                    ref.read(loginProvider.notifier).setCode(value),
              ),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(state.errorMessage!, key: const Key('login_error')),
            ],
            const SizedBox(height: 16),
            if (state.busy)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(
                  child: SizedBox(
                    key: Key('login_loading'),
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            if (state.phase == LoginPhase.phone)
              FilledButton(
                key: const Key('login_continue'),
                onPressed: state.busy
                    ? null
                    : () => ref.read(loginProvider.notifier).submitPhone(),
                child: const Text('Continue'),
              )
            else ...[
              FilledButton(
                key: const Key('login_verify'),
                onPressed: state.canVerify && state.codeInput.length == 6
                    ? () => ref.read(loginProvider.notifier).submitCode()
                    : null,
                child: const Text('Verify'),
              ),
              TextButton(
                key: const Key('login_change_number'),
                onPressed: state.busy
                    ? null
                    : () => ref.read(loginProvider.notifier).changeNumber(),
                child: const Text('Change number'),
              ),
              TextButton(
                key: const Key('login_resend'),
                onPressed: state.canResend
                    ? () => ref.read(loginProvider.notifier).resend()
                    : null,
                child: Text(
                  state.resendCooldownSeconds > 0
                      ? 'Resend in ${state.resendCooldownSeconds}s'
                      : 'Resend',
                ),
              ),
            ],
            if (state.failure == LoginFailure.network)
              TextButton(
                key: const Key('login_retry'),
                onPressed: state.busy
                    ? null
                    : () => ref.read(loginProvider.notifier).retry(),
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
