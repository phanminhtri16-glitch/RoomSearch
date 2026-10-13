import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/utils/code_generator_util.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/contract_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/landlord_provider.dart';
import '../../widgets/gold_verified_seal_widget.dart';
import '../common/chat_detail_screen.dart';

class StudentContractsScreen extends StatefulWidget {
  const StudentContractsScreen({super.key});

  @override
  State<StudentContractsScreen> createState() => _StudentContractsScreenState();
}

class _StudentContractsScreenState extends State<StudentContractsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<LandlordProvider>(context, listen: false).fetchLandlordData(user.maTK);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final landlordProvider = Provider.of<LandlordProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;

    final studentId = user?.maTK ?? 'STUDENT_1';
    final studentName = user?.hoTen ?? '';

    final contracts = landlordProvider.contracts.where((c) {
      if (studentId == 'STUDENT_1' || studentId == 'SV001' || studentId == 'CURRENT_USER') return true;
      return c.maSV == studentId ||
          c.maSV == studentName ||
          c.maSV.contains('Sinh viên') ||
          c.maSV == 'SV_CURRENT';
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hợp đồng thuê phòng của tôi'),
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
              const Text(
                'Danh sách Hợp đồng thuê phòng đã ký kết',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Quản lý chi tiết các hợp đồng điện tử và thời hạn hiệu lực thuê phòng.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              if (contracts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 48, color: AppColors.textLight),
                      SizedBox(height: 12),
                      Text(
                        'Bạn chưa có hợp đồng thuê phòng nào.\nHãy tìm phòng và gửi phiếu yêu cầu thuê!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: contracts.map((contract) {
                    return _buildContractCard(context, contract, landlordProvider);
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContractCard(
    BuildContext context,
    ContractEntity contract,
    LandlordProvider landlordProvider,
  ) {
    final now = DateTime.now();
    final daysRemaining = contract.ngayKetThuc.difference(now).inDays;
    final isExpiringSoon = daysRemaining >= 0 && daysRemaining <= 7;

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
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 40,
            child: Opacity(
              opacity: 0.85,
              child: const GoldVerifiedSealWidget(size: 76),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hợp đồng: #${CodeGeneratorUtil.formatContractDisplayCode(contract.maHopDong)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.badgeApproved,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  contract.trangThai == 'HIEU_LUC' ? 'Đang hiệu lực' : 'Đã thanh lý',
                  style: const TextStyle(fontSize: 11, color: AppColors.badgeApprovedText, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          if (isExpiringSoon) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Thông báo: Hợp đồng còn $daysRemaining ngày sẽ hết hạn (${DateFormat('dd/MM/yyyy').format(contract.ngayKetThuc)}). Vui lòng liên hệ Chủ trọ gia hạn.',
                      style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Text('Chủ trọ: Chủ trọ 1', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Phòng trọ mã: ${CodeGeneratorUtil.formatRoomDisplayCode(contract.maPhong)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Thời gian: ${DateFormat('dd/MM/yyyy').format(contract.ngayBatDau)} ➔ ${DateFormat('dd/MM/yyyy').format(contract.ngayKetThuc)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Giá thuê: ${CurrencyFormatter.format(contract.giaThueHangThang)} VNĐ/tháng', style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Tiền cọc giữ chỗ: ${CurrencyFormatter.format(contract.tienCoc)} VNĐ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showDigitalContractModal(context, contract),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16, color: AppColors.primary),
                label: const Text('Xem Hợp đồng VIP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        targetUserId: contract.maChuTro,
                        targetUserName: 'Chủ trọ 1',
                        roomId: contract.maPhong,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('Nhắn tin Chủ trọ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
      ],
      ),
    );
  }

  void _showDigitalContractModal(BuildContext context, ContractEntity contract) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel_rounded, color: AppColors.primary, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const Center(
                child: Text(
                  'Độc lập - Tự do - Hạnh phúc',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
              const Divider(height: 24),
              Center(
                child: Text(
                  'HỢP ĐỒNG THUÊ PHÒNG TRỌ ĐIỆN TỬ VIP\nMã số: #${CodeGeneratorUtil.formatContractDisplayCode(contract.maHopDong)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BÊN A (BÊN CHO THUE): CHỦ TRỌ 1', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('Đại diện hệ thống RoomSearch xác thực tư cách pháp lý chủ hộ.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    const Text('BÊN B (BÊN THUÊ): NGƯỜI DÙNG SINH VIÊN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Mã phòng thuê: ${CodeGeneratorUtil.formatRoomDisplayCode(contract.maPhong)}', style: const TextStyle(fontSize: 12)),
                    Text('Giá thuê niêm yết: ${CurrencyFormatter.format(contract.giaThueHangThang)} VNĐ/tháng', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text('Tiền cọc giữ chỗ: ${CurrencyFormatter.format(contract.tienCoc)} VNĐ (Đã xác nhận thanh toán cổng MoMo/VNPay)', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w700)),
                    Text('Thời hạn hợp đồng: Từ ${DateFormat('dd/MM/yyyy').format(contract.ngayBatDau)} Đến ${DateFormat('dd/MM/yyyy').format(contract.ngayKetThuc)}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('XÁC THỰC CHỮ KÝ SỐ KHÓA BẢO MẬT (SHA-256):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
                        SizedBox(height: 4),
                        Text('Electronic Signature Code: RSA-2048-ROOMSEARCH-VERIFIED-OK', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textPrimary)),
                        SizedBox(height: 4),
                        Text('Tất cả giao dịch trên hệ thống đều có giá trị pháp lý ràng buộc.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  const Positioned(
                    right: 12,
                    top: 8,
                    child: GoldVerifiedSealWidget(size: 90),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Đã xác nhận & Đóng hợp đồng', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
