import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/api_result.dart';
import '../domain/catalog/catalog.dart';
import 'ports.dart';
import 'provider_retry.dart';

part 'restaurant_list.g.dart';

@Riverpod(retry: noAutomaticRetry)
Future<List<Restaurant>> restaurantList(Ref ref) async {
  final result = await ref.watch(catalogRepositoryProvider).listRestaurants();
  return switch (result) {
    ApiOk(:final value) => value,
    ApiFailure(:final error) => throw error,
  };
}
