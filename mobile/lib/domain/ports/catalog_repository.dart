import '../api_result.dart';
import '../catalog/catalog.dart';

abstract interface class CatalogRepository {
  Future<ApiResult<List<Restaurant>>> listRestaurants();

  Future<ApiResult<RestaurantMenu>> getMenu(String restaurantId);
}
