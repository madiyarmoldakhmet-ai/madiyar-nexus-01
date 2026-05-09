import 'package:flutter/foundation.dart';
import '../models/message_model.dart';

/// Mock chat service for peer-to-peer messaging.
///
/// Swap with Firestore real-time listeners for production:
///   class FirestoreChatService implements ChatService { ... }
class ChatService extends ChangeNotifier {
  final List<ChatThread> _threads = [];
  final Map<String, List<ChatMessage>> _messages = {};

  List<ChatThread> get threads => List.unmodifiable(_threads);

  /// Get all messages for a given thread.
  List<ChatMessage> getMessages(String threadId) {
    return List.unmodifiable(_messages[threadId] ?? []);
  }

  /// Get or create a thread between two users.
  ChatThread getOrCreateThread({
    required String myId,
    required String myName,
    required String otherId,
    required String otherName,
  }) {
    // Check if thread already exists.
    final existing = _threads.where((t) =>
        (t.participantAId == myId && t.participantBId == otherId) ||
        (t.participantAId == otherId && t.participantBId == myId));

    if (existing.isNotEmpty) return existing.first;

    // Create new thread.
    final thread = ChatThread(
      participantAId: myId,
      participantBId: otherId,
      participantAName: myName,
      participantBName: otherName,
    );
    _threads.insert(0, thread);
    _messages[thread.id] = [];
    notifyListeners();
    return thread;
  }

  /// Send a message in a thread.
  ChatMessage sendMessage({
    required String threadId,
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    final message = ChatMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );

    _messages.putIfAbsent(threadId, () => []);
    _messages[threadId]!.add(message);

    // Update the thread's last message and move it to top.
    final threadIndex = _threads.indexWhere((t) => t.id == threadId);
    if (threadIndex != -1) {
      final thread = _threads[threadIndex];
      thread.lastMessage = message;
      thread.unreadCount++;
      // Move to top of list (most recent).
      _threads.removeAt(threadIndex);
      _threads.insert(0, thread);
    }

    notifyListeners();
    debugPrint('💬 Message sent in thread $threadId');
    return message;
  }

  /// Mark all messages in a thread as read.
  void markThreadAsRead(String threadId, String readerId) {
    final messages = _messages[threadId];
    if (messages == null) return;

    for (final msg in messages) {
      if (msg.receiverId == readerId) {
        msg.isRead = true;
      }
    }

    final threadIndex = _threads.indexWhere((t) => t.id == threadId);
    if (threadIndex != -1) {
      _threads[threadIndex].unreadCount = 0;
    }

    notifyListeners();
  }

  /// Total unread count across all threads for a user.
  int totalUnread(String userId) {
    return _threads.fold(0, (sum, t) => sum + t.unreadCount);
  }
}
