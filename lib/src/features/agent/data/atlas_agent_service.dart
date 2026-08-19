import 'package:supabase_flutter/supabase_flutter.dart';

class AtlasAgentService {
  AtlasAgentService(this._client);

  final SupabaseClient _client;

  Future<AtlasAgentReply> ask({
    required String message,
    required String screen,
    required List<AtlasAgentMessage> history,
  }) async {
    try {
      final response = await _client.functions
          .invoke(
            'atlas-agent',
            body: {
              'message': message,
              'screen': screen,
              'history': [
                for (final item in history.take(10))
                  {'role': item.role.name, 'content': item.content},
              ],
            },
          )
          .timeout(const Duration(seconds: 22));
      final data = response.data;
      if (data is Map) {
        return AtlasAgentReply.fromJson({
          for (final entry in data.entries)
            if (entry.key is String) entry.key as String: entry.value,
        });
      }
      if (data is String && data.trim().isNotEmpty) {
        return AtlasAgentReply(message: data.trim(), suggestions: const []);
      }
    } catch (_) {
      return _localFallbackReply(message);
    }
    return _localFallbackReply(message);
  }
}

AtlasAgentReply _localFallbackReply(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('rest')) {
    return const AtlasAgentReply(
      message:
          'Buddy fallback: keep today easy. Walk 20-30 minutes, stretch, hydrate, and do not force heavy sets on a recovery day.',
      suggestions: [],
      mode: 'Recovery',
    );
  }
  return const AtlasAgentReply(
    message:
        'Buddy fallback is active because the coach backend did not answer. You can still ask training questions, and Atlas will keep the chat usable while the server catches up.',
    suggestions: [],
    mode: 'Coach',
  );
}

class AtlasAgentReply {
  const AtlasAgentReply({
    required this.message,
    required this.suggestions,
    this.mode = 'Coach',
    this.contextUsed = const [],
    this.workoutEntries = const [],
  });

  factory AtlasAgentReply.fromJson(Map<String, dynamic> json) {
    final rawSuggestions = json['suggestions'];
    final rawContext = json['contextUsed'];
    final rawWorkoutEntries = json['workoutEntries'];
    return AtlasAgentReply(
      message: json['message'] as String? ?? 'I could not generate a reply.',
      mode: json['mode'] as String? ?? 'Coach',
      suggestions:
          [
            if (rawSuggestions is List)
              for (final item in rawSuggestions)
                if (item is String && item.trim().isNotEmpty) item.trim(),
          ].take(4).toList(),
      contextUsed: [
        if (rawContext is List)
          for (final item in rawContext)
            if (item is String && item.trim().isNotEmpty) item.trim(),
      ],
      workoutEntries: [
        if (rawWorkoutEntries is List)
          for (final item in rawWorkoutEntries)
            if (item is Map)
              AtlasAgentWorkoutEntry.fromJson({
                for (final entry in item.entries)
                  if (entry.key is String) entry.key as String: entry.value,
              }),
      ],
    );
  }

  final String message;
  final String mode;
  final List<String> suggestions;
  final List<String> contextUsed;
  final List<AtlasAgentWorkoutEntry> workoutEntries;
}

class AtlasAgentMessage {
  const AtlasAgentMessage({required this.role, required this.content});

  final AtlasAgentRole role;
  final String content;
}

enum AtlasAgentRole { user, assistant }

class AtlasAgentWorkoutEntry {
  const AtlasAgentWorkoutEntry({
    required this.name,
    this.muscle,
    this.equipment,
    this.sets,
    this.reps,
    this.weight,
  });

  factory AtlasAgentWorkoutEntry.fromJson(Map<String, dynamic> json) {
    return AtlasAgentWorkoutEntry(
      name: json['name'] as String? ?? json['exercise'] as String? ?? '',
      muscle: json['muscle'] as String? ?? json['targetMuscle'] as String?,
      equipment: json['equipment'] as String?,
      sets: _intFromJson(json['sets']),
      reps: _intFromJson(json['reps']),
      weight: _doubleFromJson(json['weight'] ?? json['kg']),
    );
  }

  final String name;
  final String? muscle;
  final String? equipment;
  final int? sets;
  final int? reps;
  final double? weight;
}

int? _intFromJson(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

double? _doubleFromJson(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}
