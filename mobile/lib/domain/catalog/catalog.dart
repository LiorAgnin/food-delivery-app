import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog.freezed.dart';

/// Contract `DietaryTag`. Wire values are the enum names with underscores
/// (`gluten_free`); the data layer maps them.
enum DietaryTag {
  vegetarian,
  vegan,
  spicy,
  glutenFree,
  dairyFree,
  containsNuts,
}

@freezed
abstract class OpeningHours with _$OpeningHours {
  const factory OpeningHours({
    required int dayOfWeek,
    required String opensAt,
    required String closesAt,
  }) = _OpeningHours;
}

@freezed
abstract class MenuItem with _$MenuItem {
  const factory MenuItem({
    required String id,
    required String restaurantId,
    required String categoryId,
    required String name,
    required String description,
    required int priceAgorot,
    required List<DietaryTag> dietaryTags,
    required bool isAvailable,
  }) = _MenuItem;
}

@freezed
abstract class MenuCategory with _$MenuCategory {
  const factory MenuCategory({
    required String id,
    required String name,
    required List<MenuItem> items,
  }) = _MenuCategory;
}

@freezed
abstract class Restaurant with _$Restaurant {
  const factory Restaurant({
    required String id,
    required String name,
    required String cuisine,
    required String address,
    required bool isOpen,
    required List<OpeningHours> openingHours,
    required int minOrderAgorot,
    required int deliveryFeeAgorot,
  }) = _Restaurant;
}

/// `GET /restaurants/:id/menu`.
@freezed
abstract class RestaurantMenu with _$RestaurantMenu {
  const factory RestaurantMenu({
    required Restaurant restaurant,
    required List<MenuCategory> categories,
  }) = _RestaurantMenu;
}
