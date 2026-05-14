import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  final String apiKey;
  late final GenerativeModel _model;

  AiService(this.apiKey) {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<String> explainText(String text) async {
    try {
      final prompt = 'Explain this text or word from a book simply and concisely: "$text"';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Sorry, I couldn\'t explain that.';
    } catch (e) {
      return 'Error connecting to Gemini: $e';
    }
  }

  Future<String> chat(List<Content> history) async {
    try {
      final response = await _model.generateContent(history);
      return response.text ?? 'Sorry, I didn\'t quite catch that.';
    } catch (e) {
      return 'AI Error: $e';
    }
  }
}
