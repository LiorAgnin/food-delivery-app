import 'package:json_annotation/json_annotation.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/dish_finder/dish_finder.dart';
import 'catalog_dto.dart';
import 'wire_values.dart';

part 'dish_finder_dto.g.dart';

@JsonSerializable(createToJson: false)
class DishRestaurantDto {
  const DishRestaurantDto({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.isOpen,
  });

  factory DishRestaurantDto.fromJson(Map<String, dynamic> json) =>
      _$DishRestaurantDtoFromJson(json);

  final String id;
  final String name;
  final String cuisine;
  final bool isOpen;

  DishRestaurant toDomain() =>
      DishRestaurant(id: id, name: name, cuisine: cuisine, isOpen: isOpen);
}

@JsonSerializable(createToJson: false)
class DishResultDto {
  const DishResultDto({
    required this.menuItem,
    required this.restaurant,
    required this.orderable,
  });

  factory DishResultDto.fromJson(Map<String, dynamic> json) =>
      _$DishResultDtoFromJson(json);

  final MenuItemDto menuItem;
  final DishRestaurantDto restaurant;
  final bool orderable;

  DishResult toDomain() => DishResult(
    menuItem: menuItem.toDomain(),
    restaurant: restaurant.toDomain(),
    orderable: orderable,
  );
}

@JsonSerializable(createToJson: false)
class SearchIntentDto {
  const SearchIntentDto({
    required this.keywords,
    required this.excludeKeywords,
    required this.cuisines,
    required this.includeTags,
    required this.excludeTags,
    required this.maxPriceAgorot,
    required this.openNowOnly,
    required this.sort,
  });

  factory SearchIntentDto.fromJson(Map<String, dynamic> json) =>
      _$SearchIntentDtoFromJson(json);

  final List<String> keywords;
  final List<String> excludeKeywords;
  final List<String> cuisines;

  @JsonKey(fromJson: dietaryTagsFromJson)
  final List<DietaryTag> includeTags;

  @JsonKey(fromJson: dietaryTagsFromJson)
  final List<DietaryTag> excludeTags;

  final int? maxPriceAgorot;
  final bool openNowOnly;

  @JsonKey(fromJson: searchSortFromJson)
  final SearchSort sort;

  SearchIntent toDomain() => SearchIntent(
    keywords: keywords,
    excludeKeywords: excludeKeywords,
    cuisines: cuisines,
    includeTags: includeTags,
    excludeTags: excludeTags,
    maxPriceAgorot: maxPriceAgorot,
    openNowOnly: openNowOnly,
    sort: sort,
  );
}

@JsonSerializable(createToJson: false)
class DishFinderReplyDto {
  const DishFinderReplyDto({
    required this.reply,
    required this.results,
    required this.intent,
    required this.relaxed,
  });

  factory DishFinderReplyDto.fromJson(Map<String, dynamic> json) =>
      _$DishFinderReplyDtoFromJson(json);

  final String reply;
  final List<DishResultDto> results;
  final SearchIntentDto intent;
  final List<String> relaxed;

  DishFinderReply toDomain() => DishFinderReply(
    reply: reply,
    results: [for (final result in results) result.toDomain()],
    intent: intent.toDomain(),
    relaxed: relaxed,
  );
}
