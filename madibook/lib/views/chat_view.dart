import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/auth_service.dart';
import '../view_models/chat_controller.dart';
import '../view_models/app_state.dart';
import '../widgets/message_bubble.dart';

/// Chat View — thread list + individual conversation.
class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chat, _) {
        if (chat.activeThreadId != null) {
          return _ConversationScreen(
            threadId: chat.activeThreadId!,
          );
        }
        return _ThreadListScreen();
      },
    );
  }
}

/// Thread list showing all conversations.
class _ThreadListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatController>();
    final auth = context.watch<AuthService>();
    final appState = context.watch<AppState>();
    final myId = auth.currentUser?.id ?? '';

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            backgroundColor: MadiColors.scaffoldDark,
            title: Text('Messages',
                style: Theme.of(context).textTheme.headlineSmall),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _showNewChatSheet(context, appState, chat, auth),
              ),
              const SizedBox(width: 8),
            ],
          ),
          if (chat.threads.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 64,
                        color: MadiColors.textMuted.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text('No conversations yet',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: MadiColors.textMuted)),
                    const SizedBox(height: 8),
                    Text(
                      'Start a chat from the Discover feed\nor tap the compose button above.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final thread = chat.threads[index];
                  final otherName = thread.otherName(myId);
                  final initials = thread.otherInitials(myId);
                  final lastMsg = thread.lastMessage;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [MadiColors.indigo, MadiColors.indigoLight],
                        ),
                      ),
                      child: Center(
                        child: Text(initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                      ),
                    ),
                    title: Text(otherName,
                        style: Theme.of(context).textTheme.titleMedium),
                    subtitle: lastMsg != null
                        ? Text(
                            lastMsg.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        : Text('Start chatting',
                            style: TextStyle(color: MadiColors.textMuted)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (lastMsg != null)
                          Text(
                            DateFormat.Hm().format(lastMsg.timestamp),
                            style: TextStyle(
                                color: MadiColors.textMuted, fontSize: 11),
                          ),
                        if (thread.unreadCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: MadiColors.gold,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${thread.unreadCount}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () => chat.openThread(thread.id, myId),
                  );
                },
                childCount: chat.threads.length,
              ),
            ),
        ],
      ),
    );
  }

  void _showNewChatSheet(BuildContext context, AppState appState,
      ChatController chat, AuthService auth) {
    final users = appState.communityUsers;
    final myId = auth.currentUser?.id ?? '';
    final myName = auth.currentUser?.name ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: MadiColors.surfaceDark,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(MadiRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: MadiColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('New Conversation',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...users.map((user) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: MadiColors.indigo,
                    child: Text(user.initials,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  title: Text(user.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(user.location,
                      style: Theme.of(context).textTheme.labelMedium),
                  onTap: () {
                    chat.startConversation(
                      myId: myId,
                      myName: myName,
                      otherId: user.id,
                      otherName: user.name,
                    );
                    Navigator.pop(ctx);
                  },
                )),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}

/// Individual conversation screen.
class _ConversationScreen extends StatefulWidget {
  final String threadId;
  const _ConversationScreen({required this.threadId});

  @override
  State<_ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<_ConversationScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatController>();
    final auth = context.watch<AuthService>();
    final myId = auth.currentUser?.id ?? '';
    final messages = chat.activeMessages;

    // Find thread to get other user's name.
    final thread =
        chat.threads.where((t) => t.id == widget.threadId).firstOrNull;
    final otherName = thread?.otherName(myId) ?? 'Chat';
    final otherId = thread?.otherId(myId) ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MadiColors.scaffoldDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => chat.closeThread(),
        ),
        title: Text(otherName,
            style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text('Say hello! 👋',
                        style: TextStyle(color: MadiColors.textMuted)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return MessageBubble(
                        content: msg.content,
                        time: DateFormat.Hm().format(msg.timestamp),
                        isMine: msg.senderId == myId,
                        isRead: msg.isRead,
                      );
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 8, 8, MediaQuery.of(context).padding.bottom + 8),
            decoration: const BoxDecoration(
              color: MadiColors.surfaceDark,
              border: Border(
                top: BorderSide(color: MadiColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style:
                        const TextStyle(color: MadiColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle:
                          TextStyle(color: MadiColors.textMuted),
                      filled: true,
                      fillColor: MadiColors.cardDark,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(MadiRadius.full),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: MadiColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.black, size: 20),
                    onPressed: () {
                      if (_msgController.text.trim().isEmpty) return;
                      chat.sendMessage(
                        senderId: myId,
                        receiverId: otherId,
                        content: _msgController.text,
                      );
                      _msgController.clear();
                      // Scroll to bottom.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
