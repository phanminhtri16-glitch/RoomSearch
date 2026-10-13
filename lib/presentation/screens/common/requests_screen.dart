import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/utils/code_generator_util.dart';
import '../../../domain/entities/rental_request_entity.dart';
import '../../../domain/entities/room_entity.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/landlord_provider.dart';
import '../../providers/room_provider.dart';
import '../student/payment_screen.dart';
import 'chat_detail_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _selectedTab = 'CHO_XU_LY';

  List<RentalRequestEntity> _deduplicateRequests(List<RentalRequestEntity> requests) {
    final Map<String, RentalRequestEntity> latestMap = {};

    for (var req in requests) {
      final studentKey = (req.maSV.isNotEmpty ? req.maSV : (req.tenSV ?? 'SV_UNKNOWN')).trim();
      final roomKey = req.maPhong.trim();
      final key = '${studentKey}_$roomKey';

      if (!latestMap.containsKey(key)) {
        latestMap[key] = req;
      } else {
        final existing = latestMap[key]!;
        if (req.ngayTao.isAfter(existing.ngayTao)) {
          latestMap[key] = req;
        }
      }
    }

    final result = latestMap.values.toList();
    result.sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final landlordProvider = Provider.of<LandlordProvider>(context);
    final isLandlord =
        authProvider.currentUser?.vaiTro == AppConstants.roleLandlord;

    final currentUser = authProvider.currentUser;
    final rawRequests = isLandlord
        ? landlordProvider.rentalRequests
        : landlordProvider.rentalRequests
            .where((r) =>
                currentUser == null ||
                r.maSV == currentUser.maTK ||
                r.maSV == currentUser.email ||
                (currentUser.hoTen.isNotEmpty && r.tenSV == currentUser.hoTen))
            .toList();

    final activeRequests = rawRequests.where((r) => r.trangThai != 'DA_COC').toList();
    final allRequests = _deduplicateRequests(activeRequests);

    final pendingRequests = allRequests
        .where((r) => r.trangThai == 'CHO_XU_LY')
        .toList();
    final acceptedRequests = allRequests
        .where(
          (r) =>
              r.trangThai == 'CHO_THANH_TOAN' || r.trangThai == 'DA_CHAP_NHAN',
        )
        .toList();
    final rejectedRequests = allRequests
        .where((r) => r.trangThai == 'TU_CHOI' || r.trangThai == 'DA_HUY')
        .toList();

    List<RentalRequestEntity> currentList = allRequests;
    if (_selectedTab == 'CHO_XU_LY') currentList = pendingRequests;
    if (_selectedTab == 'DA_CHAP_NHAN') currentList = acceptedRequests;
    if (_selectedTab == 'TU_CHOI') currentList = rejectedRequests;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLandlord ? 'Quản lý Yêu cầu thuê' : 'Yêu cầu thuê phòng của tôi',
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isLandlord
                            ? 'Chủ trọ vui lòng đưa ra quyết định Chấp nhận hoặc Từ chối trong thời hạn quy định 48 giờ kể từ khi nhận được yêu cầu.'
                            : 'Bạn có tối đa 5 yêu cầu thuê đang ở trạng thái "Chờ xử lý". Khi được Chấp nhận, vui lòng hoàn tất đặt cọc VNPay/MoMo trong 15 phút.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabChip(
                      'CHO_XU_LY',
                      'Chờ xử lý (${pendingRequests.length})',
                    ),
                    const SizedBox(width: 8),
                    _buildTabChip(
                      'DA_CHAP_NHAN',
                      'Đã chấp nhận (${acceptedRequests.length})',
                    ),
                    const SizedBox(width: 8),
                    _buildTabChip(
                      'TU_CHOI',
                      'Đã từ chối/Hủy (${rejectedRequests.length})',
                    ),
                    const SizedBox(width: 8),
                    _buildTabChip('TAT_CA', 'Tất cả (${allRequests.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (currentList.isEmpty)
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
                      'Không có yêu cầu thuê nào ở danh mục này',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                )
              else
                Column(
                  children: currentList.map((req) {
                    return _buildRequestCard(
                      context,
                      req,
                      landlordProvider,
                      isLandlord,
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabChip(String key, String label) {
    final isSel = _selectedTab == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: isSel ? AppColors.primary : AppColors.border),
      labelStyle: TextStyle(
        color: isSel ? Colors.white : AppColors.textSecondary,
        fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
        fontSize: 12,
      ),
      onSelected: (sel) {
        if (sel) setState(() => _selectedTab = key);
      },
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    RentalRequestEntity req,
    LandlordProvider provider,
    bool isLandlord,
  ) {
    final deadline = req.ngayTao.add(const Duration(hours: 48));
    final now = DateTime.now();
    final remainingDiff = deadline.difference(now);

    String remainingText = '';
    bool isExpired = remainingDiff.isNegative;
    if (!isExpired) {
      final hours = remainingDiff.inHours;
      final minutes = remainingDiff.inMinutes.remainder(60);
      remainingText = 'Còn $hours giờ $minutes phút';
    } else {
      remainingText = 'Đã hết hạn 48h';
    }

    Color statusBgColor = AppColors.badgePending;
    Color statusTextColor = AppColors.badgePendingText;
    String statusText = 'Chờ xử lý';
    if (req.trangThai == 'CHO_THANH_TOAN' || req.trangThai == 'DA_CHAP_NHAN') {
      statusBgColor = AppColors.badgeApproved;
      statusTextColor = AppColors.badgeApprovedText;
      statusText = 'Đã chấp nhận (Cần cọc)';
    } else if (req.trangThai == 'TU_CHOI') {
      statusBgColor = AppColors.badgeRejected;
      statusTextColor = AppColors.badgeRejectedText;
      statusText = 'Bị từ chối';
    } else if (req.trangThai == 'DA_HUY') {
      statusBgColor = AppColors.surfaceLight;
      statusTextColor = AppColors.textLight;
      statusText = 'Đã hủy';
    }

    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    RoomEntity actualRoom;
    final approvedFound = roomProvider.approvedRooms.where((r) => r.maPhong == req.maPhong);
    final landlordFound = roomProvider.landlordRooms.where((r) => r.maPhong == req.maPhong);
    if (approvedFound.isNotEmpty) {
      actualRoom = approvedFound.first;
    } else if (landlordFound.isNotEmpty) {
      actualRoom = landlordFound.first;
    } else {
      actualRoom = RoomEntity(
        maPhong: req.maPhong,
        maChuTro: req.maChuTro ?? 'LANDLORD',
        tieuDe: 'Phòng trọ mã #${CodeGeneratorUtil.formatRoomDisplayCode(req.maPhong)}',
        diaChi: 'Chi tiết địa chỉ phòng trọ',
        quanHuyen: '',
        giaThue: 3000000,
        dienTich: 20,
        loaiPhong: 'Phòng trọ',
        moTa: 'Chi tiết phòng...',
        trangThaiDuyet: 'DA_DUYET',
        trangThaiThue: 'CON_TRONG',
        danhSachAnh: [],
        tienIch: [],
      );
    }

    final rawLandlordName = req.maChuTro != null ? adminProvider.getLandlordName(req.maChuTro!) : '';
    final displayLandlordName = (rawLandlordName.isNotEmpty && rawLandlordName != req.maChuTro)
        ? (rawLandlordName.startsWith('Chủ trọ') ? rawLandlordName : 'Chủ trọ $rawLandlordName')
        : 'Chủ trọ 1';

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
                'Mã phiếu: #${req.maYeuCau}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          if (req.trangThai == 'CHO_XU_LY') ...[
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'Thời gian phản hồi 48h: $remainingText',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isExpired ? AppColors.error : AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          Text(
            isLandlord
                ? 'Sinh viên: ${req.tenSinhVien}'
                : displayLandlordName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text('Phòng trọ mã: ${CodeGeneratorUtil.formatRoomDisplayCode(req.maPhong)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(
            'Ngày muốn vào ở: ${DateFormat('dd/MM/yyyy').format(req.ngayMuonVaoO)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            'Thời hạn thuê: ${req.thoiHanThue} tháng | Số người ở: ${req.soNguoiO} người',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),

          if (req.ghiChu.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Ghi chú bổ sung: "${req.ghiChu}"',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          if (req.lyDoTuChoi != null) ...[
            const SizedBox(height: 6),
            Text(
              'Lý do từ chối: "${req.lyDoTuChoi}"',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  final targetId = isLandlord
                      ? req.maSV
                      : (req.maChuTro ?? 'LANDLORD_1');
                  final targetName = isLandlord
                      ? (req.tenSinhVien.startsWith('Sinh viên') ? req.tenSinhVien : 'Sinh viên ${req.tenSinhVien}')
                      : displayLandlordName;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        targetUserId: targetId,
                        targetUserName: targetName,
                        roomId: req.maPhong,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('Nhắn tin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),

              if (!isLandlord) ...[
                if (req.trangThai == 'CHO_XU_LY') ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final success = await provider.cancelRentalRequest(req.maYeuCau);
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã hủy phiếu yêu cầu thuê phòng!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Hủy yêu cầu',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                if (req.trangThai == 'CHO_THANH_TOAN' ||
                    req.trangThai == 'DA_CHAP_NHAN') ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            room: actualRoom,
                            requestId: req.maYeuCau,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment_rounded, size: 16),
                    label: const Text(
                      'Thanh toán cọc',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],

              if (isLandlord && req.trangThai == 'CHO_XU_LY') ...[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showRejectDialog(context, req, provider),
                  child: const Text(
                    'Từ chối',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (provider.hasActiveAcceptedRequestForRoom(
                      req.maPhong,
                      excludeRequestId: req.maYeuCau,
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Phòng này đang có 1 phiếu thuê được chấp nhận chờ cọc. Bạn không thể chấp nhận phiếu khác cho đến khi sinh viên đó hủy yêu cầu.',
                          ),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }

                    final ok = await provider.acceptRentalRequest(
                      req.maYeuCau,
                    );
                    if (context.mounted && ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Đã chấp nhận yêu cầu thuê! Sinh viên nhận được thông báo đặt cọc.',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else if (context.mounted && !ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Phòng này đang có 1 phiếu thuê được chấp nhận chờ cọc. Bạn không thể chấp nhận phiếu khác cho đến khi sinh viên đó hủy yêu cầu.',
                          ),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Chấp nhận',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    RentalRequestEntity req,
    LandlordProvider provider,
  ) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Từ chối yêu cầu thuê'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vui lòng nhập lý do cụ thể gửi tới Sinh viên (Bắt buộc):',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Ví dụ: Phòng đã có khách cọc trực tiếp...',
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                final reason = reasonCtrl.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập lý do từ chối'),
                    ),
                  );
                  return;
                }
                final ok = await provider.rejectRentalRequest(
                  req.maYeuCau,
                  reason,
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã từ chối yêu cầu thuê')),
                    );
                  }
                }
              },
              child: const Text('Xác nhận từ chối', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }
}
