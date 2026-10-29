import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'support/e2e_app.dart';

/// Names and the unavailable dish are the server seed (fixed UUIDs, idempotent):
/// open restaurants first, Falafel HaShuk closed via `is_accepting_orders`,
/// White truffle tagliatelle at Trattoria HaYarkon with `is_available = false`.
const _openRestaurants = [
  'Alei Gefen',
  'HaTachana Grill',
  'Sushi Yama',
  'Trattoria HaYarkon',
];

void main() {
  patrolTest(
    'seeded restaurants, the closed one, an out-of-stock dish, and a cart of one',
    ($) async {
      await launchFoodDelivery($);

      await $('Alei Gefen')
          .waitUntilVisible(timeout: const Duration(seconds: 30));
      for (final name in _openRestaurants.skip(1)) {
        await $(name).scrollTo();
      }
      await $('Falafel HaShuk').scrollTo();
      expect(find.text('Closed'), findsOneWidget);

      await $('Trattoria HaYarkon').scrollTo();
      await $('Trattoria HaYarkon').tap();
      await $('Margherita')
          .waitUntilVisible(timeout: const Duration(seconds: 30));

      await $('White truffle tagliatelle').scrollTo();
      expect(find.text('Out of stock'), findsOneWidget);
      final soldOut = _menuTile('White truffle tagliatelle');
      expect(soldOut, findsOneWidget);
      expect(
        find.descendant(of: soldOut, matching: find.byIcon(Icons.add)),
        findsNothing,
      );

      await $('Margherita').scrollTo();
      await $.tester.tap(
        find.descendant(
          of: _menuTile('Margherita'),
          matching: find.byIcon(Icons.add),
        ),
      );
      await $.pumpAndSettle();

      expect(
        $.tester.widget<Text>(find.byKey(const Key('cart_badge_count'))).data,
        '1',
      );
    },
  );
}

Finder _menuTile(String name) {
  return find.ancestor(
    of: find.text(name),
    matching: find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> && key.value.startsWith('menu_item_');
    }),
  );
}
