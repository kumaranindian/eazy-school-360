/// The deployment environment the app is running in.
///
/// Each environment maps to a separate Firebase project
/// (eazyschool360-dev / eazyschool360-uat / eazyschool360-prod) so that
/// development never touches production data.
enum Environment {
  development,
  uat,
  production,
}

extension EnvironmentX on Environment {
  String get label {
    switch (this) {
      case Environment.development:
        return 'development';
      case Environment.uat:
        return 'uat';
      case Environment.production:
        return 'production';
    }
  }

  bool get isProduction => this == Environment.production;
}

/// Holds the environment the app was launched with.
///
/// Set once at startup by the flavor-specific entry point
/// (`main_development.dart`, `main_uat.dart`, `main_production.dart`)
/// and read anywhere that needs environment-aware behavior
/// (e.g. logging verbosity, Firebase project selection).
class AppEnvironment {
  AppEnvironment._();

  static Environment? _current;

  static Environment get current {
    final env = _current;
    if (env == null) {
      throw StateError(
        'AppEnvironment.current read before AppEnvironment.initialize() was called. '
        'Make sure the app is launched via one of the flavor entry points.',
      );
    }
    return env;
  }

  static void initialize(Environment environment) {
    _current = environment;
  }
}
