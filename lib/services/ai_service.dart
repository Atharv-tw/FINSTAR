import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/ai_config.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

class AIService {
  late final GenerativeModel _model;
  late ChatSession _chat;

  AIService() {
    _model = GenerativeModel(
      model: AIConfig.modelName,
      apiKey: AIConfig.geminiApiKey,
      requestOptions: const RequestOptions(apiVersion: 'v1'),
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    if (AIConfig.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return "Please configure your Gemini API Key in lib/config/ai_config.dart to use the Finstar AI Coach.";
    }

    try {
      // Prepend system prompt to the very first message in the session
      final prompt = _chat.history.isEmpty 
          ? "${AIConfig.systemPrompt}\n\nUser Question: $message" 
          : message;
          
      final response = await _chat.sendMessage(Content.text(prompt));
      return response.text ?? "I'm sorry, I couldn't process that request.";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  void resetChat() {
    _chat = _model.startChat();
  }
}
