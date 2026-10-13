import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/utils/code_generator_util.dart';
import '../../../domain/entities/room_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/badge_counter_provider.dart';
import '../../providers/landlord_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../landlord/landlord_contracts_screen.dart';
import '../landlord/landlord_reviews_screen.dart';
import '../landlord/landlord_stats_screen.dart';
import '../common/notifications_screen.dart';

class LandlordHomeScreen extends ConsumerStatefulWidget {
  const LandlordHomeScreen({super.key});

  @override
  ConsumerState<LandlordHomeScreen> createState() => _LandlordHomeScreenState();
}

class _LandlordHomeScreenState extends ConsumerState<LandlordHomeScreen> {
  String _selectedStatusFilter = 'TAT_CA';

  final List<String> _districtsList = [
    'Cầu Giấy, Hà Nội',
    'Đống Đa, Hà Nội',
    'Ba Đình, Hà Nội',
    'Thanh Xuân, Hà Nội',
    'Hai Bà Trưng, Hà Nội',
    'Hoàng Mai, Hà Nội',
    'Nam Từ Liêm, Hà Nội',
    'Bắc Từ Liêm, Hà Nội',
    'Tây Hồ, Hà Nội',
    'Long Biên, Hà Nội',
    'Hà Đông, Hà Nội',
    'Quận 1, TP.HCM',
    'Quận 3, TP.HCM',
    'Quận 5, TP.HCM',
    'Quận 7, TP.HCM',
    'Quận 10, TP.HCM',
    'Bình Thạnh, TP.HCM',
    'Thủ Đức, TP.HCM',
    'Tân Bình, TP.HCM',
    'Gò Vấp, TP.HCM',
  ];

  final List<String> _sampleRoomImages = [
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
    'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800',
    'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
    'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800',
  ];

  final List<String> _availableAmenities = [
    'WiFi',
    'Máy lạnh',
    'Nóng lạnh',
    'Bãi xe',
    'Camera an ninh',
    'Giường tủ',
    'Tủ lạnh',
    'Máy giặt',
    'Thang máy',
    'Ban công',
    'Bảo vệ 24/7',
    'Tự do giờ giấc',
  ];

