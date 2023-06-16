import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ttt/assets/buttons/action_button.dart';
import 'package:illuminate/ui.dart';
import 'package:ttt/constants/routes.dart';
import 'package:ttt/constants/constants.dart';
import 'package:ttt/main/scaffolds/page_scaffold.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.p12),
        child: Center(
          child: SpacedColumn(
            spacing: Dimensions.p12,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Title"),
              ActionButton(
                title: "Open details",
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

  void push() {
    GoRouter.of(context).push(Routes.details.name);
  }
}
