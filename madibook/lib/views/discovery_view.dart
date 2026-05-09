import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../view_models/app_state.dart';
import '../view_models/match_engine.dart';
import '../widgets/skill_card.dart';

/// The Discovery Feed — the main screen of Madibook.
///
/// Shows a curated list of skill matches ranked by relevance.
/// Users can browse cards and tap "Request Swap" to initiate an exchange.
class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  @override
  void initState() {
    super.initState();
    // Run the matching engine after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runMatching();
    });
  }

  void _runMatching() {
    final appState = context.read<AppState>();
    final matchEngine = context.read<MatchEngine>();
    matchEngine.findMatches(
      currentUser: appState.currentUser,
      allUsers: appState.communityUsers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium app bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: MadiColors.scaffoldDark,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16, right: 20),
              title: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [MadiColors.goldShimmer, MadiColors.gold],
                    ).createShader(bounds),
                    child: const Text(
                      'Madibook',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      MadiColors.indigo.withValues(alpha: 0.15),
                      MadiColors.scaffoldDark,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filter',
                onPressed: () => _showFilterSheet(context),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Consumer<MatchEngine>(
                builder: (context, engine, _) {
                  final perfectCount =
                      engine.matches.where((m) => m.isPerfectMatch).length;
                  return Row(
                    children: [
                      Text(
                        'Discover Skills',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      if (perfectCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: MadiColors.gold.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(MadiRadius.full),
                            border: Border.all(
                              color: MadiColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 14, color: MadiColors.gold),
                              const SizedBox(width: 4),
                              Text(
                                '$perfectCount Perfect',
                                style: const TextStyle(
                                  color: MadiColors.gold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Seeking chips — what the current user wants to learn
          SliverToBoxAdapter(
            child: Consumer<AppState>(
              builder: (context, appState, _) {
                final seekings = appState.currentUser.seekings;
                if (seekings.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Looking to learn:',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: MadiColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: seekings.map((skill) {
                          final catData =
                              SkillCategories.catalog[skill.category];
                          final color =
                              catData?.color ?? MadiColors.indigo;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(MadiRadius.full),
                              border: Border.all(
                                  color: color.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                    catData?.icon ?? Icons.star_rounded,
                                    size: 14,
                                    color: color),
                                const SizedBox(width: 6),
                                Text(
                                  skill.name,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Match results list
          Consumer<MatchEngine>(
            builder: (context, engine, _) {
              if (engine.isSearching) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: MadiColors.gold),
                        SizedBox(height: 16),
                        Text('Finding your matches...',
                            style: TextStyle(color: MadiColors.textMuted)),
                      ],
                    ),
                  ),
                );
              }

              if (engine.matches.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.explore_outlined,
                            size: 64,
                            color: MadiColors.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No matches yet',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: MadiColors.textMuted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add more skills to your profile\nto discover people to swap with.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final match = engine.matches[index];
                      return SkillCard(
                        matchResult: match,
                        onRequestSwap: () =>
                            _showSwapDialog(context, match),
                      );
                    },
                    childCount: engine.matches.length,
                  ),
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  void _showSwapDialog(BuildContext context, MatchResult match) {
    final appState = context.read<AppState>();
    final currentUser = appState.currentUser;

    // Pick the first matched skill for the request
    final skillRequested = match.matchedSkills.first.name;
    final skillOffered = currentUser.offerings.isNotEmpty
        ? currentUser.offerings.first.name
        : 'General Knowledge';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: MadiColors.surfaceDark,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MadiRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MadiColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Request Swap',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Exchange skills with ${match.user.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Exchange preview
            Container(
              padding: const EdgeInsets.all(MadiSpacing.md),
              decoration: BoxDecoration(
                color: MadiColors.cardDark,
                borderRadius: BorderRadius.circular(MadiRadius.lg),
                border:
                    Border.all(color: MadiColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('YOU TEACH',
                            style: TextStyle(
                                color: MadiColors.emerald,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                        const SizedBox(height: 6),
                        Text(skillOffered,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge,
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: MadiColors.gold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_horiz_rounded,
                        color: MadiColors.gold, size: 24),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('YOU LEARN',
                            style: TextStyle(
                                color: MadiColors.amber,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                        const SizedBox(height: 6),
                        Text(skillRequested,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge,
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Credit info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MadiColors.gold.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(MadiRadius.md),
                border: Border.all(
                    color: MadiColors.gold.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: MadiColors.gold, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'When completed: you earn 1 MC for teaching, spend 1 MC for learning.',
                      style: TextStyle(
                        color: MadiColors.goldLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      appState.sendSwapRequest(
                        receiverId: match.user.id,
                        skillRequested: skillRequested,
                        skillOffered: skillOffered,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: MadiColors.emerald, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                  'Swap request sent to ${match.user.name}!'),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send Request'),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: MadiColors.surfaceDark,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MadiRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: MadiColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Filter by Category',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SkillCategories.catalog.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.key),
                  avatar: Icon(entry.value.icon,
                      size: 16, color: entry.value.color),
                  selected: false,
                  onSelected: (_) {
                    // TODO: Implement category filtering
                    Navigator.pop(ctx);
                  },
                  backgroundColor: MadiColors.cardDark,
                  selectedColor: entry.value.color.withValues(alpha: 0.2),
                  side: BorderSide(
                      color: entry.value.color.withValues(alpha: 0.3)),
                  labelStyle: TextStyle(color: MadiColors.textPrimary),
                );
              }).toList(),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
