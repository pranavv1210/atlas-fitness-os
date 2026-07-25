import 'package:flutter/widgets.dart';

import 'app_dependencies.dart';

class AppScope extends InheritedWidget {
  const AppScope({required this.dependencies, required super.child, super.key});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw StateError('AppScope was not found in the widget tree');
    }
    return scope.dependencies;
  }

  static AppDependencies read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw StateError('AppScope was not found in the widget tree');
    }
    return scope.dependencies;
  }

  static AppDependencies? maybeRead(BuildContext context) {
    return context.getInheritedWidgetOfExactType<AppScope>()?.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return oldWidget.dependencies != dependencies;
  }
}
