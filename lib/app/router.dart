import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/encode/encode_screen.dart';
import '../features/decode/decode_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/audio_encode/audio_encode_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/encode',
      name: 'encode',
      builder: (context, state) => const EncodeScreen(),
    ),
    GoRoute(
      path: '/audio_encode',
      name: 'audio_encode',
      builder: (context, state) => const AudioEncodeScreen(),
    ),
    GoRoute(
      path: '/decode',
      name: 'decode',
      builder: (context, state) => const DecodeScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
