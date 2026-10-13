import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/badge_counter_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/navigation_provider.dart';
import '../admin/admin_dashboard_tab.dart';
import '../admin/admin_listing_moderation_tab.dart';
import '../admin/admin_profile_tab.dart';
import '../admin/admin_review_and_config_tab.dart';
import '../admin/admin_user_management_tab.dart';
import '../common/favorites_screen.dart';
import '../common/messages_screen.dart';
import '../common/profile_screen.dart';
import '../common/requests_screen.dart';
import 'landlord_home_screen.dart';
import 'student_home_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = legacy_provider.Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = legacy_provider.Provider.of<ChatProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      final userId = currentUser?.maTK ?? 'CURRENT_USER';

      chatProvider.setBadgeCounterNotifier(ref.read(badgeCounterProvider.notifier));
      chatProvider.listenToMessages(userId);
      chatProvider.updateUnreadBadgeCount(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = legacy_provider.Provider.of<AuthProvider>(context);
    final navProvider = legacy_provider.Provider.of<NavigationProvider>(context);
    final badgeState = ref.watch(badgeCounterProvider);
    final userRole = authProvider.currentUser?.vaiTro ?? AppConstants.roleStudent;

    final List<Widget> pages = _getPagesForRole(userRole);
    final List<NavigationDestination> destinations = _getNavDestinationsForRole(
      userRole,
      unreadMessageCount: badgeState.unreadMessagesCount,
    );

    int safeIndex = navProvider.currentIndex;
    if (safeIndex >= pages.length) {
      safeIndex = 0;
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[safeIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 14, right: 14, bottom: 12, top: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: safeIndex,
            onDestinationSelected: (index) {
              navProvider.setIndex(index);
            },
            destinations: destinations,
          ),
        ),
      ),
    );
  }

  List<Widget> _getPagesForRole(String role) {
    if (role == AppConstants.roleLandlord) {
      return const [
        LandlordHomeScreen(),
        StudentHomeScreen(),
        RequestsScreen(),
        MessagesScreen(),
        ProfileScreen(),
      ];
    } else if (role == AppConstants.roleAdmin) {
      return const [
        AdminDashboardTab(),
        AdminListingModerationTab(),
        AdminUserManagementTab(),
        AdminReviewAndConfigTab(),
        AdminProfileTab(),
      ];
    }

    return const [
      StudentHomeScreen(),
      FavoritesScreen(),
      RequestsScreen(),
      MessagesScreen(),
      ProfileScreen(),
    ];
  }

  List<NavigationDestination> _getNavDestinationsForRole(
    String role, {
    required int unreadMessageCount,
  }) {
    Widget buildMessageIcon() {
      const icon = Icon(Icons.chat_bubble_outline_rounded);
      if (unreadMessageCount > 0) {
        return Badge(
          label: Text('$unreadMessageCount'),
          backgroundColor: AppColors.error,
          child: icon,
        );
      }
      return icon;
    }

    Widget buildSelectedMessageIcon() {
      const icon = Icon(Icons.chat_bubble_rounded);
      if (unreadMessageCount > 0) {
        return Badge(
          label: Text('$unreadMessageCount'),
          backgroundColor: AppColors.error,
          child: icon,
        );
      }
      return icon;
    }

    if (role == AppConstants.roleLandlord) {
      return [
        const NavigationDestination(
          icon: Icon(Icons.home_work_outlined),
          selectedIcon: Icon(Icons.home_work_rounded),
          label: 'Phòng trọ',
        ),
        const NavigationDestination(
          icon: Icon(Icons.search_rounded),
          selectedIcon: Icon(Icons.search_rounded),
          label: 'Tra cứu',
        ),
        const NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment_rounded),
          label: 'Yêu cầu',
        ),
        NavigationDestination(
          icon: buildMessageIcon(),
          selectedIcon: buildSelectedMessageIcon(),
          label: 'Tin nhắn',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Cá nhân',
        ),
      ];
    } else if (role == AppConstants.roleAdmin) {
      return const [
        NavigationDestination(
          icon: Icon(Icons.bar_chart_rounded),
          selectedIcon: Icon(Icons.bar_chart_rounded),
          label: 'Thống kê',
        ),
        NavigationDestination(
          icon: Icon(Icons.verified_outlined),
          selectedIcon: Icon(Icons.verified_rounded),
          label: 'Duyệt tin',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_alt_outlined),
          selectedIcon: Icon(Icons.people_alt_rounded),
          label: 'Tài khoản',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_suggest_outlined),
          selectedIcon: Icon(Icons.settings_suggest_rounded),
          label: 'Cấu hình',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Cá nhân',
        ),
      ];
    }

    return [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Trang chủ',
      ),
      const NavigationDestination(
        icon: Icon(Icons.favorite_border_rounded),
        selectedIcon: Icon(Icons.favorite_rounded),
        label: 'Yêu thích',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment_rounded),
        label: 'Yêu cầu',
      ),
      NavigationDestination(
        icon: buildMessageIcon(),
        selectedIcon: buildSelectedMessageIcon(),
        label: 'Tin nhắn',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Tài khoản',
      ),
    ];
  }
}
