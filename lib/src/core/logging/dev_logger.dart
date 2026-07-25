import 'dart:developer' as developer;

import 'app_logger.dart';

class DevLogger implements AppLogger {
  const DevLogger();

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log('DEBUG', message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, error: error, stackTrace: stackTrace);
  }

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log('INFO', message, error: error, stackTrace: stackTrace);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log('WARN', message, error: error, stackTrace: stackTrace);
  }

  void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'Atlas.$level',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
