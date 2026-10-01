import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/environment.dart';
import 'core/logging/app_logger.dart';

/// Shared startup path for every flavor entry point
/// (`main_development.dart`, `main_uat.dart`, `main_production.dart`).
///
/// Centralizing this means the error-handling/logging foundation (Part 17,
/// Part 18) and Firebase initialization are set up identically regardless
/// of environment.
Future<void> bootstrap({
  required Environment environment,
  required FirebaseOptions firebaseOptions,
}) async {
  AppEnvironment.initialize(environment);

  // Framework-level errors must be visible, never swallowed (see CLAUDE.md /
  // flutter-professional-development skill) — log for diagnostics and still
  // let Flutter present them.
  FlutterError.onError = (details) {
    AppLogger.error('Uncaught Flutter error', details.exception, details.stack);
    FlutterError.presentError(details);
  };

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(options: firebaseOptions);

      PlatformDispatcher.instance.onError = (error, stack) {
        AppLogger.error('Uncaught platform error', error, stack);
        return true;
      };

      runApp(const ProviderScope(child: EazySchoolApp()));
    },
    (error, stack) => AppLogger.error('Uncaught zone error', error, stack),
  );
}
