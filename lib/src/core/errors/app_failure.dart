enum AppFailureKind {
  configuration,
  authentication,
  network,
  offline,
  permission,
  notFound,
  unknown,
}

class AppFailure {
  const AppFailure({
    required this.kind,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final AppFailureKind kind;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  bool get canRetry =>
      kind == AppFailureKind.network ||
      kind == AppFailureKind.offline ||
      kind == AppFailureKind.unknown;
}
