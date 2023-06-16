import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ttt/assets/buttons/action_button.dart';
import 'package:illuminate/ui.dart';
import 'package:ttt/constants/routes.dart';
import 'package:ttt/constants/constants.dart';
import 'package:ttt/main/scaffolds/onboarding_page_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return OnboardingPageScaffold(
      child: Padding(
        padding: EdgeInsets.all(Dimensions.p12),
        child: Center(
          child: SpacedColumn(
            spacing: Dimensions.p12,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Notifications"),
              ActionButton(
                title: "Finish onboarding!",
                onPressed: () {
                  return push();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> push() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(Strings.storageKeyOnboardingFinished, true);

    if (!mounted) return;

    GoRouter.of(context).goNamed(Routes.dashboard.name);
  }
}
