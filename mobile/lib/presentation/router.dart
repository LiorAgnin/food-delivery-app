import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../application/auth_session.dart';
import '../domain/auth/auth.dart';
import 'placeholder_screen.dart';
import 'restaurants/menu_screen.dart';
import 'restaurants/restaurant_list_screen.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authSessionProvider, (_, _) {
    refresh.value++;
  });

  final router = GoRouter(
    initialLocation: ref.read(authSessionProvider) is SignedIn
        ? '/restaurants'
        : '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(authSessionProvider) is SignedIn;
      final atLogin = state.uri.path == '/login';
      if (!signedIn) return atLogin ? null : '/login';
      if (atLogin) return '/restaurants';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const PlaceholderScreen(label: 'TODO(owner): login'),
      ),
      GoRoute(
        path: '/restaurants',
        builder: (context, state) => const RestaurantListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                MenuScreen(restaurantId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) =>
            const PlaceholderScreen(label: 'TODO(owner): cart'),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) => PlaceholderScreen(
          label: 'TODO(owner): order ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) =>
            const PlaceholderScreen(label: 'TODO(owner): chat'),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
}
