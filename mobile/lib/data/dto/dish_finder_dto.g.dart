// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish_finder_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DishRestaurantDto _$DishRestaurantDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DishRestaurantDto', json, ($checkedConvert) {
      final val = DishRestaurantDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        cuisine: $checkedConvert('cuisine', (v) => v as String),
        isOpen: $checkedConvert('isOpen', (v) => v as bool),
      );
      return val;
    });

DishResultDto _$DishResultDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DishResultDto', json, ($checkedConvert) {
      final val = DishResultDto(
        menuItem: $checkedConvert(
          'menuItem',
          (v) => MenuItemDto.fromJson(v as Map<String, dynamic>),
        ),
        restaurant: $checkedConvert(
          'restaurant',
          (v) => DishRestaurantDto.fromJson(v as Map<String, dynamic>),
        ),
        orderable: $checkedConvert('orderable', (v) => v as bool),
      );
      return val;
    });

SearchIntentDto _$SearchIntentDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SearchIntentDto', json, ($checkedConvert) {
  final val = SearchIntentDto(
    keywords: $checkedConvert(
      'keywords',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    excludeKeywords: $checkedConvert(
      'excludeKeywords',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    cuisines: $checkedConvert(
      'cuisines',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    includeTags: $checkedConvert('includeTags', (v) => dietaryTagsFromJson(v)),
    excludeTags: $checkedConvert('excludeTags', (v) => dietaryTagsFromJson(v)),
    maxPriceAgorot: $checkedConvert(
      'maxPriceAgorot',
      (v) => (v as num?)?.toInt(),
    ),
    openNowOnly: $checkedConvert('openNowOnly', (v) => v as bool),
    sort: $checkedConvert('sort', (v) => searchSortFromJson(v)),
  );
  return val;
});

DishFinderReplyDto _$DishFinderReplyDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DishFinderReplyDto', json, ($checkedConvert) {
      final val = DishFinderReplyDto(
        reply: $checkedConvert('reply', (v) => v as String),
        results: $checkedConvert(
          'results',
          (v) => (v as List<dynamic>)
              .map((e) => DishResultDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        intent: $checkedConvert(
          'intent',
          (v) => SearchIntentDto.fromJson(v as Map<String, dynamic>),
        ),
        relaxed: $checkedConvert(
          'relaxed',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });
