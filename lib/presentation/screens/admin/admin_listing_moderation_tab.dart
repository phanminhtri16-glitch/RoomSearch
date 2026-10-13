import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../data/models/room_model.dart';
import '../../providers/admin_provider.dart';
import 'admin_room_detail_dialog.dart';

class AdminListingModerationTab extends StatefulWidget {
  const AdminListingModerationTab({super.key});

  @override
  State<AdminListingModerationTab> createState() => _AdminListingModerationTabState();
}

class _AdminListingModerationTabState extends State<AdminListingModerationTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.fetchUsers();
      provider.fetchPendingRooms();
      provider.fetchDeletedRooms();
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
    final pendingRooms = adminProvider.pendingRooms;
    final deletedRooms = adminProvider.deletedRooms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyệt & Quản lý Tin đăng'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chờ duyệt'),
                  if (pendingRooms.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.warning,
                      child: Text(
                        '${pendingRooms.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tin bị xóa'),
                  if (deletedRooms.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.textLight,
                      child: Text(
                        '${deletedRooms.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPendingApprovalSubTab(context, adminProvider),
            _buildDeletedListingsSubTab(context, adminProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovalSubTab(BuildContext context, AdminProvider provider) {
    final pendingRooms = provider.pendingRooms;
    final overdueRooms = provider.overduePendingRooms;

    return RefreshIndicator(
      onRefresh: () async => await provider.fetchPendingRooms(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (overdueRooms.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cảnh báo tồn đọng (${overdueRooms.length} tin > 24h)!',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.error, fontSize: 13),
                          ),
                          const Text(
                            'Quy định hệ thống yêu cầu Admin phải kiểm duyệt tin đăng trong vòng 24 giờ làm việc.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Danh sách Tin đăng phòng trọ gửi kiểm duyệt:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            if (provider.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
            else if (pendingRooms.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'Hiện tại không có tin đăng nào đang chờ duyệt',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingRooms.length,
                itemBuilder: (context, index) {
                  final room = pendingRooms[index];
                  final isOverdue = room.ngayTao != null &&
                      DateTime.now().difference(room.ngayTao!).inHours >=
                          provider.systemParams.adminApprovalDeadlineHours;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chủ trọ: ${provider.getLandlordName(room.maChuTro)}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOverdue ? AppColors.badgeRejected : AppColors.badgePending,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isOverdue ? 'Quá hạn 24h!' : 'Chờ duyệt (<24h)',
                                style: TextStyle(fontSize: 11, color: isOverdue ? AppColors.badgeRejectedText : AppColors.badgePendingText, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Text(
                          room.tieuDe,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Địa chỉ: ${room.diaChi}, ${room.quanHuyen}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${room.giaThue.toStringAsFixed(0)} đ/tháng | ${room.dienTich}m²',
                              style: const TextStyle(fontSize: 13, color: AppColors.primaryLight, fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Text(
                              'Số lần resubmit: ${room.soLanTuChoi}/${provider.systemParams.maxRejectionResubmissions}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AdminRoomDetailDialog(
                                    room: room,
                                    landlordName: provider.getLandlordName(room.maChuTro),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined, size: 16),
                              label: const Text('Xem Chi tiết', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  final ok = await provider.approveOrRejectRoom(
                                    roomId: room.maPhong,
                                    status: 'DA_DUYET',
                                    landlordId: room.maChuTro,
                                  );
                                  if (context.mounted && ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã duyệt tin đăng thành công!'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                                label: const Text('Duyệt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _showRejectDialog(context, provider, room),
                                icon: const Icon(Icons.cancel_outlined, size: 16),
                                label: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedListingsSubTab(BuildContext context, AdminProvider provider) {
    final deletedRooms = provider.deletedRooms;

    return RefreshIndicator(
      onRefresh: () async => await provider.fetchDeletedRooms(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primaryLight, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Thùng rác hệ thống: Lưu trữ tin bị xóa trong 30 ngày trước khi xóa vĩnh viễn. Admin có thể phục hồi tin đăng bất cứ lúc nào.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (provider.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
            else if (deletedRooms.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'Thùng rác trống - Không có tin đăng nào bị xóa',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: deletedRooms.length,
                itemBuilder: (context, index) {
                  final room = deletedRooms[index];
                  final daysDeleted = room.deletedAt != null
                      ? DateTime.now().difference(room.deletedAt!).inDays
                      : 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mã phòng: ${room.maPhong}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Đã xóa $daysDeleted/30 ngày',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          room.tieuDe,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Địa chỉ: ${room.diaChi}, ${room.quanHuyen}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                final ok = await provider.restoreDeletedRoom(room.maPhong);
                                if (context.mounted && ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã phục hồi tin đăng thành công!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.restore_from_trash_rounded, size: 16, color: Colors.white),
                              label: const Text('Phục hồi tin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AdminProvider provider, RoomModel room) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Từ chối tin đăng: ${room.tieuDe}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng nhập lý do từ chối để gửi thông báo cho Chủ trọ:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Ảnh phòng mờ không đạt chất lượng, địa chỉ chưa chính xác...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do từ chối!'), backgroundColor: AppColors.error),
                );
                return;
              }
              Navigator.pop(ctx);
              final ok = await provider.approveOrRejectRoom(
                roomId: room.maPhong,
                status: 'TU_CHOI',
                landlordId: room.maChuTro,
                rejectionReason: reason,
              );
              if (context.mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã từ chối tin đăng và thông báo cho Chủ trọ.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Từ chối tin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
