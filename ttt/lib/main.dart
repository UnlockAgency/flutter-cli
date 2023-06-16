import 'package:ttt/app_config.dart';
import 'package:ttt/main/app.dart';
import 'package:ttt/main_common.dart';

void main() async {
  final flavor = Flavor.fromString(const String.fromEnvironment('FLAVOR'));
  const apiHost = String.fromEnvironment('API_HOST');
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  final config = Config(
    flavor: flavor,
    apiHost: apiHost,
    sentryDsn: sentryDsn,
  );

  await mainCommon(config);

  final app = Configurable(
    config: config,
    child: App(),
  );

  run(app);
}
