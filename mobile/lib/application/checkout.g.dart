// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(idempotencyKeys)
final idempotencyKeysProvider = IdempotencyKeysProvider._();

final class IdempotencyKeysProvider
    extends
        $FunctionalProvider<IdempotencyKeys, IdempotencyKeys, IdempotencyKeys>
    with $Provider<IdempotencyKeys> {
  IdempotencyKeysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'idempotencyKeysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$idempotencyKeysHash();

  @$internal
  @override
  $ProviderElement<IdempotencyKeys> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IdempotencyKeys create(Ref ref) {
    return idempotencyKeys(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdempotencyKeys value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdempotencyKeys>(value),
    );
  }
}

String _$idempotencyKeysHash() => r'a8046423d8a6f2331451ccb27160e389d6495560';

/// One checkout attempt. The idempotency key survives a failed [place] so a
/// retry cannot create a second order. A new key is issued only after the
/// cart changes, because a different body with the old key is a conflict.

@ProviderFor(Checkout)
final checkoutProvider = CheckoutProvider._();

/// One checkout attempt. The idempotency key survives a failed [place] so a
/// retry cannot create a second order. A new key is issued only after the
/// cart changes, because a different body with the old key is a conflict.
final class CheckoutProvider
    extends $NotifierProvider<Checkout, CheckoutState> {
  /// One checkout attempt. The idempotency key survives a failed [place] so a
  /// retry cannot create a second order. A new key is issued only after the
  /// cart changes, because a different body with the old key is a conflict.
  CheckoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutHash();

  @$internal
  @override
  Checkout create() => Checkout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutState>(value),
    );
  }
}

String _$checkoutHash() => r'cb05355d5724b150a4334949306fd62f69a43447';

/// One checkout attempt. The idempotency key survives a failed [place] so a
/// retry cannot create a second order. A new key is issued only after the
/// cart changes, because a different body with the old key is a conflict.

abstract class _$Checkout extends $Notifier<CheckoutState> {
  CheckoutState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CheckoutState, CheckoutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CheckoutState, CheckoutState>,
              CheckoutState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
