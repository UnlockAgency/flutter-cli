import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:illuminate/logging.dart';
import 'package:illuminate/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttt/constants/constants.dart';
import 'package:ttt/app_config.dart';
import 'package:ttt/managers/tracking/tracking_manager.dart';
import 'package:ttt/services/tracking_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection(Config config) async {
  // Register the logger first
  getIt.registerSingleton<Logger>(await _createLogger(config));

  getIt
    ..registerLazySingleton<StorageManager>(() => StorageManager(
          prefix: 'groepsuitjes-breda',
          iosConfig: IOSConfig(),
          androidConfig: AndroidConfig(
            sharedPreferencesName: 'groepsuitjes-breda',
            encryptedSharedPreferences: true,
          ),
        ))
    ..registerLazySingleton<TrackingService>(() => TrackingManager());
}

Future<Logger> _createLogger(Config config) async {
  final serviceAccount = await rootBundle.loadString(
    'assets/keys/${Strings.cloudLoggingServiceAccount}',
  );

  // Get or create a unique id for this user
  final instance = await SharedPreferences.getInstance();
  String? loggingIdentifier = instance.getString(Strings.storageKeyLoggingIdentifier);

  if (loggingIdentifier == null) {
    loggingIdentifier = const Uuid().v4();
    instance.setString(Strings.storageKeyLoggingIdentifier, loggingIdentifier);
  }

  final logger = await Logging.createInstance(
    userIdentifier: loggingIdentifier,
    level: [
      Flavor.production,
      Flavor.release,
    ].contains(config.flavor)
        ? Level.nothing
        : Level.verbose,
    serviceAccount: serviceAccount,
  );

  // Log launch
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  final appName = packageInfo.appName;
  final bundleIdentifier = packageInfo.packageName;
  final version = packageInfo.version;
  final buildNumber = packageInfo.buildNumber;

  logger.i('''
  ---------------------------------------------
   Launching $appName
    - Operating system: ${Platform.operatingSystem}
    - Locale: ${Platform.localeName}
    - Environment: ${config.flavor}
    - Bundle identifier: $bundleIdentifier
    - Version: $version
    - Build number: $buildNumber
  ---------------------------------------------''');

  return logger;
}
