import 'app/app.dart';
import 'app/app_dependencies.dart';
import 'core/monitoring/app_monitoring.dart';

Future<void> main() async {
  final dependencies = AppDependencies.bootstrap();
  await AppMonitoring.bootstrapAndRun(
    dependencies: dependencies,
    appBuilder: () => TripSplitApp(dependencies: dependencies),
  );
}
