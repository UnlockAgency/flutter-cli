import 'package:ttt/services/tracking_service.dart';

enum EventName implements EventNameable {
  login('login');

  const EventName(this.value);

  @override
  final String value;
}

class LoginEvent implements Event {
  LoginEvent();

  @override
  Map<String, dynamic>? get parameters => null;

  @override
  EventName get name => EventName.login;
}
