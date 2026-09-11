import 'dart:io';
import 'package:atlas_fitness_os/src/core/services/atlas_preferences.dart';
import 'package:atlas_fitness_os/src/features/agent/data/atlas_agent_service.dart';
import 'package:atlas_fitness_os/src/features/atlas/data/atlas_data_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
