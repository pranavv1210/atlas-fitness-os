import 'package:atlas_fitness_os/src/app/theme/atlas_theme.dart';
import 'package:atlas_fitness_os/src/core/di/app_dependencies.dart';
import 'package:atlas_fitness_os/src/core/di/app_scope.dart';
import 'package:atlas_fitness_os/src/core/services/atlas_preferences.dart';
import 'package:atlas_fitness_os/src/features/atlas/data/atlas_data_repository.dart';
import 'package:atlas_fitness_os/src/features/atlas/data/atlas_models.dart';
import 'package:atlas_fitness_os/src/features/train/presentation/train_screen.dart';
import 'package:atlas_fitness_os/src/features/today/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repository extends Fake implements AtlasDataRepository {
  int loads = 0;
  @override
  String get currentUserId => 'test-user';
  @override
  AtlasDashboardSnapshot get cachedSnapshot => emptyAtlasSnapshot();
  @override
  Future<AtlasDashboardSnapshot> loadSnapshot() async {
    loads++;
    return emptyAtlasSnapshot();
  }
}

class _Dependencies extends Fake implements AppDependencies {
  _Dependencies(this.preferences, this.atlasDataRepository);
  @override
  final AtlasPreferences preferences;
  @override
  final AtlasDataRepository atlasDataRepository;
  @override
  final workoutDraftVersion = ValueNotifier<int>(0);
}

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'Chat draft appears immediately in Train (${dark ? 'dark' : 'light'})',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({});
        final preferences = AtlasPreferences(
          await SharedPreferences.getInstance(),
        );
        final repository = _Repository();
        final bundled = await tester.runAsync(loadBundledExercises);
        expect(bundled!.length, greaterThan(800));
        final dependencies = _Dependencies(preferences, repository);
        await tester.pumpWidget(
          AppScope(
            dependencies: dependencies,
            child: MaterialApp(
              theme: dark ? AtlasTheme.dark : AtlasTheme.light,
              home: const Scaffold(body: TrainScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final loadsBeforeChat = repository.loads;
        await preferences.setWorkoutDraft('test-user', {
          'dayNumber': 2,
          'savedAt': DateTime.now().toIso8601String(),
          'entries': [
            {
              'exerciseId': 'pulldown',
              'exerciseName': 'Lat Pulldown',
              'sets': 3,
              'reps': 15,
              'weight': 65,
            },
          ],
        });
        dependencies.workoutDraftVersion.value++;
        await tester.pump();
        expect(find.text('Lat Pulldown'), findsOneWidget);
        expect(find.text('Back + Biceps'), findsOneWidget);
        expect(
          repository.loads,
          loadsBeforeChat,
          reason: 'A local draft update must not wait for a network reload',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await preferences.setWorkoutDraft('test-user', {
          'dayNumber': 2,
          'savedAt': DateTime.now().toIso8601String(),
          'entries': [
            {
              'exerciseId': 'remote-id-changed',
              'exerciseName': 'Ab Roller',
              'sets': 3,
              'reps': 12,
              'weight': 0,
            },
          ],
        });
        await tester.pumpWidget(
          AppScope(
            dependencies: dependencies,
            child: MaterialApp(
              theme: dark ? AtlasTheme.dark : AtlasTheme.light,
              home: const Scaffold(body: TrainScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Ab Roller'),
          findsOneWidget,
          reason:
              'A restarted draft must resolve names from the full bundled library',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
