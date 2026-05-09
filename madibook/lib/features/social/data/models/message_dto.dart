import '../../domain/entities/message_entity.dart';

class MessageDto extends MessageEntity {
  MessageDto({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.content,
    required super.timestamp,
  });

  /// Factory method to create a DTO from Firestore data
  factory MessageDto.fromJson(Map<String, dynamic> json, String documentId) {
    return MessageDto(
      id: documentId,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      // Firestore Timestamp usually needs conversion, using DateTime.parse for mock
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp']) 
          : DateTime.now(),
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Create DTO from Domain Entity
  factory MessageDto.fromEntity(MessageEntity entity) {
    return MessageDto(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      content: entity.content,
      timestamp: entity.timestamp,
    );
  }
}
