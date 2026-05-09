import 'package:uuid/uuid.dart';

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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'is_read': isRead,
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

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as String,
      participantAId: json['participant_a_id'] as String,
      participantBId: json['participant_b_id'] as String,
      participantAName: json['participant_a_name'] as String,
      participantBName: json['participant_b_name'] as String,
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'participant_a_id': participantAId,
        'participant_b_id': participantBId,
        'participant_a_name': participantAName,
        'participant_b_name': participantBName,
        'last_message': lastMessage?.toJson(),
        'unread_count': unreadCount,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatThread && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
