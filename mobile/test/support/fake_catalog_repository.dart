import 'dart:async';

import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/catalog/catalog.dart';
import 'package:food_delivery/domain/failures/api_error.dart';
import 'package:food_delivery/domain/ports/catalog_repository.dart';

final class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository({
    List<ApiResult<List<Restaurant>>>? listResults,
    List<ApiResult<RestaurantMenu>>? menuResults,
    ApiResult<RestaurantMenu>? menu,
    this.hangList = false,
    this.hangMenu = false,
  }) : listResults = listResults ?? const [ApiOk(<Restaurant>[])],
       menuResults = menuResults ?? [if (menu != null) menu];

  final List<ApiResult<List<Restaurant>>> listResults;
  final List<ApiResult<RestaurantMenu>> menuResults;
  final bool hangList;
  final bool hangMenu;
  int listCalls = 0;
  int menuCalls = 0;

  Completer<void>? _listHold;
  Completer<void>? _menuHold;

  /// The next [listRestaurants] waits until [releaseList].
  void holdNextList() {
    _listHold = Completer<void>();
  }

  void releaseList() {
    final hold = _listHold;
    _listHold = null;
    if (hold != null && !hold.isCompleted) hold.complete();
  }

  /// The next [getMenu] waits until [releaseMenu].
  void holdNextMenu() {
    _menuHold = Completer<void>();
  }

  void releaseMenu() {
    final hold = _menuHold;
    _menuHold = null;
    if (hold != null && !hold.isCompleted) hold.complete();
  }

  @override
  Future<ApiResult<List<Restaurant>>> listRestaurants() async {
    listCalls += 1;
    final hold = _listHold;
    if (hold != null) await hold.future;
    if (hangList) return Completer<ApiResult<List<Restaurant>>>().future;
    final index = listCalls - 1;
    return index < listResults.length ? listResults[index] : listResults.last;
  }

  @override
  Future<ApiResult<RestaurantMenu>> getMenu(String restaurantId) async {
    menuCalls += 1;
    final hold = _menuHold;
    if (hold != null) await hold.future;
    if (hangMenu) return Completer<ApiResult<RestaurantMenu>>().future;
    if (menuResults.isEmpty) {
      return const ApiFailure(
        ApiError(code: ApiErrorCode.notFound, message: 'Not found'),
      );
    }
    final index = menuCalls - 1;
    return index < menuResults.length ? menuResults[index] : menuResults.last;
  }
}
