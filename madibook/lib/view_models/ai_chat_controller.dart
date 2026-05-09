import 'package:flutter/foundation.dart';
import '../core/ai_chat_service.dart';

/// Controls the AI Mentor chat session.
class AiChatController extends ChangeNotifier {
  final AiChatService _service = AiChatService();

  final List<AiMessage> _messages = [];
  bool _isTyping = false;

  List<AiMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  /// Send a message and get an AI response.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message.
    final userMsg = AiMessage(content: content.trim(), isUser: true);
    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    try {
      // Get AI response.
      final response = await _service.generateResponse(content, _messages);
      final aiMsg = AiMessage(content: response, isUser: false);
      _messages.add(aiMsg);
    } catch (e) {
      _messages.add(AiMessage(
        content: 'Sorry, I encountered an error. Please try again! 🔄',
        isUser: false,
      ));
      debugPrint('❌ AI error: $e');
    }

    _isTyping = false;
    notifyListeners();
  }

  /// Clear the chat history.
  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
