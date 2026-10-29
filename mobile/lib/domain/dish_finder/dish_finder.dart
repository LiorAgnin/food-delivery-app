import 'package:freezed_annotation/freezed_annotation.dart';

import '../catalog/catalog.dart';

part 'dish_finder.freezed.dart';

enum ChatRole { user, assistant }

enum SearchSort { relevance, priceAsc }

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({required ChatRole role, required String content}) =
      _ChatMessage;
}

@freezed
abstract class DishRestaurant with _$DishRestaurant {
  const factory DishRestaurant({
    required String id,
    required String name,
    required String cuisine,
    required bool isOpen,
  }) = _DishRestaurant;
}

@freezed
abstract class DishResult with _$DishResult {
  const factory DishResult({
    required MenuItem menuItem,
    required DishRestaurant restaurant,
    required bool orderable,
  }) = _DishResult;
}

@freezed
abstract class SearchIntent with _$SearchIntent {
  const factory SearchIntent({
    required List<String> keywords,
    required List<String> excludeKeywords,
    required List<String> cuisines,
    required List<DietaryTag> includeTags,
    required List<DietaryTag> excludeTags,
    required int? maxPriceAgorot,
    required bool openNowOnly,
    required SearchSort sort,
  }) = _SearchIntent;
}

@freezed
abstract class DishFinderReply with _$DishFinderReply {
  const factory DishFinderReply({
    required String reply,
    required List<DishResult> results,
    required SearchIntent intent,
    required List<String> relaxed,
  }) = _DishFinderReply;
}
