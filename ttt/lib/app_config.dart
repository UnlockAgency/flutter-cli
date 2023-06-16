import 'package:flutter/material.dart';

enum Flavor {
  test(value: 'test'),
  accept(value: 'accept'),
  production(value: 'production'),
  release(value: 'release');

  const Flavor({required this.value});
  final String value;

  static Flavor fromString(String value) {
    return values.firstWhere((type) => type.value == value, orElse: () => Flavor.release);
  }
}

class Config {
  const Config({
    required this.flavor,
    required this.apiHost,
    this.sentryDsn,
  });

  final Flavor flavor;
  final String apiHost;
  final String? sentryDsn;
}

class Configurable extends InheritedWidget {
  const Configurable({
    super.key,
    required this.config,
    required Widget child,
  }) : super(
          child: child,
        );

  final Config config;

  static Configurable of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Configurable>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
