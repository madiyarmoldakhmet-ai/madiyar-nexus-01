import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../domain/entities/message_entity.dart';
import 'chat_view_model.dart';
import '../calls/call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String receiverName;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.receiverName,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final String _currentUserId = 'user-madi'; // Mock current user ID

  @override
  void initState() {
    super.initState();
    // Initialize stream when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().initRoom(widget.roomId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MadiColors.scaffoldDark,
        title: Text(widget.receiverName),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallScreen(
                    channelName: widget.roomId,
                    isBroadcaster: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.messagesStream == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return StreamBuilder<List<MessageEntity>>(
                  stream: viewModel.messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading messages'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No messages yet. Say hi!'));
                    }

                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse: true, // Show latest messages at bottom
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == _currentUserId;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? MadiColors.indigo : MadiColors.cardDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              msg.content,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Input Bar
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: MadiColors.surfaceDark,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: MadiColors.gold),
            onPressed: () {
              context.read<ChatViewModel>().sendMessage(
                widget.roomId,
                _currentUserId,
                widget.receiverId,
                _messageController.text,
              );
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}
