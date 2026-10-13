import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/room_model.dart';
import '../../../domain/entities/review_entity.dart';
import '../../../domain/entities/room_entity.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/landlord_provider.dart';
import '../../providers/room_provider.dart';
import '../common/chat_detail_screen.dart';
import 'add_review_dialog.dart';
import 'rental_request_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/google_map_card_widget.dart';
import '../../widgets/animated_favorite_button.dart';
import '../../widgets/glowing_verification_badge.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomEntity room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  int _currentImageIndex = 0;
  late final PageController _pageController;

  final List<Map<String, dynamic>> _mockReviews = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<LandlordProvider>(context, listen: false).fetchLandlordData(user.maTK);
      }
      Provider.of<RoomProvider>(
        context,
        listen: false,
      ).viewRoomDetail(widget.room.maPhong);
      Provider.of<AdminProvider>(
        context,
        listen: false,
      ).fetchUsers();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _shareRoomLink() {
    final link = 'https://roomsearch.app/room/${widget.room.maPhong}';
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
              'Chia sẻ tin đăng phòng trọ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'Đường dẫn: $link',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(Icons.copy_rounded, 'Sao chép', () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã sao chép liên kết!')),
                  );
                }),
                _buildShareOption(Icons.chat_bubble_outline_rounded, 'Zalo', () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã mở Zalo chia sẻ!')),
                  );
                }),
                _buildShareOption(Icons.facebook_rounded, 'Facebook', () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã mở Facebook chia sẻ!')),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Icon(icon, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteRoomByAdmin(BuildContext context, RoomEntity room) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa tin đăng'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tin đăng phòng trọ này không?\n\n(Tin đăng bị xóa sẽ được đưa vào mục "Tin bị xóa" trên trang Duyệt & Quản lý tin đăng của Admin).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa tin đăng'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final roomModel = RoomModel.fromEntity(room);
      await adminProvider.softDeleteRoom(roomModel);
      await roomProvider.deleteRoom(room.maPhong, room.maChuTro);
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Đã xóa tin đăng và chuyển vào mục "Tin bị xóa"!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawRoom = widget.room;
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isLandlord = user?.vaiTro == AppConstants.roleLandlord;
    final isAdmin = user?.vaiTro == AppConstants.roleAdmin;
    final landlordProvider = Provider.of<LandlordProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);

    RoomEntity room = rawRoom;
    for (var r in roomProvider.approvedRooms) {
      if (r.maPhong == rawRoom.maPhong) {
        room = r;
        break;
      }
    }
    if (room == rawRoom) {
      for (var r in roomProvider.landlordRooms) {
        if (r.maPhong == rawRoom.maPhong) {
          room = r;
          break;
        }
      }
    }

    final hasDeposited = user != null &&
        landlordProvider.hasDepositedRoom(
          studentId: user.maTK,
          studentName: user.hoTen,
          roomId: room.maPhong,
        );
    final hasReviewed = user != null &&
        landlordProvider.hasReviewedRoom(
          studentId: user.maTK,
          roomId: room.maPhong,
        );
    final realReviews = landlordProvider.reviews
        .where((r) => r.maPhong == room.maPhong && !r.isHiddenByAdmin)
        .toList();
    final isFav = roomProvider.isFavorite(widget.room.maPhong);
    final adminProvider = Provider.of<AdminProvider>(context);

    String displayLandlordName;
    if (user != null && user.maTK == room.maChuTro && user.hoTen.trim().isNotEmpty) {
      displayLandlordName = user.hoTen.startsWith('Chủ trọ') ? user.hoTen : 'Chủ trọ ${user.hoTen}';
    } else {
      final rawLandlordName = adminProvider.getLandlordName(room.maChuTro);
      if (rawLandlordName.trim().isNotEmpty && rawLandlordName != room.maChuTro) {
        displayLandlordName = rawLandlordName.startsWith('Chủ trọ') ? rawLandlordName : 'Chủ trọ $rawLandlordName';
      } else {
        displayLandlordName = 'Chủ trọ 1';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phòng trọ'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (!isLandlord && !isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: AnimatedFavoriteButton(
                  isFavorite: isFav,
                  size: 38,
                  iconSize: 20,
                  onTap: () {
                    roomProvider.toggleFavorite(widget.room);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          !isFav
                              ? 'Đã thêm phòng vào danh sách Yêu thích!'
                              : 'Đã bỏ lưu phòng khỏi Yêu thích.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareRoomLink,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gallery Carousel Slider
              Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 260,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: room.danhSachAnh.isNotEmpty
                              ? room.danhSachAnh.length
                              : 1,
                          onPageChanged: (index) =>
                              setState(() => _currentImageIndex = index),
                          itemBuilder: (context, index) {
                            final imgUrl = room.danhSachAnh.isNotEmpty
                                ? room.danhSachAnh[index]
                                : 'https://via.placeholder.com/600x400';
                            final imgWidget = Image.network(imgUrl, fit: BoxFit.cover);
                            if (index == 0) {
                              return Hero(
                                tag: 'room-image-${room.maPhong}',
                                child: imgWidget,
                              );
                            }
                            return imgWidget;
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppGradients.imageOverlay,
                          ),
                        ),
                      ),
                      if (room.danhSachAnh.length > 1) ...[
                        Positioned(
                          left: 10,
                          top: 110,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              onPressed: () {
                                if (_currentImageIndex > 0) {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 110,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              onPressed: () {
                                if (_currentImageIndex <
                                    room.danhSachAnh.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1}/${room.danhSachAnh.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              room.danhSachAnh.length,
                              (idx) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentImageIndex == idx ? 16 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == idx
                                      ? AppColors.primary
                                      : Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (room.danhSachAnh.length > 1)
                    Container(
                      height: 60,
                      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: room.danhSachAnh.length,
                        itemBuilder: (context, index) {
                          final isSelected = _currentImageIndex == index;
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(room.danhSachAnh[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: room.trangThaiThue == 'DA_CHO_THUE'
                                ? AppColors.badgeRejected
                                : (room.trangThaiThue == 'CON_TRONG'
                                    ? AppColors.badgeApproved
                                    : AppColors.badgePending),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            room.trangThaiThue == 'DA_CHO_THUE'
                                ? 'Đã cho thuê'
                                : (room.trangThaiThue == 'CON_TRONG'
                                    ? 'Còn trống'
                                    : 'Tạm khóa / Đặt cọc'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: room.trangThaiThue == 'DA_CHO_THUE'
                                  ? AppColors.badgeRejectedText
                                  : (room.trangThaiThue == 'CON_TRONG'
                                      ? AppColors.badgeApprovedText
                                      : AppColors.badgePendingText),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            room.loaiPhong,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      room.tieuDe,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${room.diaChi}, ${room.quanHuyen}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price & Metrics container
                    Container(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Giá thuê',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${CurrencyFormatter.format(room.giaThue)} đ/tháng',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: AppColors.divider,
                          ),
                          Column(
                            children: [
                              const Text(
                                'Diện tích',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${room.dienTich} m²',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: AppColors.divider,
                          ),
                          Column(
                            children: [
                              const Text(
                                'Số người tối đa',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${room.soNguoiOToiDa} người',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Chi phí dịch vụ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCostItem(
                            Icons.bolt_rounded,
                            'Điện',
                            '${CurrencyFormatter.format(room.chiPhiDien ?? 3500)} đ/kWh',
                          ),
                        ),
                        Expanded(
                          child: _buildCostItem(
                            Icons.water_drop_rounded,
                            'Nước',
                            '${CurrencyFormatter.format(room.chiPhiNuoc ?? 30000)} đ/m³',
                          ),
                        ),
                        Expanded(
                          child: _buildCostItem(
                            Icons.miscellaneous_services_rounded,
                            'Dịch vụ khác',
                            '${CurrencyFormatter.format(room.chiPhiKhac ?? 100000)} đ/tháng',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Tiện ích phòng trọ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: room.tienIch
                          .map(
                            (t) => Chip(
                              label: Text(
                                t,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                              avatar: const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16,
                                color: AppColors.accent,
                              ),
                              backgroundColor: AppColors.surfaceLight,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Mô tả chi tiết',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      room.moTa,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    const Text(
                      'Vị trí & Bản đồ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GoogleMapCardWidget(room: room),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Landlord info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              gradient: AppGradients.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayLandlordName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const GlowingVerificationBadge(
                                  label: 'Chủ trọ Uy tín 5.0 ★ • Xác minh CCCD',
                                  fontSize: 11,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đánh giá sinh viên (${_mockReviews.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 20),
                            const SizedBox(width: 4),
                            Text(
                              _mockReviews.isEmpty && room.diemDanhGiaTB == 0.0
                                  ? '0.0 / 5.0'
                                  : '${room.diemDanhGiaTB > 0 ? room.diemDanhGiaTB.toStringAsFixed(1) : "4.8"} / 5.0',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (hasDeposited) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasReviewed ? AppColors.surfaceLight : AppColors.warning,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            if (hasReviewed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bạn đã đánh giá phòng trọ này rồi.'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                              return;
                            }
                            showDialog(
                              context: context,
                              builder: (_) => AddReviewDialog(
                                roomTitle: room.tieuDe,
                                roomId: room.maPhong,
                                studentId: user.maTK,
                                studentName: user.hoTen,
                              ),
                            );
                          },
                          icon: Icon(hasReviewed ? Icons.check_circle_rounded : Icons.rate_review_rounded, size: 18),
                          label: Text(
                            hasReviewed ? 'Đã đánh giá phòng trọ này' : 'Viết đánh giá cho phòng trọ này',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                    ],

                    if (realReviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'Chưa có đánh giá nào từ sinh viên.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    else
                      ...realReviews.map((rev) => _buildReviewCard(rev)),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isLandlord
          ? null
          : (isAdmin
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _confirmDeleteRoomByAdmin(context, room),
                      icon: const Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Xóa tin đăng (Dành cho Admin)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(
                                  receiverId: room.maChuTro,
                                  receiverName: displayLandlordName,
                                  roomTitle: room.tieuDe,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: const Text('Nhắn tin Chat', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      if (room.trangThaiThue != 'DA_CHO_THUE') ...[
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: CustomButton(
                            text: 'Gửi yêu cầu',
                            icon: Icons.assignment_turned_in_rounded,
                            onPressed: () {
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Vui lòng đăng nhập để gửi yêu cầu thuê phòng',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final landlordProvider = Provider.of<LandlordProvider>(context, listen: false);
                              final hasDeposited = landlordProvider.hasDepositedRoom(
                                studentId: user.maTK,
                                studentName: user.hoTen,
                                roomId: room.maPhong,
                              );

                              if (hasDeposited) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Bạn đã đặt cọc phòng này.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }

                              final hasActive = landlordProvider.hasActiveRequestForRoom(
                                studentId: user.maTK,
                                studentName: user.hoTen,
                                roomId: room.maPhong,
                              );

                              if (hasActive) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Mỗi sinh viên chỉ được gửi yêu cầu một lần mỗi tin.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }

                              showDialog(
                                context: context,
                                builder: (ctx) => RentalRequestDialog(room: room),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
    );
  }

  Widget _buildCostItem(IconData icon, String label, String value) {
    Color iconColor = AppColors.primary;
    if (label == 'Điện') iconColor = const Color(0xFFF59E0B);
    if (label == 'Nước') iconColor = const Color(0xFF3B82F6);
    if (label == 'Dịch vụ khác') iconColor = const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewEntity rev) {
    final dateStr = DateFormat('dd/MM/yyyy').format(rev.ngayDanhGia);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rev.tenSV,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                  const SizedBox(width: 2),
                  Text(
                    rev.diem.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            rev.noiDung,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 6),
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
