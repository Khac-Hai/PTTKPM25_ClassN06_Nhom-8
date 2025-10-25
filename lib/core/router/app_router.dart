import 'package:go_router/go_router.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../screens/main_screen.dart';
import '../../auth/auth_wrapper.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const AuthWrapper()),
      GoRoute(path: '/main', builder: (_, __) => const MainScreen()),
      GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
    ],
  );
}
