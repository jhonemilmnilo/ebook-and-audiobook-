import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/ai_service.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  // TODO: Replace with real API Key or use environment variable
  return AiService('YOUR_GEMINI_API_KEY_HERE');
});

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'text': 'Hey pare! I\'m your AI Reading Assistant. Any lines or words you don\'t understand? Just ask! 🤖'}
  ];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isAi = msg['role'] == 'ai';
                return _buildMessageBubble(msg['text']!, isAi);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          _buildInputArea(),
          const SizedBox(height: 100), // Padding for BottomNav
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isAi) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isAi ? AppTheme.surface : AppTheme.primary,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isAi ? const Radius.circular(0) : const Radius.circular(20),
            bottomRight: isAi ? const Radius.circular(20) : const Radius.circular(0),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: isAi ? AppTheme.textPrimary : Colors.black,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Type a word or line...',
                hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(LucideIcons.send, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userText = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'text': userText});
      _isLoading = true;
      _controller.clear();
    });

    // In a real app, you'd use the AiService here.
    // For now, I'll simulate a response or wait for the user to provide an API key.
    
    // Simulate AI response
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _messages.add({'role': 'ai', 'text': 'Pare, I need a Gemini API Key to actually process this! But the logic is already here. 🚀'});
      _isLoading = false;
    });
  }
}
