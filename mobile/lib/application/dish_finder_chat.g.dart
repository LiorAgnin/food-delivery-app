// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish_finder_chat.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The dish-finder transcript for this app session. Cleared on sign-out.
/// The server is stateless, so each send posts the clipped conversation.

@ProviderFor(DishFinderChat)
final dishFinderChatProvider = DishFinderChatProvider._();

/// The dish-finder transcript for this app session. Cleared on sign-out.
/// The server is stateless, so each send posts the clipped conversation.
final class DishFinderChatProvider
    extends $NotifierProvider<DishFinderChat, DishFinderChatState> {
  /// The dish-finder transcript for this app session. Cleared on sign-out.
  /// The server is stateless, so each send posts the clipped conversation.
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

String _$dishFinderChatHash() => r'3fbf408f8eb4637bfa9377b498fc0c66f6afc5c2';

/// The dish-finder transcript for this app session. Cleared on sign-out.
/// The server is stateless, so each send posts the clipped conversation.

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
