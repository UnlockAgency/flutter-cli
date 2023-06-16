import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ttt/assets/buttons/action_button.dart';
import 'package:illuminate/ui.dart';
import 'package:ttt/constants/constants.dart';
import 'package:ttt/main/scaffolds/page_scaffold.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Padding(
        padding: EdgeInsets.all(Dimensions.p12),
        child: Center(
          child: SpacedColumn(
            spacing: Dimensions.p12,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Details"),
              ActionButton(
                title: "Go back",
                onPressed: () async {
                  pop();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void pop() {
    GoRouter.of(context).pop();
  }
}
