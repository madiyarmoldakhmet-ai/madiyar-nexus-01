import 'package:flutter/foundation.dart';
import '../core/chat_service.dart';
import '../models/message_model.dart';

/// Wraps ChatService with UI-specific state for the chat views.
class ChatController extends ChangeNotifier {
  final ChatService _chatService;

  String? _activeThreadId;

  ChatController(this._chatService);

  // ── Getters ──
  List<ChatThread> get threads => _chatService.threads;
  String? get activeThreadId => _activeThreadId;

  List<ChatMessage> get activeMessages =>
      _activeThreadId != null ? _chatService.getMessages(_activeThreadId!) : [];

  int totalUnread(String userId) => _chatService.totalUnread(userId);

  /// Open a conversation thread.
  void openThread(String threadId, String readerId) {
    _activeThreadId = threadId;
    _chatService.markThreadAsRead(threadId, readerId);
    notifyListeners();
  }

  /// Close the active conversation.
  void closeThread() {
    _activeThreadId = null;
    notifyListeners();
  }

  /// Start or get a thread with another user.
  ChatThread startConversation({
    required String myId,
    required String myName,
    required String otherId,
    required String otherName,
  }) {
    final thread = _chatService.getOrCreateThread(
      myId: myId,
      myName: myName,
      otherId: otherId,
      otherName: otherName,
    );
    _activeThreadId = thread.id;
    notifyListeners();
    return thread;
  }

  /// Send a message in the active thread.
  void sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    if (_activeThreadId == null || content.trim().isEmpty) return;

    _chatService.sendMessage(
      threadId: _activeThreadId!,
      senderId: senderId,
      receiverId: receiverId,
      content: content.trim(),
    );
    notifyListeners();
  }
}
