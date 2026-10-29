import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/catalog/catalog.dart';
import '../domain/money.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

/// `POST /orders` rejects a line quantity outside 1..50.
const maxCartLineQuantity = 50;

@freezed
abstract class CartLine with _$CartLine {
  const factory CartLine({required MenuItem item, required int quantity}) =
      _CartLine;
}

@freezed
abstract class CartState with _$CartState {
  const CartState._();

  const factory CartState({
    Restaurant? restaurant,
    @Default(<CartLine>[]) List<CartLine> lines,
  }) = _CartState;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  int get subtotalAgorot => lines.fold(
    0,
    (sum, line) =>
        sum +
        Money.lineTotal(
          unitPriceAgorot: line.item.priceAgorot,
          quantity: line.quantity,
        ),
  );

  int get deliveryFeeAgorot {
    if (lines.isEmpty) return 0;
    return restaurant?.deliveryFeeAgorot ?? 0;
  }

  int get totalAgorot => Money.orderTotal(
    subtotalAgorot: subtotalAgorot,
    deliveryFeeAgorot: deliveryFeeAgorot,
  );

  bool get meetsMinimum {
    final current = restaurant;
    if (current == null || lines.isEmpty) return false;
    return subtotalAgorot >= current.minOrderAgorot;
  }

  int get missingForMinimumAgorot {
    final current = restaurant;
    if (current == null || lines.isEmpty) return 0;
    final gap = current.minOrderAgorot - subtotalAgorot;
    return gap > 0 ? gap : 0;
  }
}

sealed class AddToCartResult {
  const AddToCartResult();
}

final class AddToCartAdded extends AddToCartResult {
  const AddToCartAdded();
}

final class AddToCartUnavailable extends AddToCartResult {
  const AddToCartUnavailable();
}

final class AddToCartConflict extends AddToCartResult {
  const AddToCartConflict(this.currentRestaurant);

  final Restaurant currentRestaurant;
}

/// The cart belongs to one restaurant. An empty cart belongs to none, so
/// the next [add] is not a conflict.
@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  @override
  CartState build() => const CartState();

  AddToCartResult add(MenuItem item, Restaurant restaurant) {
    if (!_acceptable(item, restaurant)) {
      return const AddToCartUnavailable();
    }
    final current = state.restaurant;
    if (current != null && current.id != restaurant.id) {
      return AddToCartConflict(current);
    }
    state = _withLine(state.restaurant ?? restaurant, item, 1);
    return const AddToCartAdded();
  }

  /// Confirmed "Start a new cart?": drop the other restaurant's lines.
  AddToCartResult replaceWith(MenuItem item, Restaurant restaurant) {
    if (!_acceptable(item, restaurant)) {
      return const AddToCartUnavailable();
    }
    state = CartState(
      restaurant: restaurant,
      lines: [CartLine(item: item, quantity: 1)],
    );
    return const AddToCartAdded();
  }

  void increment(String menuItemId) {
    final current = state.restaurant;
    if (current == null) return;
    final line = _line(menuItemId);
    if (line == null || line.quantity >= maxCartLineQuantity) return;
    state = _withLine(current, line.item, 1);
  }

  void decrement(String menuItemId) {
    final current = state.restaurant;
    if (current == null) return;
    final lines = <CartLine>[];
    for (final line in state.lines) {
      if (line.item.id != menuItemId) {
        lines.add(line);
      } else if (line.quantity > 1) {
        lines.add(line.copyWith(quantity: line.quantity - 1));
      }
    }
    state = _commit(current, lines);
  }

  void remove(String menuItemId) {
    final current = state.restaurant;
    if (current == null) return;
    state = _commit(current, [
      for (final line in state.lines)
        if (line.item.id != menuItemId) line,
    ]);
  }

  void clear() {
    state = const CartState();
  }

  CartLine? _line(String menuItemId) {
    for (final line in state.lines) {
      if (line.item.id == menuItemId) return line;
    }
    return null;
  }

  CartState _withLine(Restaurant restaurant, MenuItem item, int delta) {
    final lines = <CartLine>[];
    var found = false;
    for (final line in state.lines) {
      if (line.item.id != item.id) {
        lines.add(line);
        continue;
      }
      found = true;
      final next = line.quantity + delta;
      lines.add(
        line.copyWith(
          quantity: next > maxCartLineQuantity ? maxCartLineQuantity : next,
        ),
      );
    }
    if (!found) {
      final initial = delta < 1
          ? 1
          : (delta > maxCartLineQuantity ? maxCartLineQuantity : delta);
      lines.add(CartLine(item: item, quantity: initial));
    }
    return _commit(restaurant, lines);
  }

  CartState _commit(Restaurant restaurant, List<CartLine> lines) {
    if (lines.isEmpty) return const CartState();
    return CartState(restaurant: restaurant, lines: lines);
  }

  bool _acceptable(MenuItem item, Restaurant restaurant) {
    return item.isAvailable && item.restaurantId == restaurant.id;
  }
}
