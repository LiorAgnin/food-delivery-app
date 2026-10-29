// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_tracker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How often [OrderTracker] calls `GET /orders/:id`. Tests override it.

@ProviderFor(orderPollInterval)
final orderPollIntervalProvider = OrderPollIntervalProvider._();

/// How often [OrderTracker] calls `GET /orders/:id`. Tests override it.

final class OrderPollIntervalProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How often [OrderTracker] calls `GET /orders/:id`. Tests override it.
  OrderPollIntervalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderPollIntervalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderPollIntervalHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return orderPollInterval(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$orderPollIntervalHash() => r'49c752d0e4516cc1fee1ac10eb8c6bac6d790080';

/// Polls one order until a terminal status or until the screen disposes.
/// The interval comes from [orderPollIntervalProvider] so tests do not wait
/// three real seconds.

@ProviderFor(OrderTracker)
final orderTrackerProvider = OrderTrackerFamily._();

/// Polls one order until a terminal status or until the screen disposes.
/// The interval comes from [orderPollIntervalProvider] so tests do not wait
/// three real seconds.
final class OrderTrackerProvider
    extends $NotifierProvider<OrderTracker, OrderTrackerState> {
  /// Polls one order until a terminal status or until the screen disposes.
  /// The interval comes from [orderPollIntervalProvider] so tests do not wait
  /// three real seconds.
  OrderTrackerProvider._({
    required OrderTrackerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderTrackerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderTrackerHash();

  @override
  String toString() {
    return r'orderTrackerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OrderTracker create() => OrderTracker();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderTrackerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderTrackerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrderTrackerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderTrackerHash() => r'31ca5f53d6e651212584fed7d26f8b137dd24519';

/// Polls one order until a terminal status or until the screen disposes.
/// The interval comes from [orderPollIntervalProvider] so tests do not wait
/// three real seconds.

final class OrderTrackerFamily extends $Family
    with
        $ClassFamilyOverride<
          OrderTracker,
          OrderTrackerState,
          OrderTrackerState,
          OrderTrackerState,
          String
        > {
  OrderTrackerFamily._()
    : super(
        retry: null,
        name: r'orderTrackerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Polls one order until a terminal status or until the screen disposes.
  /// The interval comes from [orderPollIntervalProvider] so tests do not wait
  /// three real seconds.

  OrderTrackerProvider call(String orderId) =>
      OrderTrackerProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderTrackerProvider';
}

/// Polls one order until a terminal status or until the screen disposes.
/// The interval comes from [orderPollIntervalProvider] so tests do not wait
/// three real seconds.

abstract class _$OrderTracker extends $Notifier<OrderTrackerState> {
  late final _$args = ref.$arg as String;
  String get orderId => _$args;

  OrderTrackerState build(String orderId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OrderTrackerState, OrderTrackerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OrderTrackerState, OrderTrackerState>,
              OrderTrackerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
