import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../core/auth_service.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import 'user_search_screen.dart';
import '../views/call_screen.dart';
import '../widgets/anime_background.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    final senderId = user?.id ?? 'anonymous';
    final senderName = user?.name ?? 'User';
    final senderRole = user?.role.name ?? 'talent';

    _msgController.clear();

    await FirebaseFirestore.instance.collection('messages').add({
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final myId = auth.currentUser?.id ?? 'anonymous';

    return AnimeBackground(
      assetPath: 'assets/images/backgrounds/bg_chat.png',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Global Chat',
            style: GoogleFonts.oswald(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded, color: MadiColors.bloodRed),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserSearchScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.videocam_rounded, color: MadiColors.bloodRed),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallScreen(
                      channelId: 'global_chat', // Temporary channel ID
                      remoteUserName: 'Nexus Community',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: MadiColors.textMuted)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Start chatting!',
                      style: TextStyle(color: MadiColors.textMuted),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Keep the latest messages at the bottom
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final message = Message.fromJson(data);

                    // For messages just sent locally, timestamp might be null
                    DateTime dateTime = message.timestamp.toDate();
                    final timeString = DateFormat.Hm().format(dateTime);

                    return MessageBubble(
                      content: message.text,
                      time: timeString,
                      isMine: message.senderId == myId,
                      senderName: message.senderName,
                      senderRole: message.senderRole,
                    );
                  },
                );
              },
            ),
          ),
          
          // Input Area
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
                    style: const TextStyle(color: MadiColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: MadiColors.textMuted),
                      filled: true,
                      fillColor: MadiColors.cardDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MadiRadius.full),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
