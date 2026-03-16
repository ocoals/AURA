import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/match/match_result_screen.dart';
import '../features/match/match_screen.dart';
import '../features/match/models/match_result.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/photo_onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/wardrobe/wardrobe_screen.dart';
import '../features/wardrobe/models/wardrobe_item.dart';
import '../features/wardrobe/widgets/item_confirm_screen.dart';
import '../features/wardrobe/widgets/item_detail_screen.dart';
import 'shell_screen.dart';

final authNotifier = AuthNotifier();

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final status = authNotifier.status;
    final path = state.matchedLocation;

    const publicPaths = ['/splash', '/onboarding', '/login', '/signup'];
    final isPublicPage = publicPaths.contains(path);

    switch (status) {
      case AppAuthStatus.unknown:
        // Stay on splash while checking session
        if (path != '/splash') return '/splash';
        return null;

      case AppAuthStatus.unauthenticated:
        // Leave splash once auth state is known
        if (path == '/splash') return '/onboarding';
        // Allow public pages, redirect others to login
        if (isPublicPage) return null;
        return '/login';

      case AppAuthStatus.onboardingPending:
        // Force to photo onboarding, but allow /closet/add for item registration
        if (path == '/photo-onboarding' || path == '/closet/add') return null;
        return '/photo-onboarding';

      case AppAuthStatus.ready:
        // Redirect away from public/photo-onboarding pages to home
        if (isPublicPage || path == '/photo-onboarding') return '/home';
        return null;
    }
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (_, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/photo-onboarding',
      builder: (_, state) => const PhotoOnboardingScreen(),
    ),
    GoRoute(
      path: '/closet/add',
      builder: (_, state) {
        final extra = state.extra;
        if (extra is String) {
          return ItemConfirmScreen(imagePath: extra);
        }
        final map = extra! as Map<String, dynamic>;
        return ItemConfirmScreen(
          imagePath: map['imagePath'] as String,
          isOnboarding: map['isOnboarding'] as bool? ?? false,
        );
      },
    ),
    GoRoute(
      path: '/closet/detail',
      builder: (_, state) =>
          ItemDetailScreen(item: state.extra! as WardrobeItem),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ShellScreen(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (_, state) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/closet',
              builder: (_, state) => const WardrobeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/match',
            builder: (_, state) => const MatchScreen(),
            routes: [
              GoRoute(
                path: 'result',
                builder: (_, state) => MatchResultScreen(
                  result: state.extra! as MatchResult,
                ),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/my', builder: (_, state) => const ProfileScreen()),
        ]),
      ],
    ),
  ],
);
