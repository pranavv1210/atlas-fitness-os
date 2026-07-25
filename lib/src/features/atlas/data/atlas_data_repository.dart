import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/atlas_colors.dart';
import 'atlas_models.dart';

class AtlasDataRepository {
  AtlasDataRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  Future<AtlasDashboardSnapshot> loadSnapshot() async {
    final todayWorkout = await _loadTodayWorkout();
    final library = await _loadExerciseLibrary();
    final templateExercises = await _loadTemplateExercises(
      todayWorkout.templateId,
      library,
      todayWorkout.name,
    );
    final completedThisWeek = await _countWorkouts(
      _startOfWeek(DateTime.now()),
      DateTime.now(),
    );
    final totalWorkouts = await _countAllWorkouts();
    final monthWorkouts = await _countWorkouts(
      DateTime(DateTime.now().year, DateTime.now().month),
      DateTime.now(),
    );
    final latestWeight = await _latestWeight();
    final hydrationToday = await _hydrationToday();
    final activeGoals = await loadGoals();
    final lastWorkoutTitle = await _lastWorkoutTitle();

    return AtlasDashboardSnapshot(
      todayWorkout: todayWorkout,
      templateExercises: templateExercises,
      exerciseLibrary: library,
      completedThisWeek: completedThisWeek,
      weeklyTarget: 5,
      totalWorkouts: totalWorkouts,
      monthWorkouts: monthWorkouts,
      latestWeight: latestWeight?.$1,
      latestWeightUnit: latestWeight?.$2 ?? 'kg',
      latestWeightDate: latestWeight?.$3,
      hydrationToday: hydrationToday,
      activeGoals: activeGoals,
      lastWorkoutTitle: lastWorkoutTitle,
    );
  }

