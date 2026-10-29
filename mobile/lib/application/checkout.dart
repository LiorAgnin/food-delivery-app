import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/api_result.dart';
import '../domain/failures/api_error.dart';
import '../domain/orders/order.dart';
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

/// One checkout attempt. The idempotency key survives a failed [place] so a
/// retry of the same cart cannot create a second order.
@Riverpod(keepAlive: true)
class Checkout extends _$Checkout {
  String? _idempotencyKey;

  @override
  CheckoutState build() => const CheckoutState.idle();

  Future<void> place() async {
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
        state = CheckoutState.failed(error: error, message: error.message);
    }
  }
}
