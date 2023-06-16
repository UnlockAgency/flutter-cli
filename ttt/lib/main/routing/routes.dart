import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ttt/constants/routes.dart';
import 'package:ttt/managers/tracking/tracking_manager.dart';
import 'package:ttt/routing/route_screen.dart';
import 'package:ttt/screens/dashboard/dashboard_screen.dart';
import 'package:ttt/screens/details/details_screen.dart';
import 'package:ttt/screens/onboarding/start/start_screen.dart';
import 'package:ttt/screens/onboarding/notifications/notifications_screen.dart';
import 'package:ttt/screens/splash/splash_screen.dart';

final routes = <GoRoute>[
  // SPLASH
  // ----------------
  GoRoute(
    name: Routes.splashScreen.name,
    path: Routes.splashScreen.path,
    pageBuilder: (BuildContext context, GoRouterState state) {
      return const NoTransitionPage(
        child: RouteScreen(
          child: SplashScreen(),
        ),
      );
    },
  ),

  // ONBOARDING
  // ----------------
  GoRoute(
    name: Routes.onboarding.name,
    path: Routes.onboarding.path,
    pageBuilder: (BuildContext context, GoRouterState state) {
      return const NoTransitionPage(
        child: RouteScreen(
          screen: Screen.onboardingStart,
          child: StartScreen(),
        ),
      );
    },
  ),
  GoRoute(
    name: Routes.onboardingNotifications.name,
    path: Routes.onboardingNotifications.path,
    builder: (BuildContext context, GoRouterState state) {
      return const RouteScreen(
        screen: Screen.onboardingNotifications,
        child: NotificationsScreen(),
      );
    },
  ),

  // DASHBOARD
  // ----------------
  GoRoute(
    name: Routes.dashboard.name,
    path: Routes.dashboard.path,
    pageBuilder: (BuildContext context, GoRouterState state) {
      return const NoTransitionPage(
        child: RouteScreen(
          screen: Screen.dashboard,
          child: DashboardScreen(),
        ),
      );
    },
  ),
];