  Future<void> saveWorkout({
    required AtlasWorkoutDay day,
    required List<AtlasWorkoutEntry> entries,
  }) async {
    final session =
        await _client
            .from('workout_sessions')
            .insert({
              'user_id': _userId,
              'workout_day_id': day.workoutDayId,
              'template_id': day.templateId,
              'session_date': _date(DateTime.now()),
              'started_at': DateTime.now().toUtc().toIso8601String(),
              'completed_at': DateTime.now().toUtc().toIso8601String(),
              'status': 'completed',
              'title': day.name,
            })
            .select('id')
            .single();

    final sessionId = session['id'] as String;
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final sessionExercise =
          await _client
              .from('workout_session_exercises')
              .insert({
                'workout_session_id': sessionId,
                'exercise_id': _uuidOrNull(entry.exercise.id),
                'display_order': index + 1,
                'name_snapshot': entry.exercise.name,
              })
              .select('id')
              .single();

      final sessionExerciseId = sessionExercise['id'] as String;
      await _client.from('workout_sets').insert([
        for (var set = 1; set <= entry.sets; set++)
          {
            'workout_session_exercise_id': sessionExerciseId,
            'set_number': set,
            'reps': entry.reps,
            'weight': entry.weight,
            'weight_unit': 'kg',
            'is_completed': true,
          },
      ]);
    }
  }

  Future<void> saveWeight(double weight, {String note = ''}) async {
    await _client.from('body_weight_logs').upsert({
      'user_id': _userId,
      'measured_on': _date(DateTime.now()),
      'weight': weight,
      'unit': 'kg',
      'note': note.isEmpty ? null : note,
    }, onConflict: 'user_id,measured_on');
  }

  Future<void> saveWellness({
    required int mood,
    required int energy,
    required int stress,
  }) async {
    await _client.from('wellness_logs').upsert({
      'user_id': _userId,
      'logged_on': _date(DateTime.now()),
      'mood': mood,
      'energy': energy,
      'stress': stress,
    }, onConflict: 'user_id,logged_on');
  }

  Future<void> saveHydration() async {
    await _client.from('hydration_events').insert({'user_id': _userId});
  }

  Future<void> saveCardio({
    required String activityType,
    required int durationMinutes,
    double? distance,
  }) async {
    await _client.from('cardio_sessions').insert({
      'user_id': _userId,
      'activity_type': activityType,
      'session_date': _date(DateTime.now()),
      'duration_minutes': durationMinutes,
      'distance': distance,
      'distance_unit': distance == null ? null : 'km',
      'intensity': 'moderate',
    });
  }

  Future<void> saveSport({
    required String sportName,
    required int durationMinutes,
  }) async {
    await _client.from('sports_sessions').insert({
      'user_id': _userId,
      'sport_name': sportName,
      'session_date': _date(DateTime.now()),
      'duration_minutes': durationMinutes,
      'intensity': 'moderate',
    });
  }

  Future<void> saveGoal({
    required AtlasGoalType type,
    required String title,
    required double targetValue,
    required String unit,
    double currentValue = 0,
  }) async {
    final goal =
        await _client
            .from('goals')
            .insert({
              'user_id': _userId,
              'goal_type': type.name,
              'title': title,
              'target_value': targetValue,
              'target_unit': unit,
              'current_value': currentValue,
              'status': 'active',
            })
            .select('id')
            .single();

    await _client.from('goal_progress_snapshots').insert({
      'goal_id': goal['id'],
      'user_id': _userId,
      'snapshot_date': _date(DateTime.now()),
      'progress_percent': _goalProgress(currentValue, targetValue),
      'current_value': currentValue,
    });
  }

  Future<List<AtlasGoal>> loadGoals() async {
    final rows = await _client
        .from('v_active_goals')
        .select(
          'id, goal_type, title, target_value, target_unit, current_value, progress_percent',
        )
        .order('created_at');
    return [
      for (final row in rows)
        AtlasGoal(
          id: row['id'] as String,
          type: _goalType(row['goal_type'] as String?),
          title: row['title'] as String? ?? 'Goal',
          progress: ((row['progress_percent'] as num?)?.toDouble() ?? 0) / 100,
          currentValue: (row['current_value'] as num?)?.toDouble(),
          targetValue: (row['target_value'] as num?)?.toDouble(),
          targetUnit: row['target_unit'] as String?,
        ),
    ];
  }

  Future<AtlasWorkoutDay> _loadTodayWorkout() async {
    final rows = await _client.rpc('get_today_workout');
    if (rows is List && rows.isNotEmpty) {
      final row = rows.first as Map<String, dynamic>;
      return AtlasWorkoutDay(
        dayNumber: row['cycle_day'] as int? ?? _fallbackDayNumber(),
        name: row['workout_name'] as String? ?? _fallbackDay().name,
        focus: row['focus'] as String? ?? _fallbackDay().focus,
        isRestDay: row['is_rest_day'] as bool? ?? false,
        workoutDayId: row['workout_day_id'] as String?,
        templateId: row['template_id'] as String?,
      );
    }
    return _fallbackDay();
  }

  Future<List<AtlasExercise>> _loadExerciseLibrary() async {
    try {
      final rows = await _client
          .from('exercises')
          .select('id, name, movement_pattern, default_sets, default_reps')
          .eq('is_active', true)
          .order('name');
      return [
        for (final row in rows)
          AtlasExercise(
            id: row['id'] as String,
            name: row['name'] as String,
            pattern: row['movement_pattern'] as String? ?? 'strength',
            defaultSets: row['default_sets'] as int? ?? 3,
            defaultReps: row['default_reps'] as String? ?? '10',
          ),
      ];
    } catch (_) {
      return fallbackExercises;
    }
  }

  Future<List<AtlasWorkoutExercise>> _loadTemplateExercises(
    String? templateId,
    List<AtlasExercise> library,
    String workoutName,
  ) async {
    if (templateId != null) {
      final rows = await _client
          .from('workout_template_exercises')
          .select(
            'target_sets, target_reps, notes, exercises(id, name, movement_pattern, default_sets, default_reps)',
          )
          .eq('template_id', templateId)
          .order('display_order');
      return [
        for (final row in rows)
          AtlasWorkoutExercise(
            exercise: _exerciseFromNested(row['exercises']),
            targetSets: row['target_sets'] as int? ?? 3,
            targetReps: row['target_reps'] as String? ?? '10',
            notes: row['notes'] as String? ?? '',
          ),
      ];
    }

    return fallbackPlan(workoutName, library);
  }

  AtlasExercise _exerciseFromNested(Object? value) {
    final row = value as Map<String, dynamic>? ?? {};
    return AtlasExercise(
      id: row['id'] as String? ?? '',
      name: row['name'] as String? ?? 'Exercise',
      pattern: row['movement_pattern'] as String? ?? 'strength',
      defaultSets: row['default_sets'] as int? ?? 3,
      defaultReps: row['default_reps'] as String? ?? '10',
    );
  }

  Future<int> _countWorkouts(DateTime start, DateTime end) async {
    final rows = await _client
        .from('workout_sessions')
        .select('id')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .gte('session_date', _date(start))
        .lte('session_date', _date(end));
    return rows.length;
  }

  Future<int> _countAllWorkouts() async {
    final rows = await _client
        .from('workout_sessions')
        .select('id')
        .eq('user_id', _userId)
        .eq('status', 'completed');
    return rows.length;
  }

  Future<(double, String, DateTime)?> _latestWeight() async {
    final rows = await _client
        .from('body_weight_logs')
        .select('weight, unit, measured_on')
        .eq('user_id', _userId)
        .order('measured_on', ascending: false)
        .limit(1);
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.first;
    return (
      (row['weight'] as num).toDouble(),
      row['unit'] as String? ?? 'kg',
      DateTime.parse(row['measured_on'] as String),
    );
  }

  Future<int> _hydrationToday() async {
    final rows = await _client
        .from('hydration_events')
        .select('id')
        .eq('user_id', _userId)
        .gte(
          'occurred_at',
          DateTime.now().toUtc().copyWith(hour: 0, minute: 0).toIso8601String(),
        );
    return rows.length;
  }

  Future<String?> _lastWorkoutTitle() async {
    final rows = await _client
        .from('workout_sessions')
        .select('title')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .order('session_date', ascending: false)
        .limit(1);
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['title'] as String?;
  }

  double _goalProgress(double current, double target) {
    if (target <= 0) {
      return 0;
    }
    return ((current / target) * 100).clamp(0, 100);
  }
}

