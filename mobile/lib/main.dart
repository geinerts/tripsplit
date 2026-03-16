import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';
import 'core/monitoring/app_monitoring.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.bootstrap();
  await AppMonitoring.bootstrapAndRun(
    dependencies: dependencies,
    appBuilder: () => TripSplitApp(dependencies: dependencies),
  );
}
