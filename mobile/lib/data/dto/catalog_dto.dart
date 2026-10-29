import 'package:json_annotation/json_annotation.dart';

import '../../domain/catalog/catalog.dart';
import 'wire_values.dart';

part 'catalog_dto.g.dart';

@JsonSerializable(createToJson: false)
class OpeningHoursDto {
  const OpeningHoursDto({
    required this.dayOfWeek,
    required this.opensAt,
    required this.closesAt,
  });

  factory OpeningHoursDto.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursDtoFromJson(json);

  final int dayOfWeek;
  final String opensAt;
  final String closesAt;

  OpeningHours toDomain() =>
      OpeningHours(dayOfWeek: dayOfWeek, opensAt: opensAt, closesAt: closesAt);
}

@JsonSerializable(createToJson: false)
class MenuItemDto {
  const MenuItemDto({
    required this.id,
    required this.restaurantId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.priceAgorot,
    required this.dietaryTags,
    required this.isAvailable,
  });

  factory MenuItemDto.fromJson(Map<String, dynamic> json) =>
      _$MenuItemDtoFromJson(json);

  final String id;
  final String restaurantId;
  final String categoryId;
  final String name;
  final String description;
  final int priceAgorot;

  @JsonKey(fromJson: dietaryTagsFromJson)
  final List<DietaryTag> dietaryTags;

  final bool isAvailable;

  MenuItem toDomain() => MenuItem(
    id: id,
    restaurantId: restaurantId,
    categoryId: categoryId,
    name: name,
    description: description,
    priceAgorot: priceAgorot,
    dietaryTags: dietaryTags,
    isAvailable: isAvailable,
  );
}

@JsonSerializable(createToJson: false)
class MenuCategoryDto {
  const MenuCategoryDto({
    required this.id,
    required this.name,
    required this.items,
  });

  factory MenuCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryDtoFromJson(json);

  final String id;
  final String name;
  final List<MenuItemDto> items;

  MenuCategory toDomain() => MenuCategory(
    id: id,
    name: name,
    items: [for (final item in items) item.toDomain()],
  );
}

@JsonSerializable(createToJson: false)
class RestaurantDto {
  const RestaurantDto({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.address,
    required this.isOpen,
    required this.openingHours,
    required this.minOrderAgorot,
    required this.deliveryFeeAgorot,
  });

  factory RestaurantDto.fromJson(Map<String, dynamic> json) =>
      _$RestaurantDtoFromJson(json);

  final String id;
  final String name;
  final String cuisine;
  final String address;
  final bool isOpen;
  final List<OpeningHoursDto> openingHours;
  final int minOrderAgorot;
  final int deliveryFeeAgorot;

  Restaurant toDomain() => Restaurant(
    id: id,
    name: name,
    cuisine: cuisine,
    address: address,
    isOpen: isOpen,
    openingHours: [for (final row in openingHours) row.toDomain()],
    minOrderAgorot: minOrderAgorot,
    deliveryFeeAgorot: deliveryFeeAgorot,
  );
}

@JsonSerializable(createToJson: false)
class RestaurantListDto {
  const RestaurantListDto({required this.restaurants});

  factory RestaurantListDto.fromJson(Map<String, dynamic> json) =>
      _$RestaurantListDtoFromJson(json);

  final List<RestaurantDto> restaurants;
}

@JsonSerializable(createToJson: false)
class MenuResponseDto {
  const MenuResponseDto({required this.restaurant, required this.categories});

  factory MenuResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MenuResponseDtoFromJson(json);

  final RestaurantDto restaurant;
  final List<MenuCategoryDto> categories;

  RestaurantMenu toDomain() => RestaurantMenu(
    restaurant: restaurant.toDomain(),
    categories: [for (final category in categories) category.toDomain()],
  );
}
