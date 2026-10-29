import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/app/app.dart';
import 'package:food_delivery/app/bootstrap.dart';
import 'package:patrol/patrol.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/e2e_app.dart';

/// Seeded HaTachana Grill mains the dish finder returns for the assignment
/// prompt, then for the follow-up. Prices live in the server seed: schnitzel
/// 5600 and skewer 4800 are under ₪60; platter 7600 appears only after
/// "cheaper ones?" relaxes the ceiling.
const _underSixty = ['Spicy chicken schnitzel', 'Spicy chicken skewer'];

void main() {
  patrolTest(
    'OTP login, spicy chicken under 60, add to cart, then a cheaper follow-up',
    ($) async {
      await _launchSignedOut($);

      await $(#login_phone_field)
          .waitUntilVisible(timeout: const Duration(seconds: 20));
      await $(#login_phone_field)
          .enterText('050-123-4567', settlePolicy: SettlePolicy.noSettle);
      await $(#login_continue).tap(settlePolicy: SettlePolicy.noSettle);

      await $(#login_code_field)
          .waitUntilVisible(timeout: const Duration(seconds: 20));
      expect(find.text('Dev code: 123456'), findsOneWidget);
      await $(#login_code_field)
          .enterText('123456', settlePolicy: SettlePolicy.noSettle);
      await $(#login_verify).tap(settlePolicy: SettlePolicy.noSettle);

      await $('Alei Gefen')
          .waitUntilVisible(timeout: const Duration(seconds: 30));
      expect(find.text('Restaurants'), findsOneWidget);

      await $(#chat_entry).tap();
      await $(#chat_suggestion_1).waitUntilVisible();
      expect(
        find.text('Something spicy with chicken under 60 ₪'),
        findsOneWidget,
      );
      await $(#chat_suggestion_1)
          .tap(settleTimeout: const Duration(seconds: 30));

      for (final name in _underSixty) {
        await $(name).waitUntilVisible(timeout: const Duration(seconds: 30));
      }
      expect(find.byKey(const Key('chat_reply_0')), findsOneWidget);
      expect(find.text('Spicy chicken platter'), findsNothing);

      await $('Add').scrollTo();
      await $('Add').tap();
      expect(
        $.tester.widget<Text>(find.byKey(const Key('cart_badge_count'))).data,
        '1',
      );

      await $(#chat_input).enterText('cheaper ones?');
      await $(#chat_send).tap(settleTimeout: const Duration(seconds: 30));

      await $(#chat_reply_1)
          .waitUntilVisible(timeout: const Duration(seconds: 30));
      await $('Spicy chicken platter').scrollTo();
      expect(find.text('Spicy chicken platter'), findsOneWidget);
      expect(find.text('Close matches'), findsOneWidget);
    },
  );
}

/// Same tree as `lib/main.dart`, with prefs cleared so a previous journey
/// cannot skip the login screen.
Future<void> _launchSignedOut(PatrolIntegrationTester $) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  final boot = bootstrapApp(
    prefs: prefs,
    baseUrl: e2eApiBaseUrl.isEmpty ? null : e2eApiBaseUrl,
  );
  await $.pumpWidgetAndSettle(
    ProviderScope(overrides: boot.overrides, child: const FoodDeliveryApp()),
  );
}
