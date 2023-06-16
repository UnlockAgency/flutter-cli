import 'package:flutter/material.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.child,
    this.appBar,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    // Not switching between platforms, because styling an iOS appBar is quite impossible
    return Scaffold(
      body: child,
      appBar: AppBar(
        title: const Text("Title"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
    );
  }
}
