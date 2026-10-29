import 'package:flutter_riverpod/misc.dart';
import 'package:http/http.dart' as http;

import '../application/auth_session.dart';
import '../application/ports.dart';
import '../domain/auth/auth.dart';
import 'api_base_url.dart';
import 'api_client.dart';
import 'auth/http_auth_repository.dart';
import 'catalog/http_catalog_repository.dart';
import 'dish_finder/http_dish_finder_repository.dart';
import 'orders/http_orders_repository.dart';

/// Binds the HTTP adapters. [httpClient] is for tests; production leaves it
/// null and this closes the client with the provider. Bootstrap never names
/// an `http` type — it calls this with no arguments.
List<Override> dataPlaneBindings({http.Client? httpClient, String? baseUrl}) {
  return [
    apiClientProvider.overrideWith((ref) {
      final client = httpClient ?? http.Client();
      if (httpClient == null) ref.onDispose(client.close);
      return ApiClient(
        httpClient: client,
        baseUrl: baseUrl ?? resolveApiBaseUrl(),
        readToken: () {
          return switch (ref.read(authSessionProvider)) {
            SignedIn(:final accessToken) => accessToken,
            SignedOut() => null,
          };
        },
        onUnauthorized: (sentToken) {
          return ref
              .read(authSessionProvider.notifier)
              .clearOnUnauthorized(sentToken);
        },
      );
    }),
    catalogRepositoryProvider.overrideWith(
      (ref) => HttpCatalogRepository(ref.watch(apiClientProvider)),
    ),
    ordersRepositoryProvider.overrideWith(
      (ref) => HttpOrdersRepository(ref.watch(apiClientProvider)),
    ),
    authRepositoryProvider.overrideWith(
      (ref) => HttpAuthRepository(ref.watch(apiClientProvider)),
    ),
    dishFinderRepositoryProvider.overrideWith(
      (ref) => HttpDishFinderRepository(ref.watch(apiClientProvider)),
    ),
  ];
}
