abstract class Screenable {
  String get name;
}

abstract class EventNameable {
  String get value;
}

abstract class Event {
  EventNameable get name;
  Map<String, dynamic>? get parameters;
}

abstract class UserPropertyable {
  String get name;
}

abstract class TrackingService {
  Future<void> updateUserProperty({required UserPropertyable property, String? value});

  Future<void> screenView(
    Screenable screen, {
    String? screenClass,
    Map<String, String>? parameters,
  });

  Future<void> logEvent(Event event);
}
