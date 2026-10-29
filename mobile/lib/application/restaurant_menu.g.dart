// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_menu.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(restaurantMenu)
final restaurantMenuProvider = RestaurantMenuFamily._();

final class RestaurantMenuProvider
    extends
        $FunctionalProvider<
          AsyncValue<RestaurantMenu>,
          RestaurantMenu,
          FutureOr<RestaurantMenu>
        >
    with $FutureModifier<RestaurantMenu>, $FutureProvider<RestaurantMenu> {
  RestaurantMenuProvider._({
    required RestaurantMenuFamily super.from,
    required String super.argument,
  }) : super(
         retry: noAutomaticRetry,
         name: r'restaurantMenuProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$restaurantMenuHash();

  @override
  String toString() {
    return r'restaurantMenuProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RestaurantMenu> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RestaurantMenu> create(Ref ref) {
    final argument = this.argument as String;
    return restaurantMenu(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RestaurantMenuProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$restaurantMenuHash() => r'838eeb9f97d362b69ddb99d40e10208d215383b7';

final class RestaurantMenuFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RestaurantMenu>, String> {
  RestaurantMenuFamily._()
    : super(
        retry: noAutomaticRetry,
        name: r'restaurantMenuProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RestaurantMenuProvider call(String restaurantId) =>
      RestaurantMenuProvider._(argument: restaurantId, from: this);

  @override
  String toString() => r'restaurantMenuProvider';
}