  void _showAddImageOptionsDialog(
    BuildContext context,
    Function(String) onImageAdded,
  ) {
    final urlCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thêm hình ảnh thực tế phòng trọ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lựa chọn 1: Nhập đường dẫn URL ảnh',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: urlCtrl,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'https://example.com/image.jpg',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (urlCtrl.text.trim().isNotEmpty) {
                      onImageAdded(urlCtrl.text.trim());
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Thêm'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Lựa chọn 2: Tải ảnh lên (Chọn từ bộ sưu tập mẫu)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleRoomImages.length,
                itemBuilder: (context, index) {
                  final imgUrl = _sampleRoomImages[index];
                  return GestureDetector(
                    onTap: () {
                      onImageAdded(imgUrl);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        image: DecorationImage(
                          image: NetworkImage(imgUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.add,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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

  void _confirmDeleteRoom(
    BuildContext context,
    RoomEntity room,
    String landlordId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa tin đăng'),
        content: Text(
          'Bạn có chắc chắn muốn xóa tin đăng "${room.tieuDe}" không? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await legacy_provider.Provider.of<RoomProvider>(
                context,
                listen: false,
              ).deleteRoom(room.maPhong, landlordId);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa tin đăng phòng trọ thành công!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              'Xóa tin đăng',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final landlordProvider = legacy_provider.Provider.of<LandlordProvider>(
        context,
        listen: false,
      );
      landlordProvider.setBadgeCounterNotifier(ref.read(badgeCounterProvider.notifier));

      final user = legacy_provider.Provider.of<AuthProvider>(
        context,
        listen: false,
      ).currentUser;
      if (user != null) {
        legacy_provider.Provider.of<RoomProvider>(
          context,
          listen: false,
        ).fetchLandlordRooms(user.maTK);
        landlordProvider.fetchLandlordData(user.maTK);
      }
    });
  }

  void _showAddOrEditRoomDialog(
    BuildContext context, {
    RoomEntity? existingRoom,
  }) {
    final isEdit = existingRoom != null;

    final titleCtrl = TextEditingController(text: existingRoom?.tieuDe ?? '');
    final addressCtrl = TextEditingController(text: existingRoom?.diaChi ?? '');
    final priceCtrl = TextEditingController(
      text: existingRoom?.giaThue != null
          ? existingRoom!.giaThue.toStringAsFixed(0)
          : '',
    );
    final areaCtrl = TextEditingController(
      text: existingRoom?.dienTich != null
          ? existingRoom!.dienTich.toStringAsFixed(0)
          : '',
    );
    final descCtrl = TextEditingController(text: existingRoom?.moTa ?? '');

    final elecCtrl = TextEditingController(
      text: existingRoom?.chiPhiDien != null
          ? existingRoom!.chiPhiDien!.toStringAsFixed(0)
          : '3500',
    );
    final waterCtrl = TextEditingController(
      text: existingRoom?.chiPhiNuoc != null
          ? existingRoom!.chiPhiNuoc!.toStringAsFixed(0)
          : '30000',
    );
    final otherCostCtrl = TextEditingController(
      text: existingRoom?.chiPhiKhac != null
          ? existingRoom!.chiPhiKhac!.toStringAsFixed(0)
          : '100000',
    );
    final maxOccupantsCtrl = TextEditingController(
      text: existingRoom?.soNguoiOToiDa.toString() ?? '2',
    );

    String selectedDistrict = existingRoom?.quanHuyen ?? 'Cầu Giấy, Hà Nội';
    String selectedRoomType = existingRoom?.loaiPhong ?? 'Phòng trọ khép kín';
    List<String> images = existingRoom != null
        ? List<String>.from(existingRoom.danhSachAnh)
        : [];
    List<String> selectedAmenities = existingRoom != null
        ? List<String>.from(existingRoom.tienIch)
        : ['WiFi', 'Máy lạnh', 'Nóng lạnh', 'Bãi xe', 'Camera an ninh'];

    String? modalErrorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool validatePopupForm(bool isDraft) {
              if (titleCtrl.text.trim().isEmpty) {
                setModalState(
                  () => modalErrorMessage = 'Vui lòng nhập tiêu đề tin đăng.',
                );
                return false;
              }
              if (addressCtrl.text.trim().isEmpty) {
                setModalState(
                  () =>
                      modalErrorMessage =
                          'Địa chỉ chi tiết là bắt buộc. Vui lòng nhập đầy đủ.',
                );
                return false;
              }
              final price = double.tryParse(priceCtrl.text) ?? 0;
              if (!isDraft && price < 500000) {
                setModalState(
                  () =>
                      modalErrorMessage =
                          'Giá thuê phải từ 500.000 VNĐ/tháng trở lên.',
                );
                return false;
              }
              if (images.length < 3) {
                setModalState(
                  () =>
                      modalErrorMessage =
                          'Cần tối thiểu 3 ảnh thực tế của phòng trọ.',
                );
                return false;
              }
              setModalState(() => modalErrorMessage = null);
              return true;
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Chỉnh sửa tin đăng' : 'Đăng tin phòng trọ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    if (isEdit && existingRoom.trangThaiDuyet == 'TU_CHOI') ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(
                          'Lý do bị từ chối: ${existingRoom.lyDoTuChoi ?? "Thông tin chưa hợp lệ"}',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    if (modalErrorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                modalErrorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Text(
                      'Yêu cầu: Tối thiểu 3 ảnh - Tối đa 10 ảnh thực tế.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      label: 'Tiêu đề tin đăng',
                      controller: titleCtrl,
                    ),
                    CustomTextField(
                      label: 'Địa chỉ chi tiết (Bắt buộc) *',
                      controller: addressCtrl,
                    ),

                    const Text(
                      'Quận/Huyện',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _districtsList.contains(selectedDistrict)
                          ? selectedDistrict
                          : _districtsList.first,
                      dropdownColor: AppColors.surfaceLight,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      items: _districtsList
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(color: AppColors.textPrimary))),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedDistrict = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Loại hình phòng trọ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedRoomType,
                      dropdownColor: AppColors.surfaceLight,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Phòng trọ khép kín',
                          child: Text('Phòng trọ khép kín', style: TextStyle(color: AppColors.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'Chung cư mini',
                          child: Text('Chung cư mini', style: TextStyle(color: AppColors.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'Nhà nguyên căn',
                          child: Text('Nhà nguyên căn', style: TextStyle(color: AppColors.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: 'KTX tư nhân',
                          child: Text('KTX tư nhân', style: TextStyle(color: AppColors.textPrimary)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedRoomType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Giá thuê (đ/tháng)',
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Diện tích (m²)',
                            controller: areaCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    const Text(
                      'Chi phí dịch vụ bổ sung',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Điện (đ/kWh)',
                            controller: elecCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextField(
                            label: 'Nước (đ/m³)',
                            controller: waterCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextField(
                            label: 'Phí dịch vụ khác',
                            controller: otherCostCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    CustomTextField(
                      label: 'Số người ở tối đa',
                      controller: maxOccupantsCtrl,
                      keyboardType: TextInputType.number,
                    ),

                    CustomTextField(
                      label: 'Mô tả chi tiết phòng trọ',
                      controller: descCtrl,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Text(
                          'Danh mục tiện ích phòng trọ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${selectedAmenities.length} đã chọn)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _availableAmenities.map((amenity) {
                        final isSelected = selectedAmenities.contains(amenity);
                        return FilterChip(
                          label: Text(amenity),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withValues(alpha: 0.3),
                          checkmarkColor: AppColors.primaryLight,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? AppColors.primaryLight
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          onSelected: (bool selected) {
                            setModalState(() {
                              if (selected) {
                                selectedAmenities.add(amenity);
                              } else {
                                selectedAmenities.remove(amenity);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hình ảnh thực tế (${images.length}/10 ảnh)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (images.length < 10)
                          TextButton.icon(
                            onPressed: () {
                              _showAddImageOptionsDialog(context, (newImgUrl) {
                                setModalState(() => images.add(newImgUrl));
                              });
                            },
                            icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                            label: const Text('Thêm ảnh'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (images.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text(
                            'Chưa có ảnh nào. Bấm "+ Thêm ảnh" để nhập URL hoặc chọn từ thư viện ảnh mẫu.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: images.asMap().entries.map((entry) {
                            final i = entry.key;
                            final imgUrl = entry.value;
                            return Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                    image: DecorationImage(
                                      image: NetworkImage(imgUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setModalState(() => images.removeAt(i));
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              if (!validatePopupForm(true)) return;
                              await _submitRoomForm(
                                isDraft: true,
                                isEdit: isEdit,
                                existingRoom: existingRoom,
                                title: titleCtrl.text,
                                address: addressCtrl.text,
                                district: selectedDistrict,
                                priceStr: priceCtrl.text,
                                areaStr: areaCtrl.text,
                                desc: descCtrl.text,
                                roomType: selectedRoomType,
                                elecStr: elecCtrl.text,
                                waterStr: waterCtrl.text,
                                otherStr: otherCostCtrl.text,
                                maxOccupantsStr: maxOccupantsCtrl.text,
                                images: images,
                                amenities: selectedAmenities,
                              );
                            },
                            child: const Text('Lưu nháp'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: isEdit ? 'Gửi lại tin' : 'Gửi duyệt tin',
                            onPressed: () async {
                              if (!validatePopupForm(false)) return;
                              await _submitRoomForm(
                                isDraft: false,
                                isEdit: isEdit,
                                existingRoom: existingRoom,
                                title: titleCtrl.text,
                                address: addressCtrl.text,
                                district: selectedDistrict,
                                priceStr: priceCtrl.text,
                                areaStr: areaCtrl.text,
                                desc: descCtrl.text,
                                roomType: selectedRoomType,
                                elecStr: elecCtrl.text,
                                waterStr: waterCtrl.text,
                                otherStr: otherCostCtrl.text,
                                maxOccupantsStr: maxOccupantsCtrl.text,
                                images: images,
                                amenities: selectedAmenities,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitRoomForm({
    required bool isDraft,
    required bool isEdit,
    RoomEntity? existingRoom,
    required String title,
    required String address,
    required String district,
    required String priceStr,
    required String areaStr,
    required String desc,
    required String roomType,
    required String elecStr,
    required String waterStr,
    required String otherStr,
    required String maxOccupantsStr,
    required List<String> images,
    required List<String> amenities,
  }) async {
    final price = double.tryParse(priceStr) ?? 0;
    final area = double.tryParse(areaStr) ?? 0;

    if (!isDraft && price < 500000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giá thuê phải từ 500.000 VNĐ/tháng trở lên'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (images.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cần tối thiểu 3 ảnh thực tế của phòng trọ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = legacy_provider.Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    final roomProvider = legacy_provider.Provider.of<RoomProvider>(context, listen: false);

    final room = RoomEntity(
      maPhong: (existingRoom != null && existingRoom.maPhong.trim().isNotEmpty)
          ? existingRoom.maPhong
          : CodeGeneratorUtil.generateRoomCode(district: district.trim()),
      maChuTro: user.maTK,
      tieuDe: title.trim(),
      diaChi: address.trim(),
      quanHuyen: district.trim(),
      giaThue: price,
      dienTich: area,
      loaiPhong: roomType,
      moTa: desc.trim(),
      trangThaiDuyet: isDraft ? 'NHAP' : 'CHO_DUYET',
      trangThaiThue: existingRoom?.trangThaiThue ?? 'CON_TRONG',
      danhSachAnh: images,
      tienIch: amenities.isNotEmpty
          ? amenities
          : ['WiFi', 'Máy lạnh', 'Nóng lạnh', 'Bãi xe', 'Camera an ninh'],
      chiPhiDien: double.tryParse(elecStr),
      chiPhiNuoc: double.tryParse(waterStr),
      chiPhiKhac: double.tryParse(otherStr),
      soNguoiOToiDa: int.tryParse(maxOccupantsStr) ?? 2,
      isHienThi: existingRoom?.isHienThi ?? true,
      soLanTuChoi: existingRoom?.soLanTuChoi ?? 0,
    );

    bool success;
    if (isEdit) {
      success = await roomProvider.updateRoom(room);
    } else {
      success = await roomProvider.createRoom(room);
    }

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDraft
                  ? 'Lưu tin nháp thành công!'
                  : (isEdit
                        ? 'Gửi lại tin đăng thành công! Đang chờ Admin duyệt.'
                        : 'Tạo tin đăng mới thành công! Đang chờ Admin duyệt.'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roomProvider.errorMessage ?? 'Xử lý tin đăng thất bại',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = legacy_provider.Provider.of<AuthProvider>(context).currentUser;
    final roomProvider = legacy_provider.Provider.of<RoomProvider>(context);
    final landlordProvider = legacy_provider.Provider.of<LandlordProvider>(context);
    final badgeState = ref.watch(badgeCounterProvider);

    final allRooms = roomProvider.landlordRooms;

    final filteredRooms = allRooms.where((r) {
      if (_selectedStatusFilter == 'TAT_CA') return true;
      if (_selectedStatusFilter == 'DA_DUYET') {
        return r.trangThaiDuyet == 'DA_DUYET';
      }
      if (_selectedStatusFilter == 'CHO_DUYET') {
        return r.trangThaiDuyet == 'CHO_DUYET';
      }
      if (_selectedStatusFilter == 'TU_CHOI') {
        return r.trangThaiDuyet == 'TU_CHOI';
      }
      if (_selectedStatusFilter == 'NHAP') {
        return r.trangThaiDuyet == 'NHAP';
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.home_work_rounded,
            color: AppColors.primaryLight,
            size: 28,
          ),
        ),
        title: const Text('Quản lý phòng trọ', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Thông báo hệ thống',
            icon: badgeState.unreadNotificationsCount > 0
                ? Badge(
                    label: Text('${badgeState.unreadNotificationsCount}'),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.notifications_outlined),
                  )
                : const Icon(Icons.notifications_outlined),
            onPressed: () {
              ref.read(badgeCounterProvider.notifier).resetNotifications();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: GestureDetector(
              onTap: () {
                final navProvider = legacy_provider.Provider.of<NavigationProvider>(
                  context,
                  listen: false,
                );
                navProvider.setIndex(4);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surfaceLight,
                  backgroundImage:
                      user?.avatarUrl != null &&
                          user!.avatarUrl!.trim().isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child:
                      user?.avatarUrl == null || user!.avatarUrl!.trim().isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: AppColors.primaryLight,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              await roomProvider.fetchLandlordRooms(user.maTK);
              await landlordProvider.fetchLandlordData(user.maTK);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Tổng tin đăng',
                        '${allRooms.length}',
                        Icons.home_rounded,
                        AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Yêu cầu thuê',
                        '${landlordProvider.rentalRequests.length}',
                        Icons.assignment_rounded,
                        AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Đã cho thuê',
                        '${allRooms.where((r) => r.trangThaiThue == 'DA_CHO_THUE').length}',
                        Icons.check_circle_outline_rounded,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        title: 'Hợp đồng',
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LandlordContractsScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        title: 'Đánh giá',
                        icon: Icons.star_rounded,
                        color: const Color(0xFFF59E0B),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LandlordReviewsScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        title: 'Thống kê',
                        icon: Icons.bar_chart_rounded,
                        color: const Color(0xFF10B981),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LandlordStatsScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Danh sách tin phòng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    CustomButton(
                      icon: Icons.add_rounded,
                      text: 'Đăng tin mới',
                      height: 38,
                      width: 150,
                      onPressed: () => _showAddOrEditRoomDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả (${allRooms.length})', 'TAT_CA'),
                      _buildFilterChip(
                        'Đang hiển thị (${allRooms.where((r) => r.trangThaiDuyet == 'DA_DUYET').length})',
                        'DA_DUYET',
                      ),
                      _buildFilterChip(
                        'Chờ duyệt (${allRooms.where((r) => r.trangThaiDuyet == 'CHO_DUYET').length})',
                        'CHO_DUYET',
                      ),
                      _buildFilterChip(
                        'Bị từ chối (${allRooms.where((r) => r.trangThaiDuyet == 'TU_CHOI').length})',
                        'TU_CHOI',
                      ),
                      _buildFilterChip(
                        'Nháp (${allRooms.where((r) => r.trangThaiDuyet == 'NHAP').length})',
                        'NHAP',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (roomProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredRooms.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text('Không có tin đăng nào thuộc trạng thái này', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  )
                else
                  Column(
                    children: filteredRooms.map((room) {
                      return _buildLandlordRoomCard(room, user?.maTK ?? '');
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary.withValues(alpha: 0.3),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedStatusFilter = value);
          }
        },
      ),
    );
  }

  Widget _buildLandlordRoomCard(RoomEntity room, String landlordId) {
    Color statusColor = AppColors.badgePending;
    Color textColor = AppColors.badgePendingText;
    String statusText = 'Chờ duyệt';

    if (room.trangThaiDuyet == 'DA_DUYET') {
      statusColor = AppColors.badgeApproved;
      textColor = AppColors.badgeApprovedText;
      statusText = 'Đã duyệt';
    } else if (room.trangThaiDuyet == 'TU_CHOI') {
      statusColor = AppColors.badgeRejected;
      textColor = AppColors.badgeRejectedText;
      statusText = 'Bị từ chối (${room.soLanTuChoi}/3)';
    } else if (room.trangThaiDuyet == 'NHAP') {
      statusColor = AppColors.surfaceLight;
      textColor = AppColors.textSecondary;
      statusText = 'Bản nháp';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  room.danhSachAnh.isNotEmpty
                      ? room.danhSachAnh.first
                      : 'https://via.placeholder.com/150',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: AppColors.surfaceLight,
                    child: const Icon(
                      Icons.home,
                      size: 40,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Mã: #${CodeGeneratorUtil.formatRoomDisplayCode(room.maPhong, district: room.quanHuyen)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (room.trangThaiDuyet != 'NHAP')
                          Row(
                            children: [
                              Text(
                                room.isHienThi ? 'Đang hiện' : 'Đã ẩn',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: room.isHienThi
                                      ? AppColors.success
                                      : AppColors.textLight,
                                ),
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: room.isHienThi,
                                  onChanged: (val) {
                                    legacy_provider.Provider.of<RoomProvider>(
                                      context,
                                      listen: false,
                                    ).toggleVisibility(
                                      room.maPhong,
                                      room.isHienThi,
                                      landlordId,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Text(
                      room.tieuDe,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${room.diaChi}, ${room.quanHuyen}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${room.giaThue.toStringAsFixed(0)} VNĐ/tháng • ${room.dienTich} m²',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lượt xem: ${room.luotXem} • ${room.soNguoiOToiDa} người max',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  if (room.trangThaiDuyet == 'CHO_DUYET' ||
                      room.trangThaiDuyet == 'TU_CHOI' ||
                      room.trangThaiDuyet == 'NHAP')
                    TextButton.icon(
                      onPressed: () {
                        if (room.trangThaiDuyet == 'TU_CHOI' &&
                            room.soLanTuChoi >= 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tin đăng đã bị từ chối 3 lần. Không thể chỉnh sửa nữa',
                              ),
                            ),
                          );
                          return;
                        }
                        _showAddOrEditRoomDialog(context, existingRoom: room);
                      },
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text(
                        'Chỉnh sửa',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                    tooltip: 'Xóa tin đăng',
                    onPressed: () =>
                        _confirmDeleteRoom(context, room, landlordId),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
