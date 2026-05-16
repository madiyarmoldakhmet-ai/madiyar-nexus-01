import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../models/message_dto.dart';

// IMPORTANT: Requires adding `cloud_firestore: ^4.15.5` to pubspec.yaml
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Implementation of the Chat Repository
class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> sendMessage(MessageEntity message, String roomId) async {
    try {
      final dto = MessageDto.fromEntity(message);
      
      // Firestore implementation:
      await _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .add(dto.toJson());
      
      debugPrint('Sent message "${message.content}" to room $roomId via Firestore');
      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  @override
  Stream<List<MessageEntity>> getMessagesStream(String roomId) {
    // Firestore implementation:
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageDto.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }
}
