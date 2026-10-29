// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish_finder_chat.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Session transcript for the dish finder. Empty until the failing run.

@ProviderFor(DishFinderChat)
final dishFinderChatProvider = DishFinderChatProvider._();

/// Session transcript for the dish finder. Empty until the failing run.
final class DishFinderChatProvider
    extends $NotifierProvider<DishFinderChat, DishFinderChatState> {
  /// Session transcript for the dish finder. Empty until the failing run.
  DishFinderChatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dishFinderChatProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dishFinderChatHash();

  @$internal
  @override
  DishFinderChat create() => DishFinderChat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DishFinderChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DishFinderChatState>(value),
    );
  }
}

String _$dishFinderChatHash() => r'93a2c05188669a5c05cae9bb7f286a15c2db90bd';

/// Session transcript for the dish finder. Empty until the failing run.

abstract class _$DishFinderChat extends $Notifier<DishFinderChatState> {
  DishFinderChatState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DishFinderChatState, DishFinderChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DishFinderChatState, DishFinderChatState>,
              DishFinderChatState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
