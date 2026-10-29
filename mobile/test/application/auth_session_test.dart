import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/auth_session.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/data/data_plane.dart';
import 'package:food_delivery/data/session/prefs_session_store.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/auth/auth.dart';
import 'package:food_delivery/domain/catalog/catalog.dart';
import 'package:food_delivery/domain/failures/api_error.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const signedIn = SignedIn(
    accessToken: 'token',
    customer: Customer(id: 'c1', phone: '+972501234567'),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists a session and treats a corrupt blob as signed out', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = PrefsSessionStore(prefs);
    expect(store.read(), isA<SignedOut>());

    await store.persist(signedIn);
    final restored = PrefsSessionStore(prefs).read();
    expect(restored, isA<SignedIn>());
    final session = restored as SignedIn;
    expect(session.accessToken, 'token');
    expect(session.customer.phone, '+972501234567');

    await prefs.setString(PrefsSessionStore.storageKey, '{');
    expect(PrefsSessionStore(prefs).read(), isA<SignedOut>());
  });

  test('signOut and a 401 both clear the persisted token', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = PrefsSessionStore(prefs);
    await store.persist(signedIn);

    final headers = <String?>[];
    final httpClient = MockClient((request) async {
      headers.add(request.headers['authorization']);
      return http.Response(
        jsonEncode({
          'error': {'code': 'UNAUTHORIZED', 'message': 'Sign in again'},
        }),
        401,
      );
    });

    final container = ProviderContainer(
      overrides: [
        sessionStoreProvider.overrideWithValue(store),
        ...dataPlaneBindings(
          httpClient: httpClient,
          baseUrl: 'http://localhost:3000/api',
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(authSessionProvider), isA<SignedIn>());
    final result = await container
        .read(catalogRepositoryProvider)
        .listRestaurants();
    expect(result, isA<ApiFailure<List<Restaurant>>>());
    expect(
      (result as ApiFailure<List<Restaurant>>).error.code,
      ApiErrorCode.unauthorized,
    );
    expect(container.read(authSessionProvider), isA<SignedOut>());
    expect(headers, ['Bearer token']);
    expect(prefs.getString(PrefsSessionStore.storageKey), isNull);

    await container
        .read(authSessionProvider.notifier)
        .signIn(accessToken: 'next', customer: signedIn.customer);
    expect(prefs.getString(PrefsSessionStore.storageKey), isNotNull);
    await container.read(authSessionProvider.notifier).signOut();
    expect(container.read(authSessionProvider), isA<SignedOut>());
    expect(prefs.getString(PrefsSessionStore.storageKey), isNull);
  });
}
