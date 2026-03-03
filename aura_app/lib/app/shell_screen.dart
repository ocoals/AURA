import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/app_tab_bar.dart';
import '../shared/widgets/gradient_background.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: Stack(
          children: [
            shell,
            AppTabBar(
              currentIndex: shell.currentIndex,
              onTap: (index) => shell.goBranch(
                index,
                initialLocation: index == shell.currentIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
