import 'package:food_delivery/domain/catalog/catalog.dart';

Restaurant sampleRestaurant({
  String id = 'r1',
  String name = 'Shawarma Gil',
  String cuisine = 'Israeli',
  bool isOpen = true,
  int minOrderAgorot = 4000,
  int deliveryFeeAgorot = 1500,
}) {
  return Restaurant(
    id: id,
    name: name,
    cuisine: cuisine,
    address: '1 Herzl, Tel Aviv',
    isOpen: isOpen,
    openingHours: const [
      OpeningHours(dayOfWeek: 0, opensAt: '10:00', closesAt: '22:00'),
    ],
    minOrderAgorot: minOrderAgorot,
    deliveryFeeAgorot: deliveryFeeAgorot,
  );
}

MenuItem sampleItem({
  String id = 'i1',
  String restaurantId = 'r1',
  String categoryId = 'c1',
  String name = 'Pita shawarma',
  String description = 'Lamb, tahini, salad',
  int priceAgorot = 4200,
  bool isAvailable = true,
  List<DietaryTag> dietaryTags = const [DietaryTag.spicy],
}) {
  return MenuItem(
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

RestaurantMenu sampleMenu({Restaurant? restaurant, List<MenuItem>? items}) {
  final current = restaurant ?? sampleRestaurant();
  return RestaurantMenu(
    restaurant: current,
    categories: [
      MenuCategory(id: 'c1', name: 'Mains', items: items ?? [sampleItem()]),
    ],
  );
}
