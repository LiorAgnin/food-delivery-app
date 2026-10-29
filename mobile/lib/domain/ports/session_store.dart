import '../auth/auth.dart';

/// Persistence for [AuthSessionState]. Reads are synchronous so the session
/// notifier can restore state inside `build` without an extra loading frame.
abstract interface class SessionStore {
  AuthSessionState read();

  Future<void> persist(SignedIn session);

  Future<void> clear();
}
