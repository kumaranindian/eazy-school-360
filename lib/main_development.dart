import 'bootstrap.dart';
import 'core/config/environment.dart';
import 'firebase_options_development.dart';

Future<void> main() async {
  await bootstrap(
    environment: Environment.development,
    firebaseOptions: developmentFirebaseOptions,
  );
}
