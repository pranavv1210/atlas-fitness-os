import 'dart:convert';

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
        final reply = AtlasAgentReply.fromJson({
          for (final entry in data.entries)
            if (entry.key is String) entry.key as String: entry.value,
        });
        return _withLocalEntries(reply, message);
      }
      if (data is String && data.trim().isNotEmpty) {
        return _withLocalEntries(_replyFromString(data), message);
      }
    } catch (_) {
      return _localFallbackReply(message);
    }
    return _localFallbackReply(message);
  }
}

AtlasAgentReply _withLocalEntries(AtlasAgentReply reply, String message) {
  if (reply.workoutEntries.isNotEmpty) return reply;
  final localEntries = _localWorkoutEntries(message);
  if (localEntries.isEmpty) return reply;
  return AtlasAgentReply(
    message:
        'Got it. I added ${localEntries.length} exercise${localEntries.length == 1 ? '' : 's'} to today\'s draft. Open Train, check the rows, then save.',
    suggestions: reply.suggestions,
    mode: 'Workout',
    contextUsed: reply.contextUsed,
    workoutEntries: localEntries,
  );
}

AtlasAgentReply _localFallbackReply(String message) {
  final entries = _localWorkoutEntries(message);
  if (entries.isNotEmpty) {
    return AtlasAgentReply(
      message:
          'Got it. I added ${entries.length} exercise${entries.length == 1 ? '' : 's'} to today\'s draft. Review the rows in Train, then save when it looks right.',
      suggestions: const [],
      mode: 'Workout',
      workoutEntries: entries,
    );
  }
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

AtlasAgentReply _replyFromString(String raw) {
  final parsed = _jsonMapFromString(raw);
  if (parsed != null) return AtlasAgentReply.fromJson(parsed);
  return AtlasAgentReply(message: raw.trim(), suggestions: const []);
}

Map<String, dynamic>? _jsonMapFromString(String raw) {
  final trimmed = raw.trim();
  final candidates = <String>[trimmed];
  final fenced = RegExp(
    r'```(?:json)?\s*([\s\S]*?)\s*```',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (fenced != null) candidates.add(fenced.group(1)!.trim());
  final start = trimmed.indexOf('{');
  final end = trimmed.lastIndexOf('}');
  if (start >= 0 && end > start) {
    candidates.add(trimmed.substring(start, end + 1));
  }
  for (final candidate in candidates) {
    try {
      final decoded = jsonDecode(candidate);
      if (decoded is Map) {
        return {
          for (final entry in decoded.entries)
            if (entry.key is String) entry.key as String: entry.value,
        };
      }
    } catch (_) {}
  }
  return null;
}

List<AtlasAgentWorkoutEntry> _localWorkoutEntries(String message) {
  final lower = message.toLowerCase();
  if (!RegExp(
    r'\b(kg|kgs|reps?|sets?|curl|pushdown|crunch|machine|tricep|bicep|abs)\b',
  ).hasMatch(lower)) {
    return const [];
  }
  final defaultSets =
      _firstIntMatch(lower, RegExp(r'all\s+(\d+)\s+sets?')) ?? 3;
  final defaultReps = _firstIntMatch(lower, RegExp(r'(\d+)\s+reps?')) ?? 15;
  final parts =
      message
          .split(RegExp(r',|\band\b', caseSensitive: false))
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
  return [
    for (final part in parts)
      if (_localEntryFromPart(part, defaultSets, defaultReps) != null)
        _localEntryFromPart(part, defaultSets, defaultReps)!,
  ].take(10).toList();
}

AtlasAgentWorkoutEntry? _localEntryFromPart(
  String part,
  int defaultSets,
  int defaultReps,
) {
  var source = part.toLowerCase();
  if (!RegExp(
    r'\b(kg|kgs|curl|pushdown|crusher|kick\s*backs?|crunch|machine|abs)\b',
  ).hasMatch(source)) {
    return null;
  }
  final weight = _firstDoubleMatch(source, RegExp(r'(\d+(?:\.\d+)?)\s*kgs?'));
  final sets = _firstIntMatch(source, RegExp(r'(\d+)\s+sets?')) ?? defaultSets;
  final reps = _firstIntMatch(source, RegExp(r'(\d+)\s+reps?')) ?? defaultReps;
  source =
      source
          .replaceAll(RegExp(r'\d+(?:\.\d+)?\s*kgs?'), '')
          .replaceAll(RegExp(r'(all\s+)?\d+\s+sets?'), '')
          .replaceAll(RegExp(r'\d+\s+reps?'), '')
          .replaceAll(RegExp(r'\bsame\b'), '')
          .trim();
  source = source.replaceAll(RegExp(r'\s+'), ' ');
  if (source.isEmpty) return null;
  final muscle =
      source.contains('tricep')
          ? 'Triceps'
          : source.contains('abs') || source.contains('crunch')
          ? 'Abs'
          : source.contains('bicep') || source.contains('curl')
          ? 'Biceps'
          : null;
  final equipment =
      source.contains('barbel') || source.contains('barbell')
          ? 'Barbell'
          : source.contains('machine')
          ? 'Machine'
          : source.contains('dumble') || source.contains('dumbbell')
          ? 'Dumbbell'
          : null;
  return AtlasAgentWorkoutEntry(
    name: source,
    muscle: muscle,
    equipment: equipment,
    sets: sets,
    reps: reps,
    weight: weight,
  );
}

int? _firstIntMatch(String value, RegExp pattern) {
  final match = pattern.firstMatch(value);
  return int.tryParse(match?.group(1) ?? '');
}

double? _firstDoubleMatch(String value, RegExp pattern) {
  final match = pattern.firstMatch(value);
  return double.tryParse(match?.group(1) ?? '');
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
    final rawMessage = json['message'];
    if (rawMessage is String) {
      final embedded = _jsonMapFromString(rawMessage);
      if (embedded != null && embedded['message'] != rawMessage) {
        return AtlasAgentReply.fromJson({...json, ...embedded});
      }
    }
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
