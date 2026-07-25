import 'package:flutter/material.dart';

import '../core/di/app_dependencies.dart';
import '../core/di/app_scope.dart';
import '../core/startup/startup_screen.dart';
import 'theme/atlas_theme.dart';

class AtlasApp extends StatelessWidget {
  const AtlasApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: dependencies,
      child: MaterialApp(
        title: 'Atlas',
        debugShowCheckedModeBanner: false,
        theme: AtlasTheme.light,
        home: const StartupScreen(),
      ),
    );
  }
}
