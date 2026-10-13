import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_gradients.dart';
import '../../domain/entities/room_entity.dart';
import 'animated_favorite_button.dart';
import 'glowing_verification_badge.dart';

class RoomCardWidget extends StatelessWidget {
  final RoomEntity room;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const RoomCardWidget({
    super.key,
    required this.room,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} đ/tháng';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image with gradient overlay ────────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    // Room image with Hero animation transition
                    Hero(
                      tag: 'room-image-${room.maPhong}',
                      child: SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: room.danhSachAnh.isNotEmpty
                            ? Image.network(
                                room.danhSachAnh.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.surfaceLight,
                                  child: const Center(
                                    child: Icon(
                                      Icons.home_work_outlined,
                                      size: 50,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.surfaceLight,
                                child: const Center(
                                  child: Icon(
                                    Icons.home_work_outlined,
                                    size: 50,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Bottom gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 90,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: AppGradients.imageOverlay,
                        ),
                      ),
                    ),

                    // Top gradient overlay (subtle)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: AppGradients.imageOverlayTop,
                        ),
                      ),
                    ),

                    // Status badge & Verified badge (top left)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        children: [
                          _buildStatusBadge(),
                          const SizedBox(width: 6),
                          const GlowingVerificationBadge(
                            label: 'Uy tín',
                            fontSize: 10,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ],
                      ),
                    ),

                    // Animated Favorite button (top right)
                    if (onFavoriteToggle != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AnimatedFavoriteButton(
                          isFavorite: isFavorite,
                          onTap: onFavoriteToggle!,
                        ),
                      ),

                    // Price on image (bottom left)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          _formatCurrency(room.giaThue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Rating on image (bottom right)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Color(0xFFFFD700)),
                            const SizedBox(width: 3),
                            Text(
                              room.diemDanhGiaTB.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Room details ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      room.tieuDe,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${room.quanHuyen}, ${room.diaChi}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Stats row
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.square_foot_rounded,
                          '${room.dienTich} m²',
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          Icons.people_outline_rounded,
                          '${room.soNguoiOToiDa} người',
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            room.loaiPhong,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textLight),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String text = 'Còn trống';
    Gradient gradient = AppGradients.success;

    if (room.trangThaiThue == 'TAM_KHOA_CHO_COC') {
      text = 'Chờ đặt cọc';
      gradient = AppGradients.warning;
    } else if (room.trangThaiThue == 'DA_CHO_THUE') {
      text = 'Đã cho thuê';
      gradient = AppGradients.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
