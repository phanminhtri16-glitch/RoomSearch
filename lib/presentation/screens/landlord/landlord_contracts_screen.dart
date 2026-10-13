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
import '../../providers/room_provider.dart';

class LandlordContractsScreen extends StatelessWidget {
  const LandlordContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final landlordProvider = Provider.of<LandlordProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;

    final contracts = landlordProvider.contracts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý hợp đồng & Trạng thái phòng'),
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
                'Danh sách Hợp đồng thuê phòng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hệ thống tự động nhắc nhở gia hạn hợp đồng trước khi kết thúc 7 ngày.',
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
                  child: const Center(
                    child: Text('Chưa có hợp đồng thuê phòng nào được khởi tạo', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                )
              else
                Column(
                  children: contracts.map((contract) {
                    return _buildContractCard(context, contract, roomProvider, landlordProvider, user?.maTK ?? '');
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
    RoomProvider roomProvider,
    LandlordProvider landlordProvider,
    String landlordId,
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
      child: Column(
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
                      'Thông báo tự động: Hợp đồng chỉ còn $daysRemaining ngày sẽ hết hạn (${DateFormat('dd/MM/yyyy').format(contract.ngayKetThuc)}). Vui lòng liên hệ Sinh viên gia hạn.',
                      style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Text('Sinh viên thuê: ${_getStudentDisplayName(contract, landlordProvider)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Phòng trọ mã: ${CodeGeneratorUtil.formatRoomDisplayCode(contract.maPhong)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Thời gian: ${DateFormat('dd/MM/yyyy').format(contract.ngayBatDau)} ➔ ${DateFormat('dd/MM/yyyy').format(contract.ngayKetThuc)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Giá thuê: ${CurrencyFormatter.format(contract.giaThueHangThang)} VNĐ/tháng', style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Tiền cọc giữ chỗ: ${CurrencyFormatter.format(contract.tienCoc)} VNĐ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          if (contract.trangThai == 'HIEU_LUC') ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.published_with_changes_rounded, size: 16, color: Colors.white),
                    label: const Text('Xác nhận trả phòng / Đăng lại phòng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận trả phòng'),
                          content: Text('Xác nhận sinh viên đã trả phòng #${contract.maPhong} và muốn chuyển trạng thái phòng về "Còn trống" để đăng lại?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đồng ý')),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await landlordProvider.terminateContractAndRelistRoom(contract.maPhong, landlordId);
                        final ok = await roomProvider.relistRoom(contract.maPhong, landlordId);
                        if (context.mounted && ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xác nhận trả phòng & cập nhật trạng thái hợp đồng về "Đã thanh lý"!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getStudentDisplayName(ContractEntity contract, LandlordProvider landlordProvider) {
    final rawName = contract.maSV.trim();
    if (rawName.startsWith('Sinh viên') && !rawName.contains('72')) {
      return rawName;
    }
    final matchedReq = landlordProvider.rentalRequests
        .where((r) => r.maYeuCau == contract.maYeuCau || r.maPhong == contract.maPhong)
        .firstOrNull;
    if (matchedReq != null && matchedReq.tenSV != null && matchedReq.tenSV!.trim().isNotEmpty) {
      final tName = matchedReq.tenSV!.trim();
      if (tName.startsWith('Sinh viên') && !tName.contains('72')) {
        return tName;
      }
      return 'Sinh viên 1';
    }
    return CodeGeneratorUtil.formatStudentDisplayCode(contract.maSV);
  }
}
