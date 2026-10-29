import 'dart:async';

import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/catalog/catalog.dart';
import 'package:food_delivery/domain/failures/api_error.dart';
import 'package:food_delivery/domain/ports/catalog_repository.dart';

final class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository({
    List<ApiResult<List<Restaurant>>>? listResults,
    this.menu,
    this.hangList = false,
  }) : listResults = listResults ?? const [ApiOk(<Restaurant>[])];

  final List<ApiResult<List<Restaurant>>> listResults;
  final ApiResult<RestaurantMenu>? menu;
  final bool hangList;
  int listCalls = 0;

  @override
  Future<ApiResult<List<Restaurant>>> listRestaurants() {
    listCalls += 1;
    if (hangList) return Completer<ApiResult<List<Restaurant>>>().future;
    final index = listCalls - 1;
    final result = index < listResults.length
        ? listResults[index]
        : listResults.last;
    return Future.value(result);
  }

  @override
  Future<ApiResult<RestaurantMenu>> getMenu(String restaurantId) async {
    return menu ??
        const ApiFailure(
          ApiError(code: ApiErrorCode.notFound, message: 'Not found'),
        );
  }
}
