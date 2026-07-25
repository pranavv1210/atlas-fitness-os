import 'package:flutter/material.dart';

import 'src/app/atlas_app.dart';
import 'src/core/di/app_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AtlasApp(dependencies: AppDependencies.create()));
}
