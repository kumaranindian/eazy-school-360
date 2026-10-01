import 'package:logger/logger.dart';

import 'log_event.dart';

/// Structured, environment-aware application logger.
///
/// Rules (see CLAUDE.md "Logging"):
/// - Never log passwords, tokens, or other credentials.
/// - Prefer [event]/[logError] with a [LogEvent] over ad hoc `logger.i(...)`
///   calls for anything that should be traceable (auth, tenant resolution,
///   access control decisions).
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Logs a standardized, traceable application event.
  ///
  /// [data] is for non-sensitive context only (ids, codes) — never pass
  /// credentials, tokens, or full user records.
  static void event(AppLogEvent event, {Map<String, Object?> data = const {}}) {
    _logger.i('${event.code} ${_formatData(data)}');
  }

  static void debug(String message) => _logger.d(message);

  static void info(String message) => _logger.i(message);

  static void warning(String message) => _logger.w(message);

  /// Logs an unexpected error with its stack trace for diagnostics.
  /// The caller is responsible for surfacing a safe [Failure] to the user
  /// separately — this is for internal diagnostics only.
  static void error(String message, Object error, [StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static String _formatData(Map<String, Object?> data) {
    if (data.isEmpty) return '';
    return data.entries.map((e) => '${e.key}=${e.value}').join(' ');
  }
}
