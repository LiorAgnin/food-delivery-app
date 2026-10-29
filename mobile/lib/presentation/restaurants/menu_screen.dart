import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/cart.dart';
import '../../application/restaurant_menu.dart';
import '../../domain/catalog/catalog.dart';
import '../../domain/failures/api_error.dart';
import '../format/agorot_format.dart';
import '../widgets/cart_badge_button.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({required this.restaurantId, super.key});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(restaurantMenuProvider(restaurantId));
    final title = async.asData?.value.restaurant.name ?? 'Menu';
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: const [CartBadgeButton()]),
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const Center(
          key: Key('menu_loading'),
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => _MenuMessage(
          onRefresh: () => _reload(ref),
          child: Column(
            key: const Key('menu_error'),
            children: [
              Text(_message(error), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('menu_retry'),
                onPressed: () =>
                    ref.invalidate(restaurantMenuProvider(restaurantId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (menu) => _RefreshableMenu(
          onRefresh: () => _reload(ref),
          child: _MenuList(menu: menu),
        ),
      ),
    );
  }

  Future<void> _reload(WidgetRef ref) async {
    ref.invalidate(restaurantMenuProvider(restaurantId));
    try {
      await ref.read(restaurantMenuProvider(restaurantId).future);
    } on Object {
      // The body paints the error.
    }
  }

  String _message(Object error) {
    if (error is ApiError) return error.message;
    return 'Something went wrong';
  }
}

class _RefreshableMenu extends StatelessWidget {
  const _RefreshableMenu({required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }
}

class _MenuMessage extends StatelessWidget {
  const _MenuMessage({required this.child, this.onRefresh});

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [Padding(padding: const EdgeInsets.all(24), child: child)],
    );
    final refresh = onRefresh;
    if (refresh == null) return list;
    return RefreshIndicator(onRefresh: refresh, child: list);
  }
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.menu});

  final RestaurantMenu menu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (!menu.restaurant.isOpen)
          Material(
            key: const Key('menu_closed_banner'),
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'This restaurant is closed. You can look at the menu, '
                'but adding is disabled.',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ),
        if (menu.categories.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No dishes yet',
              key: Key('menu_empty'),
              textAlign: TextAlign.center,
            ),
          ),
        for (final category in menu.categories) ...[
          Padding(
            key: Key('menu_category_${category.id}'),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(category.name, style: theme.textTheme.titleMedium),
          ),
          for (final item in category.items)
            _MenuItemTile(item: item, restaurant: menu.restaurant),
        ],
      ],
    );
  }
}

class _MenuItemTile extends ConsumerWidget {
  const _MenuItemTile({required this.item, required this.restaurant});

  final MenuItem item;
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(
      cartProvider.select((state) {
        for (final line in state.lines) {
          if (line.item.id == item.id) return line.quantity;
        }
        return 0;
      }),
    );
    final theme = Theme.of(context);
    return Opacity(
      opacity: item.isAvailable ? 1 : 0.5,
      child: Padding(
        key: Key('menu_item_${item.id}'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.titleSmall),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(item.description),
                  ],
                  const SizedBox(height: 4),
                  Text(formatAgorot(item.priceAgorot)),
                  if (item.dietaryTags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final tag in item.dietaryTags)
                          Chip(
                            key: Key('menu_tag_${item.id}_${tag.name}'),
                            label: Text(dietaryTagLabel(tag)),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ],
                  if (!item.isAvailable) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Out of stock',
                      key: Key('menu_out_of_stock_${item.id}'),
                    ),
                  ],
                ],
              ),
            ),
            _ItemAction(item: item, restaurant: restaurant, quantity: quantity),
          ],
        ),
      ),
    );
  }
}

class _ItemAction extends ConsumerWidget {
  const _ItemAction({
    required this.item,
    required this.restaurant,
    required this.quantity,
  });

  final MenuItem item;
  final Restaurant restaurant;
  final int quantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!item.isAvailable && quantity == 0) return const SizedBox.shrink();

    final canIncrease =
        restaurant.isOpen && item.isAvailable && quantity < maxCartLineQuantity;

    if (quantity == 0) {
      return IconButton(
        key: Key('menu_add_${item.id}'),
        tooltip: 'Add ${item.name}',
        onPressed: canIncrease ? () => _add(context, ref) : null,
        icon: const Icon(Icons.add),
      );
    }

    return Row(
      key: Key('menu_stepper_${item.id}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: Key('menu_decrement_${item.id}'),
          tooltip: 'Remove one',
          onPressed: () => ref.read(cartProvider.notifier).decrement(item.id),
          icon: const Icon(Icons.remove),
        ),
        Text('$quantity', key: Key('menu_quantity_${item.id}')),
        IconButton(
          key: Key('menu_increment_${item.id}'),
          tooltip: 'Add one',
          onPressed: canIncrease
              ? () => ref.read(cartProvider.notifier).increment(item.id)
              : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _add(BuildContext context, WidgetRef ref) {
    final result = ref.read(cartProvider.notifier).add(item, restaurant);
    if (result is! AddToCartConflict) return;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            key: const Key('cart_conflict_dialog'),
            title: const Text('Start a new cart?'),
            content: Text(
              'Your cart has items from ${result.currentRestaurant.name}. '
              'Starting a new cart clears them.',
            ),
            actions: [
              TextButton(
                key: const Key('cart_conflict_cancel'),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                key: const Key('cart_conflict_confirm'),
                onPressed: () {
                  ref.read(cartProvider.notifier).replaceWith(item, restaurant);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Start a new cart'),
              ),
            ],
          );
        },
      ),
    );
  }
}
