import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/app/app.dart';
import 'package:food_delivery/app/bootstrap.dart';
import 'package:food_delivery/application/auth_session.dart';
import 'package:food_delivery/domain/auth/auth.dart';
import 'package:patrol/patrol.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// From `tool/e2e.sh`: `API_BASE_URL` is `http://localhost:<port>/api` on a
/// USB device and `http://10.0.2.2:<port>/api` on the emulator.
/// Empty keeps the platform default inside the data plane.
const e2eApiBaseUrl = String.fromEnvironment('API_BASE_URL');

/// Cold-launches the same tree as `lib/main.dart`.
///
/// The login screen is still `TODO(owner): login`, so this journey cannot
/// type an OTP. `GET /restaurants` is public; the token only satisfies the
/// router's signed-in redirect. It is written through [AuthSession.signIn],
/// the port `verifyOtp` will use once that screen exists.
///
/// [accessToken] defaults to a placeholder, which is enough for the catalog.
/// `POST /orders` is authenticated: a placeholder 401s and the client clears
/// the session. Checkout passes a real customer JWT from `E2E_ACCESS_TOKEN`.
Future<void> launchFoodDelivery(
  PatrolIntegrationTester $, {
  String accessToken = 'e2e-catalog',
  String customerId = '00000000-0000-4000-8000-000000000001',
  String phone = '+972500000000',
}) async {
  final prefs = await SharedPreferences.getInstance();
  final boot = bootstrapApp(
    prefs: prefs,
    baseUrl: e2eApiBaseUrl.isEmpty ? null : e2eApiBaseUrl,
  );
  await $.pumpWidgetAndSettle(
    ProviderScope(overrides: boot.overrides, child: const FoodDeliveryApp()),
  );
  final container = ProviderScope.containerOf(
    $.tester.element(find.byType(FoodDeliveryApp)),
  );
  await container
      .read(authSessionProvider.notifier)
      .signIn(
        accessToken: accessToken,
        customer: Customer(id: customerId, phone: phone),
      );
  await $.pump();
}
