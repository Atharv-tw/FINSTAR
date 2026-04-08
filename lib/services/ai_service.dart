import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/ai_config.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

class AIService {
  late GenerativeModel _model;
  late ChatSession _chat;
  int _modelIndex = 0;
  bool _hasTriedDiscovery = false;

  static const List<String> _fallbackModels = [
    AIConfig.modelName,
    'gemini-1.5-flash-latest',
    'gemini-1.5-pro-latest',
    'gemini-1.0-pro',
  ];

  AIService() {
    _initModel(_fallbackModels[_modelIndex]);
  }

  void _initModel(String modelName) {
    _model = GenerativeModel(
      model: modelName,
      apiKey: AIConfig.geminiApiKey,
      requestOptions: const RequestOptions(apiVersion: 'v1beta'),
    );
    _chat = _model.startChat();
  }

  Future<String?> _discoverModel() async {
    if (_hasTriedDiscovery) return null;
    _hasTriedDiscovery = true;

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=${AIConfig.geminiApiKey}',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final models = (data['models'] as List<dynamic>? ?? []);

      for (final raw in models) {
        final model = raw as Map<String, dynamic>;
        final name = (model['name'] as String?) ?? '';
        final methods = (model['supportedGenerationMethods'] as List<dynamic>? ??
            model['supportedMethods'] as List<dynamic>? ??
            const []);

        final supportsGenerate = methods
            .map((m) => m.toString())
            .any((m) => m.toLowerCase() == 'generatecontent');

        if (supportsGenerate && name.contains('gemini')) {
          final cleaned = name.startsWith('models/')
              ? name.substring('models/'.length)
              : name;
          _initModel(cleaned);
          return cleaned;
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<String> sendMessage(String message) async {
    if (AIConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return "Please configure your Gemini API Key in lib/config/ai_config.dart to use the Finstar AI Coach.";
    }

    for (var attempt = 0; attempt < _fallbackModels.length; attempt++) {
      try {
        // Prepend system prompt to the very first message in the session
        final prompt = _chat.history.isEmpty
            ? "${AIConfig.systemPrompt}\n\nUser Question: $message"
            : message;

        final response = await _chat.sendMessage(Content.text(prompt));
        return response.text ?? "I'm sorry, I couldn't process that request.";
      } catch (e) {
        final errorText = e.toString();
        final isModelError = errorText.contains('not found') ||
            errorText.contains('not supported') ||
            errorText.contains('404');

        if (isModelError && _modelIndex + 1 < _fallbackModels.length) {
          _modelIndex++;
          _initModel(_fallbackModels[_modelIndex]);
          continue;
        }

        if (isModelError) {
          final discovered = await _discoverModel();
          if (discovered != null) {
            try {
              final prompt = _chat.history.isEmpty
                  ? "${AIConfig.systemPrompt}\n\nUser Question: $message"
                  : message;
              final response = await _chat.sendMessage(Content.text(prompt));
              return response.text ?? "I'm sorry, I couldn't process that request.";
            } catch (e2) {
              return "Error: ${e2.toString()} (model: $discovered)";
            }
          }
        }

        return "Error: ${e.toString()} (model: ${_fallbackModels[_modelIndex]})";
      }
    }

    return "Error: Unable to find a supported model for this API key.";
  }

  void resetChat() {
    _chat = _model.startChat();
  }
}
