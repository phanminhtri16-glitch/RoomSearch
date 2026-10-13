import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../data/models/room_model.dart';

class AdminRoomDetailDialog extends StatelessWidget {
  final RoomModel room;
  final String? landlordName;

  const AdminRoomDetailDialog({
    super.key,
    required this.room,
    this.landlordName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650, maxWidth: 500),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết phòng trọ kiểm duyệt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (room.danhSachAnh.isNotEmpty) ...[
                      const Text(
                        'Bộ sưu tập hình ảnh thực tế:',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: room.danhSachAnh.length,
                          itemBuilder: (context, index) {
                            final imgUrl = room.danhSachAnh[index];
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                                image: DecorationImage(
                                  image: NetworkImage(imgUrl),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {},
                                ),
                                color: AppColors.surfaceLight,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text(
                      room.tieuDe,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final name = landlordName;
                        final displayLandlord = (name != null && name.trim().isNotEmpty && name != room.maChuTro) ? name : 'Chủ trọ 1';
                        return Text(
                          'Chủ trọ: $displayLandlord | Loại: ${room.loaiPhong}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        );
                      },
                    ),
                    const Divider(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            Icons.monetization_on_outlined,
                            'Giá thuê',
                            '${room.giaThue.toStringAsFixed(0)} VNĐ/tháng',
                            AppColors.primaryLight,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.square_foot_rounded,
                            'Diện tích',
                            '${room.dienTich} m²',
                            AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildInfoItem(
                      Icons.location_on_outlined,
                      'Địa chỉ đầy đủ',
                      '${room.diaChi}, ${room.quanHuyen}',
                      AppColors.textPrimary,
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Chi phí dịch vụ bổ sung:',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text('Điện: ${room.chiPhiDien != null ? "${room.chiPhiDien}đ/kWh" : "Theo giá nhà nước"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text('Nước: ${room.chiPhiNuoc != null ? "${room.chiPhiNuoc}đ/m³" : "Theo giá nhà nước"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    if (room.chiPhiKhac != null) Text('Chi phí khác: ${room.chiPhiKhac}đ/tháng', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 14),

                    const Text(
                      'Danh sách tiện ích:',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: room.tienIch.map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Mô tả chi tiết phòng trọ:',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        room.moTa.isNotEmpty ? room.moTa : 'Chưa có mô tả chi tiết.',
                        style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(
                value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
