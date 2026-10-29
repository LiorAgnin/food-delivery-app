import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/api_result.dart';
import '../domain/failures/api_error.dart';
import '../domain/orders/order.dart';
import 'ports.dart';

part 'order_tracker.freezed.dart';
part 'order_tracker.g.dart';

/// How often [OrderTracker] calls `GET /orders/:id`. Tests override it.
@Riverpod(keepAlive: true)
Duration orderPollInterval(Ref ref) => const Duration(seconds: 3);

@freezed
sealed class OrderTrackerState with _$OrderTrackerState {
  const factory OrderTrackerState.loading() = OrderTrackerLoading;

  const factory OrderTrackerState.ready({
    required Order order,
    @Default(false) bool reconnecting,
  }) = OrderTrackerReady;

  const factory OrderTrackerState.failed(ApiError error) = OrderTrackerFailed;
}

/// Polls one order until a terminal status or until the screen disposes.
/// The interval comes from [orderPollIntervalProvider] so tests do not wait
/// three real seconds.
@riverpod
class OrderTracker extends _$OrderTracker {
  Timer? _timer;
  var _pollInFlight = false;

  @override
  OrderTrackerState build(String orderId) {
    final interval = ref.read(orderPollIntervalProvider);
    final timer = Timer.periodic(interval, (_) {
      unawaited(_poll(orderId));
    });
    _timer = timer;
    ref.onDispose(timer.cancel);
    unawaited(_poll(orderId));
    return const OrderTrackerState.loading();
  }

  Future<void> retry() => _poll(orderId);

  Future<void> _poll(String orderId) async {
    // A tick that lands while a request is open would let the slower
    // response arrive last and paint an older status.
    if (_pollInFlight) return;
    _pollInFlight = true;
    try {
      final result = await ref.read(ordersRepositoryProvider).getOrder(orderId);
      if (!ref.mounted) return;
      switch (result) {
        case ApiOk(:final value):
          state = OrderTrackerState.ready(order: value);
          if (value.status.isTerminal) {
            _timer?.cancel();
            _timer = null;
          }
        case ApiFailure(:final error):
          switch (state) {
            case OrderTrackerReady(:final order):
              state = OrderTrackerState.ready(order: order, reconnecting: true);
            case OrderTrackerLoading() || OrderTrackerFailed():
              state = OrderTrackerState.failed(error);
          }
      }
    } finally {
      _pollInFlight = false;
    }
  }
}
