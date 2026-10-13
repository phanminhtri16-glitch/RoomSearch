import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_gradients.dart';
import '../../providers/room_provider.dart';
import '../../widgets/room_card_widget.dart';
import '../student/room_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final favoriteRooms = roomProvider.favoriteRooms;

    return Scaffold(
      appBar: AppBar(
        title: Text('Phòng trọ yêu thích (${favoriteRooms.length}/50)'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: favoriteRooms.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.primaryLight),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Chưa có phòng trọ yêu thích nào',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tối đa lưu 50 phòng trọ yêu thích vào danh sách',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteRooms.length,
                itemBuilder: (context, index) {
                  final room = favoriteRooms[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: RoomCardWidget(
                      room: room,
                      isFavorite: true,
                      onFavoriteToggle: () {
                        roomProvider.toggleFavorite(room);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã bỏ lưu phòng khỏi danh sách Yêu thích')),
                        );
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
