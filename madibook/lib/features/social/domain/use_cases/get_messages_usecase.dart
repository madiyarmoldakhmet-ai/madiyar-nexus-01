import '../entities/message_entity.dart';
import '../repositories/i_chat_repository.dart';

class GetMessagesUseCase {
  final IChatRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> execute(String roomId) {
    return repository.getMessagesStream(roomId);
  }
}
