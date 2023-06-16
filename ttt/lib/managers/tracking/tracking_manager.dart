import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:ttt/main/injection.dart';
import 'package:logger/logger.dart';
import 'package:ttt/services/tracking_service.dart';

enum Screen implements Screenable {
  onboardingStart('Onboarding'),
  onboardingNotifications('Onboarding / Notifications'),
  dashboard('Dashboard'),
  details('Details');

  const Screen(this.name);

  @override
  final String name;
}

class TrackingManager implements TrackingService {
  final Logger _logger = getIt<Logger>();

  @override
  Future<void> updateUserProperty({required UserPropertyable property, String? value}) async {
    await FirebaseAnalytics.instance.setUserProperty(name: property.name, value: value);
  }

  @override
  Future<void> screenView(Screenable screen, {String? screenClass, Map<String, String>? parameters}) async {
    Map<String, dynamic> screenViewParameters = Map.from({
      'screen_name': screen.name,
      'screen_class': screenClass,
    }..addAll(parameters ?? {}))
      // Analytics only accepts values as String or number
      ..removeWhere((key, value) => value == null);

    _logger.d('[Tracking] <Screen>: ${screen.name}, parameters: ${jsonEncode(screenViewParameters)}');

    await FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: screenViewParameters,
    );
  }

  @override
  Future<void> logEvent(Event event) async {
    final parameters = (event.parameters ?? {})..removeWhere((key, value) => value == null);

    _logger.d('[Tracking] <Event>: ${event.name}, parameters: ${jsonEncode(parameters)}');
    await FirebaseAnalytics.instance.logEvent(
      name: event.name.value,
      parameters: parameters,
    );
  }
}
