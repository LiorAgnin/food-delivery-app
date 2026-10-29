import '../../domain/api_result.dart';
import '../../domain/dish_finder/dish_finder.dart';
import '../../domain/ports/dish_finder_repository.dart';
import '../api_client.dart';
import '../dto/dish_finder_dto.dart';
import '../dto/wire_values.dart';
import '../json_body.dart';

final class HttpDishFinderRepository implements DishFinderRepository {
  HttpDishFinderRepository(this._client);

  final ApiClient _client;

  @override
  Future<ApiResult<DishFinderReply>> search(List<ChatMessage> messages) {
    return _client.post(
      '/dish-finder/search',
      (json) => DishFinderReplyDto.fromJson(asJsonMap(json)).toDomain(),
      body: {
        'messages': [
          for (final message in messages)
            {'role': chatRoleToWire(message.role), 'content': message.content},
        ],
      },
    );
  }
}
