import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../domain/entities/deposit_transaction_entity.dart';
import '../../providers/landlord_provider.dart';
import '../../providers/room_provider.dart';

class LandlordStatsScreen extends StatelessWidget {
  const LandlordStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final landlordProvider = Provider.of<LandlordProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);

    final rooms = roomProvider.landlordRooms;
    final requests = landlordProvider.rentalRequests;
    final transactions = landlordProvider.transactions;

    final totalViews = rooms.fold<int>(0, (sum, r) => sum + r.luotXem);
    final rentedCount = rooms.where((r) => r.trangThaiThue == 'DA_CHO_THUE').length;
    final occupancyRate = rooms.isNotEmpty ? (rentedCount / rooms.length * 100).toStringAsFixed(1) : '0.0';

    final totalDepositAmount = transactions.fold<double>(0, (sum, t) => sum + t.soTienCoc);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi Giao dịch & Thống kê'),
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
                'Thống kê Hiệu quả Cá nhân',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'Tổng tin phòng',
                          '${rooms.length} phòng',
                          Icons.home_work_rounded,
                          AppColors.primaryLight,
                          AppGradients.metricBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'Tỷ lệ lấp đầy',
                          '$occupancyRate %',
                          Icons.pie_chart_rounded,
                          AppColors.accent,
                          AppGradients.metricTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'Tổng lượt xem',
                          '$totalViews lượt',
                          Icons.visibility_rounded,
                          AppColors.warning,
                          AppGradients.metricOrange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'Yêu cầu thuê',
                          '${requests.length} phiếu',
                          Icons.assignment_turned_in_rounded,
                          const Color(0xFF9B6FE0),
                          AppGradients.metricPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        gradient: AppGradients.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TỔNG TIỀN ĐẶT CỌC THÀNH CÔNG',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${totalDepositAmount.toStringAsFixed(0)} VNĐ',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Lịch sử Giao dịch Đặt cọc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              if (transactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('Chưa có giao dịch đặt cọc nào thành công', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                )
              else
                Column(
                  children: transactions.map((tx) {
                    return _buildTransactionCard(tx, landlordProvider);
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(DepositTransactionEntity tx, LandlordProvider provider) {
    final reqs = provider.rentalRequests.where((r) => r.maYeuCau == tx.maYeuCau);
    final req = reqs.isNotEmpty ? reqs.first : null;
    final studentName = req != null ? req.tenSinhVien : 'Sinh viên';
    final roomId = req != null ? req.maPhong : 'Phòng trọ';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: AppColors.success, size: 20),
        ),
        title: Text(
          'SV: $studentName • Phòng: #$roomId',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          'Mã GD: ${tx.maGiaoDich} • Phiếu YC: #${tx.maYeuCau} • Cổng: ${tx.phuongThuc}',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+${tx.soTienCoc.toStringAsFixed(0)} đ',
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.success, fontSize: 13),
            ),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(tx.ngayGiaoDich),
              style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
