import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../../domain/entities/room_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/badge_counter_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/room_card_widget.dart';
import '../../widgets/shimmer_loading_widget.dart';
import '../common/notifications_screen.dart';
import '../student/room_detail_screen.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _sortOption = 'MAC_DINH';
  String _selectedQuickCategory = 'Tất cả';

  final List<String> _quickCategories = [
    'Tất cả',
    'Gần trường',
    'Giá rẻ (< 3tr)',
    'Full tiện nghi',
    'Ở ghép',
    'Mới đăng',
  ];

  final List<RoomEntity> _fallbackRooms = [];

  String _selectedDistrict = 'Tất cả';
  String _selectedRoomType = 'Tất cả';
  String _selectedPricePreset = 'Tất cả';
  RangeValues _priceRangeValues = const RangeValues(0, 15);
  final List<String> _selectedAmenities = [];

  final List<String> _districts = [
    'Tất cả',
    'Cầu Giấy, Hà Nội',
    'Đống Đa, Hà Nội',
    'Ba Đình, Hà Nội',
    'Thanh Xuân, Hà Nội',
    'Hai Bà Trưng, Hà Nội',
    'Hoàng Mai, Hà Nội',
    'Nam Từ Liêm, Hà Nội',
    'Bắc Từ Liêm, Hà Nội',
    'Hà Đông, Hà Nội',
    'Quận 1, TP.HCM',
    'Quận 3, TP.HCM',
    'Quận 7, TP.HCM',
    'Bình Thạnh, TP.HCM',
    'Thủ Đức, TP.HCM',
  ];

  final List<String> _roomTypes = [
    'Tất cả',
    'Phòng trọ khép kín',
    'Chung cư mini',
    'Nhà nguyên căn',
    'KTX tư nhân',
  ];

  final List<String> _pricePresets = [
    'Tất cả',
    'Dưới 3 triệu',
    '3 - 5 triệu',
    '5 - 8 triệu',
    'Trên 8 triệu',
  ];

  final List<String> _availableAmenities = [
    'Wifi',
    'Điều hòa',
    'Nóng lạnh',
    'Bãi xe',
    'Camera an ninh',
    'Giường tủ',
    'Tủ lạnh',
    'Máy giặt',
    'Thang máy',
    'Ban công',
    'Tự do giờ giấc',
  ];

  void _showFilterBottomSheet(BuildContext context) {
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
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bộ lọc tìm kiếm nâng cao',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedDistrict = 'Tất cả';
                              _selectedRoomType = 'Tất cả';
                              _selectedPricePreset = 'Tất cả';
                              _selectedAmenities.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Đặt lại'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Khu vực Quận/Huyện',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
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
                      items: _districts
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(color: AppColors.textPrimary))),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _selectedDistrict = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Loại hình phòng trọ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedRoomType,
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
                      items: _roomTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: AppColors.textPrimary))),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _selectedRoomType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Mức giá thuê (đ/tháng)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_priceRangeValues.start.round()} Triệu',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13),
                        ),
                        Text(
                          '${_priceRangeValues.end.round()} Triệu+',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _priceRangeValues,
                      min: 0,
                      max: 15,
                      divisions: 15,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.surfaceLight,
                      labels: RangeLabels(
                        '${_priceRangeValues.start.round()} tr',
                        '${_priceRangeValues.end.round()} tr',
                      ),
                      onChanged: (RangeValues values) {
                        setModalState(() {
                          _priceRangeValues = values;
                          _selectedPricePreset = '${values.start.round()} - ${values.end.round()} tr';
                        });
                      },
                    ),
                    Wrap(
                      spacing: 8,
                      children: _pricePresets.map((preset) {
                        final isSel = _selectedPricePreset == preset;
                        return ChoiceChip(
                          label: Text(preset),
                          selected: isSel,
                          selectedColor: AppColors.primary.withValues(alpha: 0.3),
                          labelStyle: TextStyle(
                            color: isSel ? AppColors.primaryLight : AppColors.textSecondary,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                _selectedPricePreset = preset;
                                if (preset == '< 3 triệu') {
                                  _priceRangeValues = const RangeValues(0, 3);
                                } else if (preset == '3 - 5 triệu') {
                                  _priceRangeValues = const RangeValues(3, 5);
                                } else if (preset == '5 - 8 triệu') {
                                  _priceRangeValues = const RangeValues(5, 8);
                                } else if (preset == '> 8 triệu') {
                                  _priceRangeValues = const RangeValues(8, 15);
                                } else {
                                  _priceRangeValues = const RangeValues(0, 15);
                                }
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Tiện ích phòng trọ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _availableAmenities.map((amenity) {
                        final isSelected = _selectedAmenities.contains(amenity);
                        return FilterChip(
                          label: Text(amenity),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withValues(alpha: 0.3),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                _selectedAmenities.add(amenity);
                              } else {
                                _selectedAmenities.remove(amenity);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Áp dụng bộ lọc',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      legacy_provider.Provider.of<RoomProvider>(context, listen: false).fetchApprovedRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = legacy_provider.Provider.of<AuthProvider>(context).currentUser;
    final roomProvider = legacy_provider.Provider.of<RoomProvider>(context);
    final badgeState = ref.watch(badgeCounterProvider);
    final rawRooms = roomProvider.approvedRooms.isNotEmpty
        ? roomProvider.approvedRooms
        : _fallbackRooms;

    List<RoomEntity> displayRooms = rawRooms.where((room) {
      final kw = _searchController.text.trim().toLowerCase();
      if (kw.isNotEmpty) {
        final matchTitle = room.tieuDe.toLowerCase().contains(kw);
        final matchAddress = room.diaChi.toLowerCase().contains(kw);
        final matchDesc = room.moTa.toLowerCase().contains(kw);
        if (!matchTitle && !matchAddress && !matchDesc) return false;
      }

      if (_selectedDistrict != 'Tất cả' &&
          !room.quanHuyen.contains(
            _selectedDistrict.replaceAll(', Hà Nội', '').replaceAll(
              ', TP.HCM',
              '',
            ),
          )) {
        return false;
      }

      if (_selectedRoomType != 'Tất cả' && room.loaiPhong != _selectedRoomType) {
        return false;
      }

      if (_selectedPricePreset == 'Dưới 3 triệu' && room.giaThue >= 3000000) {
        return false;
      }
      if (_selectedPricePreset == '3 - 5 triệu' &&
          (room.giaThue < 3000000 || room.giaThue > 5000000)) {
        return false;
      }
      if (_selectedPricePreset == '5 - 8 triệu' &&
          (room.giaThue < 5000000 || room.giaThue > 8000000)) {
        return false;
      }
      if (_selectedPricePreset == 'Trên 8 triệu' && room.giaThue <= 8000000) {
        return false;
      }

      if (_selectedAmenities.isNotEmpty) {
        for (var a in _selectedAmenities) {
          if (!room.tienIch.contains(a)) return false;
        }
      }

      if (_selectedQuickCategory == 'Giá rẻ (< 3tr)' && room.giaThue >= 3000000) {
        return false;
      }
      if (_selectedQuickCategory == 'Full tiện nghi' && room.tienIch.length < 5) {
        return false;
      }

      return true;
    }).toList();

    if (_sortOption == 'GIA_TANG') {
      displayRooms.sort((a, b) => a.giaThue.compareTo(b.giaThue));
    } else if (_sortOption == 'GIA_GIAM') {
      displayRooms.sort((a, b) => b.giaThue.compareTo(a.giaThue));
    } else if (_sortOption == 'DANH_GIA') {
      displayRooms.sort((a, b) => b.diemDanhGiaTB.compareTo(a.diemDanhGiaTB));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          user != null ? 'Xin chào, ${user.hoTen}!' : 'Tìm kiếm phòng trọ',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
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
                      user?.avatarUrl != null && user!.avatarUrl!.trim().isNotEmpty
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                  child: user?.avatarUrl == null || user!.avatarUrl!.trim().isEmpty
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
            await roomProvider.fetchApprovedRooms();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar & Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() {}),
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Tìm theo tên, địa chỉ, quận...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.textLight,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showFilterBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Banner Slide
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: AppGradients.primarySoft,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: PageView(
                    children: [
                      _buildBannerSlide(
                        'Ưu đãi phòng trọ Sinh viên 2026',
                        'Đặt cọc nhanh qua VNPay/MoMo',
                        Icons.campaign_rounded,
                      ),
                      _buildBannerSlide(
                        'Phòng trọ gần ĐH Quốc Gia & FTU',
                        'Cam kết chính chủ, xem phòng thực tế 100%',
                        Icons.verified_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Categories scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickCategories.map((cat) {
                      final isSel = _selectedQuickCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          avatar: isSel ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                          label: Text(cat, style: const TextStyle(fontSize: 12)),
                          selected: isSel,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                          elevation: isSel ? 3 : 0,
                          shadowColor: AppColors.primary.withValues(alpha: 0.35),
                          onSelected: (val) {
                            if (val) setState(() => _selectedQuickCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Header & sort dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Danh sách phòng (${displayRooms.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _sortOption,
                      dropdownColor: AppColors.surfaceLight,
                      underline: const SizedBox(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'MAC_DINH',
                          child: Text('Mặc định'),
                        ),
                        DropdownMenuItem(
                          value: 'GIA_TANG',
                          child: Text('Giá: Thấp -> Cao'),
                        ),
                        DropdownMenuItem(
                          value: 'GIA_GIAM',
                          child: Text('Giá: Cao -> Thấp'),
                        ),
                        DropdownMenuItem(
                          value: 'DANH_GIA',
                          child: Text('Đánh giá cao nhất'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _sortOption = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (roomProvider.isLoading)
                  const Column(
                    children: [
                      ShimmerRoomCardSkeleton(),
                      ShimmerRoomCardSkeleton(),
                    ],
                  )
                else if (displayRooms.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: AppColors.textLight),
                        SizedBox(height: 12),
                        Text(
                          'Không tìm thấy phòng trọ phù hợp',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: displayRooms.map((room) {
                      final isFav = roomProvider.isFavorite(room.maPhong);
                      return RoomCardWidget(
                        room: room,
                        isFavorite: isFav,
                        onFavoriteToggle: () {
                          roomProvider.toggleFavorite(room);
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoomDetailScreen(room: room),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlide(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0x33FFFFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
