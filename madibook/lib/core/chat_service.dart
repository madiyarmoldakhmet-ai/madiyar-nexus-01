import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

/// Real-time Firestore chat service for peer-to-peer messaging.
class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ChatThread> _threads = [];
  final Map<String, List<ChatMessage>> _messages = {};
  final Map<String, Stream<QuerySnapshot>> _messageStreams = {};

  List<ChatThread> get threads => List.unmodifiable(_threads);

  /// Helper to generate a consistent thread ID between two users.
  String getThreadId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  String? _currentUserId;

  /// Start listening to threads for the current user.
  void initialize(String userId) {
    if (userId.isEmpty || _currentUserId == userId) return;
    _currentUserId = userId;

    // Listen to threads where the user is participantA or participantB
    _firestore.collection('chats')
      .where(Filter.or(
        Filter('participantAId', isEqualTo: userId),
        Filter('participantBId', isEqualTo: userId)
      ))
      .snapshots()
      .listen((snapshot) {
        _threads = snapshot.docs
            .map((doc) => ChatThread.fromFirestore(doc.data(), doc.id))
            .toList();
        
        // Sort by last message time if possible, or just keep order
        notifyListeners();
      });
  }

  /// Get all messages for a given thread (cached).
  List<ChatMessage> getMessages(String threadId) {
    if (!_messageStreams.containsKey(threadId)) {
      _setupMessageListener(threadId);
    }
    return List.unmodifiable(_messages[threadId] ?? []);
  }

  void _setupMessageListener(String threadId) {
    final stream = _firestore.collection('chats')
        .doc(threadId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
    
    _messageStreams[threadId] = stream;
    stream.listen((snapshot) {
      _messages[threadId] = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });
  }

  /// Get or create a thread metadata in Firestore.
  ChatThread getOrCreateThread({
    required String myId,
    required String myName,
    required String otherId,
    required String otherName,
  }) {
    final threadId = getThreadId(myId, otherId);
    final existing = _threads.where((t) => t.id == threadId);

    if (existing.isNotEmpty) return existing.first;

    final thread = ChatThread(
      id: threadId,
      participantAId: myId,
      participantBId: otherId,
      participantAName: myName,
      participantBName: otherName,
    );

    _firestore.collection('chats').doc(threadId).set(thread.toFirestore(), SetOptions(merge: true));
    
    return thread;
  }

  /// Send a message to Firestore.
  Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final docRef = _firestore.collection('chats')
        .doc(threadId)
        .collection('messages')
        .doc();

    final payload = {
      'text': content,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    debugPrint('===> [DEBUG] 📤 Sending message to Firestore: $payload');
    
    await docRef.set(payload);

    // Also update thread metadata to show it exists and maybe update unreadCount
    // For simplicity, we just ensure the thread doc exists
    _firestore.collection('chats').doc(threadId).set({
      'lastMessageText': content,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Mark messages as read in Firestore.
  void markThreadAsRead(String threadId, String readerId) async {
    final unreadQuery = await _firestore.collection('chats')
        .doc(threadId)
        .collection('messages')
        .where('receiverId', isEqualTo: readerId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  int totalUnread(String userId) {
    // This could be a complex query, but for now we sum local thread counts
    return _threads.fold(0, (sum, t) => sum + t.unreadCount);
  }
}
