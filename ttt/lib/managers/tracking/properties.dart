import 'package:ttt/services/tracking_service.dart';

enum UserProperty implements UserPropertyable {
  country(name: 'country');

  const UserProperty({required this.name});

  @override
  final String name;
}
