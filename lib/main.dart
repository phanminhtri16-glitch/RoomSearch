import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'core/constants/app_theme.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/room_repository_impl.dart';
import 'firebase_options.dart';
import 'presentation/providers/admin_provider.dart';
import 'presentation/providers/app_state_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/landlord_provider.dart';
import 'presentation/providers/navigation_provider.dart';
import 'presentation/providers/room_provider.dart';
import 'presentation/screens/auth/splash_screen.dart';

import 'presentation/providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase SDK chính thức với DefaultFirebaseOptions
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully for roomsearch-67bc8');
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Khởi tạo các dependencies & repositories
  final authRepository = AuthRepositoryImpl();
  final roomRepository = RoomRepositoryImpl();

  runApp(
    ProviderScope(
      child: legacy_provider.MultiProvider(
        providers: [
          legacy_provider.ChangeNotifierProvider(create: (_) => AppStateProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
          legacy_provider.ChangeNotifierProvider(create: (_) => RoomProvider(roomRepository)),
          legacy_provider.ChangeNotifierProvider(create: (_) => LandlordProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => AdminProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => NavigationProvider()),
          legacy_provider.ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const RoomSearchApp(),
      ),
    ),
  );
}

class RoomSearchApp extends StatelessWidget {
  const RoomSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomSearch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
