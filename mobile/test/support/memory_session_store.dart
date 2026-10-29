import 'package:food_delivery/domain/auth/auth.dart';
import 'package:food_delivery/domain/ports/session_store.dart';

final class MemorySessionStore implements SessionStore {
  MemorySessionStore([AuthSessionState? initial])
    : _state = initial ?? const SignedOut();

  AuthSessionState _state;

  @override
  AuthSessionState read() => _state;

  @override
  Future<void> persist(SignedIn session) async {
    _state = session;
  }

  @override
  Future<void> clear() async {
    _state = const SignedOut();
  }
}
