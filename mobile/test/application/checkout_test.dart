import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/cart.dart';
import 'package:food_delivery/application/checkout.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/failures/api_error.dart';

import '../support/fake_orders_repository.dart';
import '../support/fixtures.dart';

final class QueuedIdempotencyKeys implements IdempotencyKeys {
  QueuedIdempotencyKeys(this._keys);

  final List<String> _keys;
  var _index = 0;

  @override
  String next() {
    final key = _keys[_index];
    _index += 1;
    return key;
  }
}

void main() {
  test('a network failure retries with the same idempotency key', () async {
    final orders = FakeOrdersRepository(
      placeResults: [
        const ApiFailure(
          ApiError(code: ApiErrorCode.network, message: 'Network unavailable'),
        ),
        ApiOk(sampleOrder(id: 'order-9')),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(orders),
        idempotencyKeysProvider.overrideWithValue(
          QueuedIdempotencyKeys(['key-1', 'key-2']),
        ),
      ],
    );
    addTearDown(container.dispose);

    final restaurant = sampleRestaurant(id: 'r1', minOrderAgorot: 1000);
    container
        .read(cartProvider.notifier)
        .add(sampleItem(id: 'i1', priceAgorot: 4200), restaurant);

    final checkout = container.read(checkoutProvider.notifier);
    await checkout.place();

    expect(container.read(checkoutProvider), isA<CheckoutFailed>());
    expect(
      (container.read(checkoutProvider) as CheckoutFailed).error.code,
      ApiErrorCode.network,
    );
    expect(orders.idempotencyKeys, ['key-1']);
    expect(orders.restaurantIds, ['r1']);
    expect(orders.placedLines.single.single.menuItemId, 'i1');
    expect(orders.placedLines.single.single.quantity, 1);
    expect(container.read(cartProvider).lines, isNotEmpty);

    await checkout.place();

    expect(orders.idempotencyKeys, ['key-1', 'key-1']);
    final placed = container.read(checkoutProvider);
    expect(placed, isA<CheckoutPlaced>());
    expect((placed as CheckoutPlaced).orderId, 'order-9');
    expect(container.read(cartProvider).lines, isEmpty);
    expect(container.read(cartProvider).restaurant, isNull);
  });
}
