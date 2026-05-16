import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final String senderId;
  final String senderName;
  final String senderRole;
  final Timestamp timestamp;

  Message({
    required this.text,
    required this.senderId,
    this.senderName = 'Anonymous',
    this.senderRole = 'talent',
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'User',
      senderRole: json['senderRole'] as String? ?? 'talent',
      timestamp: json['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'timestamp': timestamp,
    };
  }
}
