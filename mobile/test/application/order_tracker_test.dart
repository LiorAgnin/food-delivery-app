import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/order_tracker.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/failures/api_error.dart';
import 'package:food_delivery/domain/orders/order.dart';

import '../support/fake_orders_repository.dart';
import '../support/fixtures.dart';

void main() {
  test('polls getOrder on each injected interval', () {
    fakeAsync((async) {
      final orders = FakeOrdersRepository(
        getResults: [ApiOk(sampleOrder(status: OrderStatus.placed))],
      );
      final container = _container(orders, const Duration(seconds: 5));
      container.listen(orderTrackerProvider('order-1'), (_, _) {});

      async.flushMicrotasks();

      expect(orders.getCalls, 1);
      final ready = container.read(orderTrackerProvider('order-1'));
      expect(ready, isA<OrderTrackerReady>());
      expect((ready as OrderTrackerReady).order.id, 'order-1');
      expect(ready.order.status, OrderStatus.placed);
      expect(ready.reconnecting, isFalse);

      async.elapse(const Duration(seconds: 4));
      async.flushMicrotasks();
      expect(orders.getCalls, 1);

      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(orders.getCalls, 2);

      container.dispose();
    });
  });

  test('polling stops once the order is delivered', () {
    fakeAsync((async) {
      final orders = FakeOrdersRepository(
        getResults: [
          ApiOk(sampleOrder(status: OrderStatus.placed)),
          ApiOk(sampleOrder(status: OrderStatus.delivered)),
        ],
      );
      final container = _container(orders, const Duration(seconds: 3));
      container.listen(orderTrackerProvider('order-1'), (_, _) {});

      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 3));
      async.flushMicrotasks();

      final ready =
          container.read(orderTrackerProvider('order-1')) as OrderTrackerReady;
      expect(ready.order.status, OrderStatus.delivered);
      expect(ready.reconnecting, isFalse);
      expect(orders.getCalls, 2);

      async.elapse(const Duration(seconds: 9));
      async.flushMicrotasks();
      expect(orders.getCalls, 2);

      container.dispose();
    });
  });

  test('polling stops once the order is cancelled', () {
    fakeAsync((async) {
      final orders = FakeOrdersRepository(
        getResults: [
          ApiOk(sampleOrder(status: OrderStatus.accepted)),
          ApiOk(sampleOrder(status: OrderStatus.cancelled)),
        ],
      );
      final container = _container(orders, const Duration(seconds: 3));
      container.listen(orderTrackerProvider('order-1'), (_, _) {});

      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 3));
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 6));
      async.flushMicrotasks();

      expect(orders.getCalls, 2);
      final ready =
          container.read(orderTrackerProvider('order-1')) as OrderTrackerReady;
      expect(ready.order.status, OrderStatus.cancelled);

      container.dispose();
    });
  });

  test('dispose cancels the poll timer', () {
    fakeAsync((async) {
      final orders = FakeOrdersRepository(getResults: [ApiOk(sampleOrder())]);
      final container = _container(orders, const Duration(seconds: 3));
      final sub = container.listen(orderTrackerProvider('order-1'), (_, _) {});

      async.flushMicrotasks();
      expect(orders.getCalls, 1);

      sub.close();
      async.elapse(const Duration(seconds: 9));
      async.flushMicrotasks();
      expect(orders.getCalls, 1);

      container.dispose();
    });
  });

  test('a later poll failure keeps the last order and reconnects', () {
    fakeAsync((async) {
      final orders = FakeOrdersRepository(
        getResults: [
          ApiOk(sampleOrder(status: OrderStatus.accepted)),
          const ApiFailure(
            ApiError(code: ApiErrorCode.network, message: 'down'),
          ),
          ApiOk(sampleOrder(status: OrderStatus.preparing)),
        ],
      );
      final container = _container(orders, const Duration(seconds: 3));
      container.listen(orderTrackerProvider('order-1'), (_, _) {});

      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 3));
      async.flushMicrotasks();

      final during =
          container.read(orderTrackerProvider('order-1')) as OrderTrackerReady;
      expect(during.order.status, OrderStatus.accepted);
      expect(during.reconnecting, isTrue);
      expect(during, isNot(isA<OrderTrackerFailed>()));

      async.elapse(const Duration(seconds: 3));
      async.flushMicrotasks();
      final after =
          container.read(orderTrackerProvider('order-1')) as OrderTrackerReady;
      expect(after.order.status, OrderStatus.preparing);
      expect(after.reconnecting, isFalse);

      container.dispose();
    });
  });

  test('the first failure is a full error when nothing has loaded', () {
    fakeAsync((async) {
      final orders = FakeOrdersRepository(
        getResults: [
          const ApiFailure(
            ApiError(code: ApiErrorCode.notFound, message: 'Missing'),
          ),
        ],
      );
      final container = _container(orders, const Duration(seconds: 3));
      container.listen(orderTrackerProvider('order-1'), (_, _) {});
      async.flushMicrotasks();

      final failed =
          container.read(orderTrackerProvider('order-1')) as OrderTrackerFailed;
      expect(failed.error.code, ApiErrorCode.notFound);
      expect(failed.error.message, 'Missing');

      container.dispose();
    });
  });
}

ProviderContainer _container(FakeOrdersRepository orders, Duration interval) {
  return ProviderContainer(
    overrides: [
      ordersRepositoryProvider.overrideWithValue(orders),
      orderPollIntervalProvider.overrideWithValue(interval),
    ],
  );
}
