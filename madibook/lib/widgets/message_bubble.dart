import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Chat message bubble with sent/received styling.
class MessageBubble extends StatelessWidget {
  final String content;
  final String time;
  final bool isMine;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.content,
    required this.time,
    required this.isMine,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isMine ? 48 : 0,
          right: isMine ? 0 : 48,
          bottom: 6,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? MadiColors.indigo.withValues(alpha: 0.2)
              : MadiColors.cardDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: Border.all(
            color: isMine
                ? MadiColors.indigo.withValues(alpha: 0.3)
                : MadiColors.border,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: const TextStyle(
                color: MadiColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: MadiColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: isRead ? MadiColors.indigo : MadiColors.textMuted,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
