import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../providers/badge_counter_provider.dart';
import '../../providers/landlord_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(badgeCounterProvider.notifier).resetNotifications();
      final landlordProvider = legacy_provider.Provider.of<LandlordProvider>(context, listen: false);
      landlordProvider.markAllNotificationsAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final landlordProvider = legacy_provider.Provider.of<LandlordProvider>(context);
    final notifications = landlordProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo hệ thống'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(badgeCounterProvider.notifier).resetNotifications();
                landlordProvider.markAllNotificationsAsRead();
              },
              child: const Text('Đã đọc tất cả', style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: notifications.isEmpty
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
                      child: const Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.primaryLight),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bạn chưa có thông báo nào',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return _buildNotificationTile(notif);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationEntity notif) {
    IconData iconData = Icons.notifications_rounded;
    Color iconColor = AppColors.primaryLight;

    if (notif.loaiThongBao == 'YEU_CAU_MOI') {
      iconData = Icons.assignment_outlined;
      iconColor = AppColors.warning;
    } else if (notif.loaiThongBao == 'DUYET_TIN') {
      iconData = Icons.verified_outlined;
      iconColor = AppColors.success;
    } else if (notif.loaiThongBao == 'TU_CHOI_TIN') {
      iconData = Icons.cancel_outlined;
      iconColor = AppColors.error;
    } else if (notif.loaiThongBao == 'COC_THANH_CONG') {
      iconData = Icons.monetization_on_outlined;
      iconColor = AppColors.success;
    } else if (notif.loaiThongBao == 'TIN_NHAN_MOI') {
      iconData = Icons.chat_bubble_outline_rounded;
      iconColor = AppColors.primaryLight;
    }

    return Container(
      color: notif.isDaDoc ? Colors.transparent : AppColors.primary.withValues(alpha: 0.1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.2),
          child: Icon(iconData, color: iconColor, size: 22),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                notif.tieuDe,
                style: TextStyle(
                  fontWeight: notif.isDaDoc ? FontWeight.w600 : FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              DateFormat('HH:mm dd/MM').format(notif.thoiGian),
              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            notif.noiDung,
            style: TextStyle(
              fontSize: 12,
              color: notif.isDaDoc ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
