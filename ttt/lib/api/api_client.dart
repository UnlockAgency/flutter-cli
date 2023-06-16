import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ttt/main/injection.dart';
import 'package:logger/logger.dart';
import 'package:illuminate/network.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ApiClient extends Client {
  final Logger _logger = getIt<Logger>();

  late String host;

  ApiClient({
    required this.host,
    required oauthConfig,
    bool logging = false,
  }) : super(
          ApiConfig(host: host, oAuthConfig: oauthConfig),
          exceptionHandler: (exception, stacktrace) async {
            await Sentry.captureException(
              exception,
              stackTrace: stacktrace,
            );
          },
        );

  @override
  Future<Response> request(Request request) async {
    Map<String, dynamic> headers = request.headers ?? {};
    headers['Accept-Language'] = Platform.localeName;
    request.headers = headers;

    return super.request(request);
  }
}
