import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/badge_counter_model.dart';

class BadgeCounterNotifier extends StateNotifier<BadgeCounterModel> {
  BadgeCounterNotifier()
      : super(const BadgeCounterModel(
          unreadMessagesCount: 0,
          unreadNotificationsCount: 0,
        ));

  void _safeUpdate(BadgeCounterModel newState) {
    if (state.unreadMessagesCount == newState.unreadMessagesCount &&
        state.unreadNotificationsCount == newState.unreadNotificationsCount) {
      return;
    }
    try {
      state = newState;
    } catch (_) {
      Future.microtask(() {
        if (mounted) {
          state = newState;
        }
      });
    }
  }

  // --- Messages App State Actions ---
  void incrementMessages() {
    _safeUpdate(state.copyWith(unreadMessagesCount: state.unreadMessagesCount + 1));
  }

  void decrementMessages() {
    if (state.unreadMessagesCount > 0) {
      _safeUpdate(state.copyWith(unreadMessagesCount: state.unreadMessagesCount - 1));
    }
  }

  void resetMessages() {
    _safeUpdate(state.copyWith(unreadMessagesCount: 0));
  }

  // Backward compatibility alias methods for messages
  void increment() => incrementMessages();
  void decrement() => decrementMessages();
  void reset() => resetMessages();

  void setCount(int count) {
    _safeUpdate(state.copyWith(unreadMessagesCount: count < 0 ? 0 : count));
  }

  // --- Notifications App State Actions ---
  void incrementNotifications() {
    _safeUpdate(state.copyWith(unreadNotificationsCount: state.unreadNotificationsCount + 1));
  }

  void decrementNotifications() {
    if (state.unreadNotificationsCount > 0) {
      _safeUpdate(state.copyWith(unreadNotificationsCount: state.unreadNotificationsCount - 1));
    }
  }

  void resetNotifications() {
    _safeUpdate(state.copyWith(unreadNotificationsCount: 0));
  }

  void setNotificationCount(int count) {
    _safeUpdate(state.copyWith(unreadNotificationsCount: count < 0 ? 0 : count));
  }
}

final badgeCounterProvider =
    StateNotifierProvider<BadgeCounterNotifier, BadgeCounterModel>((ref) {
  return BadgeCounterNotifier();
});
