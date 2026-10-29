import '../../domain/api_result.dart';
import '../../domain/catalog/catalog.dart';
import '../../domain/ports/catalog_repository.dart';
import '../api_client.dart';
import '../dto/catalog_dto.dart';
import '../json_body.dart';

final class HttpCatalogRepository implements CatalogRepository {
  HttpCatalogRepository(this._client);

  final ApiClient _client;

  @override
  Future<ApiResult<List<Restaurant>>> listRestaurants() {
    return _client.get('/restaurants', (json) {
      final dto = RestaurantListDto.fromJson(asJsonMap(json));
      return [for (final restaurant in dto.restaurants) restaurant.toDomain()];
    });
  }

  @override
  Future<ApiResult<RestaurantMenu>> getMenu(String restaurantId) {
    final id = Uri.encodeComponent(restaurantId);
    return _client.get('/restaurants/$id/menu', (json) {
      return MenuResponseDto.fromJson(asJsonMap(json)).toDomain();
    });
  }
}
