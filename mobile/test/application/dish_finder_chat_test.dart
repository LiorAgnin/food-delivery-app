import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/application/auth_session.dart';
import 'package:food_delivery/application/dish_finder_chat.dart';
import 'package:food_delivery/application/ports.dart';
import 'package:food_delivery/domain/api_result.dart';
import 'package:food_delivery/domain/auth/auth.dart';
import 'package:food_delivery/domain/dish_finder/dish_finder.dart';
import 'package:food_delivery/domain/failures/api_error.dart';

import '../support/fake_dish_finder_repository.dart';
import '../support/fixtures.dart';
import '../support/memory_session_store.dart';

void main() {
  const customer = Customer(id: 'c1', phone: '+972501234567');

  ProviderContainer containerOf(FakeDishFinderRepository finder) {
    final container = ProviderContainer(
      overrides: [
        dishFinderRepositoryProvider.overrideWithValue(finder),
        sessionStoreProvider.overrideWithValue(MemorySessionStore()),
      ],
    );
    final chatSub = container.listen(dishFinderChatProvider, (_, _) {});
    final authSub = container.listen(authSessionProvider, (_, _) {});
    addTearDown(() {
      chatSub.close();
      authSub.close();
      container.dispose();
    });
    return container;
  }

  test('a follow-up sends the earlier user and assistant text', () async {
    final finder = FakeDishFinderRepository(
      script: [
        ApiOk(sampleReply(reply: 'Try the skewer')),
        ApiOk(sampleReply(reply: 'The skewer is 48 shekels')),
      ],
    );
    final container = containerOf(finder);
    final chat = container.read(dishFinderChatProvider.notifier);

    await chat.send('something spicy with chicken under 60');
    await chat.send('cheaper ones?');

    expect(finder.searches[1], [
      const ChatMessage(
        role: ChatRole.user,
        content: 'something spicy with chicken under 60',
      ),
      const ChatMessage(role: ChatRole.assistant, content: 'Try the skewer'),
      const ChatMessage(role: ChatRole.user, content: 'cheaper ones?'),
    ]);
    final entries = container.read(dishFinderChatProvider).entries;
    expect(entries, hasLength(4));
    final assistant = entries[1] as AssistantTranscriptEntry;
    expect(assistant.text, 'Try the skewer');
    expect(assistant.relaxed, isEmpty);
  });

  test(
    'retry resends the same history without a second user message',
    () async {
      final dish = DishResult(
        menuItem: sampleItem(name: 'Spicy chicken skewer'),
        restaurant: const DishRestaurant(
          id: 'r1',
          name: 'HaTachana Grill',
          cuisine: 'Grill',
          isOpen: true,
        ),
        orderable: true,
      );
      final finder = FakeDishFinderRepository(
        script: [
          const ApiFailure(
            ApiError(code: ApiErrorCode.network, message: 'Offline'),
          ),
          ApiOk(sampleReply(reply: 'Try the skewer', results: [dish])),
        ],
      );
      final container = containerOf(finder);
      final chat = container.read(dishFinderChatProvider.notifier);

      await chat.send('spicy');
      final failed = container.read(dishFinderChatProvider);
      expect(failed.entries.last, isA<ErrorTranscriptEntry>());
      expect((failed.entries.last as ErrorTranscriptEntry).message, 'Offline');
      expect(failed.pending, isFalse);

      await chat.retry();

      expect(finder.searches, hasLength(2));
      expect(finder.searches[1], finder.searches[0]);
      final done = container.read(dishFinderChatProvider);
      expect(done.entries.whereType<UserTranscriptEntry>(), hasLength(1));
      expect(done.entries.last, isA<AssistantTranscriptEntry>());
      final assistant = done.entries.last as AssistantTranscriptEntry;
      expect(assistant.results.single.menuItem.name, 'Spicy chicken skewer');
      expect(done.pending, isFalse);
    },
  );

  test(
    'history keeps the last 20 messages and clips each to 500 characters',
    () async {
      final finder = FakeDishFinderRepository(
        script: [
          ApiOk(sampleReply(reply: 'b' * 600)),
          ApiOk(sampleReply(reply: 'ok')),
        ],
      );
      final container = containerOf(finder);
      final chat = container.read(dishFinderChatProvider.notifier);

      await chat.send('a' * 600);
      await chat.send('next');

      expect(finder.searches[1][0].content, 'a' * 500);
      expect(finder.searches[1][0].role, ChatRole.user);
      expect(finder.searches[1][1].content, 'b' * 500);
      expect(finder.searches[1][1].role, ChatRole.assistant);
      expect(finder.searches[1].last.content, 'next');
    },
  );

  test('only the last 20 wire messages are sent', () async {
    final finder = FakeDishFinderRepository();
    final container = containerOf(finder);
    final chat = container.read(dishFinderChatProvider.notifier);

    for (var i = 1; i <= 11; i++) {
      await chat.send('m$i');
    }

    final last = finder.searches.last;
    expect(last, hasLength(20));
    expect(
      last.first,
      const ChatMessage(role: ChatRole.assistant, content: 'a1'),
    );
    expect(last.last, const ChatMessage(role: ChatRole.user, content: 'm11'));
    expect(last.where((message) => message.content == 'm1'), isEmpty);
  });

  test('signing out clears the transcript', () async {
    final container = containerOf(FakeDishFinderRepository());
    await container
        .read(authSessionProvider.notifier)
        .signIn(accessToken: 'token', customer: customer);
    final chat = container.read(dishFinderChatProvider.notifier);
    await chat.send('hello');
    expect(container.read(dishFinderChatProvider).entries, isNotEmpty);

    await container.read(authSessionProvider.notifier).signOut();

    final state = container.read(dishFinderChatProvider);
    expect(state.entries, isEmpty);
    expect(state.pending, isFalse);
  });

  test('a reply that arrives after sign-out is dropped', () async {
    final finder = FakeDishFinderRepository(hang: true);
    final container = containerOf(finder);
    await container
        .read(authSessionProvider.notifier)
        .signIn(accessToken: 'token', customer: customer);
    final chat = container.read(dishFinderChatProvider.notifier);
    final pending = chat.send('hello');
    expect(container.read(dishFinderChatProvider).pending, isTrue);

    await container.read(authSessionProvider.notifier).signOut();
    finder.release(ApiOk(sampleReply(reply: 'too late')));
    await pending;

    expect(container.read(dishFinderChatProvider).entries, isEmpty);
    expect(container.read(dishFinderChatProvider).pending, isFalse);
  });

  test('blank text and a second send while pending do nothing', () async {
    final finder = FakeDishFinderRepository(hang: true);
    final container = containerOf(finder);
    final chat = container.read(dishFinderChatProvider.notifier);

    await chat.send('   ');
    expect(finder.searches, isEmpty);

    final pending = chat.send('one');
    await chat.send('two');
    expect(finder.searches, hasLength(1));
    expect(
      container
          .read(dishFinderChatProvider)
          .entries
          .whereType<UserTranscriptEntry>(),
      hasLength(1),
    );

    finder.release(ApiOk(sampleReply(reply: 'ok')));
    await pending;
  });
}
