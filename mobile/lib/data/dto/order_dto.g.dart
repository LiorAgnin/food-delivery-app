// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderLineDto _$OrderLineDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OrderLineDto', json, ($checkedConvert) {
      final val = OrderLineDto(
        menuItemId: $checkedConvert('menuItemId', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String),
        unitPriceAgorot: $checkedConvert(
          'unitPriceAgorot',
          (v) => (v as num).toInt(),
        ),
        quantity: $checkedConvert('quantity', (v) => (v as num).toInt()),
        lineTotalAgorot: $checkedConvert(
          'lineTotalAgorot',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

StatusEventDto _$StatusEventDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StatusEventDto', json, ($checkedConvert) {
      final val = StatusEventDto(
        from: $checkedConvert('from', (v) => nullableOrderStatusFromJson(v)),
        to: $checkedConvert('to', (v) => orderStatusFromJson(v)),
        actor: $checkedConvert('actor', (v) => actorFromJson(v)),
        at: $checkedConvert('at', (v) => instantFromJson(v)),
      );
      return val;
    });

OrderRestaurantDto _$OrderRestaurantDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OrderRestaurantDto', json, ($checkedConvert) {
      final val = OrderRestaurantDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

OrderDto _$OrderDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OrderDto', json, ($checkedConvert) {
      final val = OrderDto(
        id: $checkedConvert('id', (v) => v as String),
        status: $checkedConvert('status', (v) => orderStatusFromJson(v)),
        restaurant: $checkedConvert(
          'restaurant',
          (v) => OrderRestaurantDto.fromJson(v as Map<String, dynamic>),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => OrderLineDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        subtotalAgorot: $checkedConvert(
          'subtotalAgorot',
          (v) => (v as num).toInt(),
        ),
        deliveryFeeAgorot: $checkedConvert(
          'deliveryFeeAgorot',
          (v) => (v as num).toInt(),
        ),
        totalAgorot: $checkedConvert('totalAgorot', (v) => (v as num).toInt()),
        statusHistory: $checkedConvert(
          'statusHistory',
          (v) => (v as List<dynamic>)
              .map((e) => StatusEventDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        createdAt: $checkedConvert('createdAt', (v) => instantFromJson(v)),
        updatedAt: $checkedConvert('updatedAt', (v) => instantFromJson(v)),
      );
      return val;
    });
