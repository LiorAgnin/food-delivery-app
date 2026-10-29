import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/app/app.dart';
import 'package:food_delivery/application/cart.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/auth/auth.dart';
import 'package:food_delivery/domain/catalog/catalog.dart';
import 'package:food_delivery/domain/dish_finder/dish_finder.dart';
import 'package:food_delivery/domain/failures/api_error.dart';

import '../support/fake_catalog_repository.dart';
import '../support/fake_dish_finder_repository.dart';
import '../support/fixtures.dart';
import '../support/memory_session_store.dart';

const _suggestion = 'Something spicy with chicken under 60 ₪';

void main() {
  Future<ProviderContainer> openChat(
    WidgetTester tester, {
    required FakeDishFinderRepository finder,
    FakeCatalogRepository? catalog,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dishFinderRepositoryProvider.overrideWithValue(finder),
          sessionStoreProvider.overrideWithValue(
            MemorySessionStore(
              const SignedIn(
                accessToken: 'token',
                customer: Customer(id: 'c1', phone: '+972501234567'),
              ),
            ),
          ),
          catalogRepositoryProvider.overrideWithValue(
            catalog ?? FakeCatalogRepository(),
          ),
        ],
        child: const FoodDeliveryApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat_entry')));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(FoodDeliveryApp)),
    );
  }

  DishResult dish({
    required String id,
    required String name,
    required int priceAgorot,
    required bool orderable,
    bool isAvailable = true,
    bool restaurantOpen = true,
    String restaurantId = 'grill',
    String restaurantName = 'HaTachana Grill',
    List<DietaryTag> tags = const [DietaryTag.spicy],
  }) {
    return DishResult(
      menuItem: sampleItem(
        id: id,
        restaurantId: restaurantId,
        name: name,
        priceAgorot: priceAgorot,
        isAvailable: isAvailable,
        dietaryTags: tags,
      ),
      restaurant: DishRestaurant(
        id: restaurantId,
        name: restaurantName,
        cuisine: 'Grill',
        isOpen: restaurantOpen,
      ),
      orderable: orderable,
    );
  }

  testWidgets('a suggestion sends that text and renders the returned dishes', (
    tester,
  ) async {
    final skewer = dish(
      id: 'skewer',
      name: 'Spicy chicken skewer',
      priceAgorot: 4800,
      orderable: true,
    );
    final finder = FakeDishFinderRepository(
      script: [
        ApiOk(
          sampleReply(
            reply: 'Spicy chicken under 60.',
            results: [skewer],
            relaxed: const ['maxPriceAgorot'],
          ),
        ),
      ],
    );

    await openChat(tester, finder: finder);

    expect(find.text('I want a margherita pizza'), findsOneWidget);
    expect(find.text(_suggestion), findsOneWidget);
    expect(find.text('Vegan dinner, not burgers'), findsOneWidget);
    expect(
      find.text('Show me sushi from places that are open now'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('chat_suggestion_1')));
    await tester.pumpAndSettle();

    expect(finder.searches, hasLength(1));
    expect(finder.searches.single.last.role, ChatRole.user);
    expect(finder.searches.single.last.content, _suggestion);
    expect(find.byKey(const Key('chat_reply_0')), findsOneWidget);
    expect(find.text('Spicy chicken under 60.'), findsOneWidget);
    expect(find.text('Spicy chicken skewer'), findsOneWidget);
    expect(find.text('HaTachana Grill'), findsOneWidget);
    expect(find.text('₪48.00'), findsOneWidget);
    expect(find.text('Spicy'), findsOneWidget);
    expect(find.byKey(const Key('dish_close_matches')), findsOneWidget);
    expect(find.text('Close matches'), findsOneWidget);
    expect(find.byKey(const Key('chat_suggestion_1')), findsNothing);
  });

  testWidgets('a non-orderable dish is dimmed and cannot be added', (
    tester,
  ) async {
    final finder = FakeDishFinderRepository(
      script: [
        ApiOk(
          sampleReply(
            reply: 'Some of these are unavailable.',
            results: [
              dish(
                id: 'schnitzel',
                name: 'Spicy chicken schnitzel',
                priceAgorot: 5600,
                orderable: false,
                isAvailable: false,
              ),
              dish(
                id: 'sabich',
                name: 'Sabich',
                priceAgorot: 2800,
                orderable: false,
                restaurantId: 'shuk',
                restaurantName: 'Falafel HaShuk',
                restaurantOpen: false,
              ),
              dish(
                id: 'mystery',
                name: 'Secret dish',
                priceAgorot: 3900,
                orderable: false,
              ),
            ],
          ),
        ),
      ],
    );

    await openChat(tester, finder: finder);
    await tester.enterText(find.byKey(const Key('chat_input')), 'chicken');
    await tester.tap(find.byKey(const Key('chat_send')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<Opacity>(find.byKey(const Key('dish_dim_schnitzel')))
          .opacity,
      0.45,
    );
    expect(find.text('Out of stock'), findsOneWidget);
    expect(
      tester
          .widget<ButtonStyleButton>(
            find.byKey(const Key('dish_add_schnitzel')),
          )
          .onPressed,
      isNull,
    );

    expect(
      tester.widget<Opacity>(find.byKey(const Key('dish_dim_sabich'))).opacity,
      0.45,
    );
    expect(find.text('Restaurant closed'), findsOneWidget);
    expect(
      tester
          .widget<ButtonStyleButton>(find.byKey(const Key('dish_add_sabich')))
          .onPressed,
      isNull,
    );

    expect(find.text('Unavailable'), findsOneWidget);
    expect(
      tester
          .widget<ButtonStyleButton>(find.byKey(const Key('dish_add_mystery')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('a failed search can be retried without a second user message', (
    tester,
  ) async {
    final finder = FakeDishFinderRepository(
      script: [
        const ApiFailure(
          ApiError(code: ApiErrorCode.network, message: 'Offline'),
        ),
        ApiOk(sampleReply(reply: 'Recovered.')),
      ],
    );

    await openChat(tester, finder: finder);
    await tester.enterText(
      find.byKey(const Key('chat_input')),
      'cheaper ones?',
    );
    await tester.tap(find.byKey(const Key('chat_send')));
    await tester.pumpAndSettle();

    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('cheaper ones?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('chat_retry')));
    await tester.pumpAndSettle();

    expect(finder.searches, hasLength(2));
    expect(finder.searches[0].single.content, 'cheaper ones?');
    expect(finder.searches[0].single.role, ChatRole.user);
    expect(finder.searches[1].single.content, 'cheaper ones?');
    expect(find.text('cheaper ones?'), findsOneWidget);
    expect(find.text('Recovered.'), findsOneWidget);
    expect(find.text('Offline'), findsNothing);
  });

  testWidgets('the composer is disabled while a search is in flight', (
    tester,
  ) async {
    final finder = FakeDishFinderRepository(hang: true);

    await openChat(tester, finder: finder);
    await tester.enterText(find.byKey(const Key('chat_input')), 'sushi');
    await tester.tap(find.byKey(const Key('chat_send')));
    await tester.pump();

    expect(find.byKey(const Key('chat_typing')), findsOneWidget);
    expect(find.text('Finding dishes…'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byKey(const Key('chat_input'))).enabled,
      isFalse,
    );
    expect(
      tester
          .widget<ButtonStyleButton>(find.byKey(const Key('chat_send')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('view restaurant opens that restaurant menu', (tester) async {
    final skewer = dish(
      id: 'skewer',
      name: 'Spicy chicken skewer',
      priceAgorot: 4800,
      orderable: true,
    );
    final finder = FakeDishFinderRepository(
      script: [
        ApiOk(sampleReply(reply: 'One match.', results: [skewer])),
      ],
    );
    final catalog = FakeCatalogRepository(
      menu: ApiOk(
        sampleMenu(
          restaurant: sampleRestaurant(id: 'grill', name: 'HaTachana Grill'),
          items: [skewer.menuItem],
        ),
      ),
    );

    await openChat(tester, finder: finder, catalog: catalog);
    await tester.tap(find.byKey(const Key('chat_suggestion_1')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('dish_view_skewer')));
    await tester.tap(find.byKey(const Key('dish_view_skewer')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('menu_item_skewer')), findsOneWidget);
    expect(find.text('HaTachana Grill'), findsWidgets);
  });

  testWidgets('add to cart shows a view-cart snackbar', (tester) async {
    final skewer = dish(
      id: 'skewer',
      name: 'Spicy chicken skewer',
      priceAgorot: 4800,
      orderable: true,
    );
    final grill = sampleRestaurant(id: 'grill', name: 'HaTachana Grill');
    final finder = FakeDishFinderRepository(
      script: [
        ApiOk(sampleReply(reply: 'One match.', results: [skewer])),
      ],
    );
    final catalog = FakeCatalogRepository(
      menu: ApiOk(sampleMenu(restaurant: grill, items: [skewer.menuItem])),
    );

    final container = await openChat(tester, finder: finder, catalog: catalog);
    await tester.tap(find.byKey(const Key('chat_suggestion_1')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('dish_add_skewer')));
    await tester.tap(find.byKey(const Key('dish_add_skewer')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.text('View cart'), findsOneWidget);
    expect(container.read(cartProvider).restaurant?.id, 'grill');
    expect(container.read(cartProvider).lines.single.item.id, 'skewer');
    expect(container.read(cartProvider).lines.single.quantity, 1);
    final badgeCounts = tester
        .widgetList<Text>(find.byKey(const Key('cart_badge_count')))
        .map((text) => text.data)
        .toList();
    expect(badgeCounts, ['1']);

    await tester.tap(find.text('View cart'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cart_line_skewer')), findsOneWidget);
  });

  testWidgets('adding from another restaurant asks to start a new cart', (
    tester,
  ) async {
    final skewer = dish(
      id: 'skewer',
      name: 'Spicy chicken skewer',
      priceAgorot: 4800,
      orderable: true,
    );
    final grill = sampleRestaurant(id: 'grill', name: 'HaTachana Grill');
    final finder = FakeDishFinderRepository(
      script: [
        ApiOk(sampleReply(reply: 'One match.', results: [skewer])),
      ],
    );
    final catalog = FakeCatalogRepository(
      menu: ApiOk(sampleMenu(restaurant: grill, items: [skewer.menuItem])),
    );

    final container = await openChat(tester, finder: finder, catalog: catalog);
    await tester.tap(find.byKey(const Key('chat_suggestion_1')));
    await tester.pumpAndSettle();

    final elsewhere = sampleRestaurant(id: 'r2', name: 'Pizza Dan');
    final seeded = container
        .read(cartProvider.notifier)
        .add(
          sampleItem(id: 'slice', restaurantId: 'r2', name: 'Slice'),
          elsewhere,
        );
    expect(seeded, isA<AddToCartAdded>());

    await tester.ensureVisible(find.byKey(const Key('dish_add_skewer')));
    await tester.tap(find.byKey(const Key('dish_add_skewer')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cart_conflict_dialog')), findsOneWidget);
    expect(find.text('Start a new cart?'), findsOneWidget);
    expect(
      find.text(
        'Your cart has items from Pizza Dan. Starting a new cart clears them.',
      ),
      findsOneWidget,
    );
    expect(container.read(cartProvider).restaurant?.id, 'r2');

    await tester.tap(find.byKey(const Key('cart_conflict_confirm')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(container.read(cartProvider).restaurant?.id, 'grill');
    expect(container.read(cartProvider).lines.single.item.id, 'skewer');
    expect(find.text('View cart'), findsOneWidget);
  });
}
