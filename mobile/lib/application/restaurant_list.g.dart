// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(restaurantList)
final restaurantListProvider = RestaurantListProvider._();

final class RestaurantListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Restaurant>>,
          List<Restaurant>,
          FutureOr<List<Restaurant>>
        >
    with $FutureModifier<List<Restaurant>>, $FutureProvider<List<Restaurant>> {
  RestaurantListProvider._()
    : super(
        from: null,
        argument: null,
        retry: noAutomaticRetry,
        name: r'restaurantListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restaurantListHash();

  @$internal
  @override
  $FutureProviderElement<List<Restaurant>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Restaurant>> create(Ref ref) {
    return restaurantList(ref);
  }
}

String _$restaurantListHash() => r'8d957bfa88b6341980b2e553fd2fdea363b80a9a';
