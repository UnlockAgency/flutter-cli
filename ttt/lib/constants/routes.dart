import 'package:illuminate/routing.dart';

class Routes {
  static const splashScreen = Route(name: 'splash', path: '/');
  static const onboarding = Route(name: 'onboarding', path: '/onboarding');
  static const onboardingNotifications = Route(name: 'onboarding-notifications', path: '/onboarding/notifications');
  static const dashboard = Route(name: 'dashboard', path: '/app');
  static const details = Route(name: 'details', path: '/app/details');
}
