import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/utils/code_generator_util.dart';
import '../../../domain/entities/review_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/landlord_provider.dart';
import '../../providers/room_provider.dart';

class AddReviewDialog extends StatefulWidget {
  final String roomTitle;
  final String roomId;
  final String studentId;
  final String studentName;

  const AddReviewDialog({
    super.key,
    required this.roomTitle,
    required this.roomId,
    this.studentId = '',
    this.studentName = '',
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  double _overallRating = 5.0;
  double _sachSeRating = 5.0;
  double _chuTroRating = 5.0;
  double _dungMoTaRating = 5.0;
  double _viTriRating = 5.0;

  final _commentController = TextEditingController();
  final List<String> _reviewImages = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bài nhận xét chi tiết cần có tối thiểu 20 ký tự'), backgroundColor: AppColors.error),
      );
      return;
    }

    final landlordProvider = Provider.of<LandlordProvider>(context, listen: false);
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;

    final newReview = ReviewEntity(
      maDanhGia: CodeGeneratorUtil.generateReviewCode(),
      maPhong: widget.roomId,
      maSV: widget.studentId.isNotEmpty ? widget.studentId : (user?.maTK ?? 'SV_CURRENT'),
      tenSV: widget.studentName.isNotEmpty ? widget.studentName : (user?.hoTen ?? 'Sinh viên'),
      diem: _overallRating,
      noiDung: comment,
      ngayDanhGia: DateTime.now(),
    );

    await landlordProvider.addReview(newReview, roomProvider: roomProvider);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi đánh giá thành công! Cảm ơn bạn đã đóng góp ý kiến.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Đánh giá Phòng trọ & Chủ trọ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text(widget.roomTitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. Đánh giá số sao tổng quát', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1.0;
                return IconButton(
                  icon: Icon(starVal <= _overallRating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFFFD700), size: 32),
                  onPressed: () => setState(() => _overallRating = starVal),
                );
              }),
            ),
            const SizedBox(height: 12),

            const Text('2. Chấm điểm 4 tiêu chí chi tiết', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            _buildCriteriaSlider('Độ sạch sẽ phòng trọ', _sachSeRating, (v) => setState(() => _sachSeRating = v)),
            _buildCriteriaSlider('Chủ trọ thân thiện/hỗ trợ', _chuTroRating, (v) => setState(() => _chuTroRating = v)),
            _buildCriteriaSlider('Đúng như mô tả thực tế', _dungMoTaRating, (v) => setState(() => _dungMoTaRating = v)),
            _buildCriteriaSlider('Vị trí & An ninh xung quanh', _viTriRating, (v) => setState(() => _viTriRating = v)),

            const SizedBox(height: 14),

            const Text('3. Nhận xét chi tiết (Tối thiểu 20 ký tự)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Hãy chia sẻ trải nghiệm sống của bạn về căn phòng, bác chủ trọ, giờ giấc, an ninh...',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hình ảnh thực tế (${_reviewImages.length}/5)', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
                if (_reviewImages.length < 5)
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _reviewImages.add('https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800'));
                    },
                    icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                    label: const Text('Thêm ảnh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            if (_reviewImages.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _reviewImages.map((img) => Container(
                    width: 54,
                    height: 54,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border), image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)),
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: _submitReview,
            child: const Text('Gửi đánh giá', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildCriteriaSlider(String label, double val, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('${val.toStringAsFixed(1)} ★', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFFD700))),
          ],
        ),
        Slider(
          value: val,
          min: 1.0,
          max: 5.0,
          divisions: 8,
          activeColor: const Color(0xFFFFD700),
          inactiveColor: AppColors.surfaceLight,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
