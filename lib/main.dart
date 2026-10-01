// Default entry point — defers to the development flavor so plain
// `flutter run` works out of the box. CI/release builds should always
// target `main_development.dart` / `main_uat.dart` / `main_production.dart`
// explicitly via `-t`.
import 'main_development.dart' as development;

Future<void> main() => development.main();
