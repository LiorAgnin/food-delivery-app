import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/cart.dart';

class CartBadgeButton extends ConsumerWidget {
  const CartBadgeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartProvider.select((state) => state.itemCount));
    return IconButton(
      key: const Key('cart_badge'),
      tooltip: 'Cart',
      onPressed: () => context.push('/cart'),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count', key: const Key('cart_badge_count')),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}
