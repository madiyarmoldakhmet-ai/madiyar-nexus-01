import '../entities/message_entity.dart';
import '../repositories/i_chat_repository.dart';

class SendMessageUseCase {
  final IChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<bool> execute({
    required String senderId,
    required String receiverId,
    required String content,
    required String roomId,
  }) async {
    if (content.trim().isEmpty) return false;

    final message = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Mock ID generation
      senderId: senderId,
      receiverId: receiverId,
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    return await repository.sendMessage(message, roomId);
  }
}
