// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The cart belongs to one restaurant. An empty cart belongs to none, so
/// the next [add] is not a conflict.

@ProviderFor(Cart)
final cartProvider = CartProvider._();

/// The cart belongs to one restaurant. An empty cart belongs to none, so
/// the next [add] is not a conflict.
final class CartProvider extends $NotifierProvider<Cart, CartState> {
  /// The cart belongs to one restaurant. An empty cart belongs to none, so
  /// the next [add] is not a conflict.
  CartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartHash();

  @$internal
  @override
  Cart create() => Cart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CartState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CartState>(value),
    );
  }
}

String _$cartHash() => r'6ca4c8643baabe18c08653eb9d0aa3f110e2aef6';

/// The cart belongs to one restaurant. An empty cart belongs to none, so
/// the next [add] is not a conflict.

abstract class _$Cart extends $Notifier<CartState> {
  CartState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CartState, CartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CartState, CartState>,
              CartState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
