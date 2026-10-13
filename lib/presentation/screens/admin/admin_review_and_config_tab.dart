import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../data/models/system_param_model.dart';
import '../../providers/admin_provider.dart';

class AdminReviewAndConfigTab extends StatefulWidget {
  const AdminReviewAndConfigTab({super.key});

  @override
  State<AdminReviewAndConfigTab> createState() =>
      _AdminReviewAndConfigTabState();
}

class _AdminReviewAndConfigTabState extends State<AdminReviewAndConfigTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.fetchReviews();
      provider.fetchSystemParameters();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá & Tham số Hệ thống'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Giám sát Đánh giá'),
            Tab(text: 'Cấu hình Tham số'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildReviewModerationSubTab(context, adminProvider),
            _buildSystemParametersSubTab(context, adminProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewModerationSubTab(
    BuildContext context,
    AdminProvider provider,
  ) {
    final reviews = provider.reviews;

    return RefreshIndicator(
      onRefresh: () async => await provider.fetchReviews(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Giám sát & Xử lý Bài đánh giá:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ẩn các bài đánh giá chứa từ ngữ vi phạm. Điểm đánh giá trung bình của phòng trọ sẽ tự động được tính toán lại ngay lập tức.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: reviews.isEmpty
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
                          'Chưa có bài đánh giá nào',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        final isHidden = review.isHiddenByAdmin;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${review.tenSV} (${review.maSV})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isHidden
                                          ? AppColors.badgeRejected
                                          : AppColors.badgeApproved,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isHidden
                                          ? 'Đã ẩn (Vi phạm)'
                                          : 'Hiển thị',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isHidden
                                            ? AppColors.badgeRejectedText
                                            : AppColors.badgeApprovedText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text('Mã phòng: ${review.maPhong} | ', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text(
                                    '${review.diem} ⭐',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(review.ngayDanhGia),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isHidden
                                      ? AppColors.error.withValues(alpha: 0.1)
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  review.noiDung,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: isHidden
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    color: isHidden
                                        ? AppColors.error
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: isHidden
                                    ? OutlinedButton.icon(
                                        onPressed: () async {
                                          final success = await provider
                                              .toggleReviewVisibility(
                                                reviewId: review.maDanhGia,
                                                roomId: review.maPhong,
                                                isHidden: false,
                                              );
                                          if (context.mounted && success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Đã phục hồi bài đánh giá & tính lại điểm trung bình cho phòng!',
                                                ),
                                                backgroundColor:
                                                    AppColors.success,
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.visibility_rounded,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Phục hồi đánh giá',
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.success,
                                          side: const BorderSide(color: AppColors.success),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      )
                                    : OutlinedButton.icon(
                                        onPressed: () async {
                                          final success = await provider
                                              .toggleReviewVisibility(
                                                reviewId: review.maDanhGia,
                                                roomId: review.maPhong,
                                                isHidden: true,
                                              );
                                          if (context.mounted && success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Đã ẩn bài đánh giá vi phạm & tự động loại trừ khỏi điểm trung bình phòng!',
                                                ),
                                                backgroundColor:
                                                    AppColors.error,
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.visibility_off_rounded,
                                          size: 16,
                                        ),
                                        label: const Text('Ẩn bài vi phạm', style: TextStyle(fontWeight: FontWeight.w700)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                          side: const BorderSide(color: AppColors.error),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
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

  Widget _buildSystemParametersSubTab(
    BuildContext context,
    AdminProvider provider,
  ) {
    final p = provider.systemParams;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý trực tiếp bảng THAM_SO hệ thống:',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          const Text(
            'Điều chỉnh các tham số cấu hình quy định nghiệp vụ trực tiếp trong CSDL không cần thay đổi source code.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          _buildParamCard(
            context,
            '1. Quy định Tài khoản & OTP',
            [
              _paramRow('Độ tuổi tối thiểu đăng ký', '${p.minUserAge} tuổi'),
              _paramRow(
                'Thời gian hiệu lực mã OTP',
                '${p.otpValidityDurationSeconds} giây (5 phút)',
              ),
              _paramRow(
                'Số lần nhập sai OTP tối đa',
                '${p.otpMaxAttempts} lần',
              ),
              _paramRow(
                'Thời gian khóa OTP tạm thời',
                '${p.otpLockoutDurationSeconds} giây (15 phút)',
              ),
            ],
            onEdit: () => _editOtpParamsDialog(context, provider),
          ),
          const SizedBox(height: 14),

          _buildParamCard(
            context,
            '2. Quy định Đăng & Duyệt tin phòng',
            [
              _paramRow(
                'Số ảnh thực tế tối thiểu',
                '${p.minListingImages} ảnh',
              ),
              _paramRow(
                'Giá thuê phòng tối thiểu',
                '${p.minListingPrice.toStringAsFixed(0)} VNĐ',
              ),
              _paramRow(
                'Thời hạn Admin duyệt tin (SLA)',
                '${p.adminApprovalDeadlineHours} giờ',
              ),
              _paramRow(
                'Số lần Chủ trọ được sửa/gửi lại',
                '${p.maxRejectionResubmissions} lần',
              ),
            ],
            onEdit: () => _editListingParamsDialog(context, provider),
          ),
          const SizedBox(height: 14),

          _buildParamCard(
            context,
            '3. Quy định Thống kê, Yêu cầu thuê & Khác',
            [
              _paramRow(
                'Số yêu cầu thuê chờ tối đa',
                '${p.maxPendingRequestsPerStudent} yêu cầu',
              ),
              _paramRow(
                'Thời hạn Chủ trọ phản hồi yêu cầu',
                '${p.landlordResponseDeadlineHours} giờ',
              ),
              _paramRow(
                'Số ngày ở tối thiểu để viết đánh giá',
                '${p.minStayDaysForReview} ngày',
              ),
              _paramRow(
                'Số ký tự tối thiểu nhận xét',
                '${p.minReviewLength} ký tự',
              ),
              _paramRow(
                'Số phòng tối đa danh sách yêu thích',
                '${p.maxFavoriteRoomsPerStudent} phòng',
              ),
              _paramRow(
                'Thời gian xác nhận giao dịch cọc',
                '${p.depositConfirmationSeconds} giây',
              ),
            ],
            onEdit: () => _editOtherParamsDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildParamCard(
    BuildContext context,
    String title,
    List<Widget> children, {
    required VoidCallback onEdit,
  }) {
    return Container(
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
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.primaryLight,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
                onPressed: onEdit,
                tooltip: 'Điều chỉnh tham số',
              ),
            ],
          ),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _paramRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  void _editOtpParamsDialog(BuildContext context, AdminProvider provider) {
    final minAgeController = TextEditingController(
      text: provider.systemParams.minUserAge.toString(),
    );
    final otpDurationController = TextEditingController(
      text: provider.systemParams.otpValidityDurationSeconds.toString(),
    );
    final otpMaxAttemptsController = TextEditingController(
      text: provider.systemParams.otpMaxAttempts.toString(),
    );
    final otpLockoutController = TextEditingController(
      text: provider.systemParams.otpLockoutDurationSeconds.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Điều chỉnh Tham số OTP & Tài khoản'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minAgeController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Độ tuổi tối thiểu (mặc định 18)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: otpDurationController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Thời gian hiệu lực OTP (giây)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: otpMaxAttemptsController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số lần nhập sai tối đa',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: otpLockoutController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Thời gian khóa OTP tạm thời (giây)',
                ),
              ),
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
              final newModel = SystemParamModel(
                minUserAge:
                    int.tryParse(minAgeController.text) ??
                    provider.systemParams.minUserAge,
                otpValidityDurationSeconds:
                    int.tryParse(otpDurationController.text) ??
                    provider.systemParams.otpValidityDurationSeconds,
                otpMaxAttempts:
                    int.tryParse(otpMaxAttemptsController.text) ??
                    provider.systemParams.otpMaxAttempts,
                otpLockoutDurationSeconds:
                    int.tryParse(otpLockoutController.text) ??
                    provider.systemParams.otpLockoutDurationSeconds,
                minListingImages: provider.systemParams.minListingImages,
                minListingPrice: provider.systemParams.minListingPrice,
                adminApprovalDeadlineHours:
                    provider.systemParams.adminApprovalDeadlineHours,
                maxRejectionResubmissions:
                    provider.systemParams.maxRejectionResubmissions,
                maxPendingRequestsPerStudent:
                    provider.systemParams.maxPendingRequestsPerStudent,
                landlordResponseDeadlineHours:
                    provider.systemParams.landlordResponseDeadlineHours,
                minStayDaysForReview:
                    provider.systemParams.minStayDaysForReview,
                minReviewLength: provider.systemParams.minReviewLength,
                maxFavoriteRoomsPerStudent:
                    provider.systemParams.maxFavoriteRoomsPerStudent,
                depositConfirmationSeconds:
                    provider.systemParams.depositConfirmationSeconds,
              );
              Navigator.pop(ctx);
              await provider.updateSystemParameters(newModel);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật bảng THAM_SO!')),
                );
              }
            },
            child: const Text('Lưu tham số', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _editListingParamsDialog(BuildContext context, AdminProvider provider) {
    final minImgController = TextEditingController(
      text: provider.systemParams.minListingImages.toString(),
    );
    final minPriceController = TextEditingController(
      text: provider.systemParams.minListingPrice.toStringAsFixed(0),
    );
    final deadlineController = TextEditingController(
      text: provider.systemParams.adminApprovalDeadlineHours.toString(),
    );
    final resubmitController = TextEditingController(
      text: provider.systemParams.maxRejectionResubmissions.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Điều chỉnh Tham số Đăng & Duyệt tin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minImgController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số ảnh tối thiểu (mặc định 3)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: minPriceController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Giá thuê tối thiểu (VNĐ)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deadlineController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Thời hạn Admin duyệt (giờ)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: resubmitController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số lần resubmit tối đa (3)',
                ),
              ),
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
              final newModel = SystemParamModel(
                minUserAge: provider.systemParams.minUserAge,
                otpValidityDurationSeconds:
                    provider.systemParams.otpValidityDurationSeconds,
                otpMaxAttempts: provider.systemParams.otpMaxAttempts,
                otpLockoutDurationSeconds:
                    provider.systemParams.otpLockoutDurationSeconds,
                minListingImages:
                    int.tryParse(minImgController.text) ??
                    provider.systemParams.minListingImages,
                minListingPrice:
                    double.tryParse(minPriceController.text) ??
                    provider.systemParams.minListingPrice,
                adminApprovalDeadlineHours:
                    int.tryParse(deadlineController.text) ??
                    provider.systemParams.adminApprovalDeadlineHours,
                maxRejectionResubmissions:
                    int.tryParse(resubmitController.text) ??
                    provider.systemParams.maxRejectionResubmissions,
                maxPendingRequestsPerStudent:
                    provider.systemParams.maxPendingRequestsPerStudent,
                landlordResponseDeadlineHours:
                    provider.systemParams.landlordResponseDeadlineHours,
                minStayDaysForReview:
                    provider.systemParams.minStayDaysForReview,
                minReviewLength: provider.systemParams.minReviewLength,
                maxFavoriteRoomsPerStudent:
                    provider.systemParams.maxFavoriteRoomsPerStudent,
                depositConfirmationSeconds:
                    provider.systemParams.depositConfirmationSeconds,
              );
              Navigator.pop(ctx);
              await provider.updateSystemParameters(newModel);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật bảng THAM_SO!')),
                );
              }
            },
            child: const Text('Lưu tham số', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _editOtherParamsDialog(BuildContext context, AdminProvider provider) {
    final maxReqController = TextEditingController(
      text: provider.systemParams.maxPendingRequestsPerStudent.toString(),
    );
    final landlordDeadlineController = TextEditingController(
      text: provider.systemParams.landlordResponseDeadlineHours.toString(),
    );
    final minStayController = TextEditingController(
      text: provider.systemParams.minStayDaysForReview.toString(),
    );
    final minRevController = TextEditingController(
      text: provider.systemParams.minReviewLength.toString(),
    );
    final maxFavController = TextEditingController(
      text: provider.systemParams.maxFavoriteRoomsPerStudent.toString(),
    );
    final depositConfirmController = TextEditingController(
      text: provider.systemParams.depositConfirmationSeconds.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Điều chỉnh Tham số Nghiệp vụ Khác'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: maxReqController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số yêu cầu thuê chờ tối đa (mặc định 5)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: landlordDeadlineController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Thời hạn Chủ trọ phản hồi (giờ, mặc định 48)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: minStayController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số ngày ở tối thiểu viết đánh giá (mặc định 7)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: minRevController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số ký tự nhận xét tối thiểu (mặc định 20)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: maxFavController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Số phòng tối đa yêu thích (mặc định 20)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: depositConfirmController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Thời gian xác nhận giao dịch cọc (giây)',
                ),
              ),
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
              final newModel = SystemParamModel(
                minUserAge: provider.systemParams.minUserAge,
                otpValidityDurationSeconds:
                    provider.systemParams.otpValidityDurationSeconds,
                otpMaxAttempts: provider.systemParams.otpMaxAttempts,
                otpLockoutDurationSeconds:
                    provider.systemParams.otpLockoutDurationSeconds,
                minListingImages: provider.systemParams.minListingImages,
                minListingPrice: provider.systemParams.minListingPrice,
                adminApprovalDeadlineHours:
                    provider.systemParams.adminApprovalDeadlineHours,
                maxRejectionResubmissions:
                    provider.systemParams.maxRejectionResubmissions,
                maxPendingRequestsPerStudent:
                    int.tryParse(maxReqController.text) ??
                    provider.systemParams.maxPendingRequestsPerStudent,
                landlordResponseDeadlineHours:
                    int.tryParse(landlordDeadlineController.text) ??
                    provider.systemParams.landlordResponseDeadlineHours,
                minStayDaysForReview:
                    int.tryParse(minStayController.text) ??
                    provider.systemParams.minStayDaysForReview,
                minReviewLength:
                    int.tryParse(minRevController.text) ??
                    provider.systemParams.minReviewLength,
                maxFavoriteRoomsPerStudent:
                    int.tryParse(maxFavController.text) ??
                    provider.systemParams.maxFavoriteRoomsPerStudent,
                depositConfirmationSeconds:
                    int.tryParse(depositConfirmController.text) ??
                    provider.systemParams.depositConfirmationSeconds,
              );
              Navigator.pop(ctx);
              await provider.updateSystemParameters(newModel);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật bảng THAM_SO!')),
                );
              }
            },
            child: const Text('Lưu tham số', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
