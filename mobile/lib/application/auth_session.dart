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

  /// HTTP 401 for [sentToken]. Omit the token when the caller does not
  /// know it. A bearer that is no longer the current session is ignored,
  /// so a late 401 cannot sign out a newer sign-in. The in-memory flip
  /// happens before disk so a redirect does not wait on shared_preferences.
  Future<void> clearOnUnauthorized([String? sentToken]) async {
    final current = state;
    if (current is! SignedIn) return;
    if (sentToken != null && sentToken != current.accessToken) return;
    state = const SignedOut();
    await ref.read(sessionStoreProvider).clear();
  }
}
