import 'package:json_annotation/json_annotation.dart';

import '../../domain/orders/order.dart';
import 'wire_values.dart';

part 'order_dto.g.dart';

@JsonSerializable(createToJson: false)
class OrderLineDto {
  const OrderLineDto({
    required this.menuItemId,
    required this.name,
    required this.unitPriceAgorot,
    required this.quantity,
    required this.lineTotalAgorot,
  });

  factory OrderLineDto.fromJson(Map<String, dynamic> json) =>
      _$OrderLineDtoFromJson(json);

  final String? menuItemId;
  final String name;
  final int unitPriceAgorot;
  final int quantity;
  final int lineTotalAgorot;

  OrderLine toDomain() => OrderLine(
    menuItemId: menuItemId,
    name: name,
    unitPriceAgorot: unitPriceAgorot,
    quantity: quantity,
    lineTotalAgorot: lineTotalAgorot,
  );
}

@JsonSerializable(createToJson: false)
class StatusEventDto {
  const StatusEventDto({
    required this.from,
    required this.to,
    required this.actor,
    required this.at,
  });

  factory StatusEventDto.fromJson(Map<String, dynamic> json) =>
      _$StatusEventDtoFromJson(json);

  @JsonKey(fromJson: nullableOrderStatusFromJson)
  final OrderStatus? from;

  @JsonKey(fromJson: orderStatusFromJson)
  final OrderStatus to;

  @JsonKey(fromJson: actorFromJson)
  final Actor actor;

  @JsonKey(fromJson: instantFromJson)
  final DateTime at;

  StatusEvent toDomain() =>
      StatusEvent(from: from, to: to, actor: actor, at: at);
}

@JsonSerializable(createToJson: false)
class OrderRestaurantDto {
  const OrderRestaurantDto({required this.id, required this.name});

  factory OrderRestaurantDto.fromJson(Map<String, dynamic> json) =>
      _$OrderRestaurantDtoFromJson(json);

  final String id;
  final String name;
}

@JsonSerializable(createToJson: false)
class OrderDto {
  const OrderDto({
    required this.id,
    required this.status,
    required this.restaurant,
    required this.items,
    required this.subtotalAgorot,
    required this.deliveryFeeAgorot,
    required this.totalAgorot,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);

  final String id;

  @JsonKey(fromJson: orderStatusFromJson)
  final OrderStatus status;

  final OrderRestaurantDto restaurant;
  final List<OrderLineDto> items;
  final int subtotalAgorot;
  final int deliveryFeeAgorot;
  final int totalAgorot;
  final List<StatusEventDto> statusHistory;

  @JsonKey(fromJson: instantFromJson)
  final DateTime createdAt;

  @JsonKey(fromJson: instantFromJson)
  final DateTime updatedAt;

  Order toDomain() => Order(
    id: id,
    status: status,
    restaurantId: restaurant.id,
    restaurantName: restaurant.name,
    items: [for (final line in items) line.toDomain()],
    subtotalAgorot: subtotalAgorot,
    deliveryFeeAgorot: deliveryFeeAgorot,
    totalAgorot: totalAgorot,
    statusHistory: [for (final event in statusHistory) event.toDomain()],
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
