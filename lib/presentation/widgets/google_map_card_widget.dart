import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/room_entity.dart';

class GoogleMapCardWidget extends StatelessWidget {
  final RoomEntity room;

  const GoogleMapCardWidget({
    super.key,
    required this.room,
  });

  String get _fullAddress {
    final addr = room.diaChi.trim();
    final district = room.quanHuyen.trim();
    if (addr.toLowerCase().contains('hà nội')) {
      return addr;
    }
    if (district.isNotEmpty && !addr.contains(district)) {
      return '$addr, $district, Hà Nội';
    }
    return '$addr, Hà Nội';
  }

  Future<void> _openGoogleMaps(BuildContext context, {bool isDirections = false}) async {
    String query;
    if (room.viDo != null && room.kinhDo != null) {
      query = '${room.viDo},${room.kinhDo}';
    } else {
      query = _fullAddress;
    }

    final String encodedQuery = Uri.encodeComponent(query);
    final String urlString = isDirections
        ? 'https://www.google.com/maps/dir/?api=1&destination=$encodedQuery'
        : 'https://www.google.com/maps/search/?api=1&query=$encodedQuery';

    final Uri url = Uri.parse(urlString);

    try {
      bool launched = false;
      try {
        launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        launched = await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        );
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở ứng dụng Google Maps. Vui lòng kiểm tra thiết bị của bạn!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final errStr = e.toString();
        if (errStr.contains('MissingPluginException')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                'Vui lòng TẮT HẲN ỨNG DỤNG và CHẠY LẠI (Rebuild/Flutter Run) để ứng dụng nạp native plugin url_launcher!',
              ),
              duration: Duration(seconds: 6),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi mở bản đồ: $e'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.indigo.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.blue.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner xem vị trí với hiệu ứng tương tác
          InkWell(
            onTap: () => _openGoogleMaps(context, isDirections: false),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.white.withValues(alpha: 0.6),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.map_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Vị trí trên Google Maps',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fullAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (room.viDo != null && room.kinhDo != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Tọa độ: ${room.viDo!.toStringAsFixed(4)}, ${room.kinhDo!.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Colors.black12),

          // Các nút hành động: Mở Maps & Chỉ đường
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _openGoogleMaps(context, isDirections: false),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text(
                      'Xem Bản Đồ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _openGoogleMaps(context, isDirections: true),
                    icon: const Icon(Icons.directions_outlined, size: 18),
                    label: const Text(
                      'Chỉ Đường',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
