import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/app/app.dart';
import 'package:food_delivery/app/bootstrap.dart';
import 'package:food_delivery/application/auth_session.dart';
import 'package:food_delivery/domain/auth/auth.dart';
import 'package:patrol/patrol.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// From `tool/e2e.sh`: `--dart-define=API_BASE_URL=http://10.0.2.2:<port>/api`.
/// Empty keeps the platform default inside the data plane.
const e2eApiBaseUrl = String.fromEnvironment('API_BASE_URL');

/// Cold-launches the same tree as `lib/main.dart`.
///
/// The login screen is still `TODO(owner): login`, so this journey cannot
/// type an OTP. `GET /restaurants` is public; the token only satisfies the
/// router's signed-in redirect. It is written through [AuthSession.signIn],
/// the port `verifyOtp` will use once that screen exists. A real JWT is not
/// required for the catalog, and a 401 from a later authenticated call would
/// clear this session the same way a user's would.
Future<void> launchFoodDelivery(PatrolIntegrationTester $) async {
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
        accessToken: 'e2e-catalog',
        customer: const Customer(
          id: '00000000-0000-4000-8000-000000000001',
          phone: '+972500000000',
        ),
      );
  await $.pump();
}
