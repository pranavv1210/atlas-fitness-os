import 'dart:io';
import 'package:atlas_fitness_os/src/core/services/atlas_preferences.dart';
import 'package:atlas_fitness_os/src/core/services/atlas_notification_service.dart';
import 'package:atlas_fitness_os/src/features/agent/data/atlas_agent_service.dart';
import 'package:atlas_fitness_os/src/features/atlas/data/atlas_data_repository.dart';
import 'package:atlas_fitness_os/src/features/atlas/data/atlas_models.dart';
import 'package:atlas_fitness_os/src/features/agent/presentation/atlas_agent_overlay.dart';
import 'package:atlas_fitness_os/src/features/today/presentation/today_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  test('notifications stay inside the 6:00 AM to 11:30 PM window', () {
    expect(
      isWithinAtlasNotificationWindow(DateTime(2026, 9, 12, 5, 59)),
      isFalse,
    );
    expect(isWithinAtlasNotificationWindow(DateTime(2026, 9, 12, 6)), isTrue);
    expect(
      isWithinAtlasNotificationWindow(DateTime(2026, 9, 12, 23, 30)),
      isTrue,
    );
    expect(
      isWithinAtlasNotificationWindow(DateTime(2026, 9, 12, 23, 31)),
      isFalse,
    );
  });

  test('notification timezone aliases resolve to India local time', () {
    expect(resolveAtlasTimezone('IST').name, 'Asia/Kolkata');
    expect(resolveAtlasTimezone('Asia/Calcutta').name, 'Asia/Kolkata');
    expect(
      fallbackAtlasTimezone(const Duration(hours: 5, minutes: 30))?.name,
      'Asia/Kolkata',
    );
  });

  test('workout day rolls over at local midnight', () {
    final beforeMidnight = DateTime(2026, 9, 12, 23, 59, 59, 999);
    expect(nextLocalMidnight(beforeMidnight), DateTime(2026, 9, 13));
  });

  test('Buddy parses all four exercises with joined kg and shared sets', () {
    final entries = parseWorkoutEntries(
      'lat pull down machine 65kg, cable machine rowing 65kg, '
      'rope pull down for back 20kg and rear delt 30kg all 3 sets 15 reps',
    );
    expect(entries, hasLength(4));
    expect(entries.map((e) => e.weight), [65, 65, 20, 30]);
    expect(entries.every((e) => e.sets == 3 && e.reps == 15), isTrue);
  });

  test('Buddy skips explicitly excluded muscles', () {
    final entries = parseWorkoutEntries(
      'lat pulldown 35kg 3 sets 15 reps, no biceps today',
    );
    expect(entries, hasLength(1));
  });

  test('Buddy keeps only exercises explicitly named in chat', () {
    final entries = parseWorkoutEntries(
      'lat pulldown 35kg and seated cable row 30kg',
    );

    expect(entries.map((entry) => entry.name), [
      'lat pulldown',
      'seated cable row',
    ]);
    expect(entries.any((entry) => entry.name.contains('tricep')), isFalse);
  });

  test('Buddy does not match a generic cable token to triceps', () {
    const library = [
      AtlasExercise(
        id: 'triceps',
        name: 'Cable Incline Triceps Extension',
        pattern: 'extension',
        defaultSets: 3,
        defaultReps: '15',
        primaryMuscle: 'Triceps',
        equipment: 'Cable',
      ),
      AtlasExercise(
        id: 'row',
        name: 'Seated Cable Row',
        pattern: 'row',
        defaultSets: 3,
        defaultReps: '15',
        primaryMuscle: 'Back',
        equipment: 'Cable',
      ),
    ];
    const request = AtlasAgentWorkoutEntry(
      name: 'cable row for back',
      muscle: 'Back',
    );

    expect(matchAgentExercise(request, library)?.id, 'row');
  });

  test('Buddy rejects a muscle-incompatible fuzzy match', () {
    const library = [
      AtlasExercise(
        id: 'triceps',
        name: 'Cable Incline Triceps Extension',
        pattern: 'extension',
        defaultSets: 3,
        defaultReps: '15',
        primaryMuscle: 'Triceps',
        equipment: 'Cable',
      ),
    ];
    const request = AtlasAgentWorkoutEntry(
      name: 'cable movement for back',
      muscle: 'Back',
    );

    expect(matchAgentExercise(request, library), isNull);
  });

  test('Back and biceps day rejects chest, triceps, and abs exercises', () {
    const back = AtlasExercise(
      id: 'back',
      name: 'Cable Row',
      pattern: 'row',
      defaultSets: 3,
      defaultReps: '15',
      primaryMuscle: 'Back',
    );
    const biceps = AtlasExercise(
      id: 'biceps',
      name: 'Barbell Curl',
      pattern: 'curl',
      defaultSets: 3,
      defaultReps: '15',
      primaryMuscle: 'Biceps',
    );
    const chest = AtlasExercise(
      id: 'chest',
      name: 'Cable Fly',
      pattern: 'fly',
      defaultSets: 3,
      defaultReps: '15',
      primaryMuscle: 'Chest',
    );
    const triceps = AtlasExercise(
      id: 'triceps',
      name: 'Cable Triceps Extension',
      pattern: 'extension',
      defaultSets: 3,
      defaultReps: '15',
      primaryMuscle: 'Triceps',
    );
    const abs = AtlasExercise(
      id: 'abs',
      name: 'Cable Side Bend',
      pattern: 'bend',
      defaultSets: 3,
      defaultReps: '15',
      primaryMuscle: 'Abs',
    );

    expect(exerciseAllowedForWorkout(back, 'Back + Biceps'), isTrue);
    expect(exerciseAllowedForWorkout(biceps, 'Back + Biceps'), isTrue);
    expect(exerciseAllowedForWorkout(chest, 'Back + Biceps'), isFalse);
    expect(exerciseAllowedForWorkout(triceps, 'Back + Biceps'), isFalse);
    expect(exerciseAllowedForWorkout(abs, 'Back + Biceps'), isFalse);
  });

  test('Chest and triceps day rejects exercises from other workout days', () {
    const chest = AtlasExercise(
      id: 'chest',
      name: 'Cable Fly',
      pattern: 'fly',
      defaultSets: 3,
      defaultReps: '15',
      primaryMuscle: 'Chest',
    );
    const triceps = AtlasExercise(
      id: 'triceps',
      name: 'Cable Triceps Extension',
      pattern: 'extension',
      defaultSets: 3,
      defaultReps: '15',
      primaryMuscle: 'Triceps',
    );
    const back = AtlasExercise(
      id: 'back',
      name: 'Cable Row',
      pattern: 'row',
      defaultSets: 3,
      defaultReps: '15',
      primaryMuscle: 'Back',
    );

    expect(exerciseAllowedForWorkout(chest, 'Chest + Triceps'), isTrue);
    expect(exerciseAllowedForWorkout(triceps, 'Chest + Triceps'), isTrue);
    expect(exerciseAllowedForWorkout(back, 'Chest + Triceps'), isFalse);
  });

  test('Arms and abs plus leg days expand to their related muscle groups', () {
    expect(
      allowedMuscleGroupsForWorkout('Arms + Abs'),
      containsAll({'biceps', 'triceps', 'forearms', 'abs'}),
    );
    expect(
      allowedMuscleGroupsForWorkout('Shoulders + Legs'),
      containsAll({'shoulders', 'legs', 'glutes'}),
    );
  });

  test(
    'Draft survives preferences reload and remains account scoped',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = AtlasPreferences(
        await SharedPreferences.getInstance(),
      );
      await preferences.setWorkoutDraft('user-a', {
        'dayNumber': 2,
        'savedAt': DateTime.now().toIso8601String(),
        'entries': [
          {'exerciseId': 'pulldown', 'sets': 3, 'reps': 15, 'weight': 65},
        ],
      });
      await preferences.reload();
      expect(preferences.workoutDraftFor('user-a')?['dayNumber'], 2);
      expect(preferences.workoutDraftFor('user-b'), isNull);
      await preferences.setWorkoutDraft('user-a', {
        'dayNumber': 2,
        'savedAt':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      });
      expect(preferences.workoutDraftFor('user-a'), isNull);
    },
  );

  test('Every bundled photo reference has an offline thumbnail', () async {
    final exercises = await loadBundledExercises();
    var photos = 0;
    for (final exercise in exercises) {
      final url = exercise.imageUrl;
      if (url == null || !url.contains('free-exercise-db')) continue;
      final segments = Uri.parse(url).pathSegments;
      final id = segments[segments.length - 2];
      expect(
        File('assets/exercises/$id.webp').existsSync(),
        isTrue,
        reason: '${exercise.name}: missing $id',
      );
      photos++;
    }
    expect(photos, greaterThan(800));
  });
}
