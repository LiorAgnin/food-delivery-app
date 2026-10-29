import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/api_result.dart';
import '../domain/auth/auth.dart';
import '../domain/dish_finder/dish_finder.dart';
import '../domain/failures/api_error.dart';
import 'auth_session.dart';
import 'ports.dart';

part 'dish_finder_chat.g.dart';

/// Contract `POST /dish-finder/search`: at most 20 messages, 500 characters each.
const dishFinderHistoryLimit = 20;
const dishFinderMessageLimit = 500;

sealed class TranscriptEntry {
  const TranscriptEntry();
}

final class UserTranscriptEntry extends TranscriptEntry {
  const UserTranscriptEntry(this.text);

  final String text;
}

final class AssistantTranscriptEntry extends TranscriptEntry {
  const AssistantTranscriptEntry({
    required this.text,
    required this.results,
    required this.relaxed,
  });

  final String text;
  final List<DishResult> results;
  final List<String> relaxed;
}

final class ErrorTranscriptEntry extends TranscriptEntry {
  const ErrorTranscriptEntry(this.message);

  final String message;
}

class DishFinderChatState {
  const DishFinderChatState({this.entries = const [], this.pending = false});

  final List<TranscriptEntry> entries;
  final bool pending;
}

/// The dish-finder transcript for this app session. Cleared on sign-out.
/// The server is stateless, so each send posts the clipped conversation.
@Riverpod(keepAlive: true)
class DishFinderChat extends _$DishFinderChat {
  var _epoch = 0;

  @override
  DishFinderChatState build() {
    ref.listen(authSessionProvider, (previous, next) {
      if (next is SignedOut) {
        _epoch++;
        state = const DishFinderChatState();
      }
    });
    return const DishFinderChatState();
  }

  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || state.pending) return;
    final entries = [...state.entries, UserTranscriptEntry(text)];
    final epoch = _epoch;
    state = DishFinderChatState(entries: entries, pending: true);
    await _search(entries, epoch);
  }

  Future<void> retry() async {
    if (state.pending) return;
    final entries = [...state.entries];
    if (entries.isEmpty || entries.last is! ErrorTranscriptEntry) return;
    entries.removeLast();
    final epoch = _epoch;
    state = DishFinderChatState(entries: entries, pending: true);
    await _search(entries, epoch);
  }

  Future<void> _search(List<TranscriptEntry> entries, int epoch) async {
    final result = await ref
        .read(dishFinderRepositoryProvider)
        .search(_wireHistory(entries));
    if (!ref.mounted || epoch != _epoch) return;
    switch (result) {
      case ApiOk(:final value):
        state = DishFinderChatState(
          entries: [
            ...entries,
            AssistantTranscriptEntry(
              text: value.reply,
              results: value.results,
              relaxed: value.relaxed,
            ),
          ],
        );
      case ApiFailure(:final error):
        final message = error.message.isEmpty
            ? 'Something went wrong'
            : error.message;
        state = DishFinderChatState(
          entries: [...entries, ErrorTranscriptEntry(message)],
        );
    }
  }
}

/// User and assistant text only. Error bubbles stay on screen and are not sent.
List<ChatMessage> _wireHistory(List<TranscriptEntry> entries) {
  final messages = <ChatMessage>[];
  for (final entry in entries) {
    switch (entry) {
      case UserTranscriptEntry(:final text):
        messages.add(
          ChatMessage(role: ChatRole.user, content: _clipFinderText(text)),
        );
      case AssistantTranscriptEntry(:final text):
        messages.add(
          ChatMessage(role: ChatRole.assistant, content: _clipFinderText(text)),
        );
      case ErrorTranscriptEntry():
        break;
    }
  }
  if (messages.length <= dishFinderHistoryLimit) return messages;
  return messages.sublist(messages.length - dishFinderHistoryLimit);
}

String _clipFinderText(String text) {
  if (text.length <= dishFinderMessageLimit) return text;
  var end = dishFinderMessageLimit;
  final unit = text.codeUnitAt(end - 1);
  if (unit >= 0xD800 && unit <= 0xDBFF) end -= 1;
  return text.substring(0, end);
}
