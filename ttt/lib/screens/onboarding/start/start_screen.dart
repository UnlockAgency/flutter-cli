import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ttt/assets/buttons/action_button.dart';
import 'package:illuminate/ui.dart';
import 'package:ttt/constants/routes.dart';
import 'package:ttt/constants/constants.dart';
import 'package:ttt/main/scaffolds/onboarding_page_scaffold.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final Logger _logger = getIt<Logger>();
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageScaffold(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.p12),
        child: Center(
          child: SpacedColumn(
            spacing: Dimensions.p8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Start, welcome!"),
              ActionButton(
                title: "Go to notifications",
                loading: _isLoading,
                onPressed: () async {
                  push();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> push() async {
    setState(() => _isLoading = true);

    if (!mounted) return;

    setState(() => _isLoading = false);

    GoRouter.of(context).pushNamed(Routes.onboardingNotifications.name);
  }
}
