import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/swap_request_model.dart';

/// Displays a swap request as a card in the Swaps tab.
class SwapRequestCard extends StatelessWidget {
  final SwapRequest request;
  final String otherUserName;
  final bool isIncoming;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const SwapRequestCard({
    super.key,
    required this.request,
    required this.otherUserName,
    required this.isIncoming,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: MadiSpacing.md),
      padding: const EdgeInsets.all(MadiSpacing.md),
      decoration: BoxDecoration(
        color: MadiColors.cardDark,
        borderRadius: BorderRadius.circular(MadiRadius.lg),
        border: Border.all(color: MadiColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                isIncoming
                    ? Icons.call_received_rounded
                    : Icons.call_made_rounded,
                color: isIncoming ? MadiColors.emerald : MadiColors.indigo,
                size: 18,
              ),
              const SizedBox(width: MadiSpacing.sm),
              Expanded(
                child: Text(
                  isIncoming
                      ? '$otherUserName wants to swap with you'
                      : 'You requested a swap with $otherUserName',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _buildStatusBadge(context),
            ],
          ),

          const SizedBox(height: MadiSpacing.md),

          // Skill exchange visualization
          Container(
            padding: const EdgeInsets.all(MadiSpacing.md),
            decoration: BoxDecoration(
              color: MadiColors.scaffoldDark,
              borderRadius: BorderRadius.circular(MadiRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'TEACHES',
                        style: TextStyle(
                          color: MadiColors.emerald,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.skillOffered,
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MadiColors.gold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: MadiColors.gold,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'LEARNS',
                        style: TextStyle(
                          color: MadiColors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.skillRequested,
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons for incoming pending requests
          if (isIncoming && request.isPending) ...[
            const SizedBox(height: MadiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDecline,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MadiColors.rose,
                      side: BorderSide(
                          color: MadiColors.rose.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(width: MadiSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MadiColors.emerald,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final (String label, Color color) = switch (request.status) {
      SwapStatus.pending => ('Pending', MadiColors.amber),
      SwapStatus.accepted => ('Accepted', MadiColors.emerald),
      SwapStatus.declined => ('Declined', MadiColors.rose),
      SwapStatus.completed => ('Completed', MadiColors.gold),
      SwapStatus.cancelled => ('Cancelled', MadiColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MadiRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
