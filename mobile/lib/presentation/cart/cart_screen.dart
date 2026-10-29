import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/cart.dart';
import '../../application/checkout.dart';
import '../format/agorot_format.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);
    ref.listen(checkoutProvider, (previous, next) {
      if (next case CheckoutPlaced(:final orderId)) {
        context.go('/orders/$orderId');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.lines.isEmpty
          ? const _EmptyCart()
          : _CartBody(cart: cart, checkout: checkout),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('cart_empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Your cart is empty'),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('cart_browse_restaurants'),
            onPressed: () => context.go('/restaurants'),
            child: const Text('Browse restaurants'),
          ),
        ],
      ),
    );
  }
}

class _CartBody extends ConsumerWidget {
  const _CartBody({required this.cart, required this.checkout});

  final CartState cart;
  final CheckoutState checkout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = checkout;
    final submitting = status is CheckoutSubmitting;
    final canPlace = cart.meetsMinimum && !submitting;
    final theme = Theme.of(context);
    final restaurant = cart.restaurant!;
    final unavailable = switch (status) {
      CheckoutFailed(:final unavailableMenuItemIds) => unavailableMenuItemIds,
      _ => const <String>[],
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          restaurant.name,
          key: const Key('cart_restaurant'),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        for (final line in cart.lines)
          _CartLineTile(
            line: line,
            enabled: !submitting,
            unavailable: unavailable.contains(line.item.id),
          ),
        const Divider(),
        _MoneyRow(
          label: 'Subtotal',
          amountKey: 'cart_subtotal',
          agorot: cart.subtotalAgorot,
        ),
        _MoneyRow(
          label: 'Delivery',
          amountKey: 'cart_delivery_fee',
          agorot: cart.deliveryFeeAgorot,
        ),
        _MoneyRow(
          label: 'Total',
          amountKey: 'cart_total',
          agorot: cart.totalAgorot,
        ),
        if (cart.missingForMinimumAgorot > 0) ...[
          const SizedBox(height: 12),
          Material(
            key: const Key('cart_minimum_banner'),
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Add ${formatAgorot(cart.missingForMinimumAgorot)} more to '
                'reach the ${formatAgorot(restaurant.minOrderAgorot)} minimum',
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ),
        ],
        if (status case CheckoutFailed(
          :final message,
          :final unavailableMenuItemIds,
        )) ...[
          const SizedBox(height: 12),
          Text(message, key: const Key('cart_checkout_error')),
          if (status.canRetry)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('cart_checkout_retry'),
                onPressed: () =>
                    unawaited(ref.read(checkoutProvider.notifier).place()),
                child: const Text('Retry'),
              ),
            ),
          if (unavailableMenuItemIds.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('cart_remove_unavailable'),
                onPressed: () {
                  final notifier = ref.read(cartProvider.notifier);
                  for (final id in unavailableMenuItemIds) {
                    notifier.remove(id);
                  }
                },
                child: const Text('Remove unavailable items'),
              ),
            ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('cart_place_order'),
          onPressed: canPlace
              ? () => unawaited(ref.read(checkoutProvider.notifier).place())
              : null,
          child: submitting
              ? const SizedBox(
                  key: Key('cart_place_order_spinner'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Place order'),
        ),
      ],
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.amountKey,
    required this.agorot,
  });

  final String label;
  final String amountKey;
  final int agorot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(formatAgorot(agorot), key: Key(amountKey)),
        ],
      ),
    );
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({
    required this.line,
    required this.enabled,
    required this.unavailable,
  });

  final CartLine line;
  final bool enabled;
  final bool unavailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = line.item.id;
    return Padding(
      key: Key('cart_line_$id'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.item.name),
                Text(formatAgorot(line.item.priceAgorot)),
                if (unavailable)
                  Text('Unavailable', key: Key('cart_line_unavailable_$id')),
              ],
            ),
          ),
          IconButton(
            key: Key('cart_decrement_$id'),
            tooltip: 'Remove one',
            onPressed: enabled
                ? () => ref.read(cartProvider.notifier).decrement(id)
                : null,
            icon: const Icon(Icons.remove),
          ),
          Text('${line.quantity}', key: Key('cart_quantity_$id')),
          IconButton(
            key: Key('cart_increment_$id'),
            tooltip: 'Add one',
            onPressed: enabled && line.quantity < maxCartLineQuantity
                ? () => ref.read(cartProvider.notifier).increment(id)
                : null,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            key: Key('cart_remove_$id'),
            tooltip: 'Remove ${line.item.name}',
            onPressed: enabled
                ? () => ref.read(cartProvider.notifier).remove(id)
                : null,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
