import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/cart.dart';
import '../../application/dish_finder_chat.dart';
import '../../application/ports.dart';
import '../../domain/api_result.dart';
import '../../domain/catalog/catalog.dart';
import '../../domain/dish_finder/dish_finder.dart';
import '../format/agorot_format.dart';
import '../widgets/cart_badge_button.dart';

const _suggestions = <String>[
  'I want a margherita pizza',
  'Something spicy with chicken under 60 ₪',
  'Vegan dinner, not burgers',
  'Show me sushi from places that are open now',
];

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dishFinderChatProvider);
    final pending = state.pending;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dish finder'),
        actions: const [CartBadgeButton()],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.entries.isEmpty
                ? const _Suggestions()
                : _Transcript(state: state),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('chat_input'),
                      controller: _input,
                      enabled: !pending,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: 'What do you feel like eating?',
                      ),
                      onSubmitted: pending ? null : (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('chat_send'),
                    onPressed: pending ? null : _send,
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    if (ref.read(dishFinderChatProvider).pending) return;
    final text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    unawaited(ref.read(dishFinderChatProvider.notifier).send(text));
  }
}

class _Suggestions extends ConsumerWidget {
  const _Suggestions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var index = 0; index < _suggestions.length; index++)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ActionChip(
                key: Key('chat_suggestion_$index'),
                label: Text(_suggestions[index]),
                onPressed: () {
                  unawaited(
                    ref
                        .read(dishFinderChatProvider.notifier)
                        .send(_suggestions[index]),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Transcript extends ConsumerWidget {
  const _Transcript({required this.state});

  final DishFinderChatState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _lines(ref),
      ),
    );
  }

  List<Widget> _lines(WidgetRef ref) {
    final lines = <Widget>[];
    var replyIndex = 0;
    for (final entry in state.entries) {
      switch (entry) {
        case UserTranscriptEntry(:final text):
          lines.add(_UserLine(text));
        case AssistantTranscriptEntry():
          lines.add(
            _AssistantReply(key: Key('chat_reply_$replyIndex'), entry: entry),
          );
          replyIndex += 1;
        case ErrorTranscriptEntry(:final message):
          lines.add(
            _ErrorLine(
              message: message,
              onRetry: state.pending
                  ? null
                  : () {
                      unawaited(
                        ref.read(dishFinderChatProvider.notifier).retry(),
                      );
                    },
            ),
          );
      }
    }
    if (state.pending) {
      lines.add(
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Finding dishes…', key: Key('chat_typing')),
        ),
      );
    }
    return lines;
  }
}

class _UserLine extends StatelessWidget {
  const _UserLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(alignment: Alignment.centerRight, child: Text(text)),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('chat_retry'),
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _AssistantReply extends ConsumerWidget {
  const _AssistantReply({required this.entry, super.key});

  final AssistantTranscriptEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.text),
          if (entry.relaxed.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text('Close matches', key: Key('dish_close_matches')),
          ],
          for (final result in entry.results) ...[
            const SizedBox(height: 8),
            _DishCard(result: result),
          ],
        ],
      ),
    );
  }
}

class _DishCard extends ConsumerWidget {
  const _DishCard({required this.result});

  final DishResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = result.menuItem;
    final restaurant = result.restaurant;
    final theme = Theme.of(context);
    final reason = _unavailableReason(result);
    return Opacity(
      key: Key('dish_dim_${item.id}'),
      opacity: reason == null ? 1 : 0.45,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(restaurant.name),
              const SizedBox(height: 4),
              Text(formatAgorot(item.priceAgorot)),
              if (item.dietaryTags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final tag in item.dietaryTags)
                      Chip(
                        label: Text(dietaryTagLabel(tag)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
              if (reason != null) ...[const SizedBox(height: 4), Text(reason)],
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    key: Key('dish_view_${item.id}'),
                    onPressed: () =>
                        context.push('/restaurants/${restaurant.id}'),
                    child: const Text('View restaurant'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: Key('dish_add_${item.id}'),
                    onPressed: reason == null
                        ? () => unawaited(_addToCart(context, ref, result))
                        : null,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _unavailableReason(DishResult result) {
  if (result.orderable) return null;
  if (!result.menuItem.isAvailable) return 'Out of stock';
  if (!result.restaurant.isOpen) return 'Restaurant closed';
  return 'Unavailable';
}

Future<void> _addToCart(
  BuildContext context,
  WidgetRef ref,
  DishResult result,
) async {
  if (!result.orderable) return;
  final loaded = await ref
      .read(catalogRepositoryProvider)
      .getMenu(result.restaurant.id);
  if (!context.mounted) return;
  switch (loaded) {
    case ApiFailure(:final error):
      final message = error.message.isEmpty
          ? 'Could not add this dish'
          : error.message;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    case ApiOk(:final value):
      final outcome = ref
          .read(cartProvider.notifier)
          .add(result.menuItem, value.restaurant);
      switch (outcome) {
        case AddToCartAdded():
          _showAdded(context);
        case AddToCartUnavailable():
          break;
        case AddToCartConflict(:final currentRestaurant):
          await _confirmNewCart(
            context,
            ref,
            item: result.menuItem,
            restaurant: value.restaurant,
            currentName: currentRestaurant.name,
          );
      }
  }
}

Future<void> _confirmNewCart(
  BuildContext context,
  WidgetRef ref, {
  required MenuItem item,
  required Restaurant restaurant,
  required String currentName,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        key: const Key('cart_conflict_dialog'),
        title: const Text('Start a new cart?'),
        content: Text(
          'Your cart has items from $currentName. '
          'Starting a new cart clears them.',
        ),
        actions: [
          TextButton(
            key: const Key('cart_conflict_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('cart_conflict_confirm'),
            onPressed: () {
              ref.read(cartProvider.notifier).replaceWith(item, restaurant);
              Navigator.of(dialogContext).pop();
              _showAdded(context);
            },
            child: const Text('Start a new cart'),
          ),
        ],
      );
    },
  );
}

void _showAdded(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Added to cart'),
      // An action makes persist default to true, so the bar would cover
      // the composer until the action is tapped.
      persist: false,
      action: SnackBarAction(
        label: 'View cart',
        onPressed: () => context.push('/cart'),
      ),
    ),
  );
}
