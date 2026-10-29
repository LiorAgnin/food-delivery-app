import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/auth/auth.dart';
import 'ports.dart';

part 'auth_session.g.dart';

@Riverpod(keepAlive: true)
class AuthSession extends _$AuthSession {
  @override
  AuthSessionState build() => ref.watch(sessionStoreProvider).read();

  Future<void> signIn({
    required String accessToken,
    required Customer customer,
  }) async {
    final next = SignedIn(accessToken: accessToken, customer: customer);
    await ref.read(sessionStoreProvider).persist(next);
    state = next;
  }

  Future<void> signOut() async {
    await ref.read(sessionStoreProvider).clear();
    state = const SignedOut();
  }

  /// HTTP 401. The in-memory flip happens before disk so a redirect does
  /// not wait on shared_preferences, and the disk clear is awaited by the
  /// call that observed the 401.
  Future<void> clearOnUnauthorized() async {
    if (state is SignedOut) return;
    state = const SignedOut();
    await ref.read(sessionStoreProvider).clear();
  }
}
