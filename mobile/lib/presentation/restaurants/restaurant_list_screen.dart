import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth_session.dart';
import '../../application/restaurant_list.dart';
import '../../domain/catalog/catalog.dart';
import '../../domain/failures/api_error.dart';
import '../format/agorot_format.dart';
import '../widgets/cart_badge_button.dart';

class RestaurantListScreen extends ConsumerWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(restaurantListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            key: const Key('chat_entry'),
            tooltip: 'Dish finder',
            onPressed: () => context.push('/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          const CartBadgeButton(),
          PopupMenuButton<String>(
            key: const Key('restaurant_overflow'),
            tooltip: 'Account',
            onSelected: (value) {
              if (value == 'sign_out') {
                unawaited(ref.read(authSessionProvider.notifier).signOut());
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                key: Key('sign_out'),
                value: 'sign_out',
                child: Text('Sign out'),
              ),
            ],
          ),
        ],
      ),
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const Center(
          key: Key('restaurant_list_loading'),
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => _Refreshable(
          onRefresh: () => _reload(ref),
          child: _ErrorBody(
            message: _message(error),
            onRetry: () => ref.invalidate(restaurantListProvider),
          ),
        ),
        data: (restaurants) => _Refreshable(
          onRefresh: () => _reload(ref),
          child: restaurants.isEmpty
              ? const _EmptyBody()
              : _RestaurantList(restaurants: restaurants),
        ),
      ),
    );
  }

  Future<void> _reload(WidgetRef ref) async {
    ref.invalidate(restaurantListProvider);
    try {
      await ref.read(restaurantListProvider.future);
    } on Object {
      // The body paints the error.
    }
  }

  String _message(Object error) {
    if (error is ApiError) return error.message;
    return 'Something went wrong';
  }
}

class _Refreshable extends StatelessWidget {
  const _Refreshable({required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            key: const Key('restaurant_list_error'),
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('restaurant_list_retry'),
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No restaurants yet',
            key: Key('restaurant_list_empty'),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _RestaurantList extends StatelessWidget {
  const _RestaurantList({required this.restaurants});

  final List<Restaurant> restaurants;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: restaurants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) =>
          _RestaurantCard(restaurant: restaurants[index]),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final open = restaurant.isOpen;
    final theme = Theme.of(context);
    return Opacity(
      key: Key('restaurant_dim_${restaurant.id}'),
      opacity: open ? 1 : 0.45,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: InkWell(
          key: Key('restaurant_card_${restaurant.id}'),
          onTap: () => context.push('/restaurants/${restaurant.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurant.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(restaurant.cuisine),
                      const SizedBox(height: 4),
                      Text(
                        'Delivery ${formatAgorot(restaurant.deliveryFeeAgorot)}'
                        ' · Min ${formatAgorot(restaurant.minOrderAgorot)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  key: Key(
                    open
                        ? 'restaurant_open_badge_${restaurant.id}'
                        : 'restaurant_closed_badge_${restaurant.id}',
                  ),
                  label: Text(open ? 'Open' : 'Closed'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
