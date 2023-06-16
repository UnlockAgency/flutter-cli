import 'dart:isolate';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ttt/app_config.dart';
// import 'package:ttt/firebase/firebase_options.dart' as firebase_release;
// import 'package:ttt/firebase/firebase_options_test.dart' as firebase_test;
// import 'package:ttt/firebase/firebase_options_accept.dart' as firebase_accept;
// import 'package:ttt/firebase/firebase_options_production.dart' as firebase_production;
import 'package:ttt/main/injection.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Flavor kFlavor = Flavor.release;

Future<void> mainCommon(Config config) async {
  WidgetsFlutterBinding.ensureInitialized();

  kFlavor = config.flavor;

  // Switch Firebase configuration based on Flavor
  // FirebaseOptions? options;

  // if (config.flavor == Flavor.test) {
  //   options = firebase_test.DefaultFirebaseOptions.currentPlatform;
  // } else if (config.flavor == Flavor.accept) {
  //   options = firebase_accept.DefaultFirebaseOptions.currentPlatform;
  // } else if (config.flavor == Flavor.production) {
  //   options = firebase_production.DefaultFirebaseOptions.currentPlatform;
  // } else {
  //   options = firebase_release.DefaultFirebaseOptions.currentPlatform;
  // }

  // await Firebase.initializeApp(
  //   name: "firebase-${config.flavor.name}",
  //   options: options,
  // );

  if (!kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // Catch errors happening outside of Flutter
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  await setupDependencyInjection(config);

  final log = 'Starting app in flavor: ${config.flavor}';
  getIt<Logger>().i(log);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

Future<void> run(Configurable app) async {
  final sentryDsn = app.config.sentryDsn;

  if (kDebugMode || sentryDsn == null) {
    runApp(app);
    return;
  }

  await SentryFlutter.init(
    (options) => options.dsn = sentryDsn,
    appRunner: () => runApp(app),
  );
}
