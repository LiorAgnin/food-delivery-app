import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/app/app.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/auth/auth.dart';
import 'package:food_delivery/domain/failures/api_error.dart';

import '../support/fake_auth_repository.dart';
import '../support/fake_catalog_repository.dart';
import '../support/memory_session_store.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    required FakeAuthRepository auth,
    AuthSessionState session = const SignedOut(),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          sessionStoreProvider.overrideWithValue(MemorySessionStore(session)),
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ],
        child: const FoodDeliveryApp(),
      ),
    );
  }

  testWidgets('an invalid phone is rejected inline', (tester) async {
    final auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('login_phone_field')), '123');
    await tester.tap(find.byKey(const Key('login_continue')));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter an Israeli number like 050-123-4567'),
      findsOneWidget,
    );
    expect(auth.requestedPhones, isEmpty);
    expect(find.byKey(const Key('login_code_field')), findsNothing);
  });

  testWidgets('a wrong code shows Wrong code and stays on the code step', (
    tester,
  ) async {
    final auth = FakeAuthRepository(
      verifications: const [
        ApiFailure(ApiError(code: ApiErrorCode.otpInvalid, message: 'Nope')),
      ],
    );
    await pumpApp(tester, auth: auth);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_phone_field')),
      '050-123-4567',
    );
    await tester.tap(find.byKey(const Key('login_continue')));
    await tester.pumpAndSettle();

    expect(find.text('Dev code: 123456'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('login_code_field')), '000000');
    await tester.tap(find.byKey(const Key('login_verify')));
    await tester.pumpAndSettle();

    expect(find.text('Wrong code'), findsOneWidget);
    expect(find.byKey(const Key('login_code_field')), findsOneWidget);
    expect(find.text('Restaurants'), findsNothing);
  });

  testWidgets('a valid code opens the restaurant list', (tester) async {
    final auth = FakeAuthRepository();
    await pumpApp(tester, auth: auth);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_phone_field')),
      '+972501234567',
    );
    await tester.tap(find.byKey(const Key('login_continue')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('login_code_field')), '123456');
    await tester.tap(find.byKey(const Key('login_verify')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('restaurant_list_empty')), findsOneWidget);
    expect(find.byKey(const Key('login_phone_field')), findsNothing);
    expect(auth.submittedCodes.single.code, '123456');
    expect(auth.submittedCodes.single.phone, '+972501234567');
  });

  testWidgets('sign out from the restaurant list returns to login', (
    tester,
  ) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      session: const SignedIn(
        accessToken: 'token',
        customer: Customer(id: 'c1', phone: '+972501234567'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('restaurant_overflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sign_out')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_phone_field')), findsOneWidget);
    expect(find.text('Restaurants'), findsNothing);
  });
}
