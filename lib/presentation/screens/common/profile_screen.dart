import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_gradients.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../auth/login_screen.dart';
import '../student/student_contracts_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getRoleText(String? role) {
    if (role == AppConstants.roleStudent) return 'Sinh viên (Người thuê)';
    if (role == AppConstants.roleLandlord) return 'Chủ trọ';
    if (role == AppConstants.roleAdmin) return 'Quản trị hệ thống';
    return 'Chưa xác định';
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final nameCtrl = TextEditingController(text: user?.hoTen ?? '');
    final phoneCtrl = TextEditingController(text: user?.soDienThoai ?? '');
    final cccdCtrl = TextEditingController(text: user?.soCCCD ?? '');
    final addressCtrl = TextEditingController(text: user?.diaChiLienHe ?? '');
    final avatarUrlCtrl = TextEditingController(text: user?.avatarUrl ?? '');

    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Cập nhật thông tin cá nhân'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dialogError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dialogError!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Họ và tên *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Số điện thoại *'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: avatarUrlCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'URL Ảnh đại diện (Link hình ảnh)',
                      hintText: 'https://example.com/avatar.jpg',
                    ),
                  ),
                  if (user?.vaiTro == AppConstants.roleLandlord) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: cccdCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Số giấy tờ CCCD/Xác minh (Bắt buộc) *',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ liên hệ chính thức (Bắt buộc) *',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                    setDialogState(() => dialogError = 'Vui lòng điền đầy đủ Họ và tên và Số điện thoại.');
                    return;
                  }
                  if (user?.vaiTro == AppConstants.roleLandlord) {
                    if (cccdCtrl.text.trim().isEmpty) {
                      setDialogState(
                        () => dialogError = 'Chủ trọ bắt buộc phải nhập số CCCD/Xác minh.',
                      );
                      return;
                    }
                    if (addressCtrl.text.trim().isEmpty) {
                      setDialogState(
                        () => dialogError = 'Chủ trọ bắt buộc phải nhập Địa chỉ liên hệ chính thức.',
                      );
                      return;
                    }
                  }
                  setDialogState(() => dialogError = null);
                  final success = await authProvider.updateProfile(
                    hoTen: nameCtrl.text.trim(),
                    soDienThoai: phoneCtrl.text.trim(),
                    soCCCD: cccdCtrl.text.trim().isEmpty ? null : cccdCtrl.text.trim(),
                    diaChiLienHe: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
                    avatarUrl: avatarUrlCtrl.text.trim().isEmpty ? null : avatarUrlCtrl.text.trim(),
                  );
                  if (ctx.mounted && success) {
                    Navigator.pop(ctx);
                  }
                  if (context.mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật thông tin cá nhân thành công!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: const Text('Lưu thay đổi', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider authProvider) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassCtrl,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Mật khẩu mới (tối thiểu 6 ký tự)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassCtrl,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
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
              if (newPassCtrl.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mật khẩu mới phải có tối thiểu 6 ký tự')),
                );
                return;
              }
              if (newPassCtrl.text != confirmPassCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xác nhận mật khẩu mới không khớp')),
                );
                return;
              }
              final success = await authProvider.changePassword(
                oldPassCtrl.text,
                newPassCtrl.text,
              );
              if (ctx.mounted && success) {
                Navigator.pop(ctx);
              }
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đổi mật khẩu thành công!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else if (authProvider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.errorMessage!),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản cá nhân'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.surface,
                        backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.trim().isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null || user!.avatarUrl!.trim().isEmpty
                            ? const Icon(Icons.person_rounded, size: 52, color: AppColors.primaryLight)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?.hoTen ?? 'Người dùng',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, color: Color(0xFFF59E0B), size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            _getRoleText(user?.vaiTro),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'VIP MEMBER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline_rounded, color: AppColors.primaryLight),
                      title: const Text('Thông tin cá nhân', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        user?.vaiTro == AppConstants.roleLandlord
                            ? 'SĐT: ${user?.soDienThoai} • CCCD: ${user?.soCCCD ?? "Chưa cập nhật"}\nĐịa chỉ: ${user?.diaChiLienHe ?? "Chưa cập nhật"}'
                            : 'SĐT: ${user?.soDienThoai}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryLight),
                      onTap: () => _showEditProfileDialog(context, authProvider),
                    ),
                    if (user?.vaiTro == AppConstants.roleLandlord) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.star_outline_rounded, color: Color(0xFFFFD700)),
                        title: const Text('Điểm uy tín trung bình', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        trailing: Text(
                          '${user?.diemUyTinhTrungBinh.toStringAsFixed(1)} / 5.0 ★',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFFFD700)),
                        ),
                      ),
                    ] else ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.assignment_outlined, color: AppColors.primaryLight),
                        title: const Text('Hợp đồng thuê phòng của tôi', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Xem các hợp đồng thuê phòng đã khởi tạo', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StudentContractsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryLight),
                      title: const Text('Đổi mật khẩu', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => _showChangePasswordDialog(context, authProvider),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.verified_user_outlined, color: AppColors.primaryLight),
                      title: Text('Trạng thái xác thực tài khoản', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      trailing: Text(
                        'Đã xác thực',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Consumer<AppStateProvider>(
                builder: (context, appState, _) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 14, bottom: 4),
                          child: Text(
                            'Cài đặt & Giao diện ứng dụng',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                          ),
                        ),
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryLight),
                          title: const Text('Thông báo hệ thống', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Nhận thông báo cập nhật phòng trọ và duyệt tin', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          value: appState.isNotificationEnabled,
                          onChanged: (val) => appState.toggleNotification(val),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.history_rounded, color: AppColors.primaryLight),
                          title: const Text('Lịch sử tìm kiếm', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            'Đã lưu ${appState.recentSearches.length} từ khóa gần đây',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          trailing: TextButton(
                            onPressed: appState.recentSearches.isEmpty
                                ? null
                                : () async {
                                    await appState.clearRecentSearches();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã xóa lịch sử tìm kiếm!')),
                                      );
                                    }
                                  },
                            child: const Text('Xóa lịch sử', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800),
                  ),
                  onTap: () async {
                    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                    navProvider.setIndex(0);

                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );

                    await authProvider.logout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
