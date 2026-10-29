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
/// retry of the same cart cannot create a second order. A cart edit drops
/// the key: the body changed, and the old key would come back as
/// `IDEMPOTENCY_CONFLICT`.

@ProviderFor(Checkout)
final checkoutProvider = CheckoutProvider._();

/// One checkout attempt. The idempotency key survives a failed [place] so a
/// retry of the same cart cannot create a second order. A cart edit drops
/// the key: the body changed, and the old key would come back as
/// `IDEMPOTENCY_CONFLICT`.
final class CheckoutProvider
    extends $NotifierProvider<Checkout, CheckoutState> {
  /// One checkout attempt. The idempotency key survives a failed [place] so a
  /// retry of the same cart cannot create a second order. A cart edit drops
  /// the key: the body changed, and the old key would come back as
  /// `IDEMPOTENCY_CONFLICT`.
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

String _$checkoutHash() => r'11747c94d86ac649579312bb86d1b044cd165a8c';

/// One checkout attempt. The idempotency key survives a failed [place] so a
/// retry of the same cart cannot create a second order. A cart edit drops
/// the key: the body changed, and the old key would come back as
/// `IDEMPOTENCY_CONFLICT`.

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
