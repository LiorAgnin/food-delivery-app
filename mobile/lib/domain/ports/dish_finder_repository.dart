import '../api_result.dart';
import '../dish_finder/dish_finder.dart';

abstract interface class DishFinderRepository {
  /// Sends the whole conversation. The server stays stateless.
  Future<ApiResult<DishFinderReply>> search(List<ChatMessage> messages);
}
