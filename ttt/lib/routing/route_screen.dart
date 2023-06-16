import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ttt/main/app.dart';
import 'package:ttt/main/injection.dart';
import 'package:ttt/services/tracking_service.dart';
import 'package:ttt/styles/text_style.dart';

class RouteScreen extends StatefulWidget {
  final Screenable? screen;
  final Widget child;

  const RouteScreen({
    super.key,
    this.screen,
    required this.child,
  });

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> with RouteAware {
  final Logger _logger = getIt<Logger>();
  final TrackingService _trackingService = getIt<TrackingService>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _logger.i('RouteScreen.didPush() => ${widget.child} (${widget.screen?.name ?? 'unknown'})');

    if (widget.screen != null) {
      _trackingService.screenView(widget.screen!);
    }
  }

  @override
  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    _logger.i('RouteScreen.didPopNext() => ${widget.child} (${widget.screen?.name ?? 'unknown'})');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: BaseTextStyle(),
      child: widget.child,
    );
  }
}
