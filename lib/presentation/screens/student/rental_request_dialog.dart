import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/utils/code_generator_util.dart';
import '../../../domain/entities/rental_request_entity.dart';
import '../../../domain/entities/room_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/landlord_provider.dart';

class RentalRequestDialog extends StatefulWidget {
  final RoomEntity room;

  const RentalRequestDialog({super.key, required this.room});

  @override
  State<RentalRequestDialog> createState() => _RentalRequestDialogState();
}

class _RentalRequestDialogState extends State<RentalRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _moveInDate = DateTime.now().add(const Duration(days: 3));
  int _leaseDurationMonths = 6;
  int _occupantsCount = 1;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Phiếu Gửi Yêu Cầu Thuê',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            'Điền đầy đủ thông tin gửi tới Chủ trọ',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.room.tieuDe,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Giá thuê: ${widget.room.giaThue.toStringAsFixed(0)} đ/tháng',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Thông tin người gửi',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Họ tên: ${user?.hoTen ?? "Chưa cập nhật"} • SĐT: ${user?.soDienThoai ?? "Chưa cập nhật"}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ngày dự kiến vào ở:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _moveInDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) setState(() => _moveInDate = picked);
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryLight),
                    label: Text(
                      '${_moveInDate.day}/${_moveInDate.month}/${_moveInDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Thời hạn thuê dự kiến:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  DropdownButton<int>(
                    value: _leaseDurationMonths,
                    dropdownColor: AppColors.surfaceLight,
                    style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3 tháng')),
                      DropdownMenuItem(value: 6, child: Text('6 tháng')),
                      DropdownMenuItem(
                        value: 12,
                        child: Text('12 tháng (1 năm)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _leaseDurationMonths = val);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Số người ở cùng:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryLight),
                    onPressed: _occupantsCount > 1
                        ? () => setState(() => _occupantsCount--)
                        : null,
                  ),
                  Text(
                    '$_occupantsCount người',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLight),
                    onPressed: _occupantsCount < widget.room.soNguoiOToiDa
                        ? () => setState(() => _occupantsCount++)
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Ghi chú / Yêu cầu thêm dành cho Chủ trọ',
                  hintText: 'Ví dụ: Em muốn hẹn xem phòng vào thứ 7 tuần này...',
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
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
            onPressed: () async {
              final landlordProvider = Provider.of<LandlordProvider>(context, listen: false);
              final user = Provider.of<AuthProvider>(context, listen: false).currentUser;

              if (user != null) {
                final hasDeposited = landlordProvider.hasDepositedRoom(
                  studentId: user.maTK,
                  studentName: user.hoTen,
                  roomId: widget.room.maPhong,
                );
                if (hasDeposited) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn đã đặt cọc phòng này.'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }
              }

              final newRequest = RentalRequestEntity(
                maYeuCau: CodeGeneratorUtil.generateRequestCode(),
                maSV: user?.maTK ?? 'SV_CURRENT',
                tenSV: (user?.hoTen != null && user!.hoTen.trim().isNotEmpty)
                    ? user.hoTen
                    : 'Sinh viên ${user?.email ?? ""}',
                maChuTro: widget.room.maChuTro,
                maPhong: widget.room.maPhong,
                ngayMuonVaoO: _moveInDate,
                thoiHanThue: _leaseDurationMonths,
                soNguoiO: _occupantsCount,
                ghiChu: _notesController.text.trim(),
                trangThai: 'CHO_XU_LY',
                ngayTao: DateTime.now(),
              );

              await landlordProvider.addRentalRequest(newRequest);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Gửi phiếu yêu cầu thuê phòng thành công! Đang chờ Chủ trọ phản hồi.',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              'Gửi Phiếu',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
