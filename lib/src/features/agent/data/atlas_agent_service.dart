import 'package:supabase_flutter/supabase_flutter.dart';

class AtlasAgentService {
  AtlasAgentService(this._client);

  final SupabaseClient _client;

  Future<AtlasAgentReply> ask({
    required String message,
    required String screen,
    required List<AtlasAgentMessage> history,
  }) async {
    final response = await _client.functions.invoke(
      'atlas-agent',
      body: {
        'message': message,
        'screen': screen,
        'history': [
          for (final item in history.take(10))
            {'role': item.role.name, 'content': item.content},
        ],
      },
    );
    final data = response.data;
    if (data is Map) {
      return AtlasAgentReply.fromJson({
        for (final entry in data.entries)
          if (entry.key is String) entry.key as String: entry.value,
      });
    }
    return AtlasAgentReply(
      message:
          data is String && data.trim().isNotEmpty
              ? data
              : 'Atlas Agent could not read the response. Try again.',
      suggestions: const ['What should I train today?', 'Review my week'],
    );
  }
}

class AtlasAgentReply {
  const AtlasAgentReply({
    required this.message,
    required this.suggestions,
    this.mode = 'Coach',
    this.contextUsed = const [],
  });

  factory AtlasAgentReply.fromJson(Map<String, dynamic> json) {
    final rawSuggestions = json['suggestions'];
    final rawContext = json['contextUsed'];
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
    );
  }

  final String message;
  final String mode;
  final List<String> suggestions;
  final List<String> contextUsed;
}

class AtlasAgentMessage {
  const AtlasAgentMessage({required this.role, required this.content});

  final AtlasAgentRole role;
  final String content;
}

enum AtlasAgentRole { user, assistant }
