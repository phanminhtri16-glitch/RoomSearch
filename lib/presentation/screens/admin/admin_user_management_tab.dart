import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/services/email_service.dart';
import '../../../core/utils/otp_generator.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';

class AdminUserManagementTab extends StatefulWidget {
  const AdminUserManagementTab({super.key});

  @override
  State<AdminUserManagementTab> createState() => _AdminUserManagementTabState();
}

class _AdminUserManagementTabState extends State<AdminUserManagementTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchKeyword = '';
  String _selectedRoleFilter = 'ALL';
  String _selectedStatusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.fetchUsers();
      provider.fetchAuditLogs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentAdmin = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tài khoản & Audit Log'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tài khoản người dùng'),
            Tab(text: 'Nhật ký hệ thống (Audit Logs)'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUserListSubTab(context, adminProvider, currentAdmin),
            _buildAuditLogSubTab(context, adminProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListSubTab(BuildContext context, AdminProvider provider, UserEntity? currentAdmin) {
    var users = provider.allUsers.where((u) => u.vaiTro != AppConstants.roleAdmin).toList();

    if (_selectedRoleFilter != 'ALL') {
      users = users.where((u) => u.vaiTro == _selectedRoleFilter).toList();
    }

    if (_selectedStatusFilter != 'ALL') {
      users = users.where((u) => u.trangThai == _selectedStatusFilter).toList();
    }

    if (_searchKeyword.trim().isNotEmpty) {
      final kw = _searchKeyword.toLowerCase().trim();
      users = users.where((u) =>
          u.hoTen.toLowerCase().contains(kw) ||
          u.email.toLowerCase().contains(kw) ||
          u.soDienThoai.contains(kw) ||
          u.maTK.toLowerCase().contains(kw)).toList();
    }

    return RefreshIndicator(
      onRefresh: () async => await provider.fetchUsers(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                TextField(
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên, email, sđt...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchKeyword = val;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _selectedRoleFilter,
                      underline: const SizedBox(),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('Vai trò: Tất cả')),
                        DropdownMenuItem(value: AppConstants.roleStudent, child: Text('Sinh viên')),
                        DropdownMenuItem(value: AppConstants.roleLandlord, child: Text('Chủ trọ')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedRoleFilter = val;
                          });
                        }
                      },
                    ),
                    DropdownButton<String>(
                      value: _selectedStatusFilter,
                      underline: const SizedBox(),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('Trạng thái: Tất cả')),
                        DropdownMenuItem(value: 'HOAT_DONG', child: Text('Hoạt động')),
                        DropdownMenuItem(value: 'CHO_XAC_THUC', child: Text('Chưa xác thực OTP')),
                        DropdownMenuItem(value: 'KHOA', child: Text('Đã khóa')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedStatusFilter = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : users.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Không tìm thấy tài khoản nào',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final isUnverified = user.trangThai == 'CHO_XAC_THUC';
                            final isLocked = user.trangThai == 'KHOA';
                            final isStudent = user.vaiTro == AppConstants.roleStudent;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isUnverified ? AppColors.warning.withValues(alpha: 0.15) : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isUnverified
                                      ? AppColors.warning
                                      : (isLocked
                                          ? AppColors.error
                                          : AppColors.border),
                                  width: isUnverified ? 1.5 : 1,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isUnverified
                                      ? AppColors.warning.withValues(alpha: 0.2)
                                      : (isLocked
                                          ? AppColors.error.withValues(alpha: 0.2)
                                          : (isStudent ? AppColors.primary.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2))),
                                  child: Icon(
                                    isUnverified
                                        ? Icons.mark_email_unread_outlined
                                        : (isLocked ? Icons.lock_rounded : (isStudent ? Icons.school_rounded : Icons.home_work_rounded)),
                                    color: isUnverified
                                        ? AppColors.warning
                                        : (isLocked ? AppColors.error : (isStudent ? AppColors.primaryLight : Colors.orange)),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.hoTen.isNotEmpty ? user.hoTen : 'Chưa đặt tên',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: isUnverified ? AppColors.warning : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isUnverified
                                            ? AppColors.badgePending
                                            : (isLocked ? AppColors.badgeRejected : AppColors.badgeApproved),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isUnverified
                                            ? '⚠️ Chưa xác thực OTP'
                                            : (isLocked ? 'Đã khóa' : 'Hoạt động'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isUnverified
                                              ? AppColors.badgePendingText
                                              : (isLocked ? AppColors.badgeRejectedText : AppColors.badgeApprovedText),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Role: ${user.vaiTro} | SĐT: ${user.soDienThoai}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text('Email: ${user.email}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    if (isUnverified)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                                        child: Text(
                                          '⚠️ Trạng thái: Chưa xác thực OTP (Mã: ${user.currentOtp ?? "Hết hạn"})',
                                          style: const TextStyle(
                                            color: AppColors.warning,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                                  color: AppColors.surface,
                                  onSelected: (action) async {
                                    if (action == 'TOGGLE_LOCK') {
                                       final newStatus = isLocked ? 'HOAT_DONG' : 'KHOA';
                                       final ok = await provider.updateUserStatus(
                                         userId: user.maTK,
                                         status: newStatus,
                                         reason: 'Admin thay đổi trạng thái tài khoản',
                                         adminId: 'ADMIN',
                                         adminEmail: 'admin@system.com',
                                         userEmail: user.email,
                                         currentStatus: user.trangThai,
                                       );
                                       if (context.mounted && ok) {
                                         ScaffoldMessenger.of(context).showSnackBar(
                                           SnackBar(
                                             content: Text(isLocked ? 'Đã mở khóa tài khoản!' : 'Đã khóa tài khoản!'),
                                             backgroundColor: isLocked ? AppColors.success : AppColors.error,
                                           ),
                                         );
                                       }
                                     } else if (action == 'BYPASS_OTP') {
                                       final ok = await provider.updateUserStatus(
                                         userId: user.maTK,
                                         status: 'DA_XAC_THUC',
                                         reason: 'Admin xác thực tài khoản thủ công',
                                         adminId: 'ADMIN',
                                         adminEmail: 'admin@system.com',
                                         userEmail: user.email,
                                         currentStatus: user.trangThai,
                                       );
                                       if (context.mounted && ok) {
                                         ScaffoldMessenger.of(context).showSnackBar(
                                           const SnackBar(
                                             content: Text('Đã xác thực tài khoản thủ công thành công!'),
                                             backgroundColor: AppColors.success,
                                           ),
                                         );
                                       }
                                     } else if (action == 'RESEND_OTP') {
                                      _resendOtpByAdmin(context, provider, user);
                                    } else if (action == 'DELETE') {
                                      _confirmDeleteUser(context, provider, user);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    if (isUnverified) ...[
                                      const PopupMenuItem(
                                        value: 'BYPASS_OTP',
                                        child: Row(
                                          children: [
                                            Icon(Icons.verified, color: AppColors.success, size: 18),
                                            SizedBox(width: 8),
                                            Text('Xác thực thủ công (Kích hoạt)', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'RESEND_OTP',
                                        child: Row(
                                          children: [
                                            Icon(Icons.mark_email_read, color: AppColors.primaryLight, size: 18),
                                            SizedBox(width: 8),
                                            Text('Gửi lại mã OTP mới', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    PopupMenuItem(
                                      value: 'TOGGLE_LOCK',
                                      child: Row(
                                        children: [
                                          Icon(isLocked ? Icons.lock_open : Icons.block, color: isLocked ? AppColors.success : AppColors.error, size: 18),
                                          const SizedBox(width: 8),
                                          Text(isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'DELETE',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_forever, color: AppColors.error, size: 18),
                                          SizedBox(width: 8),
                                          Text('Xóa vĩnh viễn', style: TextStyle(color: AppColors.error, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogSubTab(BuildContext context, AdminProvider provider) {
    final logs = provider.auditLogs;

    return RefreshIndicator(
      onRefresh: () async => await provider.fetchAuditLogs(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ghi nhận Lịch sử Thao tác (Audit Trail):',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            const Text(
              'Hệ thống tự động ghi nhật ký mọi hành vi kiểm duyệt tin, khóa tài khoản, thay đổi tham số...',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : logs.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Chưa có dữ liệu nhật ký hệ thống',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            final dateStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(log.thoiGian);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                         log.hanhDong,
                                         style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryLight),
                                       ),
                                       Text(
                                         dateStr,
                                         style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                       ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                     log.lyDo,
                                     style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                   ),
                                  const SizedBox(height: 4),
                                  Text(
                                     'Admin ID: ${log.adminId}',
                                     style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                                   ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _resendOtpByAdmin(BuildContext context, AdminProvider provider, UserEntity user) async {
    final newOtp = OtpGenerator.generate6DigitOtp();
    await EmailService.sendOtpEmail(recipientEmail: user.email, otpCode: newOtp);
    if (context.mounted) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Đã phát hành Mã OTP mới!'),
            content: Text(
              'Hệ thống đã cấp mã OTP mới [ $newOtp ] và tự động gửi email đến địa chỉ "${user.email}".',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _confirmDeleteUser(BuildContext context, AdminProvider provider, UserEntity user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Xóa vĩnh viễn: ${user.hoTen}'),
        content: Text(
          'Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản "${user.email}" khỏi hệ thống không?\n\nHành động này không thể phục hồi.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      final ok = await provider.deleteUserAccount(user.maTK, roomProvider);
      if (context.mounted && ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa vĩnh viễn tài khoản người dùng khỏi hệ thống!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
