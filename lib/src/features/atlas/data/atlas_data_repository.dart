import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/services/atlas_preferences.dart';
import 'atlas_models.dart';

class AtlasDataRepository {
  AtlasDataRepository(this._client, {AtlasPreferences? preferences})
    : _preferences = preferences;

  final SupabaseClient _client;
  final AtlasPreferences? _preferences;
  AtlasDashboardSnapshot? _cachedSnapshot;

  String get _userId => _client.auth.currentUser!.id;
  String get currentUserId => _userId;
  AtlasDashboardSnapshot? get cachedSnapshot =>
      _cachedSnapshot ?? _loadCachedSnapshot();

  Future<AtlasDashboardSnapshot> loadSnapshot() async {
    final completedToday = await _hasCompletedWorkoutOn(DateTime.now());
    final totalWorkouts = await _countAllWorkouts();
    final hasStarted = totalWorkouts > 0;
    final todayWorkout =
        hasStarted
            ? await _loadWorkoutDay(
              _cycleDayForCompletedCount(
                totalWorkouts,
                completedToday: completedToday,
              ),
            )
            : null;
    final starterWorkout = hasStarted ? null : await _loadWorkoutDay(1);
    final library = await _loadExerciseLibrary();
    const templateExercises = <AtlasWorkoutExercise>[];
    final completedThisWeek = await _countWorkouts(
      _startOfWeek(DateTime.now()),
      DateTime.now(),
    );
    final monthWorkouts = await _countWorkouts(
      DateTime(DateTime.now().year, DateTime.now().month),
      DateTime.now(),
    );
    final latestWeight = await _latestWeight();
    final hydrationToday = await _hydrationToday();
    final activeGoals = await loadGoals();
    final lastWorkoutTitle = await _lastWorkoutTitle();
    final todayReport =
        completedToday ? await loadWorkoutReport(DateTime.now()) : null;
    final currentStreak = await _currentWorkoutStreak();

    final snapshot = AtlasDashboardSnapshot(
      todayWorkout: todayWorkout,
      starterWorkout: starterWorkout,
      templateExercises: templateExercises,
      exerciseLibrary: library,
      completedThisWeek: completedThisWeek,
      weeklyTarget: 5,
      totalWorkouts: totalWorkouts,
      monthWorkouts: monthWorkouts,
      completedToday: completedToday,
      cycleStarted: hasStarted,
      currentStreak: currentStreak,
      latestWeight: latestWeight?.$1,
      latestWeightUnit: latestWeight?.$2 ?? 'kg',
      latestWeightDate: latestWeight?.$3,
      hydrationToday: hydrationToday,
      activeGoals: activeGoals,
      lastWorkoutTitle: lastWorkoutTitle,
      todayReport: todayReport,
    );
    _cachedSnapshot = snapshot;
    await _preferences?.setDashboardSnapshot(
      _userId,
      _snapshotToJson(snapshot),
    );
    return snapshot;
  }

