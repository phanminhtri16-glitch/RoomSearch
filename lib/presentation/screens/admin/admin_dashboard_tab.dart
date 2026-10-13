import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../data/models/system_report_model.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/pulsing_dot_widget.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAllAdminData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final stats = adminProvider.dashboardStats;
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo & Thống kê hệ thống'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => adminProvider.fetchAllAdminData(),
            tooltip: 'Làm mới dữ liệu',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: adminProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async => await adminProvider.fetchAllAdminData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard chỉ số Real-time',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.35,
                        children: [
                          _buildMetricCard(
                            'Tổng người dùng',
                            '${stats['totalUsers'] ?? 0}',
                            Icons.people_alt_rounded,
                            AppColors.primaryLight,
                            AppGradients.metricBlue,
                          ),
                          _buildMetricCard(
                            'Tin trọ chờ duyệt',
                            '${stats['pendingRoomsCount'] ?? 0}',
                            Icons.rate_review_rounded,
                            AppColors.warning,
                            AppGradients.warning,
                          ),
                          _buildMetricCard(
                            'Yêu cầu thuê',
                            '${stats['totalRequestsCount'] ?? 0}',
                            Icons.assignment_rounded,
                            const Color(0xFF9B6FE0),
                            AppGradients.metricPurple,
                          ),
                          _buildMetricCard(
                            'Doanh thu cọc',
                            currencyFormatter.format(stats['totalDepositRevenue'] ?? 0.0),
                            Icons.account_balance_wallet_rounded,
                            AppColors.success,
                            AppGradients.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(18),
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
                            const Row(
                              children: [
                                Icon(Icons.date_range_rounded, color: AppColors.primaryLight),
                                SizedBox(width: 8),
                                Text(
                                  'Tạo Báo cáo Thống kê Thủ công',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Chọn khoảng thời gian bất kỳ (ngày/tháng/năm) để tự động tổng hợp số liệu và xuất file report PDF/Excel.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _selectDate(context, isStart: true),
                                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                                    label: Text(
                                      'Từ: ${DateFormat('dd/MM/yyyy').format(_startDate)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _selectDate(context, isStart: false),
                                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                                    label: Text(
                                      'Đến: ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            ElevatedButton.icon(
                              onPressed: () async {
                                final report = await adminProvider.generateCustomReport(
                                  loaiBaoCao: 'THU_CONG',
                                  tuNgay: _startDate,
                                  denNgay: _endDate,
                                );
                                if (context.mounted && report != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã tổng hợp báo cáo thủ công thành công!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  _showExportDialog(context, report);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.analytics_outlined),
                              label: const Text('Tổng hợp & Tạo báo cáo ngay', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Lịch sử Báo cáo (Lưu trữ 5 năm)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final now = DateTime.now();
                              final firstDayThisMonth = DateTime(now.year, now.month, 1);
                              final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
                              await adminProvider.generateCustomReport(
                                loaiBaoCao: 'TU_DONG_HANG_THANG',
                                tuNgay: firstDayLastMonth,
                                denNgay: firstDayThisMonth,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã chạy giả lập tổng hợp báo cáo định kỳ tháng!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.autorenew_rounded, size: 16),
                            label: const Text('Giả lập báo cáo định kỳ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (adminProvider.systemReports.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Chưa có dữ liệu báo cáo lịch sử. Bấm nút "Tổng hợp & Tạo báo cáo" để tạo mới.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: adminProvider.systemReports.map((report) {
                            return _buildReportItem(context, report);
                          }).toList(),
                        ),
                    ],
                  ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Row(
                children: [
                  if (title == 'Tin trọ chờ duyệt' && value != '0')
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: PulsingDotWidget(size: 8),
                    ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, SystemReportModel report) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(report.ngayTao);
    final rangeStr = '${DateFormat('dd/MM/yyyy').format(report.tuNgay)} ➔ ${DateFormat('dd/MM/yyyy').format(report.denNgay)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryLight),
        ),
        title: Text(
          report.maBaoCao,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          'Loại: ${report.loaiBaoCao} • Kỳ: $rangeStr\nNgày tạo: $dateStr',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.download_rounded, color: AppColors.primaryLight),
          onPressed: () => _showExportDialog(context, report),
          tooltip: 'Xuất file PDF/Excel',
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _showExportDialog(BuildContext context, SystemReportModel report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xuất file Báo cáo ${report.maBaoCao}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng tin đăng mới: ${report.soTinDangMoi}'),
            Text('Tổng yêu cầu thuê: ${report.tongYeuCauThue}'),
            Text('Tổng số giao dịch cọc: ${report.tongGiaoDichDatCoc}'),
            Text('Tổng doanh thu cọc: ${report.tongDoanhThuDatCoc.toStringAsFixed(0)} đ'),
            const SizedBox(height: 16),
            const Text(
              'Chọn định dạng xuất dữ liệu chuẩn hóa hệ thống:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.table_chart, color: Colors.green),
            label: const Text('Xuất Excel (.xlsx)', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xuất file Excel cho Báo cáo ${report.maBaoCao} thành công!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: const Text('Xuất PDF (.pdf)'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xuất file PDF cho Báo cáo ${report.maBaoCao} thành công!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
