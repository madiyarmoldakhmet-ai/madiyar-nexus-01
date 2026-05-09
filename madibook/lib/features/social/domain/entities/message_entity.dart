class MessageEntity {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;

  MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });
}
