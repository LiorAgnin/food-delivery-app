import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';

/// Postgres `order_status`. [delivered] and [cancelled] are terminal.
enum OrderStatus { placed, accepted, preparing, pickedUp, delivered, cancelled }

extension OrderStatusTerminal on OrderStatus {
  bool get isTerminal =>
      this == OrderStatus.delivered || this == OrderStatus.cancelled;
}

enum Actor { customer, restaurant, courier, system }

/// One line the client sends on `POST /orders`. Prices stay on the server.
final class OrderDraftLine {
  const OrderDraftLine({required this.menuItemId, required this.quantity});

  final String menuItemId;
  final int quantity;
}

@freezed
abstract class OrderLine with _$OrderLine {
  const factory OrderLine({
    required String? menuItemId,
    required String name,
    required int unitPriceAgorot,
    required int quantity,
    required int lineTotalAgorot,
  }) = _OrderLine;
}

@freezed
abstract class StatusEvent with _$StatusEvent {
  const factory StatusEvent({
    required OrderStatus? from,
    required OrderStatus to,
    required Actor actor,
    required DateTime at,
  }) = _StatusEvent;
}

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required OrderStatus status,
    required String restaurantId,
    required String restaurantName,
    required List<OrderLine> items,
    required int subtotalAgorot,
    required int deliveryFeeAgorot,
    required int totalAgorot,
    required List<StatusEvent> statusHistory,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Order;
}
