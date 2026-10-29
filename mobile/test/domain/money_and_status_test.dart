import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/domain/failures/api_error.dart';
import 'package:food_delivery/domain/money.dart';
import 'package:food_delivery/domain/orders/order.dart';
import 'package:food_delivery/presentation/format/agorot_format.dart';

void main() {
  test('line and order totals stay in agorot', () {
    expect(Money.lineTotal(unitPriceAgorot: 4200, quantity: 2), 8400);
    expect(
      Money.orderTotal(subtotalAgorot: 8400, deliveryFeeAgorot: 1500),
      9900,
    );
  });

  test('formats agorot as shekels', () {
    expect(formatAgorot(4200), '₪42.00');
    expect(formatAgorot(50), '₪0.50');
    expect(formatAgorot(0), '₪0.00');
    expect(formatAgorot(-10), '-₪0.10');
  });

  test('only delivered and cancelled are terminal', () {
    expect(OrderStatus.placed.isTerminal, isFalse);
    expect(OrderStatus.accepted.isTerminal, isFalse);
    expect(OrderStatus.preparing.isTerminal, isFalse);
    expect(OrderStatus.pickedUp.isTerminal, isFalse);
    expect(OrderStatus.delivered.isTerminal, isTrue);
    expect(OrderStatus.cancelled.isTerminal, isTrue);
  });

  test('unknown wire codes do not crash', () {
    expect(apiErrorCodeFromWire('BELOW_MINIMUM'), ApiErrorCode.belowMinimum);
    expect(apiErrorCodeFromWire('NOT_A_CODE'), ApiErrorCode.unknown);
  });
}
