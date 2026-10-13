class BadgeCounterModel {
  final int unreadMessagesCount;
  final int unreadNotificationsCount;

  const BadgeCounterModel({
    this.unreadMessagesCount = 0,
    this.unreadNotificationsCount = 0,
  });

  // Backward compatibility getter
  int get unreadCount => unreadMessagesCount;

  BadgeCounterModel copyWith({
    int? unreadMessagesCount,
    int? unreadNotificationsCount,
    int? unreadCount,
  }) {
    return BadgeCounterModel(
      unreadMessagesCount: unreadMessagesCount ?? unreadCount ?? this.unreadMessagesCount,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
    );
  }
}
