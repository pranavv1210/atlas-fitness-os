import 'package:flutter/material.dart';

import 'src/app/atlas_app.dart';
import 'src/core/di/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.create();
  await dependencies.initializeLocalServices();
  runApp(AtlasApp(dependencies: dependencies));
}
