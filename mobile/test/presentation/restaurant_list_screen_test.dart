import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/app/app.dart';
import 'package:food_delivery/application/cart.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/auth/auth.dart';
import 'package:food_delivery/domain/failures/api_error.dart';
import 'package:food_delivery/presentation/restaurants/restaurant_list_screen.dart';
import 'package:go_router/go_router.dart';

import '../support/fake_catalog_repository.dart';
import '../support/fixtures.dart';
import '../support/memory_session_store.dart';

void main() {
  Widget harness(FakeCatalogRepository catalog) {
    return ProviderScope(
      overrides: [catalogRepositoryProvider.overrideWithValue(catalog)],
      child: const MaterialApp(home: RestaurantListScreen()),
    );
  }

  testWidgets('shows a loading indicator until the list arrives', (
    tester,
  ) async {
    await tester.pumpWidget(harness(FakeCatalogRepository(hangList: true)));
    expect(find.byKey(const Key('restaurant_list_loading')), findsOneWidget);
  });

  testWidgets('shows an empty state', (tester) async {
    await tester.pumpWidget(harness(FakeCatalogRepository()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('restaurant_list_empty')), findsOneWidget);
    expect(find.text('No restaurants yet'), findsOneWidget);
  });

  testWidgets('shows the error and retries into the list', (tester) async {
    final open = sampleRestaurant();
    final catalog = FakeCatalogRepository(
      listResults: [
        const ApiFailure(
          ApiError(code: ApiErrorCode.network, message: 'Offline'),
        ),
        ApiOk([open]),
      ],
    );

    await tester.pumpWidget(harness(catalog));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('restaurant_list_error')), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);

    await tester.tap(find.byKey(const Key('restaurant_list_retry')));
    await tester.pumpAndSettle();

    expect(catalog.listCalls, 2);
    expect(find.text('Shawarma Gil'), findsOneWidget);
    expect(find.text('Israeli'), findsOneWidget);
    expect(find.textContaining('₪15.00'), findsOneWidget);
    expect(find.textContaining('₪40.00'), findsOneWidget);
    expect(find.byKey(const Key('restaurant_open_badge_r1')), findsOneWidget);
    expect(find.byKey(const Key('restaurant_list_error')), findsNothing);
  });

  testWidgets('retry shows loading and does not stack another request', (
    tester,
  ) async {
    final catalog = FakeCatalogRepository(
      listResults: [
        const ApiFailure(
          ApiError(code: ApiErrorCode.network, message: 'Offline'),
        ),
        ApiOk([sampleRestaurant()]),
      ],
    );

    await tester.pumpWidget(harness(catalog));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('restaurant_list_retry')), findsOneWidget);

    catalog.holdNextList();
    await tester.tap(find.byKey(const Key('restaurant_list_retry')));
    await tester.pump();

    expect(catalog.listCalls, 2);
    expect(find.byKey(const Key('restaurant_list_loading')), findsOneWidget);
    expect(find.byKey(const Key('restaurant_list_error')), findsNothing);
    expect(find.byKey(const Key('restaurant_list_retry')), findsNothing);

    catalog.releaseList();
    await tester.pumpAndSettle();

    expect(find.text('Shawarma Gil'), findsOneWidget);
    expect(catalog.listCalls, 2);
  });

  testWidgets('the cart badge sums quantities, not lines', (tester) async {
    final catalog = FakeCatalogRepository(
      listResults: [
        ApiOk([sampleRestaurant()]),
      ],
    );
    await tester.pumpWidget(harness(catalog));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(RestaurantListScreen)),
    );
    final restaurant = sampleRestaurant();
    container.read(cartProvider.notifier).add(sampleItem(), restaurant);
    container.read(cartProvider.notifier).add(sampleItem(), restaurant);
    container
        .read(cartProvider.notifier)
        .add(sampleItem(id: 'i2', name: 'Fries'), restaurant);
    await tester.pump();

    expect(
      tester.widget<Text>(find.byKey(const Key('cart_badge_count'))).data,
      '3',
    );
  });

  testWidgets('pull to refresh fetches the list again', (tester) async {
    final catalog = FakeCatalogRepository(
      listResults: [
        ApiOk([sampleRestaurant(name: 'Shawarma Gil')]),
        ApiOk([sampleRestaurant(id: 'r2', name: 'Pizza Dan')]),
      ],
    );
    await tester.pumpWidget(harness(catalog));
    await tester.pumpAndSettle();
    expect(find.text('Shawarma Gil'), findsOneWidget);
    expect(catalog.listCalls, 1);

    catalog.holdNextList();
    await tester.fling(find.text('Shawarma Gil'), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(catalog.listCalls, 2);
    expect(find.text('Shawarma Gil'), findsOneWidget);
    expect(find.byKey(const Key('restaurant_list_loading')), findsNothing);

    catalog.releaseList();
    await tester.pumpAndSettle();
    expect(find.text('Pizza Dan'), findsOneWidget);
    expect(find.text('Shawarma Gil'), findsNothing);
  });

  testWidgets('dims a closed restaurant, badges it, and still opens the menu', (
    tester,
  ) async {
    final closed = sampleRestaurant(
      id: 'closed',
      name: 'Night Bakery',
      isOpen: false,
    );
    final catalog = FakeCatalogRepository(
      listResults: [
        ApiOk([closed]),
      ],
    );

    final router = GoRouter(
      initialLocation: '/restaurants',
      routes: [
        GoRoute(
          path: '/restaurants',
          builder: (context, state) => const RestaurantListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  Text('menu ${state.pathParameters['id']}'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [catalogRepositoryProvider.overrideWithValue(catalog)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('restaurant_closed_badge_closed')),
      findsOneWidget,
    );
    expect(find.text('Closed'), findsOneWidget);
    final dim = tester.widget<Opacity>(
      find.byKey(const Key('restaurant_dim_closed')),
    );
    expect(dim.opacity, lessThan(1));

    await tester.tap(find.byKey(const Key('restaurant_card_closed')));
    await tester.pumpAndSettle();
    expect(find.text('menu closed'), findsOneWidget);
  });

  testWidgets('the cart badge and chat entry are on the list', (tester) async {
    final router = GoRouter(
      initialLocation: '/restaurants',
      routes: [
        GoRoute(
          path: '/restaurants',
          builder: (context, state) => const RestaurantListScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const Text('TODO(owner): chat'),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const Text('TODO(owner): cart'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('chat_entry')));
    await tester.pumpAndSettle();
    expect(find.text('TODO(owner): chat'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cart_badge')));
    await tester.pumpAndSettle();
    expect(find.text('TODO(owner): cart'), findsOneWidget);
  });

  testWidgets('signed-out users land on login, signed-in users on the list', (
    tester,
  ) async {
    Future<void> pump(AuthSessionState session) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionStoreProvider.overrideWithValue(MemorySessionStore(session)),
            catalogRepositoryProvider.overrideWithValue(
              FakeCatalogRepository(),
            ),
          ],
          child: const FoodDeliveryApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pump(const SignedOut());
    expect(find.text('TODO(owner): login'), findsOneWidget);

    await pump(
      const SignedIn(
        accessToken: 'token',
        customer: Customer(id: 'c1', phone: '+972501234567'),
      ),
    );
    expect(find.byKey(const Key('restaurant_list_empty')), findsOneWidget);
    expect(find.text('TODO(owner): login'), findsNothing);
  });
}
