// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpeningHoursDto _$OpeningHoursDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OpeningHoursDto', json, ($checkedConvert) {
      final val = OpeningHoursDto(
        dayOfWeek: $checkedConvert('dayOfWeek', (v) => (v as num).toInt()),
        opensAt: $checkedConvert('opensAt', (v) => v as String),
        closesAt: $checkedConvert('closesAt', (v) => v as String),
      );
      return val;
    });

MenuItemDto _$MenuItemDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MenuItemDto', json, ($checkedConvert) {
      final val = MenuItemDto(
        id: $checkedConvert('id', (v) => v as String),
        restaurantId: $checkedConvert('restaurantId', (v) => v as String),
        categoryId: $checkedConvert('categoryId', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        priceAgorot: $checkedConvert('priceAgorot', (v) => (v as num).toInt()),
        dietaryTags: $checkedConvert(
          'dietaryTags',
          (v) => dietaryTagsFromJson(v),
        ),
        isAvailable: $checkedConvert('isAvailable', (v) => v as bool),
      );
      return val;
    });

MenuCategoryDto _$MenuCategoryDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MenuCategoryDto', json, ($checkedConvert) {
      final val = MenuCategoryDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => MenuItemDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

RestaurantDto _$RestaurantDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RestaurantDto', json, ($checkedConvert) {
      final val = RestaurantDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        cuisine: $checkedConvert('cuisine', (v) => v as String),
        address: $checkedConvert('address', (v) => v as String),
        isOpen: $checkedConvert('isOpen', (v) => v as bool),
        openingHours: $checkedConvert(
          'openingHours',
          (v) => (v as List<dynamic>)
              .map((e) => OpeningHoursDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        minOrderAgorot: $checkedConvert(
          'minOrderAgorot',
          (v) => (v as num).toInt(),
        ),
        deliveryFeeAgorot: $checkedConvert(
          'deliveryFeeAgorot',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

RestaurantListDto _$RestaurantListDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RestaurantListDto', json, ($checkedConvert) {
      final val = RestaurantListDto(
        restaurants: $checkedConvert(
          'restaurants',
          (v) => (v as List<dynamic>)
              .map((e) => RestaurantDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

MenuResponseDto _$MenuResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MenuResponseDto', json, ($checkedConvert) {
      final val = MenuResponseDto(
        restaurant: $checkedConvert(
          'restaurant',
          (v) => RestaurantDto.fromJson(v as Map<String, dynamic>),
        ),
        categories: $checkedConvert(
          'categories',
          (v) => (v as List<dynamic>)
              .map((e) => MenuCategoryDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });
