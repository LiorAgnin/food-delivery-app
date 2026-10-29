import 'dart:async';

import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/orders/order.dart';
import 'package:food_delivery/domain/ports/orders_repository.dart';

/// Scripted [OrdersRepository]. Each call takes the next result and then
/// repeats the last one, so a poll can keep returning the same order.
final class FakeOrdersRepository implements OrdersRepository {
  FakeOrdersRepository({
    List<ApiResult<Order>>? placeResults,
    List<ApiResult<Order>>? getResults,
  }) : placeResults = placeResults ?? <ApiResult<Order>>[],
       getResults = getResults ?? <ApiResult<Order>>[];

  final List<ApiResult<Order>> placeResults;
  final List<ApiResult<Order>> getResults;
  final List<String> idempotencyKeys = [];
  final List<String> restaurantIds = [];
  final List<List<OrderDraftLine>> placedLines = [];
  int getCalls = 0;

  /// When set, [placeOrder] waits on it after recording the attempt.
  Completer<void>? blockPlace;

  /// When set, [getOrder] waits on it after counting the call.
  Completer<void>? blockGet;

  @override
  Future<ApiResult<Order>> placeOrder({
    required String restaurantId,
    required List<OrderDraftLine> lines,
    required String idempotencyKey,
  }) async {
    idempotencyKeys.add(idempotencyKey);
    restaurantIds.add(restaurantId);
    placedLines.add(lines);
    final gate = blockPlace;
    if (gate != null) await gate.future;
    return _at(placeResults, idempotencyKeys.length - 1);
  }

  @override
  Future<ApiResult<Order>> getOrder(String orderId) async {
    final index = getCalls;
    getCalls += 1;
    final gate = blockGet;
    if (gate != null) await gate.future;
    return _at(getResults, index);
  }

  ApiResult<Order> _at(List<ApiResult<Order>> results, int index) {
    if (results.isEmpty) {
      throw StateError('FakeOrdersRepository has no scripted result');
    }
    return index < results.length ? results[index] : results.last;
  }
}
