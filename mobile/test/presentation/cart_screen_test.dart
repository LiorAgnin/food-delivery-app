import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/cart.dart';
import 'package:food_delivery/presentation/cart/cart_screen.dart';
import 'package:go_router/go_router.dart';

import '../support/fixtures.dart';

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
}

String _text(WidgetTester tester, String key) {
  return tester.widget<Text>(find.byKey(Key(key))).data!;
}

Future<ProviderContainer> _pumpCart(WidgetTester tester) async {
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

  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  return container;
}
