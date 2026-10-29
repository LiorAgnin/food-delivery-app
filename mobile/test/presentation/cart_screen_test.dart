import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/cart.dart';
import 'package:food_delivery/application/checkout.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/failures/api_error.dart';
import 'package:food_delivery/presentation/cart/cart_screen.dart';
import 'package:go_router/go_router.dart';

import '../support/fake_orders_repository.dart';
import '../support/fixtures.dart';
import '../support/queued_idempotency_keys.dart';

void main() {
  testWidgets('the minimum banner disables Place order', (tester) async {
    final container = await _pumpCart(tester);
    final restaurant = sampleRestaurant(
      name: 'Shawarma Gil',
      minOrderAgorot: 6000,
      deliveryFeeAgorot: 1500,
    );
    container
        .read(cartProvider.notifier)
        .add(
          sampleItem(id: 'i1', name: 'Pita shawarma', priceAgorot: 4800),
          restaurant,
        );
    await tester.pump();

    expect(find.text('Shawarma Gil'), findsOneWidget);
    expect(find.text('Pita shawarma'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(_text(tester, 'cart_subtotal'), '₪48.00');
    expect(_text(tester, 'cart_delivery_fee'), '₪15.00');
    expect(_text(tester, 'cart_total'), '₪63.00');
    expect(
      find.text('Add ₪12.00 more to reach the ₪60.00 minimum'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('cart_place_order')))
          .onPressed,
      isNull,
    );

    container
        .read(cartProvider.notifier)
        .add(
          sampleItem(id: 'i1', name: 'Pita shawarma', priceAgorot: 4800),
          restaurant,
        );
    await tester.pump();

    expect(find.byKey(const Key('cart_minimum_banner')), findsNothing);
    expect(_text(tester, 'cart_subtotal'), '₪96.00');
    expect(_text(tester, 'cart_total'), '₪111.00');
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('cart_place_order')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('an empty cart offers to browse restaurants', (tester) async {
    await _pumpCart(tester);

    expect(find.byKey(const Key('cart_empty')), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byKey(const Key('cart_place_order')), findsNothing);

    await tester.tap(find.byKey(const Key('cart_browse_restaurants')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('restaurants_page')), findsOneWidget);
  });

  testWidgets('placing an order shows a spinner and opens the order', (
    tester,
  ) async {
    final orders = FakeOrdersRepository(
      placeResults: [ApiOk(sampleOrder(id: 'order-7'))],
    );
    final gate = Completer<void>();
    orders.blockPlace = gate;
    final container = await _pumpCart(tester, orders: orders);
    container
        .read(cartProvider.notifier)
        .add(
          sampleItem(priceAgorot: 7000),
          sampleRestaurant(minOrderAgorot: 6000),
        );
    await tester.pump();

    await tester.tap(find.byKey(const Key('cart_place_order')));
    await tester.pump();

    expect(find.byKey(const Key('cart_place_order_spinner')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('cart_place_order')))
          .onPressed,
      isNull,
    );

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.text('order-7'), findsOneWidget);
    expect(container.read(cartProvider).lines, isEmpty);
  });

  testWidgets('a network failure offers a retry with the same key', (
    tester,
  ) async {
    final orders = FakeOrdersRepository(
      placeResults: [
        const ApiFailure(ApiError(code: ApiErrorCode.network, message: 'down')),
        ApiOk(sampleOrder(id: 'order-9')),
      ],
    );
    final container = await _pumpCart(tester, orders: orders);
    container
        .read(cartProvider.notifier)
        .add(
          sampleItem(priceAgorot: 7000),
          sampleRestaurant(minOrderAgorot: 6000),
        );
    await tester.pump();

    await tester.tap(find.byKey(const Key('cart_place_order')));
    await tester.pumpAndSettle();

    expect(find.text('Network unavailable. Try again.'), findsOneWidget);
    expect(orders.idempotencyKeys, ['key-1']);

    await tester.tap(find.byKey(const Key('cart_checkout_retry')));
    await tester.pumpAndSettle();

    expect(orders.idempotencyKeys, ['key-1', 'key-1']);
    expect(find.text('order-9'), findsOneWidget);
    expect(container.read(cartProvider).lines, isEmpty);
  });

  testWidgets('unavailable lines are marked and can be removed', (
    tester,
  ) async {
    final orders = FakeOrdersRepository(
      placeResults: [
        const ApiFailure(
          ApiError(
            code: ApiErrorCode.itemUnavailable,
            message: 'nope',
            details: {
              'menuItemIds': ['i1'],
            },
          ),
        ),
      ],
    );
    final container = await _pumpCart(tester, orders: orders);
    final restaurant = sampleRestaurant(minOrderAgorot: 1000);
    container
        .read(cartProvider.notifier)
        .add(sampleItem(id: 'i1', name: 'Pita shawarma'), restaurant);
    container
        .read(cartProvider.notifier)
        .add(
          sampleItem(id: 'i2', name: 'Fries', priceAgorot: 1200),
          restaurant,
        );
    await tester.pump();

    await tester.tap(find.byKey(const Key('cart_place_order')));
    await tester.pumpAndSettle();

    expect(find.text('Some items are no longer available.'), findsOneWidget);
    expect(find.byKey(const Key('cart_line_unavailable_i1')), findsOneWidget);
    expect(find.byKey(const Key('cart_line_unavailable_i2')), findsNothing);

    await tester.tap(find.byKey(const Key('cart_remove_unavailable')));
    await tester.pump();

    expect(container.read(cartProvider).lines.single.item.id, 'i2');
    expect(find.text('Pita shawarma'), findsNothing);
  });

  testWidgets('a closed restaurant explains why and does not offer retry', (
    tester,
  ) async {
    final orders = FakeOrdersRepository(
      placeResults: [
        const ApiFailure(
          ApiError(code: ApiErrorCode.restaurantClosed, message: 'closed'),
        ),
      ],
    );
    final container = await _pumpCart(tester, orders: orders);
    container
        .read(cartProvider.notifier)
        .add(
          sampleItem(priceAgorot: 7000),
          sampleRestaurant(minOrderAgorot: 6000),
        );
    await tester.pump();

    await tester.tap(find.byKey(const Key('cart_place_order')));
    await tester.pumpAndSettle();

    expect(find.text('This restaurant is closed right now.'), findsOneWidget);
    expect(find.byKey(const Key('cart_checkout_retry')), findsNothing);
    expect(container.read(cartProvider).lines, isNotEmpty);
  });
}

String _text(WidgetTester tester, String key) {
  return tester.widget<Text>(find.byKey(Key(key))).data!;
}

Future<ProviderContainer> _pumpCart(
  WidgetTester tester, {
  FakeOrdersRepository? orders,
}) async {
  final router = GoRouter(
    initialLocation: '/cart',
    routes: [
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(
        path: '/restaurants',
        builder: (_, _) => const Scaffold(
          body: Text('Restaurants', key: Key('restaurants_page')),
        ),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, state) => Scaffold(
          body: Text(state.pathParameters['id']!, key: const Key('order_page')),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  final container = ProviderContainer(
    overrides: [
      if (orders != null) ordersRepositoryProvider.overrideWithValue(orders),
      idempotencyKeysProvider.overrideWithValue(
        QueuedIdempotencyKeys(['key-1', 'key-2']),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  return container;
}