AtlasGoalType _goalType(String? value) {
  return AtlasGoalType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => AtlasGoalType.habit,
  );
}

String? _uuidOrNull(String value) => value.length > 20 ? value : null;

String _date(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

DateTime _startOfWeek(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return local.subtract(Duration(days: local.weekday - 1));
}

int _fallbackDayNumber() {
  final anchor = DateTime(2026, 7, 26);
  final now = DateTime.now();
  return now
              .difference(DateTime(anchor.year, anchor.month, anchor.day))
              .inDays %
          5 +
      1;
}

AtlasWorkoutDay _fallbackDay() => fallbackCycle[_fallbackDayNumber() - 1];

const fallbackCycle = [
  AtlasWorkoutDay(
    dayNumber: 1,
    name: 'Chest + Triceps',
    focus: 'Push strength and upper-body pressing',
    isRestDay: false,
  ),
  AtlasWorkoutDay(
    dayNumber: 2,
    name: 'Back + Biceps',
    focus: 'Pull strength and posterior upper body',
    isRestDay: false,
  ),
  AtlasWorkoutDay(
    dayNumber: 3,
    name: 'Arms + Abs',
    focus: 'Arm volume and trunk control',
    isRestDay: false,
  ),
  AtlasWorkoutDay(
    dayNumber: 4,
    name: 'Shoulders + Legs',
    focus: 'Shoulder strength and lower-body work',
    isRestDay: false,
  ),
  AtlasWorkoutDay(
    dayNumber: 5,
    name: 'Rest',
    focus: 'Recovery, mobility, hydration, and readiness',
    isRestDay: true,
  ),
];

const fallbackExercises = [
  AtlasExercise(
    id: 'bench',
    name: 'Barbell Bench Press',
    pattern: 'horizontal_push',
    defaultSets: 4,
    defaultReps: '8-10',
  ),
  AtlasExercise(
    id: 'incline',
    name: 'Incline Dumbbell Press',
    pattern: 'incline_push',
    defaultSets: 3,
    defaultReps: '10',
  ),
  AtlasExercise(
    id: 'fly',
    name: 'Cable Fly',
    pattern: 'chest_isolation',
    defaultSets: 3,
    defaultReps: '12-15',
  ),
  AtlasExercise(
    id: 'dips',
    name: 'Dips',
    pattern: 'vertical_push',
    defaultSets: 3,
    defaultReps: '8-12',
  ),
  AtlasExercise(
    id: 'pushdown',
    name: 'Rope Pushdown',
    pattern: 'triceps_isolation',
    defaultSets: 3,
    defaultReps: '12',
  ),
  AtlasExercise(
    id: 'extension',
    name: 'Overhead Extension',
    pattern: 'triceps_isolation',
    defaultSets: 2,
    defaultReps: '12-15',
  ),
  AtlasExercise(
    id: 'deadlift',
    name: 'Deadlift',
    pattern: 'hinge_pull',
    defaultSets: 3,
    defaultReps: '5',
  ),
  AtlasExercise(
    id: 'pulldown',
    name: 'Lat Pulldown',
    pattern: 'vertical_pull',
    defaultSets: 4,
    defaultReps: '8-12',
  ),
  AtlasExercise(
    id: 'row',
    name: 'Seated Cable Row',
    pattern: 'horizontal_pull',
    defaultSets: 3,
    defaultReps: '10-12',
  ),
  AtlasExercise(
    id: 'curl',
    name: 'Dumbbell Curl',
    pattern: 'biceps_isolation',
    defaultSets: 3,
    defaultReps: '10-12',
  ),
  AtlasExercise(
    id: 'raise',
    name: 'Lateral Raise',
    pattern: 'shoulder_isolation',
    defaultSets: 4,
    defaultReps: '12-15',
  ),
  AtlasExercise(
    id: 'press',
    name: 'Overhead Press',
    pattern: 'vertical_push',
    defaultSets: 4,
    defaultReps: '6-8',
  ),
  AtlasExercise(
    id: 'squat',
    name: 'Back Squat',
    pattern: 'squat',
    defaultSets: 4,
    defaultReps: '6-10',
  ),
  AtlasExercise(
    id: 'leg_press',
    name: 'Leg Press',
    pattern: 'squat',
    defaultSets: 3,
    defaultReps: '10-12',
  ),
  AtlasExercise(
    id: 'plank',
    name: 'Plank',
    pattern: 'anti_extension',
    defaultSets: 3,
    defaultReps: '45',
  ),
];

List<AtlasWorkoutExercise> fallbackPlan(
  String workoutName,
  List<AtlasExercise> library,
) {
  final names = switch (workoutName) {
    'Back + Biceps' => [
      'Deadlift',
      'Lat Pulldown',
      'Seated Cable Row',
      'Dumbbell Curl',
    ],
    'Arms + Abs' => [
      'Dumbbell Curl',
      'Rope Pushdown',
      'Overhead Extension',
      'Plank',
    ],
    'Shoulders + Legs' => [
      'Overhead Press',
      'Lateral Raise',
      'Back Squat',
      'Leg Press',
    ],
    _ => [
      'Barbell Bench Press',
      'Incline Dumbbell Press',
      'Cable Fly',
      'Rope Pushdown',
    ],
  };
  return [
    for (final name in names)
      if (_findExercise(library, name) != null)
        AtlasWorkoutExercise(
          exercise: _findExercise(library, name)!,
          targetSets: _findExercise(library, name)!.defaultSets,
          targetReps: _findExercise(library, name)!.defaultReps,
          notes: '',
        ),
  ];
}

AtlasExercise? _findExercise(List<AtlasExercise> library, String name) {
  for (final exercise in [...library, ...fallbackExercises]) {
    if (exercise.name == name) {
      return exercise;
    }
  }
  return null;
}

ExerciseVisual exerciseVisual(AtlasExercise exercise) {
  final pattern = exercise.pattern;
  if (pattern.contains('pull') || pattern.contains('curl')) {
    return const ExerciseVisual(
      icon: Icons.keyboard_double_arrow_down_rounded,
      gradient: [AtlasColors.success, AtlasColors.accent],
      cue: 'Pull with control',
    );
  }
  if (pattern.contains('squat') || pattern.contains('leg')) {
    return const ExerciseVisual(
      icon: Icons.vertical_align_bottom_rounded,
      gradient: [AtlasColors.warning, AtlasColors.success],
      cue: 'Drive through the floor',
    );
  }
  if (pattern.contains('core') || pattern.contains('extension')) {
    return const ExerciseVisual(
      icon: Icons.all_inclusive_rounded,
      gradient: [AtlasColors.lilac, AtlasColors.accent],
      cue: 'Brace and breathe',
    );
  }
  return const ExerciseVisual(
    icon: Icons.keyboard_double_arrow_up_rounded,
    gradient: [AtlasColors.accent, AtlasColors.lilac],
    cue: 'Press with intent',
  );
}
