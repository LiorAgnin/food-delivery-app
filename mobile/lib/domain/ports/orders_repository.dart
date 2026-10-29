import '../api_result.dart';
import '../orders/order.dart';

abstract interface class OrdersRepository {
  Future<ApiResult<Order>> placeOrder({
    required String restaurantId,
    required List<OrderDraftLine> lines,
    required String idempotencyKey,
  });

  Future<ApiResult<Order>> getOrder(String orderId);
}
