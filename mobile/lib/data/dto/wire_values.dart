import '../../domain/catalog/catalog.dart';
import '../../domain/dish_finder/dish_finder.dart';
import '../../domain/orders/order.dart';

DietaryTag dietaryTagFromWire(String raw) {
  return switch (raw) {
    'vegetarian' => DietaryTag.vegetarian,
    'vegan' => DietaryTag.vegan,
    'spicy' => DietaryTag.spicy,
    'gluten_free' => DietaryTag.glutenFree,
    'dairy_free' => DietaryTag.dairyFree,
    'contains_nuts' => DietaryTag.containsNuts,
    _ => throw FormatException('Unknown dietary tag: $raw'),
  };
}

List<DietaryTag> dietaryTagsFromJson(Object? raw) {
  if (raw is! List) {
    throw const FormatException('dietaryTags must be a list');
  }
  return [
    for (final entry in raw)
      if (entry is String)
        dietaryTagFromWire(entry)
      else
        throw const FormatException('Dietary tag must be a string'),
  ];
}

OrderStatus orderStatusFromJson(Object? raw) {
  if (raw is! String) {
    throw const FormatException('Expected an order status');
  }
  return switch (raw) {
    'PLACED' => OrderStatus.placed,
    'ACCEPTED' => OrderStatus.accepted,
    'PREPARING' => OrderStatus.preparing,
    'PICKED_UP' => OrderStatus.pickedUp,
    'DELIVERED' => OrderStatus.delivered,
    'CANCELLED' => OrderStatus.cancelled,
    _ => throw FormatException('Unknown order status: $raw'),
  };
}

OrderStatus? nullableOrderStatusFromJson(Object? raw) {
  if (raw == null) return null;
  return orderStatusFromJson(raw);
}

Actor actorFromJson(Object? raw) {
  if (raw is! String) {
    throw const FormatException('Expected an actor');
  }
  return switch (raw) {
    'customer' => Actor.customer,
    'restaurant' => Actor.restaurant,
    'courier' => Actor.courier,
    'system' => Actor.system,
    _ => throw FormatException('Unknown actor: $raw'),
  };
}

SearchSort searchSortFromJson(Object? raw) {
  if (raw is! String) {
    throw const FormatException('Expected a sort');
  }
  return switch (raw) {
    'relevance' => SearchSort.relevance,
    'price_asc' => SearchSort.priceAsc,
    _ => throw FormatException('Unknown sort: $raw'),
  };
}

DateTime instantFromJson(Object? raw) {
  if (raw is! String) {
    throw const FormatException('Expected an ISO-8601 timestamp');
  }
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    throw FormatException('Invalid timestamp: $raw');
  }
  return parsed.toUtc();
}

String chatRoleToWire(ChatRole role) {
  return switch (role) {
    ChatRole.user => 'user',
    ChatRole.assistant => 'assistant',
  };
}
