import '../entities/message_entity.dart';

abstract class IChatRepository {
  /// Sends a message and returns true if successful.
  Future<bool> sendMessage(MessageEntity message, String roomId);

  /// Returns a real-time stream of messages for a specific room.
  Stream<List<MessageEntity>> getMessagesStream(String roomId);
}
