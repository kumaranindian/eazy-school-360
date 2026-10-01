import 'bootstrap.dart';
import 'core/config/environment.dart';
import 'firebase_options_production.dart';

Future<void> main() async {
  await bootstrap(
    environment: Environment.production,
    firebaseOptions: productionFirebaseOptions,
  );
}
