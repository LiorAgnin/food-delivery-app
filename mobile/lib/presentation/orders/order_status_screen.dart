import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/order_tracker.dart';
import '../../domain/failures/api_error.dart';
import '../../domain/orders/order.dart';
import '../format/agorot_format.dart';

/// `18:05` in UTC. Status history instants are absolute, and tests pin them
/// with `DateTime.utc`, so the label does not depend on the host timezone.
String formatStatusTime(DateTime at) {
  final utc = at.toUtc();
  final hour = utc.hour.toString().padLeft(2, '0');
  final minute = utc.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class OrderStatusScreen extends ConsumerWidget {
  const OrderStatusScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = ref.watch(orderTrackerProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: const Text('Order')),
      body: switch (tracker) {
        OrderTrackerLoading() => const Center(
          key: Key('order_loading'),
          child: CircularProgressIndicator(),
        ),
        OrderTrackerFailed(:final error) => _OrderError(
          orderId: orderId,
          error: error,
        ),
        OrderTrackerReady(:final order, :final reconnecting) => _OrderBody(
          order: order,
          reconnecting: reconnecting,
        ),
      },
    );
  }
}

class _OrderError extends ConsumerWidget {
  const _OrderError({required this.orderId, required this.error});

  final String orderId;
  final ApiError error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            key: const Key('order_error'),
            children: [
              Text(error.message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('order_retry'),
                onPressed: () => unawaited(
                  ref.read(orderTrackerProvider(orderId).notifier).retry(),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({required this.order, required this.reconnecting});

  final Order order;
  final bool reconnecting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (reconnecting)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              key: const Key('order_reconnecting'),
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Reconnecting…'),
              ),
            ),
          ),
        Text(
          order.restaurantName,
          key: const Key('order_restaurant'),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(order.id, key: const Key('order_id')),
        const SizedBox(height: 16),
        if (order.status == OrderStatus.cancelled)
          _Cancelled(order: order)
        else
          _Stepper(order: order),
        const Divider(height: 32),
        for (final line in order.items) ...[
          Text('${line.name} × ${line.quantity}'),
          Text(formatAgorot(line.lineTotalAgorot)),
          const SizedBox(height: 8),
        ],
        _MoneyRow(
          label: 'Subtotal',
          agorot: order.subtotalAgorot,
          amountKey: 'order_subtotal',
        ),
        _MoneyRow(
          label: 'Delivery',
          agorot: order.deliveryFeeAgorot,
          amountKey: 'order_delivery_fee',
        ),
        _MoneyRow(
          label: 'Total',
          agorot: order.totalAgorot,
          amountKey: 'order_total',
        ),
      ],
    );
  }
}

class _Cancelled extends StatelessWidget {
  const _Cancelled({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final at = _timeOf(order, OrderStatus.cancelled);
    return Material(
      key: const Key('order_cancelled'),
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancelled',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            if (at != null)
              Text(
                formatStatusTime(at),
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.order});

  final Order order;

  static const _steps = <(OrderStatus, String)>[
    (OrderStatus.placed, 'Placed'),
    (OrderStatus.accepted, 'Accepted'),
    (OrderStatus.preparing, 'Preparing'),
    (OrderStatus.pickedUp, 'Picked up'),
    (OrderStatus.delivered, 'Delivered'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = _steps.indexWhere((step) => step.$1 == order.status);
    return Column(
      children: [
        for (var index = 0; index < _steps.length; index++)
          _Step(
            status: _steps[index].$1,
            label: _steps[index].$2,
            time: _timeOf(order, _steps[index].$1),
            phase: index < current
                ? _StepPhase.done
                : index == current
                ? _StepPhase.current
                : _StepPhase.upcoming,
            color: theme.colorScheme.primary,
          ),
      ],
    );
  }
}

enum _StepPhase { done, current, upcoming }

class _Step extends StatelessWidget {
  const _Step({
    required this.status,
    required this.label,
    required this.time,
    required this.phase,
    required this.color,
  });

  final OrderStatus status;
  final String label;
  final DateTime? time;
  final _StepPhase phase;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final upcoming = phase == _StepPhase.upcoming;
    return Opacity(
      opacity: upcoming ? 0.4 : 1,
      child: Padding(
        key: Key('order_step_${status.name}'),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              phase == _StepPhase.upcoming
                  ? Icons.circle_outlined
                  : Icons.check_circle,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    key: phase == _StepPhase.current
                        ? Key('order_step_current_${status.name}')
                        : null,
                    style: upcoming
                        ? null
                        : const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (time != null)
                    Text(
                      formatStatusTime(time!),
                      key: Key('order_step_time_${status.name}'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.agorot,
    required this.amountKey,
  });

  final String label;
  final int agorot;
  final String amountKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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

DateTime? _timeOf(Order order, OrderStatus status) {
  DateTime? at;
  for (final event in order.statusHistory) {
    if (event.to == status) at = event.at;
  }
  return at;
}
