import 'package:flutter/material.dart';

enum AtlasGoalType { weight, strength, habit, deadline }

class AtlasExercise {
  const AtlasExercise({
    required this.id,
    required this.name,
    required this.pattern,
    required this.defaultSets,
    required this.defaultReps,
    this.primaryMuscle = 'Strength',
    this.equipment = 'Gym',
    this.difficulty = 'Moderate',
    this.imageUrl,
    this.gifUrl,
    this.secondaryMuscles = const [],
    this.movementType = 'strength',
    this.instructions = const [],
    this.previewImage,
    this.previewGif,
    this.previewVideo,
    this.thumbnail,
  });

  final String id;
  final String name;
  final String pattern;
  final int defaultSets;
  final String defaultReps;
  final String primaryMuscle;
  final String equipment;
  final String difficulty;
  final String? imageUrl;
  final String? gifUrl;
  final List<String> secondaryMuscles;
  final String movementType;
  final List<String> instructions;
  final String? previewImage;
  final String? previewGif;
  final String? previewVideo;
  final String? thumbnail;

  @override
  bool operator ==(Object other) {
    return other is AtlasExercise && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}

class AtlasWorkoutDay {
  const AtlasWorkoutDay({
    required this.dayNumber,
    required this.name,
    required this.focus,
    required this.isRestDay,
    this.workoutDayId,
    this.templateId,
  });

  final int dayNumber;
  final String name;
  final String focus;
  final bool isRestDay;
  final String? workoutDayId;
  final String? templateId;
}

class AtlasWorkoutExercise {
  const AtlasWorkoutExercise({
    required this.exercise,
    required this.targetSets,
    required this.targetReps,
    required this.notes,
  });

  final AtlasExercise exercise;
  final int targetSets;
  final String targetReps;
  final String notes;
}

class AtlasWorkoutEntry {
  const AtlasWorkoutEntry({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  final AtlasExercise exercise;
  final int sets;
  final int reps;
  final double weight;
}

class AtlasGoal {
  const AtlasGoal({
    required this.id,
    required this.type,
    required this.title,
    required this.progress,
    this.currentValue,
    this.targetValue,
    this.targetUnit,
  });

  final String id;
  final AtlasGoalType type;
  final String title;
  final double progress;
  final double? currentValue;
  final double? targetValue;
  final String? targetUnit;
}

class AtlasDashboardSnapshot {
  const AtlasDashboardSnapshot({
    required this.todayWorkout,
    required this.starterWorkout,
    required this.templateExercises,
    required this.exerciseLibrary,
    required this.completedThisWeek,
    required this.weeklyTarget,
    required this.totalWorkouts,
    required this.monthWorkouts,
    required this.hydrationToday,
    required this.activeGoals,
    this.latestWeight,
    this.latestWeightUnit = 'kg',
    this.latestWeightDate,
    this.lastWorkoutTitle,
  });

  final AtlasWorkoutDay? todayWorkout;
  final AtlasWorkoutDay? starterWorkout;
  final List<AtlasWorkoutExercise> templateExercises;
  final List<AtlasExercise> exerciseLibrary;
  final int completedThisWeek;
  final int weeklyTarget;
  final int totalWorkouts;
  final int monthWorkouts;
  final int hydrationToday;
  final List<AtlasGoal> activeGoals;
  final double? latestWeight;
  final String latestWeightUnit;
  final DateTime? latestWeightDate;
  final String? lastWorkoutTitle;

  bool get hasWorkoutCycleStarted => totalWorkouts > 0;

  int? get fitnessScore {
    if (totalWorkouts == 0 &&
        latestWeight == null &&
        hydrationToday == 0 &&
        activeGoals.isEmpty) {
      return null;
    }
    var score = 0;
    score += (completedThisWeek * 9).clamp(0, 36);
    if (latestWeight != null) {
      score += 24;
    }
    if (hydrationToday > 0) {
      score += 18;
    }
    if (activeGoals.isNotEmpty) {
      score += 22;
    }
    return score.clamp(0, 100);
  }

  int? get recoveryScore {
    if (totalWorkouts == 0 && hydrationToday == 0) {
      return null;
    }
    var score = hydrationToday * 12;
    if (totalWorkouts > 0) {
      score += 40;
    }
    if (completedThisWeek >= weeklyTarget) {
      score -= 6;
    }
    return score.clamp(0, 100);
  }
}

class ExerciseVisual {
  const ExerciseVisual({
    required this.icon,
    required this.gradient,
    required this.cue,
  });

  final IconData icon;
  final List<Color> gradient;
  final String cue;
}
