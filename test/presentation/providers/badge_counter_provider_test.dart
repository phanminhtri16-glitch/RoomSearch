import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_search/presentation/providers/badge_counter_provider.dart';

void main() {
  group('Notifications and Messages Riverpod App State Test', () {
    test('Initial unread messages and notifications count should be 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(badgeCounterProvider);
      expect(state.unreadMessagesCount, equals(0));
      expect(state.unreadNotificationsCount, equals(0));
    });

    test('Messages state actions (increment, decrement, reset)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(badgeCounterProvider.notifier);
      notifier.incrementMessages();
      expect(container.read(badgeCounterProvider).unreadMessagesCount, equals(1));

      notifier.decrementMessages();
      expect(container.read(badgeCounterProvider).unreadMessagesCount, equals(0));

      notifier.incrementMessages();
      notifier.resetMessages();
      expect(container.read(badgeCounterProvider).unreadMessagesCount, equals(0));
    });

    test('Notifications state actions (increment, decrement, reset)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(badgeCounterProvider.notifier);
      notifier.incrementNotifications();
      expect(container.read(badgeCounterProvider).unreadNotificationsCount, equals(1));

      notifier.decrementNotifications();
      expect(container.read(badgeCounterProvider).unreadNotificationsCount, equals(0));

      notifier.incrementNotifications();
      notifier.resetNotifications();
      expect(container.read(badgeCounterProvider).unreadNotificationsCount, equals(0));
    });
  });
}
