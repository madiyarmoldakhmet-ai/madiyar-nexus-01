import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/ai_chat_service.dart';
import '../view_models/ai_chat_controller.dart';

/// AI Mentor Chat View — a premium chat interface with Madi Mentor.
class AiChatView extends StatefulWidget {
  const AiChatView({super.key});

  @override
  State<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<AiChatView> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiChatController>(
      builder: (context, ai, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: MadiColors.scaffoldDark,
            title: Row(
              children: [
                // AI avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [MadiColors.gold, MadiColors.goldDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MadiColors.gold.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome, size: 18, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Madi Mentor',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      ai.isTyping ? 'typing...' : 'AI Learning Assistant',
                      style: TextStyle(
                        color: ai.isTyping
                            ? MadiColors.emerald
                            : MadiColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              if (ai.messages.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: () => ai.clearChat(),
                  tooltip: 'Clear chat',
                ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              // Messages
              Expanded(
                child: ai.messages.isEmpty
                    ? _buildWelcomeScreen(context)
                    : _buildMessageList(context, ai),
              ),

              // Input bar
              _buildInputBar(context, ai),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // AI icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [MadiColors.gold, MadiColors.goldDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: MadiColors.gold.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome, size: 36, color: Colors.black),
            ),
          ),

          const SizedBox(height: 24),

          Text('Madi Mentor',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Your AI-powered learning assistant.\nAsk me anything about Math, Physics, English, or FPV!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 32),

          // Suggested prompts
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _promptChip('Explain Newton\'s 2nd Law', Icons.science_rounded),
              _promptChip('Solve: 2x + 5 = 15', Icons.calculate_rounded),
              _promptChip('Help with English grammar', Icons.translate_rounded),
              _promptChip('How to build an FPV drone?', Icons.flight_rounded),
              _promptChip('How do Nexus-Credits work?', Icons.account_balance_wallet_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _promptChip(String text, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: MadiColors.gold),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: MadiColors.cardDark,
      side: BorderSide(color: MadiColors.gold.withValues(alpha: 0.2)),
      labelStyle: const TextStyle(color: MadiColors.textPrimary),
      onPressed: () {
        _inputController.text = text;
        _sendMessage();
      },
    );
  }

  Widget _buildMessageList(BuildContext context, AiChatController ai) {
    _scrollToBottom();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: ai.messages.length + (ai.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // Typing indicator
        if (index == ai.messages.length && ai.isTyping) {
          return _buildTypingIndicator();
        }

        final msg = ai.messages[index];
        return _buildBubble(context, msg);
      },
    );
  }

  Widget _buildBubble(BuildContext context, AiMessage msg) {
    final time = DateFormat.Hm().format(msg.timestamp);

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: EdgeInsets.only(
          left: msg.isUser ? 40 : 0,
          right: msg.isUser ? 0 : 40,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment:
              msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Avatar + name for AI messages
            if (!msg.isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [MadiColors.gold, MadiColors.goldDark],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_awesome,
                            size: 10, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Madi Mentor',
                        style: TextStyle(
                            color: MadiColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

            // Bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? MadiColors.indigo.withValues(alpha: 0.2)
                    : MadiColors.cardDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: msg.isUser
                      ? MadiColors.indigo.withValues(alpha: 0.3)
                      : MadiColors.border,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: msg.isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.content,
                    style: const TextStyle(
                      color: MadiColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(time,
                      style:
                          TextStyle(color: MadiColors.textMuted, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: MadiColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MadiColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600 + (i * 200)),
              builder: (context, value, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MadiColors.gold
                        .withValues(alpha: 0.3 + (value * 0.5)),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, AiChatController ai) {
    return Container(
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
              controller: _inputController,
              style: const TextStyle(color: MadiColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ask Madi Mentor anything...',
                hintStyle: TextStyle(color: MadiColors.textMuted),
                filled: true,
                fillColor: MadiColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MadiRadius.full),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [MadiColors.gold, MadiColors.goldDark],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: MadiColors.gold.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
              onPressed: ai.isTyping ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    context.read<AiChatController>().sendMessage(text);
  }
}
