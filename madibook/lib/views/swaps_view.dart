import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../view_models/app_state.dart';
import '../widgets/swap_request_card.dart';

/// Swaps View — shows incoming and outgoing swap requests.
class SwapsView extends StatelessWidget {
  const SwapsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final incoming = appState.incomingRequests;
        final outgoing = appState.outgoingRequests;
        final hasAny = incoming.isNotEmpty || outgoing.isNotEmpty;

        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                pinned: true,
                backgroundColor: MadiColors.scaffoldDark,
                title: Text('My Swaps',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              if (!hasAny)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.swap_horiz_rounded,
                            size: 64,
                            color: MadiColors.textMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text('No swaps yet',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: MadiColors.textMuted)),
                        const SizedBox(height: 8),
                        Text(
                          'Discover skills and request\nyour first swap!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (incoming.isNotEmpty) ...[
                          _sectionHeader(context, 'Incoming Requests',
                              Icons.call_received_rounded, MadiColors.emerald),
                          const SizedBox(height: 12),
                          ...incoming.map((req) {
                            final sender = appState.communityUsers
                                .where((u) => u.id == req.requesterId);
                            final name = sender.isNotEmpty
                                ? sender.first.name
                                : 'Unknown';
                            return SwapRequestCard(
                              request: req,
                              otherUserName: name,
                              isIncoming: true,
                              onAccept: () =>
                                  appState.acceptSwapRequest(req.id),
                              onDecline: () =>
                                  appState.declineSwapRequest(req.id),
                            );
                          }),
                          const SizedBox(height: MadiSpacing.lg),
                        ],
                        if (outgoing.isNotEmpty) ...[
                          _sectionHeader(context, 'Sent Requests',
                              Icons.call_made_rounded, MadiColors.indigo),
                          const SizedBox(height: 12),
                          ...outgoing.map((req) {
                            final receiver = appState.communityUsers
                                .where((u) => u.id == req.receiverId);
                            final name = receiver.isNotEmpty
                                ? receiver.first.name
                                : 'Unknown';
                            return SwapRequestCard(
                              request: req,
                              otherUserName: name,
                              isIncoming: false,
                            );
                          }),
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 8),
      Text(title, style: Theme.of(context).textTheme.titleLarge),
    ]);
  }
}
