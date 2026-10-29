import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/cart.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/presentation/restaurants/menu_screen.dart';

import '../support/fake_catalog_repository.dart';
import '../support/fixtures.dart';

void main() {
  Future<ProviderContainer> pumpMenu(
    WidgetTester tester,
    FakeCatalogRepository catalog, {
    String restaurantId = 'r1',
  }) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [catalogRepositoryProvider.overrideWithValue(catalog)],
        child: MaterialApp(home: MenuScreen(restaurantId: restaurantId)),
      ),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(MenuScreen)),
    );
    return container;
  }

  testWidgets('an out-of-stock item has no add button', (tester) async {
    final soldOut = sampleItem(id: 'sold-out', isAvailable: false);
    final catalog = FakeCatalogRepository(
      menu: ApiOk(sampleMenu(items: [soldOut])),
    );

    await pumpMenu(tester, catalog);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('menu_out_of_stock_sold-out')), findsOneWidget);
    expect(find.text('Out of stock'), findsOneWidget);
    expect(find.byKey(const Key('menu_add_sold-out')), findsNothing);
    expect(find.text('₪42.00'), findsOneWidget);
    expect(find.text('Spicy'), findsOneWidget);
  });

  testWidgets('a closed restaurant shows a banner and disables adding', (
    tester,
  ) async {
    final restaurant = sampleRestaurant(isOpen: false);
    final catalog = FakeCatalogRepository(
      menu: ApiOk(sampleMenu(restaurant: restaurant, items: [sampleItem()])),
    );

    await pumpMenu(tester, catalog);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('menu_closed_banner')), findsOneWidget);
    final button = tester.widget<IconButton>(
      find.byKey(const Key('menu_add_i1')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('adding from another restaurant asks to start a new cart', (
    tester,
  ) async {
    final here = sampleRestaurant();
    final item = sampleItem();
    final catalog = FakeCatalogRepository(
      menu: ApiOk(sampleMenu(restaurant: here, items: [item])),
    );

    final container = await pumpMenu(tester, catalog);
    await tester.pumpAndSettle();

    final elsewhere = sampleRestaurant(id: 'r2', name: 'Pizza Dan');
    final seeded = container
        .read(cartProvider.notifier)
        .add(
          sampleItem(id: 'slice', restaurantId: 'r2', name: 'Slice'),
          elsewhere,
        );
    expect(seeded, isA<AddToCartAdded>());
    await tester.pump();

    await tester.tap(find.byKey(const Key('menu_add_i1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cart_conflict_dialog')), findsOneWidget);
    expect(find.text('Start a new cart?'), findsOneWidget);
    expect(container.read(cartProvider).restaurant?.id, 'r2');

    await tester.tap(find.byKey(const Key('cart_conflict_confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cart_conflict_dialog')), findsNothing);
    expect(container.read(cartProvider).restaurant?.id, 'r1');
    expect(container.read(cartProvider).lines.single.item.id, 'i1');
    expect(find.byKey(const Key('menu_stepper_i1')), findsOneWidget);
    expect(find.text('1'), findsWidgets);
  });
}
