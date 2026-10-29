import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/data/api_client.dart';
import 'package:food_delivery/data/auth/http_auth_repository.dart';
import 'package:food_delivery/data/catalog/http_catalog_repository.dart';
import 'package:food_delivery/data/dish_finder/http_dish_finder_repository.dart';
import 'package:food_delivery/data/orders/http_orders_repository.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/catalog/catalog.dart';
import 'package:food_delivery/domain/dish_finder/dish_finder.dart';
import 'package:food_delivery/domain/failures/api_error.dart';
import 'package:food_delivery/domain/orders/order.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late http.Request last;

  ApiClient api(String body, {int status = 200}) {
    return ApiClient(
      httpClient: MockClient((request) async {
        last = request;
        return http.Response(body, status);
      }),
      baseUrl: 'http://localhost:3000/api',
      readToken: () => 'token',
    );
  }

  test('listRestaurants and getMenu map the contract', () async {
    const listBody = '''
{
  "restaurants": [
    {
      "id": "r1",
      "name": "Shawarma Gil",
      "cuisine": "Israeli",
      "address": "1 Herzl, Tel Aviv",
      "isOpen": false,
      "openingHours": [
        {"dayOfWeek": 0, "opensAt": "10:00", "closesAt": "02:00"}
      ],
      "minOrderAgorot": 4000,
      "deliveryFeeAgorot": 1500
    }
  ]
}
''';
    final catalog = HttpCatalogRepository(api(listBody));
    final listed = await catalog.listRestaurants();
    expect(last.url.path, '/api/restaurants');
    expect(listed, isA<ApiOk<List<Restaurant>>>());
    final restaurant = (listed as ApiOk<List<Restaurant>>).value.single;
    expect(restaurant.isOpen, isFalse);
    expect(restaurant.openingHours.single.closesAt, '02:00');
    expect(restaurant.minOrderAgorot, 4000);

    const menuBody = '''
{
  "restaurant": {
    "id": "r1",
    "name": "Shawarma Gil",
    "cuisine": "Israeli",
    "address": "1 Herzl, Tel Aviv",
    "isOpen": true,
    "openingHours": [],
    "minOrderAgorot": 4000,
    "deliveryFeeAgorot": 1500
  },
  "categories": [
    {
      "id": "c1",
      "name": "Mains",
      "items": [
        {
          "id": "i1",
          "restaurantId": "r1",
          "categoryId": "c1",
          "name": "Pita",
          "description": "Lamb",
          "priceAgorot": 4200,
          "dietaryTags": ["gluten_free", "spicy"],
          "isAvailable": false
        }
      ]
    }
  ]
}
''';
    final menuResult = await HttpCatalogRepository(api(menuBody)).getMenu('r1');
    expect(last.url.path, '/api/restaurants/r1/menu');
    final menu = (menuResult as ApiOk<RestaurantMenu>).value;
    final item = menu.categories.single.items.single;
    expect(item.dietaryTags, [DietaryTag.glutenFree, DietaryTag.spicy]);
    expect(item.isAvailable, isFalse);
    expect(item.priceAgorot, 4200);
  });

  test('an unknown dietary tag is malformed', () async {
    const menuBody = '''
{
  "restaurant": {
    "id": "r1", "name": "A", "cuisine": "B", "address": "C",
    "isOpen": true, "openingHours": [],
    "minOrderAgorot": 0, "deliveryFeeAgorot": 0
  },
  "categories": [
    {
      "id": "c1", "name": "Mains",
      "items": [
        {
          "id": "i1", "restaurantId": "r1", "categoryId": "c1",
          "name": "Pita", "description": "", "priceAgorot": 100,
          "dietaryTags": ["keto"], "isAvailable": true
        }
      ]
    }
  ]
}
''';
    final result = await HttpCatalogRepository(api(menuBody)).getMenu('r1');
    expect(result, isA<ApiFailure<RestaurantMenu>>());
    expect(
      (result as ApiFailure<RestaurantMenu>).error.code,
      ApiErrorCode.malformed,
    );
  });

  test(
    'placeOrder sends the idempotency key and snapshots the order',
    () async {
      const orderBody = '''
{
  "id": "o1",
  "status": "PLACED",
  "restaurant": {"id": "r1", "name": "Shawarma Gil"},
  "items": [
    {
      "menuItemId": "i1",
      "name": "Pita",
      "unitPriceAgorot": 4200,
      "quantity": 2,
      "lineTotalAgorot": 8400
    }
  ],
  "subtotalAgorot": 8400,
  "deliveryFeeAgorot": 1500,
  "totalAgorot": 9900,
  "statusHistory": [
    {
      "from": null,
      "to": "PLACED",
      "actor": "customer",
      "at": "2026-04-01T12:00:00Z"
    }
  ],
  "createdAt": "2026-04-01T12:00:00Z",
  "updatedAt": "2026-04-01T12:00:00Z"
}
''';
      final orders = HttpOrdersRepository(api(orderBody, status: 201));
      final result = await orders.placeOrder(
        restaurantId: 'r1',
        lines: const [OrderDraftLine(menuItemId: 'i1', quantity: 2)],
        idempotencyKey: 'idem-1',
      );

      expect(last.method, 'POST');
      expect(last.url.path, '/api/orders');
      expect(last.headers['idempotency-key'], 'idem-1');
      expect(jsonDecode(last.body), {
        'restaurantId': 'r1',
        'items': [
          {'menuItemId': 'i1', 'quantity': 2},
        ],
      });

      final order = (result as ApiOk<Order>).value;
      expect(order.status, OrderStatus.placed);
      expect(order.status.isTerminal, isFalse);
      expect(order.restaurantName, 'Shawarma Gil');
      expect(order.items.single.lineTotalAgorot, 8400);
      expect(order.statusHistory.single.from, isNull);
      expect(order.statusHistory.single.actor, Actor.customer);
      expect(order.createdAt.isUtc, isTrue);

      final fetched = await HttpOrdersRepository(api(orderBody))
          .getOrder('o 1');
      expect(last.url.path, '/api/orders/o%201');
      expect((fetched as ApiOk<Order>).value.id, 'o1');
    },
  );

  test('auth maps the dev code and the verified customer', () async {
    final auth = HttpAuthRepository(
      api('{"expiresInSeconds":300,"devCode":"123456"}', status: 202),
    );
    final requested = await auth.requestOtp('+972501234567');
    expect(last.url.path, '/api/auth/otp/request');
    expect(jsonDecode(last.body), {'phone': '+972501234567'});
    final challenge = (requested as ApiOk).value;
    expect(challenge.expiresInSeconds, 300);
    expect(challenge.devCode, '123456');

    final verifiedApi = HttpAuthRepository(
      api(
        '{"accessToken":"jwt","customer":{"id":"c1","phone":"+972501234567"}}',
      ),
    );
    final verified = await verifiedApi.verifyOtp(
      phone: '+972501234567',
      code: '123456',
    );
    expect(last.url.path, '/api/auth/otp/verify');
    final session = (verified as ApiOk).value;
    expect(session.accessToken, 'jwt');
    expect(session.customer.phone, '+972501234567');
  });

  test('dish finder sends the whole conversation', () async {
    const body = '''
{
  "reply": "Try the pita.",
  "results": [
    {
      "menuItem": {
        "id": "i1",
        "restaurantId": "r1",
        "categoryId": "c1",
        "name": "Pita",
        "description": "Lamb",
        "priceAgorot": 4200,
        "dietaryTags": ["spicy"],
        "isAvailable": true
      },
      "restaurant": {
        "id": "r1",
        "name": "Shawarma Gil",
        "cuisine": "Israeli",
        "isOpen": true
      },
      "orderable": true
    }
  ],
  "intent": {
    "keywords": ["chicken"],
    "excludeKeywords": [],
    "cuisines": [],
    "includeTags": ["spicy"],
    "excludeTags": [],
    "maxPriceAgorot": 6000,
    "openNowOnly": false,
    "sort": "price_asc"
  },
  "relaxed": ["maxPriceAgorot"]
}
''';
    final finder = HttpDishFinderRepository(api(body));
    final result = await finder.search(const [
      ChatMessage(role: ChatRole.user, content: 'something spicy'),
      ChatMessage(role: ChatRole.assistant, content: 'How about shawarma?'),
      ChatMessage(role: ChatRole.user, content: 'cheaper ones?'),
    ]);

    expect(jsonDecode(last.body), {
      'messages': [
        {'role': 'user', 'content': 'something spicy'},
        {'role': 'assistant', 'content': 'How about shawarma?'},
        {'role': 'user', 'content': 'cheaper ones?'},
      ],
    });
    final reply = (result as ApiOk<DishFinderReply>).value;
    expect(reply.reply, 'Try the pita.');
    expect(reply.results.single.orderable, isTrue);
    expect(reply.results.single.menuItem.dietaryTags, [DietaryTag.spicy]);
    expect(reply.intent.sort, SearchSort.priceAsc);
    expect(reply.intent.maxPriceAgorot, 6000);
    expect(reply.relaxed, ['maxPriceAgorot']);
  });
}
