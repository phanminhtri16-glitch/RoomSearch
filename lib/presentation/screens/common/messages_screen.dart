import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_gradients.dart';
import '../../providers/auth_provider.dart';
import '../../providers/badge_counter_provider.dart';
import '../../providers/chat_provider.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = legacy_provider.Provider.of<ChatProvider>(context, listen: false);
      chatProvider.setBadgeCounterNotifier(ref.read(badgeCounterProvider.notifier));

      final user = legacy_provider.Provider.of<AuthProvider>(context, listen: false).currentUser;
      final userId = user?.maTK ?? 'CURRENT_USER';
      chatProvider.listenToMessages(userId);
      chatProvider.updateUnreadBadgeCount(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = legacy_provider.Provider.of<AuthProvider>(context);
    final chatProvider = legacy_provider.Provider.of<ChatProvider>(context);
    final currentUser = authProvider.currentUser;
    final isLandlord = currentUser?.vaiTro == AppConstants.roleLandlord;

    final conversations = chatProvider.getConversationsForUser(
      currentUser?.maTK ?? 'CURRENT_USER',
      isLandlord: isLandlord,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn trực tiếp'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: conversations.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.primaryLight),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Chưa có cuộc trò chuyện nào',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tin nhắn với người dùng khác sẽ hiển thị tại đây',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: conversations.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                itemBuilder: (context, index) {
                  final chat = conversations[index];
                  final hasUnread = chat['unread'] == '1';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Icon(
                        isLandlord ? Icons.person_rounded : Icons.home_work_rounded,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chat['name']!,
                          style: TextStyle(
                            fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          chat['time']!,
                          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      chat['lastMsg']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasUnread ? AppColors.primaryLight : AppColors.textSecondary,
                        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                    trailing: hasUnread
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                          )
                        : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                    onTap: () {
                      ref.read(badgeCounterProvider.notifier).decrement();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            targetUserId: chat['id']!,
                            targetUserName: chat['name']!,
                            targetUserPhone: chat['phone']!,
                            roomId: chat['room']!,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
