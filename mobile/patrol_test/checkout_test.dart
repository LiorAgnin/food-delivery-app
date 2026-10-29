import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'support/e2e_app.dart';

/// Minted on the host (`npm run token`) and passed by `tool/e2e.sh`.
/// A fake catalog token 401s on `POST /orders`.
const _accessToken = String.fromEnvironment('E2E_ACCESS_TOKEN');

/// Alei Gefen seed: tabbouleh ₪34.00, fries ₪28.00, minimum ₪45.00.
const _belowMinimum = 'Add ₪11.00 more to reach the ₪45.00 minimum';

void main() {
  patrolTest(
    'a short cart stays disabled, then the placed order reaches Delivered',
    ($) async {
      expect(_accessToken, isNotEmpty);
      await launchFoodDelivery(
        $,
        accessToken: _accessToken,
        customerId: _customerId(_accessToken),
      );

      await $('Alei Gefen')
          .waitUntilVisible(timeout: const Duration(seconds: 30));
      await $('Alei Gefen').tap();
      await $('Quinoa tabbouleh')
          .waitUntilVisible(timeout: const Duration(seconds: 30));

      await _addItem($, 'Quinoa tabbouleh');
      await $(#cart_badge).tap();

      await $(#cart_minimum_banner).waitUntilVisible();
      expect(find.text(_belowMinimum), findsOneWidget);
      await $(#cart_place_order).scrollTo();
      expect(
        $.tester
            .widget<FilledButton>(find.byKey(const Key('cart_place_order')))
            .onPressed,
        isNull,
      );

      await $.tester.pageBack();
      await $.pumpAndSettle();
      await _addItem($, 'Sweet potato fries');
      await $(#cart_badge).tap();

      await $(#cart_place_order).scrollTo();
      expect(find.byKey(const Key('cart_minimum_banner')), findsNothing);
      expect(
        $.tester
            .widget<FilledButton>(find.byKey(const Key('cart_place_order')))
            .onPressed,
        isNotNull,
      );

      await $(#cart_place_order).tap(settlePolicy: SettlePolicy.noSettle);
      await $(#order_step_current_placed)
          .waitUntilVisible(timeout: const Duration(seconds: 30));
      final orderId = $.tester
          .widget<Text>(find.byKey(const Key('order_id')))
          .data;
      if (orderId == null || orderId.isEmpty) {
        fail('placed order had no id');
      }

      await _advance(orderId, 'ACCEPTED', 'restaurant');
      await _advance(orderId, 'PREPARING', 'restaurant');
      await _advance(orderId, 'PICKED_UP', 'courier');
      await _advance(orderId, 'DELIVERED', 'courier');

      await $(#order_step_current_delivered)
          .waitUntilVisible(timeout: const Duration(seconds: 20));
      expect(find.text('Placed'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Picked up'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
    },
  );
}

Future<void> _addItem(PatrolIntegrationTester $, String name) async {
  await $(name).scrollTo();
  await $.tester.tap(
    find.descendant(of: _menuTile(name), matching: find.byIcon(Icons.add)),
  );
  await $.pumpAndSettle();
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

String _customerId(String jwt) {
  final payload = jwt.split('.');
  if (payload.length < 2) {
    throw StateError('E2E_ACCESS_TOKEN is not a JWT');
  }
  final decoded = jsonDecode(
    utf8.decode(base64Url.decode(base64Url.normalize(payload[1]))),
  );
  if (decoded is! Map) {
    throw StateError('E2E_ACCESS_TOKEN payload is not an object');
  }
  final sub = decoded['sub'];
  if (sub is! String || sub.isEmpty) {
    throw StateError('E2E_ACCESS_TOKEN has no customer sub');
  }
  return sub;
}

Future<void> _advance(String orderId, String status, String actor) async {
  final client = HttpClient();
  try {
    final request = await client.patchUrl(
      Uri.parse('$e2eApiBaseUrl/orders/$orderId/status'),
    );
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'status': status, 'actor': actor}));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      fail('PATCH $status by $actor returned ${response.statusCode}: $body');
    }
  } finally {
    client.close(force: true);
  }
}
