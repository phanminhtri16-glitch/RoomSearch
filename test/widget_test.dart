import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:room_search/data/repositories/auth_repository_impl.dart';
import 'package:room_search/data/repositories/room_repository_impl.dart';
import 'package:room_search/main.dart';
import 'package:room_search/presentation/providers/admin_provider.dart';
import 'package:room_search/presentation/providers/app_state_provider.dart';
import 'package:room_search/presentation/providers/auth_provider.dart';
import 'package:room_search/presentation/providers/chat_provider.dart';
import 'package:room_search/presentation/providers/landlord_provider.dart';
import 'package:room_search/presentation/providers/navigation_provider.dart';
import 'package:room_search/presentation/providers/room_provider.dart';

void main() {
  testWidgets('RoomSearchApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: legacy_provider.MultiProvider(
          providers: [
            legacy_provider.ChangeNotifierProvider(create: (_) => AppStateProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepositoryImpl())),
            legacy_provider.ChangeNotifierProvider(create: (_) => RoomProvider(RoomRepositoryImpl())),
            legacy_provider.ChangeNotifierProvider(create: (_) => LandlordProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => AdminProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => NavigationProvider()),
            legacy_provider.ChangeNotifierProvider(create: (_) => ChatProvider()),
          ],
          child: const RoomSearchApp(),
        ),
      ),
    );
    expect(find.byType(RoomSearchApp), findsOneWidget);
  });
}
