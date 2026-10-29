import 'package:food_delivery/domain/catalog/catalog.dart';
import 'package:food_delivery/domain/orders/order.dart';

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

Order sampleOrder({
  String id = 'order-1',
  OrderStatus status = OrderStatus.placed,
  String restaurantId = 'r1',
  String restaurantName = 'Shawarma Gil',
  List<OrderLine>? items,
  List<StatusEvent>? statusHistory,
  int subtotalAgorot = 4200,
  int deliveryFeeAgorot = 1500,
  int totalAgorot = 5700,
}) {
  return Order(
    id: id,
    status: status,
    restaurantId: restaurantId,
    restaurantName: restaurantName,
    items:
        items ??
        const [
          OrderLine(
            menuItemId: 'i1',
            name: 'Pita shawarma',
            unitPriceAgorot: 4200,
            quantity: 1,
            lineTotalAgorot: 4200,
          ),
        ],
    subtotalAgorot: subtotalAgorot,
    deliveryFeeAgorot: deliveryFeeAgorot,
    totalAgorot: totalAgorot,
    statusHistory:
        statusHistory ??
        [
          StatusEvent(
            from: null,
            to: OrderStatus.placed,
            actor: Actor.customer,
            at: DateTime.utc(2026, 10, 29, 18),
          ),
        ],
    createdAt: DateTime.utc(2026, 10, 29, 18),
    updatedAt: DateTime.utc(2026, 10, 29, 18),
  );
}

RestaurantMenu sampleMenu({
  Restaurant? restaurant,
  List<MenuItem>? items,
  List<MenuCategory>? categories,
}) {
  final current = restaurant ?? sampleRestaurant();
  return RestaurantMenu(
    restaurant: current,
    categories:
        categories ??
        [
          MenuCategory(id: 'c1', name: 'Mains', items: items ?? [sampleItem()]),
        ],
  );
}
