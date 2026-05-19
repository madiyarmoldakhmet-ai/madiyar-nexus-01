import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A single chat message between two users.
class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  bool isRead;

  ChatMessage({
    String? id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    DateTime? timestamp,
    this.isRead = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromFirestore(Map<String, dynamic>? json, String docId) {
    final data = json ?? {};
    DateTime parsedTime;
    final ts = data['timestamp'];
    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    } else if (ts is String) {
      parsedTime = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    return ChatMessage(
      id: docId,
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      content: data['text'] as String? ?? '',
      timestamp: parsedTime,
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'text': content,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': isRead,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A conversation thread between two users.
class ChatThread {
  final String id;
  final String participantAId;
  final String participantBId;
  final String participantAName;
  final String participantBName;
  ChatMessage? lastMessage;
  int unreadCount;

  ChatThread({
    String? id,
    required this.participantAId,
    required this.participantBId,
    required this.participantAName,
    required this.participantBName,
    this.lastMessage,
    this.unreadCount = 0,
  }) : id = id ?? const Uuid().v4();

  /// Get the other participant's name given the current user's ID.
  String otherName(String myId) =>
      myId == participantAId ? participantBName : participantAName;

  /// Get the other participant's ID given the current user's ID.
  String otherId(String myId) =>
      myId == participantAId ? participantBId : participantAId;

  /// Get initials for the other participant.
  String otherInitials(String myId) {
    final name = otherName(myId);
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory ChatThread.fromFirestore(Map<String, dynamic>? json, String docId) {
    final data = json ?? {};
    return ChatThread(
      id: docId,
      participantAId: data['participantAId'] as String? ?? '',
      participantBId: data['participantBId'] as String? ?? '',
      participantAName: data['participantAName'] as String? ?? '',
      participantBName: data['participantBName'] as String? ?? '',
      unreadCount: data['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'participantAId': participantAId,
        'participantBId': participantBId,
        'participantAName': participantAName,
        'participantBName': participantBName,
        'unreadCount': unreadCount,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatThread && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
