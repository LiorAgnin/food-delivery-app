import 'dart:async';

import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/catalog/catalog.dart';
import 'package:food_delivery/domain/dish_finder/dish_finder.dart';
import 'package:food_delivery/domain/ports/dish_finder_repository.dart';

DishFinderReply sampleReply({
  String reply = 'Here are a few dishes.',
  List<DishResult> results = const [],
  List<String> relaxed = const [],
}) {
  return DishFinderReply(
    reply: reply,
    results: results,
    intent: const SearchIntent(
      keywords: <String>[],
      excludeKeywords: <String>[],
      cuisines: <String>[],
      includeTags: <DietaryTag>[],
      excludeTags: <DietaryTag>[],
      maxPriceAgorot: null,
      openNowOnly: false,
      sort: SearchSort.relevance,
    ),
    relaxed: relaxed,
  );
}

final class FakeDishFinderRepository implements DishFinderRepository {
  FakeDishFinderRepository({
    List<ApiResult<DishFinderReply>>? script,
    this.hang = false,
  }) : script = script ?? const <ApiResult<DishFinderReply>>[];

  final List<ApiResult<DishFinderReply>> script;
  final bool hang;
  final List<List<ChatMessage>> searches = [];
  Completer<ApiResult<DishFinderReply>>? _hanging;

  @override
  Future<ApiResult<DishFinderReply>> search(List<ChatMessage> messages) {
    searches.add([
      for (final message in messages)
        ChatMessage(role: message.role, content: message.content),
    ]);
    if (hang && _hanging == null) {
      _hanging = Completer<ApiResult<DishFinderReply>>();
      return _hanging!.future;
    }
    final index = searches.length - 1;
    if (script.isEmpty) {
      return Future<ApiResult<DishFinderReply>>.value(
        ApiOk(sampleReply(reply: 'a${index + 1}')),
      );
    }
    final result = index < script.length ? script[index] : script.last;
    return Future<ApiResult<DishFinderReply>>.value(result);
  }

  void release(ApiResult<DishFinderReply> result) {
    final pending = _hanging;
    _hanging = null;
    pending?.complete(result);
  }
}
