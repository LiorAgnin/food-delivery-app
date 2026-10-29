import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/auth_session.dart';
import 'package:food_delivery/application/cart.dart';
import 'package:food_delivery/application/checkout.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/auth/auth.dart';
import 'package:food_delivery/domain/failures/api_error.dart';

import '../support/fake_orders_repository.dart';
import '../support/fixtures.dart';
import '../support/memory_session_store.dart';

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

  test('changing the cart issues a new idempotency key', () async {
    final orders = FakeOrdersRepository(
      placeResults: [
        const ApiFailure(
          ApiError(code: ApiErrorCode.network, message: 'Network unavailable'),
        ),
        ApiOk(sampleOrder(id: 'order-2')),
      ],
    );
    final container = _container(orders, ['key-1', 'key-2']);
    addTearDown(container.dispose);

    container
        .read(cartProvider.notifier)
        .add(
          sampleItem(id: 'i1', priceAgorot: 4200),
          sampleRestaurant(minOrderAgorot: 1000),
        );

    final checkout = container.read(checkoutProvider.notifier);
    await checkout.place();
    container.read(cartProvider.notifier).increment('i1');
    await checkout.place();

    expect(orders.idempotencyKeys, ['key-1', 'key-2']);
    expect(orders.placedLines[1].single.quantity, 2);
  });

  test('a second tap while submitting does not send another order', () async {
    final orders = FakeOrdersRepository(
      placeResults: [ApiOk(sampleOrder(id: 'order-3'))],
    );
    final gate = Completer<void>();
    orders.blockPlace = gate;
    final container = _container(orders, ['key-1', 'key-2']);
    addTearDown(container.dispose);
    _seed(container);

    final checkout = container.read(checkoutProvider.notifier);
    final first = checkout.place();
    final second = checkout.place();
    expect(orders.idempotencyKeys, ['key-1']);
    expect(container.read(checkoutProvider), isA<CheckoutSubmitting>());

    gate.complete();
    await first;
    await second;
    expect(container.read(checkoutProvider), isA<CheckoutPlaced>());
    expect(orders.idempotencyKeys, ['key-1']);
  });

  test('a closed restaurant keeps the cart and explains why', () async {
    final failed = await _fail(
      const ApiError(
        code: ApiErrorCode.restaurantClosed,
        message: 'Restaurant is closed',
      ),
    );
    expect(failed.message, 'This restaurant is closed right now.');
    expect(failed.canRetry, isFalse);
    expect(failed.unavailableMenuItemIds, isEmpty);
  });

  test('unavailable items are named so the cart can mark them', () async {
    final failed = await _fail(
      const ApiError(
        code: ApiErrorCode.itemUnavailable,
        message: 'Item unavailable',
        details: {
          'menuItemIds': ['i1', 'i9'],
        },
      ),
    );
    expect(failed.message, 'Some items are no longer available.');
    expect(failed.unavailableMenuItemIds, ['i1', 'i9']);
    expect(failed.canRetry, isFalse);
  });

  test('an item from another restaurant is named the same way', () async {
    final failed = await _fail(
      const ApiError(
        code: ApiErrorCode.itemNotInRestaurant,
        message: 'Wrong restaurant',
        details: {
          'menuItemIds': ['i1', 3, null],
        },
      ),
    );
    expect(failed.message, 'Some items are not on this menu.');
    expect(failed.unavailableMenuItemIds, ['i1']);
  });

  test('below minimum keeps the cart and says so', () async {
    final failed = await _fail(
      const ApiError(
        code: ApiErrorCode.belowMinimum,
        message: 'Below minimum',
        details: {'minOrderAgorot': 6000, 'subtotalAgorot': 4800},
      ),
    );
    expect(failed.message, 'This order is below the minimum.');
    expect(failed.canRetry, isFalse);
  });

  test('a timeout retry reuses the key and says to try again', () async {
    final orders = FakeOrdersRepository(
      placeResults: [
        const ApiFailure(
          ApiError(code: ApiErrorCode.timeout, message: 'timed out'),
        ),
        ApiOk(sampleOrder(id: 'order-4')),
      ],
    );
    final container = _container(orders, ['key-1', 'key-2']);
    addTearDown(container.dispose);
    _seed(container);

    final checkout = container.read(checkoutProvider.notifier);
    await checkout.place();
    final failed = container.read(checkoutProvider) as CheckoutFailed;
    expect(failed.message, 'The request timed out. Try again.');
    expect(failed.canRetry, isTrue);

    await checkout.place();
    expect(orders.idempotencyKeys, ['key-1', 'key-1']);
  });

  test('a network failure tells the customer to try again', () async {
    final failed = await _fail(
      const ApiError(code: ApiErrorCode.network, message: 'down'),
    );
    expect(failed.message, 'Network unavailable. Try again.');
    expect(failed.canRetry, isTrue);
  });

  test('unauthorized signs the customer out', () async {
    final orders = FakeOrdersRepository(
      placeResults: [
        const ApiFailure(
          ApiError(code: ApiErrorCode.unauthorized, message: 'nope'),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(orders),
        idempotencyKeysProvider.overrideWithValue(
          QueuedIdempotencyKeys(['key-1']),
        ),
        sessionStoreProvider.overrideWithValue(
          MemorySessionStore(
            const SignedIn(
              accessToken: 'token',
              customer: Customer(id: 'c1', phone: '+972501234567'),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(authSessionProvider), isA<SignedIn>());
    _seed(container);

    await container.read(checkoutProvider.notifier).place();

    expect(container.read(authSessionProvider), isA<SignedOut>());
    final failed = container.read(checkoutProvider) as CheckoutFailed;
    expect(failed.message, 'Sign in again.');
    expect(failed.canRetry, isFalse);
    expect(container.read(cartProvider).lines, isNotEmpty);
  });
}

Future<CheckoutFailed> _fail(ApiError error) async {
  final orders = FakeOrdersRepository(placeResults: [ApiFailure(error)]);
  final container = _container(orders, ['key-1']);
  addTearDown(container.dispose);
  _seed(container);
  await container.read(checkoutProvider.notifier).place();
  final state = container.read(checkoutProvider);
  expect(state, isA<CheckoutFailed>());
  expect(container.read(cartProvider).lines, isNotEmpty);
  return state as CheckoutFailed;
}

void _seed(ProviderContainer container) {
  container
      .read(cartProvider.notifier)
      .add(
        sampleItem(id: 'i1', priceAgorot: 4200),
        sampleRestaurant(minOrderAgorot: 1000),
      );
}

ProviderContainer _container(FakeOrdersRepository orders, List<String> keys) {
  return ProviderContainer(
    overrides: [
      ordersRepositoryProvider.overrideWithValue(orders),
      idempotencyKeysProvider.overrideWithValue(QueuedIdempotencyKeys(keys)),
    ],
  );
}