  AtlasDashboardSnapshot? _loadCachedSnapshot() {
    final raw = _preferences?.dashboardSnapshotFor(_userId);
    if (raw == null) return null;
    try {
      final latestWeight = (raw['latestWeight'] as num?)?.toDouble();
      final latestWeightDate = raw['latestWeightDate'];
      final goals = raw['activeGoals'];
      return AtlasDashboardSnapshot(
        todayWorkout: _workoutDayFromJson(raw['todayWorkout']),
        starterWorkout: _workoutDayFromJson(raw['starterWorkout']),
        templateExercises: const [],
        exerciseLibrary: fallbackExercises,
        completedThisWeek: raw['completedThisWeek'] as int? ?? 0,
        weeklyTarget: raw['weeklyTarget'] as int? ?? 5,
        totalWorkouts: raw['totalWorkouts'] as int? ?? 0,
        monthWorkouts: raw['monthWorkouts'] as int? ?? 0,
        completedToday: raw['completedToday'] as bool? ?? false,
        cycleStarted: raw['cycleStarted'] as bool? ?? false,
        currentStreak: raw['currentStreak'] as int? ?? 0,
        latestWeight: latestWeight,
        latestWeightUnit: raw['latestWeightUnit'] as String? ?? 'kg',
        latestWeightDate:
            latestWeightDate is String
                ? DateTime.tryParse(latestWeightDate)
                : null,
        hydrationToday: raw['hydrationToday'] as int? ?? 0,
        activeGoals:
            goals is List
                ? [
                  for (final goal in goals)
                    if (goal is Map)
                      AtlasGoal(
                        id: goal['id'] as String? ?? 'cached-goal',
                        type: _goalType(goal['type'] as String?),
                        title: goal['title'] as String? ?? 'Goal',
                        progress: (goal['progress'] as num?)?.toDouble() ?? 0,
                        currentValue:
                            (goal['currentValue'] as num?)?.toDouble(),
                        targetValue: (goal['targetValue'] as num?)?.toDouble(),
                        targetUnit: goal['targetUnit'] as String?,
                      ),
                ]
                : const [],
        lastWorkoutTitle: raw['lastWorkoutTitle'] as String?,
        todayReport: null,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _snapshotToJson(AtlasDashboardSnapshot snapshot) {
    return {
      'todayWorkout': _workoutDayToJson(snapshot.todayWorkout),
      'starterWorkout': _workoutDayToJson(snapshot.starterWorkout),
      'completedThisWeek': snapshot.completedThisWeek,
      'weeklyTarget': snapshot.weeklyTarget,
      'totalWorkouts': snapshot.totalWorkouts,
      'monthWorkouts': snapshot.monthWorkouts,
      'completedToday': snapshot.completedToday,
      'cycleStarted': snapshot.cycleStarted,
      'currentStreak': snapshot.currentStreak,
      'latestWeight': snapshot.latestWeight,
      'latestWeightUnit': snapshot.latestWeightUnit,
      'latestWeightDate': snapshot.latestWeightDate?.toIso8601String(),
      'hydrationToday': snapshot.hydrationToday,
      'activeGoals': [
        for (final goal in snapshot.activeGoals)
          {
            'id': goal.id,
            'type': goal.type.name,
            'title': goal.title,
            'progress': goal.progress,
            'currentValue': goal.currentValue,
            'targetValue': goal.targetValue,
            'targetUnit': goal.targetUnit,
          },
      ],
      'lastWorkoutTitle': snapshot.lastWorkoutTitle,
    };
  }

  Map<String, dynamic>? _workoutDayToJson(AtlasWorkoutDay? day) {
    if (day == null) return null;
    return {
      'dayNumber': day.dayNumber,
      'name': day.name,
      'focus': day.focus,
      'isRestDay': day.isRestDay,
      'workoutDayId': day.workoutDayId,
      'templateId': day.templateId,
    };
  }

  AtlasWorkoutDay? _workoutDayFromJson(Object? raw) {
    if (raw is! Map) return null;
    return AtlasWorkoutDay(
      dayNumber: raw['dayNumber'] as int? ?? 1,
      name: raw['name'] as String? ?? 'Workout',
      focus: raw['focus'] as String? ?? 'Train with intent',
      isRestDay: raw['isRestDay'] as bool? ?? false,
      workoutDayId: raw['workoutDayId'] as String?,
      templateId: raw['templateId'] as String?,
    );
  }

  Future<void> saveWorkout({
    required AtlasWorkoutDay day,
    required List<AtlasWorkoutEntry> entries,
  }) async {
    final now = DateTime.now();
    if (await _hasCompletedWorkoutOn(now)) {
      throw const AtlasWorkoutAlreadySavedException();
    }

    String? sessionId;
    try {
      final session =
          await _client
              .from('workout_sessions')
              .insert({
                'user_id': _userId,
                'workout_day_id': day.workoutDayId,
                'template_id': day.templateId,
                'session_date': _date(now),
                'started_at': now.toUtc().toIso8601String(),
                'completed_at': now.toUtc().toIso8601String(),
                'status': 'completed',
                'title': day.name,
              })
              .select('id')
              .single();

      sessionId = session['id'] as String;
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
    } catch (_) {
      if (sessionId != null) {
        await _client
            .from('workout_sessions')
            .delete()
            .eq('id', sessionId)
            .eq('user_id', _userId);
      }
      rethrow;
    }
  }

  Future<void> saveWeight(
    double weight, {
    String note = '',
    DateTime? measuredOn,
  }) async {
    await _client.from('body_weight_logs').upsert({
      'user_id': _userId,
      'measured_on': _date(measuredOn ?? DateTime.now()),
      'weight': weight,
      'unit': 'kg',
      'note': note.isEmpty ? null : note,
    }, onConflict: 'user_id,measured_on');
  }

  Future<void> saveHydration() async {
    await _client.from('hydration_events').insert({'user_id': _userId});
  }

  Future<void> saveCardio({
    required String activityType,
    required int durationMinutes,
    double? distance,
    double? calories,
  }) async {
    await _client.from('cardio_sessions').insert({
      'user_id': _userId,
      'activity_type': activityType,
      'session_date': _date(DateTime.now()),
      'duration_minutes': durationMinutes,
      'distance': distance,
      'distance_unit': distance == null ? null : 'km',
      'intensity': 'moderate',
      'notes': calories == null ? null : 'Calories: ${calories.round()}',
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

  Future<List<DateTime>> loadWorkoutHistoryDates({int limit = 120}) async {
    final rows = await _client
        .from('workout_sessions')
        .select('session_date')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .order('session_date', ascending: false)
        .limit(limit);
    final dates = <String, DateTime>{};
    for (final row in rows) {
      final value = row['session_date'] as String?;
      if (value == null) continue;
      dates.putIfAbsent(value, () => DateTime.parse(value));
    }
    return dates.values.toList()..sort((a, b) => b.compareTo(a));
  }

  Future<List<DateTime>> loadActivityHistoryDates({int limit = 160}) async {
    final dates = <String, DateTime>{};
    void addDate(Object? value) {
      if (value is! String || value.isEmpty) return;
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        dates.putIfAbsent(_date(parsed), () => parsed);
      }
    }

    final workouts = await _client
        .from('workout_sessions')
        .select('session_date')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .order('session_date', ascending: false)
        .limit(limit);
    for (final row in workouts) {
      addDate(row['session_date']);
    }

    final cardio = await _client
        .from('cardio_sessions')
        .select('session_date')
        .eq('user_id', _userId)
        .order('session_date', ascending: false)
        .limit(limit);
    for (final row in cardio) {
      addDate(row['session_date']);
    }

    final sports = await _client
        .from('sports_sessions')
        .select('session_date')
        .eq('user_id', _userId)
        .order('session_date', ascending: false)
        .limit(limit);
    for (final row in sports) {
      addDate(row['session_date']);
    }

    final weights = await _client
        .from('body_weight_logs')
        .select('measured_on')
        .eq('user_id', _userId)
        .order('measured_on', ascending: false)
        .limit(limit);
    for (final row in weights) {
      addDate(row['measured_on']);
    }

    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 30)).toUtc();
    final hydration = await _client
        .from('hydration_events')
        .select('occurred_at')
        .eq('user_id', _userId)
        .gte('occurred_at', start.toIso8601String())
        .order('occurred_at', ascending: false)
        .limit(limit);
    for (final row in hydration) {
      addDate(row['occurred_at']);
    }

    return dates.values.toList()..sort((a, b) => b.compareTo(a));
  }

  Future<AtlasDailyActivityReport> loadDailyActivityReport(
    DateTime date,
  ) async {
    final key = _date(date);
    final workout = await loadWorkoutReport(date);
    final hydration = await _hydrationCountOn(date);

    final cardioRows = await _client
        .from('cardio_sessions')
        .select(
          'activity_type, duration_minutes, distance, distance_unit, notes',
        )
        .eq('user_id', _userId)
        .eq('session_date', key)
        .order('created_at');
    final sportRows = await _client
        .from('sports_sessions')
        .select('sport_name, duration_minutes, notes')
        .eq('user_id', _userId)
        .eq('session_date', key)
        .order('created_at');
    final weightRows = await _client
        .from('body_weight_logs')
        .select('weight, unit')
        .eq('user_id', _userId)
        .eq('measured_on', key)
        .limit(1);

    final weight = weightRows.isEmpty ? null : weightRows.first;
    return AtlasDailyActivityReport(
      date: DateTime.parse(key),
      workout: workout,
      hydrationSips: hydration,
      weight: (weight?['weight'] as num?)?.toDouble(),
      weightUnit: weight?['unit'] as String? ?? 'kg',
      cardio: [
        for (final row in cardioRows)
          AtlasCardioLog(
            activityType: row['activity_type'] as String? ?? 'Cardio',
            durationMinutes: row['duration_minutes'] as int? ?? 0,
            distance: (row['distance'] as num?)?.toDouble(),
            distanceUnit: row['distance_unit'] as String?,
            notes: row['notes'] as String?,
          ),
      ],
      sports: [
        for (final row in sportRows)
          AtlasSportLog(
            sportName: row['sport_name'] as String? ?? 'Sport',
            durationMinutes: row['duration_minutes'] as int? ?? 0,
            notes: row['notes'] as String?,
          ),
      ],
    );
  }

  Future<AtlasWorkoutReport?> loadWorkoutReport(DateTime date) async {
    final sessions = await _client
        .from('workout_sessions')
        .select(
          'id, session_date, started_at, completed_at, status, title, notes',
        )
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .eq('session_date', _date(date))
        .order('completed_at', ascending: false)
        .limit(1);
    if (sessions.isEmpty) {
      return null;
    }

    final session = sessions.first;
    final sessionId = session['id'] as String;
    final exerciseRows = await _client
        .from('workout_session_exercises')
        .select(
          'id, exercise_id, display_order, name_snapshot, notes, workout_sets(set_number, reps, weight, weight_unit)',
        )
        .eq('workout_session_id', sessionId)
        .order('display_order');
    final library = await _loadExerciseLibrary();
    final byId = {for (final exercise in library) exercise.id: exercise};
    final byName = {
      for (final exercise in library)
        _normalizeExerciseKeyPart(exercise.name): exercise,
    };

    final exercises = <AtlasWorkoutExerciseLog>[];
    for (final row in exerciseRows) {
      final rawSets = row['workout_sets'] as List<dynamic>? ?? const [];
      final sets =
          rawSets.whereType<Map<String, dynamic>>().map((set) {
              return AtlasWorkoutSetLog(
                setNumber: set['set_number'] as int? ?? 1,
                reps: set['reps'] as int? ?? 0,
                weight: (set['weight'] as num?)?.toDouble() ?? 0,
                weightUnit: set['weight_unit'] as String? ?? 'kg',
              );
            }).toList()
            ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
      final name = row['name_snapshot'] as String? ?? 'Exercise';
      final exerciseId = row['exercise_id'] as String?;
      final exercise =
          (exerciseId == null ? null : byId[exerciseId]) ??
          byName[_normalizeExerciseKeyPart(name)];
      exercises.add(
        AtlasWorkoutExerciseLog(
          name: _cleanExerciseName(name),
          displayOrder: row['display_order'] as int? ?? exercises.length + 1,
          sets: sets,
          exercise: exercise,
          notes: row['notes'] as String?,
        ),
      );
    }

    return AtlasWorkoutReport(
      id: sessionId,
      date: DateTime.parse(session['session_date'] as String),
      title: session['title'] as String? ?? 'Workout',
      status: session['status'] as String? ?? 'completed',
      startedAt: _parseDateTime(session['started_at']),
      completedAt: _parseDateTime(session['completed_at']),
      notes: session['notes'] as String?,
      exercises:
          exercises..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
    );
  }

  Future<List<double>> loadWeeklyWorkoutVolumes() async {
    final start = _startOfWeek(DateTime.now());
    final volumes = <double>[];
    for (var index = 0; index < 7; index++) {
      final report = await loadWorkoutReport(start.add(Duration(days: index)));
      volumes.add(report?.totalVolume ?? 0);
    }
    return volumes;
  }

  Future<List<AtlasWeightTrendPoint>> loadWeightTrend({int limit = 12}) async {
    final rows = await _client
        .from('body_weight_logs')
        .select('measured_on, weight, unit')
        .eq('user_id', _userId)
        .order('measured_on', ascending: false)
        .limit(limit);
    return [
      for (final row in rows.reversed)
        AtlasWeightTrendPoint(
          date: DateTime.parse(row['measured_on'] as String),
          weight: (row['weight'] as num).toDouble(),
          unit: row['unit'] as String? ?? 'kg',
        ),
    ];
  }

  Future<AtlasWorkoutDay> _loadWorkoutDay(int dayNumber) async {
    try {
      final rows = await _client
          .from('workout_days')
          .select('id, name, focus, is_rest_day, workout_templates(id)')
          .eq('day_number', dayNumber)
          .limit(1);
      if (rows.isNotEmpty) {
        final row = rows.first;
        final templates =
            row['workout_templates'] as List<dynamic>? ?? const [];
        return AtlasWorkoutDay(
          dayNumber: dayNumber,
          name: row['name'] as String? ?? 'Chest + Triceps',
          focus: row['focus'] as String? ?? 'Start your Atlas cycle',
          isRestDay: row['is_rest_day'] as bool? ?? false,
          workoutDayId: row['id'] as String?,
          templateId:
              templates.isEmpty
                  ? null
                  : (templates.first as Map<String, dynamic>)['id'] as String?,
        );
      }
    } catch (_) {}
    return fallbackCycle.first;
  }

  Future<List<AtlasExercise>> _loadExerciseLibrary() async {
    try {
      final rows = await _client
          .from('exercises')
          .select(
            'id, name, movement_pattern, default_sets, default_reps, image_url, gif_url, target_muscle, equipment, difficulty',
          )
          .eq('is_active', true)
          .order('name');
      final remote = [for (final row in rows) _exerciseFromRow(row)];
      return _mergeExerciseLibraries(remote, await loadBundledExercises());
    } catch (_) {
      try {
        final rows = await _client
            .from('exercises')
            .select('id, name, movement_pattern, default_sets, default_reps')
            .eq('is_active', true)
            .order('name');
        final remote = [for (final row in rows) _exerciseFromRow(row)];
        return _mergeExerciseLibraries(remote, await loadBundledExercises());
      } catch (_) {
        return loadBundledExercises();
      }
    }
  }

  AtlasExercise _exerciseFromRow(Map<String, dynamic> row) {
    final name = row['name'] as String? ?? 'Exercise';
    final pattern = row['movement_pattern'] as String? ?? 'strength';
    return AtlasExercise(
      id: row['id'] as String? ?? name,
      name: _cleanExerciseName(name),
      pattern: pattern,
      defaultSets: row['default_sets'] as int? ?? 3,
      defaultReps: row['default_reps'] as String? ?? '15',
      primaryMuscle: _canonicalPrimaryMuscle(
        name,
        row['target_muscle'] as String? ?? _primaryMuscle(pattern),
      ),
      equipment: _normalizeEquipment(
        row['equipment'] as String? ?? _equipment(name),
      ),
      difficulty: _normalizeDifficulty(
        row['difficulty'] as String? ?? 'Moderate',
      ),
      imageUrl: row['image_url'] as String? ?? _exerciseImageUrl(name),
      gifUrl: row['gif_url'] as String?,
      previewImage: row['preview_image_url'] as String?,
      previewGif: row['preview_gif_url'] as String?,
      previewVideo: row['preview_video_url'] as String?,
      thumbnail: row['thumbnail_url'] as String?,
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

  Future<int> _currentWorkoutStreak() async {
    // Atlas keeps the current workout pending across missed calendar days.
    // The streak must follow completed sessions, not strict daily attendance.
    return _countAllWorkouts();
  }

  Future<bool> _hasCompletedWorkoutOn(DateTime date) async {
    final rows = await _client
        .from('workout_sessions')
        .select('id')
        .eq('user_id', _userId)
        .eq('status', 'completed')
        .eq('session_date', _date(date))
        .limit(1);
    return rows.isNotEmpty;
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

  Future<int> _hydrationCountOn(DateTime date) async {
    final local = DateTime(date.year, date.month, date.day);
    final start = local.toUtc();
    final end = local.add(const Duration(days: 1)).toUtc();
    final rows = await _client
        .from('hydration_events')
        .select('id')
        .eq('user_id', _userId)
        .gte('occurred_at', start.toIso8601String())
        .lt('occurred_at', end.toIso8601String());
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

DateTime? _parseDateTime(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}

class AtlasWorkoutAlreadySavedException implements Exception {
  const AtlasWorkoutAlreadySavedException();
}

AtlasGoalType _goalType(String? value) {
  return AtlasGoalType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => AtlasGoalType.habit,
  );
}

final _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

String? _uuidOrNull(String value) =>
    _uuidPattern.hasMatch(value) ? value : null;

String _date(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

DateTime _startOfWeek(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return local.subtract(Duration(days: local.weekday - 1));
}

int _cycleDayForCompletedCount(
  int completedWorkouts, {
  required bool completedToday,
}) {
  if (completedWorkouts <= 0) {
    return 1;
  }
  final completedBeforeToday =
      completedToday ? completedWorkouts - 1 : completedWorkouts;
  return (completedBeforeToday % fallbackCycle.length) + 1;
}

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

List<AtlasExercise>? _bundledExerciseCache;

Future<List<AtlasExercise>> loadBundledExercises() async {
  final cached = _bundledExerciseCache;
  if (cached != null) {
    return cached;
  }
  try {
    final source = await rootBundle.loadString(
      'assets/data/free_exercise_db.json',
    );
    final decoded = jsonDecode(source) as List<dynamic>;
    final exercises =
        decoded
            .whereType<Map<String, dynamic>>()
            .map(_exerciseFromFreeExerciseDb)
            .whereType<AtlasExercise>()
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    final expansion = await _loadExerciseExpansion();
    _bundledExerciseCache = _dedupeExercises([
      ...fallbackExercises,
      ...exercises,
      ...expansion,
    ]);
  } catch (_) {
    _bundledExerciseCache = fallbackExercises;
  }
  return _bundledExerciseCache!;
}

Future<List<AtlasExercise>> _loadExerciseExpansion() async {
  try {
    final source = await rootBundle.loadString(
      'assets/data/exercise_expansion_metadata.json',
    );
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_exerciseFromExpansion)
        .whereType<AtlasExercise>()
        .toList();
  } catch (_) {
    return const [];
  }
}

AtlasExercise? _exerciseFromExpansion(Map<String, dynamic> row) {
  final id = row['id'] as String?;
  final name = row['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) {
    return null;
  }

  return AtlasExercise(
    id: id,
    name: _cleanExerciseName(name),
    pattern: row['pattern'] as String? ?? 'strength',
    defaultSets: row['defaultSets'] as int? ?? 3,
    defaultReps: row['defaultReps'] as String? ?? '15',
    primaryMuscle: _canonicalPrimaryMuscle(
      name,
      row['primaryMuscle'] as String? ?? 'Strength',
    ),
    secondaryMuscles: [
      for (final muscle in _stringList(row['secondaryMuscles']))
        _normalizeMuscle(muscle),
    ],
    equipment: _normalizeEquipment(row['equipment'] as String? ?? 'Bodyweight'),
    difficulty: _normalizeDifficulty(
      row['difficulty'] as String? ?? 'Intermediate',
    ),
    movementType: _normalizeMovementType(
      row['movementType'] as String? ?? 'Strength',
    ),
    instructions: _stringList(row['instructions']),
    imageUrl: row['imageUrl'] as String?,
    gifUrl: row['gifUrl'] as String?,
    previewImage: row['previewImage'] as String?,
    previewGif: row['previewGif'] as String?,
    previewVideo: row['previewVideo'] as String?,
    thumbnail: row['thumbnail'] as String?,
  );
}

AtlasExercise? _exerciseFromFreeExerciseDb(Map<String, dynamic> row) {
  final id = row['id'] as String?;
  final name = row['name'] as String?;
  if (id == null || id.isEmpty || name == null || name.isEmpty) {
    return null;
  }
  final primaryMuscles = _stringList(row['primaryMuscles']);
  final secondaryMuscles = _stringList(row['secondaryMuscles']);
  final instructions = _stringList(row['instructions']);
  final images = _stringList(row['images']);
  final imageUrl =
      images.isEmpty
          ? null
          : 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/${images.first}';
  final equipment = _titleCase(row['equipment'] as String? ?? 'Bodyweight');
  final category = row['category'] as String? ?? 'strength';
  final force = row['force'] as String?;
  final mechanic = row['mechanic'] as String?;
  final pattern = [
    if (force != null) force,
    if (mechanic != null) mechanic,
    category,
  ].join('_');

  return AtlasExercise(
    id: id,
    name: _cleanExerciseName(name),
    pattern: pattern,
    defaultSets: category == 'stretching' ? 2 : 3,
    defaultReps: category == 'stretching' ? '30 sec' : '15',
    primaryMuscle: _canonicalPrimaryMuscle(
      name,
      primaryMuscles.isEmpty ? _primaryMuscle(pattern) : primaryMuscles.first,
    ),
    secondaryMuscles: [
      for (final muscle in secondaryMuscles) _normalizeMuscle(muscle),
    ],
    equipment: _normalizeEquipment(equipment),
    difficulty: _normalizeDifficulty(row['level'] as String? ?? 'Moderate'),
    movementType: _normalizeMovementType(mechanic ?? category),
    instructions: instructions,
    imageUrl: imageUrl,
    previewImage: imageUrl,
    thumbnail: imageUrl,
  );
}

List<AtlasExercise> _mergeExerciseLibraries(
  List<AtlasExercise> primary,
  List<AtlasExercise> secondary,
) {
  return _dedupeExercises([...primary, ...secondary])
    ..sort((a, b) => a.name.compareTo(b.name));
}

List<AtlasExercise> _dedupeExercises(List<AtlasExercise> exercises) {
  final byExerciseKey = <String, AtlasExercise>{};
  for (final exercise in exercises) {
    byExerciseKey.putIfAbsent(
      _normalizeExerciseKeyPart(exercise.name),
      () => exercise,
    );
  }
  return byExerciseKey.values.toList();
}

String _normalizeExerciseKeyPart(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

List<String> _stringList(Object? source) {
  if (source is List) {
    return [
      for (final value in source)
        if (value is String && value.trim().isNotEmpty) value.trim(),
    ];
  }
  return const [];
}

String _titleCase(String value) {
  final lowerWords = {'of', 'to', 'and', 'with', 'on', 'in', 'the'};
  final words =
      value.split(RegExp(r'[\s_-]+')).where((part) => part.isNotEmpty).toList();
  return [
    for (var index = 0; index < words.length; index++)
      _titleCaseWord(
        words[index],
        lowerWords: index == 0 ? const {} : lowerWords,
      ),
  ].join(' ');
}

String _titleCaseWord(String value, {Set<String> lowerWords = const {}}) {
  final lower = value.toLowerCase();
  if (lowerWords.contains(lower)) {
    return lower;
  }
  if (lower == 'db') return 'DB';
  if (lower == 'bb') return 'BB';
  return lower.isEmpty ? lower : lower[0].toUpperCase() + lower.substring(1);
}

String _cleanExerciseName(String value) {
  final cleaned =
      value
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll('3/4 sit-up', '3/4 Sit-Up')
          .trim();
  return _titleCase(cleaned);
}

String _normalizeMuscle(String value) {
  final normalized = _normalizeExerciseKeyPart(value);
  return switch (normalized) {
    'ab' || 'abs' || 'abdominal' || 'abdominals' || 'waist' || 'wai t' => 'Abs',
    'core' || 'oblique' || 'obliques' => 'Abs',
    'pectorals' || 'pectoral' || 'chest' || 'che t' => 'Chest',
    'lat' || 'lats' || 'rhomboid' || 'trapezius' || 'upper back' => 'Back',
    'lower back' || 'back' => 'Back',
    'bicep' || 'biceps' => 'Biceps',
    'tricep' || 'triceps' => 'Triceps',
    'forearm' || 'forearms' => 'Forearms',
    'shoulder' ||
    'shoulders' ||
    'deltoid' ||
    'deltoids' ||
    'houlder' => 'Shoulders',
    'quad' || 'quads' || 'quadricep' || 'quadriceps' => 'Legs',
    'ham tring' || 'hamstring' || 'hamstrings' => 'Legs',
    'calve' || 'calves' || 'calf' => 'Legs',
    'glute' || 'glutes' => 'Glutes',
    'upper leg' || 'upper legs' || 'lower leg' || 'lower legs' => 'Legs',
    'cardiova cular y tem' || 'cardiovascular system' || 'cardio' => 'Cardio',
    _ => _titleCase(value),
  };
}

String _canonicalPrimaryMuscle(String exerciseName, String metadataMuscle) {
  final name = _normalizeExerciseKeyPart(exerciseName);
  if (_containsAny(name, const [
    'squat',
    'leg press',
    'leg extension',
    'leg curl',
    'lunge',
    'step up',
    'calf',
    'hamstring',
    'quad',
    'thigh',
  ])) {
    return 'Legs';
  }

  if (_containsAny(name, const [
    'hip thrust',
    'glute bridge',
    'kickback',
    'glute',
    'abductor',
  ])) {
    return 'Glutes';
  }
  if (_containsAny(name, const [
    'bench press',
    'chest press',
    'chest fly',
    'cable crossover',
    'push up',
    'pushup',
    'pec deck',
    'dip',
  ])) {
    return 'Chest';
  }
  if (_containsAny(name, const [
    'pulldown',
    'pull up',
    'pullup',
    'chin up',
    'row',
    'deadlift',
    'lat ',
    'back extension',
  ])) {
    return 'Back';
  }
  if (_containsAny(name, const ['bicep', 'curl', 'preacher', 'hammer curl'])) {
    return 'Biceps';
  }
  if (_containsAny(name, const [
    'tricep',
    'pushdown',
    'pressdown',
    'skullcrusher',
    'skull crusher',
  ])) {
    return 'Triceps';
  }
  if (_containsAny(name, const [
    'shoulder',
    'lateral raise',
    'front raise',
    'rear delt',
    'overhead press',
    'military press',
    'arnold press',
  ])) {
    return 'Shoulders';
  }
  if (_containsAny(name, const [
    'sit up',
    'crunch',
    'plank',
    'leg raise',
    'russian twist',
    'ab ',
    'abs ',
    'oblique',
  ])) {
    return 'Abs';
  }
  if (_containsAny(name, const [
    'run',
    'walk',
    'bike',
    'cycling',
    'sprint',
    'jump rope',
  ])) {
    return 'Cardio';
  }
  return _normalizeMuscle(metadataMuscle);
}

bool _containsAny(String value, List<String> terms) {
  return terms.any(value.contains);
}

String _normalizeEquipment(String value) {
  final normalized = _normalizeExerciseKeyPart(value);
  return switch (normalized) {
    'body weight' || 'bodyweight' || 'body only' || 'body only' => 'Bodyweight',
    'dumbbells' || 'dumbbell' => 'Dumbbell',
    'barbells' || 'barbell' => 'Barbell',
    'cables' || 'cable' => 'Cable',
    'machine' || 'machines' => 'Machine',
    'band' || 'bands' || 'resistance band' => 'Band',
    'kettlebell' || 'kettlebells' => 'Kettlebell',
    'medicine ball' || 'med ball' => 'Medicine Ball',
    'bosu ball' || 'bo u ball' => 'Bosu Ball',
    'assisted' || 'a i ted' => 'Assisted',
    _ => _titleCase(value),
  };
}

String _normalizeDifficulty(String value) {
  final normalized = _normalizeExerciseKeyPart(value);
  return switch (normalized) {
    'easy' || 'beginner' => 'Beginner',
    'medium' || 'moderate' || 'intermediate' => 'Intermediate',
    'hard' || 'advanced' || 'expert' => 'Advanced',
    _ => _titleCase(value),
  };
}

String _normalizeMovementType(String value) {
  final normalized = _normalizeExerciseKeyPart(value);
  return switch (normalized) {
    'che t' => 'Chest',
    'wai t' => 'Abs',
    'upper arm' || 'upper arms' => 'Arms',
    'lower arm' || 'lower arms' => 'Arms',
    'upper leg' || 'upper legs' => 'Legs',
    'lower leg' || 'lower legs' => 'Legs',
    _ => _titleCase(value),
  };
}

const fallbackExercises = [
  AtlasExercise(
    id: 'bench',
    name: 'Barbell Bench Press',
    pattern: 'horizontal_push',
    defaultSets: 4,
    defaultReps: '8-10',
    primaryMuscle: 'Chest',
    equipment: 'Barbell',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Bench_Press/0.jpg',
  ),
  AtlasExercise(
    id: 'incline',
    name: 'Incline Dumbbell Press',
    pattern: 'incline_push',
    defaultSets: 3,
    defaultReps: '10',
    primaryMuscle: 'Chest',
    equipment: 'Dumbbells',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Incline_Dumbbell_Bench_Press/0.jpg',
  ),
  AtlasExercise(
    id: 'fly',
    name: 'Cable Fly',
    pattern: 'chest_isolation',
    defaultSets: 3,
    defaultReps: '12-15',
    primaryMuscle: 'Chest',
    equipment: 'Cable',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Cable_Crossover/0.jpg',
  ),
  AtlasExercise(
    id: 'dips',
    name: 'Dips',
    pattern: 'vertical_push',
    defaultSets: 3,
    defaultReps: '8-12',
    primaryMuscle: 'Chest',
    equipment: 'Bodyweight',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Triceps_Dip/0.jpg',
  ),
  AtlasExercise(
    id: 'pushdown',
    name: 'Rope Pushdown',
    pattern: 'triceps_isolation',
    defaultSets: 3,
    defaultReps: '12',
    primaryMuscle: 'Triceps',
    equipment: 'Cable',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Triceps_Pushdown/0.jpg',
  ),
  AtlasExercise(
    id: 'extension',
    name: 'Overhead Extension',
    pattern: 'triceps_isolation',
    defaultSets: 2,
    defaultReps: '12-15',
    primaryMuscle: 'Triceps',
    equipment: 'Dumbbell',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Dumbbell_Triceps_Extension/0.jpg',
  ),
  AtlasExercise(
    id: 'deadlift',
    name: 'Deadlift',
    pattern: 'hinge_pull',
    defaultSets: 3,
    defaultReps: '5',
    primaryMuscle: 'Back',
    equipment: 'Barbell',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Deadlift/0.jpg',
  ),
  AtlasExercise(
    id: 'pulldown',
    name: 'Lat Pulldown',
    pattern: 'vertical_pull',
    defaultSets: 4,
    defaultReps: '8-12',
    primaryMuscle: 'Back',
    equipment: 'Cable',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Lat_Pulldown/0.jpg',
  ),
  AtlasExercise(
    id: 'row',
    name: 'Seated Cable Row',
    pattern: 'horizontal_pull',
    defaultSets: 3,
    defaultReps: '10-12',
    primaryMuscle: 'Back',
    equipment: 'Cable',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Seated_Cable_Row/0.jpg',
  ),
  AtlasExercise(
    id: 'curl',
    name: 'Dumbbell Curl',
    pattern: 'biceps_isolation',
    defaultSets: 3,
    defaultReps: '10-12',
    primaryMuscle: 'Biceps',
    equipment: 'Dumbbells',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Bicep_Curl/0.jpg',
  ),
  AtlasExercise(
    id: 'raise',
    name: 'Lateral Raise',
    pattern: 'shoulder_isolation',
    defaultSets: 4,
    defaultReps: '12-15',
    primaryMuscle: 'Shoulders',
    equipment: 'Dumbbells',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Dumbbell_Lateral_Raise/0.jpg',
  ),
  AtlasExercise(
    id: 'press',
    name: 'Overhead Press',
    pattern: 'vertical_push',
    defaultSets: 4,
    defaultReps: '6-8',
    primaryMuscle: 'Shoulders',
    equipment: 'Barbell',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Standing_Military_Press/0.jpg',
  ),
  AtlasExercise(
    id: 'squat',
    name: 'Back Squat',
    pattern: 'squat',
    defaultSets: 4,
    defaultReps: '6-10',
    primaryMuscle: 'Legs',
    equipment: 'Barbell',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Barbell_Squat/0.jpg',
  ),
  AtlasExercise(
    id: 'leg_press',
    name: 'Leg Press',
    pattern: 'squat',
    defaultSets: 3,
    defaultReps: '10-12',
    primaryMuscle: 'Legs',
    equipment: 'Machine',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Leg_Press/0.jpg',
  ),
  AtlasExercise(
    id: 'plank',
    name: 'Plank',
    pattern: 'anti_extension',
    defaultSets: 3,
    defaultReps: '45',
    primaryMuscle: 'Core',
    equipment: 'Bodyweight',
    imageUrl:
        'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/Plank/0.jpg',
  ),
];

String _primaryMuscle(String? pattern) {
  final value = pattern ?? '';
  if (value.contains('pull') || value.contains('hinge')) return 'Back';
  if (value.contains('curl')) return 'Biceps';
  if (value.contains('triceps')) return 'Triceps';
  if (value.contains('squat') || value.contains('leg')) return 'Legs';
  if (value.contains('core') || value.contains('extension')) return 'Core';
  if (value.contains('shoulder')) return 'Shoulders';
  return 'Chest';
}

String _equipment(String name) {
  final value = name.toLowerCase();
  if (value.contains('dumbbell') || value.contains('curl')) return 'Dumbbells';
  if (value.contains('cable') || value.contains('pushdown')) return 'Cable';
  if (value.contains('press') ||
      value.contains('deadlift') ||
      value.contains('squat')) {
    return 'Barbell';
  }
  if (value.contains('plank') || value.contains('dips')) return 'Bodyweight';
  return 'Gym';
}

String? _exerciseImageUrl(String name) {
  for (final exercise in fallbackExercises) {
    if (exercise.name == name) {
      return exercise.imageUrl;
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
