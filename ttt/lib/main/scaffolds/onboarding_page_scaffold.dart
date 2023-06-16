import 'package:flutter/material.dart';
import 'package:ttt/constants/constants.dart';

class OnboardingPageScaffold extends StatelessWidget {
  const OnboardingPageScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Not switching between platforms, because styling an iOS appBar is quite impossible
    return Scaffold(
      body: child,
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Onboarding"),
        elevation: 0,
      ),
    );
  }
}
