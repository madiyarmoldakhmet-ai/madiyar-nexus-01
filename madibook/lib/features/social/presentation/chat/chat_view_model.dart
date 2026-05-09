import 'package:flutter/foundation.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/use_cases/send_message_usecase.dart';
import '../../domain/use_cases/get_messages_usecase.dart';

class ChatViewModel extends ChangeNotifier {
  final SendMessageUseCase _sendMessageUseCase;
  final GetMessagesUseCase _getMessagesUseCase;

  Stream<List<MessageEntity>>? messagesStream;
  bool _isLoading = false;
  String? _error;

  ChatViewModel({
    required SendMessageUseCase sendMessageUseCase,
    required GetMessagesUseCase getMessagesUseCase,
  })  : _sendMessageUseCase = sendMessageUseCase,
        _getMessagesUseCase = getMessagesUseCase;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initializes the real-time stream for the chat room.
  void initRoom(String roomId) {
    messagesStream = _getMessagesUseCase.execute(roomId);
    notifyListeners();
  }

  /// Sends a message via the use case.
  Future<void> sendMessage(String roomId, String currentUserId, String receiverId, String text) async {
    if (text.trim().isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _sendMessageUseCase.execute(
      senderId: currentUserId,
      receiverId: receiverId,
      content: text,
      roomId: roomId,
    );

    if (!success) {
      _error = "Failed to send message";
    }

    _isLoading = false;
    notifyListeners();
  }
}
