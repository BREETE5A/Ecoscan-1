import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/splash/welcome_splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/settings/change_password_screen.dart';
import '../screens/settings/change_email_screen.dart';
import '../screens/auth/two_factor_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/scan/scan_result_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/badges/badges_screen.dart';
import '../screens/guide/guide_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/leaderboard/leaderboard_screen.dart';
import '../screens/language/language_screen.dart';
import '../screens/challenges/challenges_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/rewards/rewards_screen.dart';
import '../widgets/main_scaffold.dart';

CustomTransitionPage<void> _fadeSlide(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, _, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final slide = Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (c, s) => _fadeSlide(c, s, const SplashScreen()),
    ),
    GoRoute(
      path: '/language',
      pageBuilder: (c, s) => _fadeSlide(c, s, const LanguageScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (c, s) => _fadeSlide(c, s, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/welcome',
      pageBuilder: (c, s) => _fadeSlide(c, s, const WelcomeSplashScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (c, s) => _fadeSlide(c, s, const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (c, s) => _fadeSlide(c, s, const RegisterScreen()),
    ),
    GoRoute(
      path: '/verify-email',
      pageBuilder: (c, s) => _fadeSlide(c, s, const VerifyEmailScreen()),
    ),
    GoRoute(
      path: '/change-password',
      pageBuilder: (c, s) => _fadeSlide(c, s, const ChangePasswordScreen()),
    ),
    GoRoute(
      path: '/change-email',
      pageBuilder: (c, s) => _fadeSlide(c, s, const ChangeEmailScreen()),
    ),
    GoRoute(
      path: '/two-factor-setup',
      pageBuilder: (c, s) => _fadeSlide(c, s, const TwoFactorScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (c, s) => _fadeSlide(c, s, const HomeScreen()),
        ),
        GoRoute(
          path: '/map',
          pageBuilder: (c, s) => _fadeSlide(c, s, const MapScreen()),
        ),
        GoRoute(
          path: '/scan',
          pageBuilder: (c, s) => _fadeSlide(c, s, const ScanScreen()),
        ),
        GoRoute(
          path: '/scan/result',
          pageBuilder: (c, s) => _fadeSlide(c, s, const ScanResultScreen()),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (c, s) => _fadeSlide(c, s, const ChatScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (c, s) => _fadeSlide(c, s, const ProfileScreen()),
        ),
        GoRoute(
          path: '/profile/edit',
          pageBuilder: (c, s) => _fadeSlide(c, s, const EditProfileScreen()),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (c, s) => _fadeSlide(c, s, const StatsScreen()),
        ),
        GoRoute(
          path: '/badges',
          pageBuilder: (c, s) => _fadeSlide(c, s, const BadgesScreen()),
        ),
        GoRoute(
          path: '/guide',
          pageBuilder: (c, s) => _fadeSlide(c, s, const GuideScreen()),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (c, s) => _fadeSlide(c, s, const NotificationsScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (c, s) => _fadeSlide(c, s, const SettingsScreen()),
        ),
        GoRoute(
          path: '/leaderboard',
          pageBuilder: (c, s) => _fadeSlide(c, s, const LeaderboardScreen()),
        ),
        GoRoute(
          path: '/challenges',
          pageBuilder: (c, s) => _fadeSlide(c, s, const ChallengesScreen()),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (c, s) => _fadeSlide(c, s, const HistoryScreen()),
        ),
        GoRoute(
          path: '/rewards',
          pageBuilder: (c, s) => _fadeSlide(c, s, const RewardsScreen()),
        ),
      ],
    ),
  ],
);
