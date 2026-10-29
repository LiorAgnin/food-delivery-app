import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/api_result.dart';
import '../domain/failures/api_error.dart';
import '../domain/orders/order.dart';
import 'auth_session.dart';
import 'cart.dart';
import 'ports.dart';

part 'checkout.freezed.dart';
part 'checkout.g.dart';

/// Randomness for `Idempotency-Key`. Tests override the provider.
abstract interface class IdempotencyKeys {
  String next();
}

final class RandomIdempotencyKeys implements IdempotencyKeys {
  RandomIdempotencyKeys({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  @override
  String next() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}

@Riverpod(keepAlive: true)
IdempotencyKeys idempotencyKeys(Ref ref) => RandomIdempotencyKeys();

@freezed
sealed class CheckoutState with _$CheckoutState {
  const factory CheckoutState.idle() = CheckoutIdle;

  const factory CheckoutState.submitting() = CheckoutSubmitting;

  const factory CheckoutState.failed({
    required ApiError error,
    required String message,
    @Default(<String>[]) List<String> unavailableMenuItemIds,
  }) = CheckoutFailed;

  const factory CheckoutState.placed({required String orderId}) =
      CheckoutPlaced;
}

extension CheckoutFailureActions on CheckoutFailed {
  /// Network and timeout are the failures a retry can safely repeat.
  /// The idempotency key is still the one from the failed attempt.
  bool get canRetry =>
      error.code == ApiErrorCode.network || error.code == ApiErrorCode.timeout;
}

String _checkoutFailureMessage(ApiError error) {
  return switch (error.code) {
    ApiErrorCode.restaurantClosed => 'This restaurant is closed right now.',
    ApiErrorCode.itemUnavailable => 'Some items are no longer available.',
    ApiErrorCode.itemNotInRestaurant => 'Some items are not on this menu.',
    ApiErrorCode.belowMinimum => 'This order is below the minimum.',
    ApiErrorCode.network => 'Network unavailable. Try again.',
    ApiErrorCode.timeout => 'The request timed out. Try again.',
    ApiErrorCode.unauthorized => 'Sign in again.',
    _ => error.message,
  };
}

List<String> _unavailableMenuItemIds(ApiError error) {
  if (error.code != ApiErrorCode.itemUnavailable &&
      error.code != ApiErrorCode.itemNotInRestaurant) {
    return const [];
  }
  final details = error.details;
  if (details is! Map) return const [];
  final raw = details['menuItemIds'];
  if (raw is! List) return const [];
  return [
    for (final id in raw)
      if (id is String) id,
  ];
}

/// One checkout attempt. The idempotency key survives a failed [place] so a
/// retry of the same cart cannot create a second order. A cart edit drops
/// the key: the body changed, and the old key would come back as
/// `IDEMPOTENCY_CONFLICT`.
@Riverpod(keepAlive: true)
class Checkout extends _$Checkout {
  String? _idempotencyKey;

  @override
  CheckoutState build() {
    ref.listen(cartProvider, (previous, next) {
      if (previous != null && previous != next) {
        _idempotencyKey = null;
      }
    });
    return const CheckoutState.idle();
  }

  Future<void> place() async {
    if (state is CheckoutSubmitting) return;
    final cart = ref.read(cartProvider);
    final restaurant = cart.restaurant;
    if (restaurant == null || cart.lines.isEmpty) return;

    final key = _idempotencyKey ??= ref.read(idempotencyKeysProvider).next();
    state = const CheckoutState.submitting();
    final result = await ref
        .read(ordersRepositoryProvider)
        .placeOrder(
          restaurantId: restaurant.id,
          lines: [
            for (final line in cart.lines)
              OrderDraftLine(menuItemId: line.item.id, quantity: line.quantity),
          ],
          idempotencyKey: key,
        );

    switch (result) {
      case ApiOk(:final value):
        state = CheckoutState.placed(orderId: value.id);
        ref.read(cartProvider.notifier).clear();
      case ApiFailure(:final error):
        if (error.code == ApiErrorCode.unauthorized) {
          await ref.read(authSessionProvider.notifier).clearOnUnauthorized();
        }
        state = CheckoutState.failed(
          error: error,
          message: _checkoutFailureMessage(error),
          unavailableMenuItemIds: _unavailableMenuItemIds(error),
        );
    }
  }
}
