import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ttt/constants/assets.dart';
import 'package:ttt/constants/routes.dart';
import 'package:ttt/constants/constants.dart';
import 'package:ttt/mixins/post_frame_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with PostFrameMixin {
  @override
  void initState() {
    super.initState();

    // Using postFrame mixin, to be able to use InheritedWidget calls in initState method.
    postFrame(start);
  }

  Future<void> start() async {
    final instance = await SharedPreferences.getInstance();

    bool onboardingFinished = instance.getBool(Strings.storageKeyOnboardingFinished) ?? false;

    // Check if we're able to access the context
    if (!mounted) {
      return;
    }

    if (onboardingFinished) {
      GoRouter.of(context).pushReplacementNamed(Routes.dashboard.name);
      return;
    }

    GoRouter.of(context).pushReplacementNamed(Routes.onboarding.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: const <Widget>[
          Center(
            child: Image(
              height: 175.0,
              width: 175.0,
              fit: BoxFit.contain,
              image: AssetImage(Assets.iconApp),
            ),
          ),
        ],
      ),
    );
  }
}
