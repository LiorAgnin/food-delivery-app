import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/cart.dart';

import '../support/fixtures.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  Cart notifier() => container.read(cartProvider.notifier);
  CartState state() => container.read(cartProvider);

  test('add starts a cart and stacks quantity for the same item', () {
    final restaurant = sampleRestaurant();
    final item = sampleItem();
    final other = sampleItem(id: 'i2', name: 'Fries', priceAgorot: 1200);

    expect(notifier().add(item, restaurant), isA<AddToCartAdded>());
    expect(notifier().add(item, restaurant), isA<AddToCartAdded>());
    expect(notifier().add(other, restaurant), isA<AddToCartAdded>());

    final cart = state();
    expect(cart.restaurant?.id, restaurant.id);
    expect(cart.lines, hasLength(2));
    expect(cart.lines.first.quantity, 2);
    expect(cart.lines.last.quantity, 1);
    expect(cart.itemCount, 3);
    expect(cart.subtotalAgorot, 4200 * 2 + 1200);
    expect(cart.deliveryFeeAgorot, 1500);
    expect(cart.totalAgorot, cart.subtotalAgorot + 1500);
    expect(cart.meetsMinimum, isTrue);
    expect(cart.missingForMinimumAgorot, 0);
  });

  test('a different restaurant conflicts and does not mutate the cart', () {
    final first = sampleRestaurant();
    final second = sampleRestaurant(id: 'r2', name: 'Pizza Dan');
    final item = sampleItem();
    final foreign = sampleItem(id: 'p1', restaurantId: 'r2', name: 'Slice');

    notifier().add(item, first);
    final before = state();
    final result = notifier().add(foreign, second);

    expect(result, isA<AddToCartConflict>());
    expect((result as AddToCartConflict).currentRestaurant.id, first.id);
    expect((result).currentRestaurant.name, first.name);
    expect(state(), before);
  });

  test('the same restaurant id is not a conflict', () {
    final first = sampleRestaurant(deliveryFeeAgorot: 1500);
    final refreshed = first.copyWith(deliveryFeeAgorot: 900, name: 'Renamed');
    notifier().add(sampleItem(), first);

    final result = notifier().add(
      sampleItem(id: 'i2', priceAgorot: 1000),
      refreshed,
    );

    expect(result, isA<AddToCartAdded>());
    expect(state().restaurant?.deliveryFeeAgorot, 1500);
    expect(state().lines, hasLength(2));
  });

  test('unavailable items and mismatched restaurants are rejected', () {
    final restaurant = sampleRestaurant();
    notifier().add(sampleItem(), restaurant);
    final before = state();

    expect(
      notifier().add(
        sampleItem(id: 'sold-out', isAvailable: false),
        restaurant,
      ),
      isA<AddToCartUnavailable>(),
    );
    expect(
      notifier().add(
        sampleItem(id: 'elsewhere', restaurantId: 'r9'),
        restaurant,
      ),
      isA<AddToCartUnavailable>(),
    );
    expect(state(), before);
  });

  test('an unavailable item does not start a cart', () {
    expect(
      notifier().add(sampleItem(isAvailable: false), sampleRestaurant()),
      isA<AddToCartUnavailable>(),
    );
    expect(state().lines, isEmpty);
    expect(state().restaurant, isNull);
  });

  test('a closed restaurant can still be added; the menu disables that', () {
    final closed = sampleRestaurant(isOpen: false);
    expect(notifier().add(sampleItem(), closed), isA<AddToCartAdded>());
    expect(state().restaurant?.isOpen, isFalse);
  });

  test('replaceWith swaps restaurants and refuses an unavailable item', () {
    final first = sampleRestaurant();
    final second = sampleRestaurant(id: 'r2', name: 'Pizza Dan');
    notifier().add(sampleItem(), first);
    final before = state();

    expect(
      notifier().replaceWith(
        sampleItem(id: 'sold-out', restaurantId: 'r2', isAvailable: false),
        second,
      ),
      isA<AddToCartUnavailable>(),
    );
    expect(state(), before);

    final slice = sampleItem(
      id: 'slice',
      restaurantId: 'r2',
      name: 'Slice',
      priceAgorot: 2000,
    );
    expect(notifier().replaceWith(slice, second), isA<AddToCartAdded>());
    expect(state().restaurant?.id, 'r2');
    expect(state().lines.single.item.id, 'slice');
    expect(state().lines.single.quantity, 1);
  });

  test(
    'increment, decrement, and remove keep the one-restaurant invariant',
    () {
      final restaurant = sampleRestaurant(minOrderAgorot: 5000);
      final pita = sampleItem(priceAgorot: 2000);
      final fries = sampleItem(id: 'fries', name: 'Fries', priceAgorot: 1000);
      notifier().add(pita, restaurant);
      notifier().add(fries, restaurant);

      notifier().increment(pita.id);
      expect(state().lines.first.quantity, 2);
      notifier().increment('missing');
      expect(state().itemCount, 3);

      notifier().decrement(pita.id);
      expect(state().lines.first.quantity, 1);
      expect(state().restaurant?.id, restaurant.id);

      notifier().remove(fries.id);
      expect(state().lines, hasLength(1));
      expect(state().deliveryFeeAgorot, 1500);

      notifier().decrement(pita.id);
      expect(state().lines, isEmpty);
      expect(state().restaurant, isNull);
      expect(state().itemCount, 0);
      expect(state().subtotalAgorot, 0);
      expect(state().deliveryFeeAgorot, 0);
      expect(state().totalAgorot, 0);
      expect(state().meetsMinimum, isFalse);
      expect(state().missingForMinimumAgorot, 0);

      notifier().decrement(pita.id);
      notifier().remove(pita.id);
      notifier().increment(pita.id);
      expect(state().lines, isEmpty);
    },
  );

  test('clear drops the restaurant', () {
    notifier().add(sampleItem(), sampleRestaurant());
    notifier().clear();
    expect(state().lines, isEmpty);
    expect(state().restaurant, isNull);
  });

  test('quantity stops at 50', () {
    final item = sampleItem();
    notifier().add(item, sampleRestaurant());
    for (var i = 0; i < 60; i++) {
      notifier().increment(item.id);
    }
    expect(state().lines.single.quantity, maxCartLineQuantity);
    expect(notifier().add(item, sampleRestaurant()), isA<AddToCartAdded>());
    expect(state().lines.single.quantity, maxCartLineQuantity);
  });

  test('minimum uses the subtotal and ignores the delivery fee', () {
    final restaurant = sampleRestaurant(
      minOrderAgorot: 5000,
      deliveryFeeAgorot: 2000,
    );
    final item = sampleItem(priceAgorot: 2000);
    notifier().add(item, restaurant);
    notifier().increment(item.id);

    expect(state().subtotalAgorot, 4000);
    expect(state().meetsMinimum, isFalse);
    expect(state().missingForMinimumAgorot, 1000);
    expect(state().totalAgorot, 6000);

    notifier().increment(item.id);
    expect(state().subtotalAgorot, 6000);
    expect(state().meetsMinimum, isTrue);
    expect(state().missingForMinimumAgorot, 0);
  });
}
