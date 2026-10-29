import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/order_tracker.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/failures/api_error.dart';
import 'package:food_delivery/domain/orders/order.dart';
import 'package:food_delivery/presentation/orders/order_status_screen.dart';

import '../support/fake_orders_repository.dart';
import '../support/fixtures.dart';

void main() {
  testWidgets('the stepper shows preparing and the snapshot prices', (
    tester,
  ) async {
    final order = sampleOrder(
      id: 'order-1',
      status: OrderStatus.preparing,
      restaurantName: 'Shawarma Gil',
      items: const [
        OrderLine(
          menuItemId: 'i1',
          name: 'Pita shawarma',
          unitPriceAgorot: 4200,
          quantity: 2,
          lineTotalAgorot: 8400,
        ),
      ],
      subtotalAgorot: 8400,
      deliveryFeeAgorot: 1500,
      totalAgorot: 9900,
      statusHistory: [
        StatusEvent(
          from: null,
          to: OrderStatus.placed,
          actor: Actor.customer,
          at: DateTime.utc(2026, 10, 29, 18, 1),
        ),
        StatusEvent(
          from: OrderStatus.placed,
          to: OrderStatus.accepted,
          actor: Actor.restaurant,
          at: DateTime.utc(2026, 10, 29, 18, 4),
        ),
        StatusEvent(
          from: OrderStatus.accepted,
          to: OrderStatus.preparing,
          actor: Actor.restaurant,
          at: DateTime.utc(2026, 10, 29, 18, 9),
        ),
      ],
    );
    await _show(
      tester,
      FakeOrdersRepository(getResults: [ApiOk(order)]),
      () async {
        expect(
          find.byKey(const Key('order_step_current_preparing')),
          findsOneWidget,
        );
        expect(find.text('Placed'), findsOneWidget);
        expect(find.text('Accepted'), findsOneWidget);
        expect(find.text('Preparing'), findsOneWidget);
        expect(find.text('Picked up'), findsOneWidget);
        expect(find.text('Delivered'), findsOneWidget);
        expect(find.text('18:01'), findsOneWidget);
        expect(find.text('18:04'), findsOneWidget);
        expect(find.text('18:09'), findsOneWidget);
        expect(find.byKey(const Key('order_step_time_pickedUp')), findsNothing);
        expect(
          find.byKey(const Key('order_step_time_delivered')),
          findsNothing,
        );

        expect(find.text('Shawarma Gil'), findsOneWidget);
        expect(find.text('order-1'), findsOneWidget);
        expect(find.text('Pita shawarma × 2'), findsOneWidget);
        expect(find.text('₪84.00'), findsNWidgets(2));
        expect(_text(tester, 'order_subtotal'), '₪84.00');
        expect(_text(tester, 'order_delivery_fee'), '₪15.00');
        expect(_text(tester, 'order_total'), '₪99.00');
        expect(find.byKey(const Key('order_reconnecting')), findsNothing);
        expect(find.byKey(const Key('order_cancelled')), findsNothing);
      },
    );
  });

  testWidgets('a cancelled order is not the delivery stepper', (tester) async {
    final order = sampleOrder(
      status: OrderStatus.cancelled,
      restaurantName: 'Shawarma Gil',
      statusHistory: [
        StatusEvent(
          from: null,
          to: OrderStatus.placed,
          actor: Actor.customer,
          at: DateTime.utc(2026, 10, 29, 18, 1),
        ),
        StatusEvent(
          from: OrderStatus.placed,
          to: OrderStatus.cancelled,
          actor: Actor.restaurant,
          at: DateTime.utc(2026, 10, 29, 18, 20),
        ),
      ],
    );
    await _show(
      tester,
      FakeOrdersRepository(getResults: [ApiOk(order)]),
      () async {
        expect(find.byKey(const Key('order_cancelled')), findsOneWidget);
        expect(find.text('Cancelled'), findsOneWidget);
        expect(find.text('18:20'), findsOneWidget);
        expect(find.byKey(const Key('order_step_placed')), findsNothing);
        expect(find.byKey(const Key('order_step_delivered')), findsNothing);
        expect(find.text('Shawarma Gil'), findsOneWidget);
        expect(find.text('Pita shawarma × 1'), findsOneWidget);
        expect(find.text('₪42.00'), findsWidgets);
        expect(find.text('₪57.00'), findsOneWidget);
      },
    );
  });

  testWidgets('loading, then a full error with retry when nothing loaded', (
    tester,
  ) async {
    final orders = FakeOrdersRepository(
      getResults: [
        const ApiFailure(
          ApiError(code: ApiErrorCode.notFound, message: 'Missing'),
        ),
        ApiOk(sampleOrder(status: OrderStatus.placed)),
      ],
    );
    final gate = Completer<void>();
    orders.blockGet = gate;
    await _show(tester, orders, () async {
      expect(find.byKey(const Key('order_loading')), findsOneWidget);

      gate.complete();
      orders.blockGet = null;
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('order_error')), findsOneWidget);
      expect(find.text('Missing'), findsOneWidget);
      expect(find.byKey(const Key('order_loading')), findsNothing);

      await tester.tap(find.byKey(const Key('order_retry')));
      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(const Key('order_step_current_placed')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('order_error')), findsNothing);
    }, settle: false);
  });

  testWidgets('a later poll failure keeps the order and says reconnecting', (
    tester,
  ) async {
    final orders = FakeOrdersRepository(
      getResults: [
        ApiOk(
          sampleOrder(
            status: OrderStatus.accepted,
            restaurantName: 'Alei Gefen',
          ),
        ),
        const ApiFailure(
          ApiError(code: ApiErrorCode.timeout, message: 'timed out'),
        ),
      ],
    );
    await _show(
      tester,
      orders,
      () async {
        await tester.pump();

        expect(find.text('Alei Gefen'), findsOneWidget);
        expect(find.byKey(const Key('order_reconnecting')), findsNothing);

        await tester.pump(const Duration(seconds: 1));
        await tester.pump();

        expect(find.text('Reconnecting…'), findsOneWidget);
        expect(find.text('Alei Gefen'), findsOneWidget);
        expect(find.byKey(const Key('order_error')), findsNothing);
        expect(
          find.byKey(const Key('order_step_current_accepted')),
          findsOneWidget,
        );
      },
      settle: false,
      interval: const Duration(seconds: 1),
    );
  });
}

String _text(WidgetTester tester, String key) {
  return tester.widget<Text>(find.byKey(Key(key))).data!;
}

Future<void> _show(
  WidgetTester tester,
  FakeOrdersRepository orders,
  Future<void> Function() check, {
  bool settle = true,
  Duration interval = const Duration(hours: 1),
}) async {
  final container = ProviderContainer(
    overrides: [
      ordersRepositoryProvider.overrideWithValue(orders),
      orderPollIntervalProvider.overrideWithValue(interval),
    ],
  );
  try {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OrderStatusScreen(orderId: 'order-1')),
      ),
    );
    if (settle) {
      await tester.pump();
      await tester.pump();
    }
    await check();
  } finally {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
  }
}
