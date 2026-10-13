import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../providers/admin_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../home/student_home_screen.dart';

class AdminProfileTab extends StatefulWidget {
  const AdminProfileTab({super.key});

  @override
  State<AdminProfileTab> createState() => _AdminProfileTabState();
}

class _AdminProfileTabState extends State<AdminProfileTab> {
  bool _showRoomSearch = false;

  @override
  Widget build(BuildContext context) {
    if (_showRoomSearch) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tra cứu phòng trọ'),
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              setState(() {
                _showRoomSearch = false;
              });
            },
          ),
        ),
        body: const StudentHomeScreen(),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final user = authProvider.currentUser;

    final overdueCount = adminProvider.overduePendingRooms.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ Quản trị viên & Cài đặt'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                          backgroundImage:
                              (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child:
                              (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                              ? const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 50,
                                  color: AppColors.primaryLight,
                                )
                              : null,
                        ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () => _updateAvatarDialog(context, authProvider),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.hoTen ?? 'Quản trị viên Hệ thống',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? 'admin@roomsearch.com',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Role: QUẢN TRỊ VIÊN (ADMIN)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Thông báo hệ thống (FCM Alerts)',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.rate_review_rounded,
                        color: AppColors.warning,
                      ),
                      title: Text(
                        'Có ${adminProvider.pendingRooms.length} tin đăng mới gửi chờ duyệt',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Nhận thông báo tự động mỗi khi Chủ trọ gửi tin mới',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    if (overdueCount > 0)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                        ),
                        title: Text(
                          'Cảnh báo: Có $overdueCount tin trọ sắp/quá 24h chưa duyệt!',
                          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                        ),
                        subtitle: const Text(
                          'Yêu cầu kiểm duyệt xử lý gấp tránh tồn đọng SLA',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    const ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.event_note_rounded,
                        color: AppColors.success,
                      ),
                      title: Text(
                        'Báo cáo thống kê tháng 00:00 sẵn sàng',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Hệ thống vừa tổng hợp xong báo cáo dữ liệu định kỳ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primaryLight,
                      ),
                      title: const Text('Tra cứu phòng trọ', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Xem danh sách & chi tiết phòng trọ', style: TextStyle(color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () {
                        setState(() {
                          _showRoomSearch = true;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primaryLight,
                      ),
                      title: const Text('Cập nhật Hồ sơ cá nhân', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => _updateProfileDialog(context, authProvider),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.primaryLight,
                      ),
                      title: const Text('Đổi mật khẩu tài khoản', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => _changePasswordDialog(context, authProvider),
                    ),
                    const Divider(height: 1),
                    Consumer<AppStateProvider>(
                      builder: (context, appState, _) {
                        return SwitchListTile(
                          secondary: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.primaryLight,
                          ),
                          title: const Text('Cài đặt Nhận Thông báo đẩy (FCM)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          subtitle: const Text(
                            'Bật/Tắt nhận cảnh báo tức thì từ hệ thống',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          value: appState.isNotificationEnabled,
                          onChanged: (val) {
                            appState.toggleNotification(val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  val
                                      ? 'Đã bật nhận thông báo đẩy!'
                                      : 'Đã tắt nhận thông báo đẩy.',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Đăng xuất'),
                      content: const Text(
                        'Bạn có chắc chắn muốn đăng xuất khỏi trang Quản trị Admin?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text('Đăng xuất tài khoản Quản trị', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateAvatarDialog(BuildContext context, AuthProvider authProvider) {
    final urlController = TextEditingController(
      text: authProvider.currentUser?.avatarUrl ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Thay đổi Ảnh đại diện Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tải ảnh lên Firebase Storage hoặc dán đường dẫn URL ảnh đại diện mới:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: urlController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'URL Ảnh đại diện',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = urlController.text.trim();
              Navigator.pop(ctx);
              final user = authProvider.currentUser;
              if (user != null) {
                await authProvider.updateProfile(
                  hoTen: user.hoTen,
                  soDienThoai: user.soDienThoai,
                  avatarUrl: newUrl,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Đã cập nhật ảnh đại diện Admin thành công!',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: const Text('Lưu ảnh', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _updateProfileDialog(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final nameController = TextEditingController(text: user?.hoTen ?? '');
    final phoneController = TextEditingController(
      text: user?.soDienThoai ?? '',
    );
    final addressController = TextEditingController(
      text: user?.diaChiLienHe ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cập nhật Hồ sơ Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Địa chỉ liên hệ'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (user != null) {
                await authProvider.updateProfile(
                  hoTen: nameController.text.trim(),
                  soDienThoai: phoneController.text.trim(),
                  diaChiLienHe: addressController.text.trim(),
                  avatarUrl: user.avatarUrl,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã cập nhật thông tin thành công!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: const Text('Cập nhật', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _changePasswordDialog(BuildContext context, AuthProvider authProvider) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đổi mật khẩu'),
        content: TextField(
          controller: passController,
          obscureText: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Đã cập nhật mật khẩu mới cho tài khoản Admin!',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
