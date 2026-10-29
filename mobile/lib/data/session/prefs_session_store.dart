import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/auth/auth.dart';
import '../../domain/ports/session_store.dart';

/// A corrupt or half-written blob is treated as signed out. Keeping a token
/// we cannot parse would just 401 on the next launch.
final class PrefsSessionStore implements SessionStore {
  PrefsSessionStore(this._prefs);

  static const storageKey = 'auth_session_v1';

  final SharedPreferences _prefs;

  @override
  AuthSessionState read() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return const SignedOut();
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return const SignedOut();
      final token = json['accessToken'];
      final customer = json['customer'];
      if (token is! String || token.isEmpty) return const SignedOut();
      if (customer is! Map<String, dynamic>) return const SignedOut();
      final id = customer['id'];
      final phone = customer['phone'];
      if (id is! String || id.isEmpty || phone is! String || phone.isEmpty) {
        return const SignedOut();
      }
      return SignedIn(
        accessToken: token,
        customer: Customer(id: id, phone: phone),
      );
    } on FormatException {
      return const SignedOut();
    }
  }

  @override
  Future<void> persist(SignedIn session) {
    return _prefs.setString(
      storageKey,
      jsonEncode({
        'accessToken': session.accessToken,
        'customer': {
          'id': session.customer.id,
          'phone': session.customer.phone,
        },
      }),
    );
  }

  @override
  Future<void> clear() => _prefs.remove(storageKey);
}
