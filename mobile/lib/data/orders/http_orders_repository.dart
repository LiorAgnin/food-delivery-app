import '../../domain/api_result.dart';
import '../../domain/orders/order.dart';
import '../../domain/ports/orders_repository.dart';
import '../api_client.dart';
import '../dto/order_dto.dart';
import '../json_body.dart';

final class HttpOrdersRepository implements OrdersRepository {
  HttpOrdersRepository(this._client);

  final ApiClient _client;

  @override
  Future<ApiResult<Order>> placeOrder({
    required String restaurantId,
    required List<OrderDraftLine> lines,
    required String idempotencyKey,
  }) {
    return _client.post(
      '/orders',
      (json) => OrderDto.fromJson(asJsonMap(json)).toDomain(),
      headers: {'Idempotency-Key': idempotencyKey},
      body: {
        'restaurantId': restaurantId,
        'items': [
          for (final line in lines)
            {'menuItemId': line.menuItemId, 'quantity': line.quantity},
        ],
      },
    );
  }

  @override
  Future<ApiResult<Order>> getOrder(String orderId) {
    final id = Uri.encodeComponent(orderId);
    return _client.get(
      '/orders/$id',
      (json) => OrderDto.fromJson(asJsonMap(json)).toDomain(),
    );
  }
}
