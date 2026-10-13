import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../domain/entities/review_entity.dart';
import '../../providers/landlord_provider.dart';

class LandlordReviewsScreen extends StatelessWidget {
  const LandlordReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final landlordProvider = Provider.of<LandlordProvider>(context);

    final reviews = landlordProvider.reviews;
    final avgReputation = reviews.isNotEmpty
        ? (reviews.fold<double>(0.0, (sum, r) => sum + r.diem) / reviews.length)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi Đánh giá & Điểm uy tín'),
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
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppGradients.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'ĐIỂM UY TÍN TRUNG BÌNH CỦA CHỦ TRỌ',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 40),
                        const SizedBox(width: 8),
                        Text(
                          avgReputation.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const Text(
                          ' / 5.0',
                          style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dựa trên đánh giá độ sạch sẽ, thái độ phục vụ, đúng mô tả & vị trí từ Sinh viên',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Danh sách Đánh giá & Nhận xét',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              if (reviews.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('Chưa có bài đánh giá nào cho các phòng trọ của bạn', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                )
              else
                Column(
                  children: reviews.map((review) {
                    return _buildReviewCard(review);
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewEntity review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, size: 20, color: AppColors.primaryLight),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.tenSV,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Mã phòng: ${review.maPhong}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x33FFD700),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      review.diem.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFFFD700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${review.noiDung}"',
            style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(review.ngayDanhGia),
              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }
}
