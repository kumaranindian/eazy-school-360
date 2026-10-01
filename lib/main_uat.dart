import 'bootstrap.dart';
import 'core/config/environment.dart';
import 'firebase_options_uat.dart';

Future<void> main() async {
  await bootstrap(
    environment: Environment.uat,
    firebaseOptions: uatFirebaseOptions,
  );
}
