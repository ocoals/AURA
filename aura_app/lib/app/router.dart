import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/wardrobe/wardrobe_screen.dart';
import '../features/match/match_screen.dart';
import '../features/profile/profile_screen.dart';
import 'shell_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ShellScreen(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (_, state) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/closet', builder: (_, state) => const WardrobeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/match', builder: (_, state) => const MatchScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/my', builder: (_, state) => const ProfileScreen()),
        ]),
      ],
    ),
  ],
);
