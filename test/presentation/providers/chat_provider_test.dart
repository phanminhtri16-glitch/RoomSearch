import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_search/data/models/chat_message_model.dart';
import 'package:room_search/presentation/providers/badge_counter_provider.dart';
import 'package:room_search/presentation/providers/chat_provider.dart';

void main() {
  group('ChatProvider and BadgeCounterNotifier Integration Test', () {
    test('Receiving message from opponent should increment badge counter', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final badgeNotifier = container.read(badgeCounterProvider.notifier);
      final chatProvider = ChatProvider();
      chatProvider.setBadgeCounterNotifier(badgeNotifier);

      expect(container.read(badgeCounterProvider).unreadMessagesCount, equals(0));

      final opponentMsg = ChatMessageModel(
        maTinNhan: 'TN-20260808-001',
        maNguoiGui: 'LANDLORD_1',
        maNguoiNhan: 'STUDENT_1',
        maPhong: 'P101',
        noiDung: 'Xin chào',
        thoiGian: DateTime.now(),
        isDaXem: false,
      );

      await chatProvider.sendMessage(opponentMsg, currentUserId: 'STUDENT_1');

      expect(container.read(badgeCounterProvider).unreadMessagesCount, equals(1));
    });

    test('Marking messages as read should update badge counter to 0', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final badgeNotifier = container.read(badgeCounterProvider.notifier);
      final chatProvider = ChatProvider();
      chatProvider.setBadgeCounterNotifier(badgeNotifier);

      final opponentMsg = ChatMessageModel(
        maTinNhan: 'TN-20260808-001',
        maNguoiGui: 'LANDLORD_1',
        maNguoiNhan: 'STUDENT_1',
        maPhong: 'P101',
        noiDung: 'Xin chào',
        thoiGian: DateTime.now(),
        isDaXem: false,
      );

      await chatProvider.sendMessage(opponentMsg, currentUserId: 'STUDENT_1');
      expect(container.read(badgeCounterProvider).unreadMessagesCount, equals(1));

      chatProvider.markMessagesAsRead('STUDENT_1', 'LANDLORD_1');
      expect(container.read(badgeCounterProvider).unreadMessagesCount, equals(0));
    });

    test('getUserDisplayName returns clean human readable role names based on account sequence', () {
      final chatProvider = ChatProvider();
      expect(chatProvider.getUserDisplayName('LANDLORD_1'), equals('Chủ trọ 1'));
      expect(chatProvider.getUserDisplayName('STUDENT_1', isLandlord: true), equals('Sinh viên 1'));
      expect(chatProvider.getUserDisplayName('SV002', isLandlord: true), equals('Sinh viên 2'));
    });
  });
}
