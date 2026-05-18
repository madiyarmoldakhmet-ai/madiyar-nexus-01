import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../view_models/app_state.dart';
import '../view_models/match_engine.dart';
import '../widgets/skill_card.dart';
import 'project_showcase_view.dart';
import 'package:google_fonts/google_fonts.dart';

/// The Discovery Feed — the main screen of Nexus.
/// Highly optimized for performance and premium aesthetics.
class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  String? _filterStatus;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _runMatching();
  }

  void _runMatching() {
    final appState = Provider.of<AppState>(context, listen: true);
    final matchEngine = context.read<MatchEngine>();
    final user = appState.currentUser;

    if (user != null) {
      matchEngine.findMatches(
        currentUser: user,
        allUsers: appState.communityUsers,
        filterStatus: _filterStatus,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Background is now handled by index.html (GOD MODE)
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: const FlexibleSpaceBar(
                background: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
              title: Text(
                'Nexus',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
              bottom: TabBar(
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 3,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).disabledColor,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 14),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('SHOWCASE'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_alt_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('MENTORS'),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  onPressed: () => _showFilterSheet(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
          body: TabBarView(
            children: [
              ProjectShowcaseView(),
              _buildMentorsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMentorsList() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Consumer<MatchEngine>(
              builder: (context, engine, _) {
                final perfectCount =
                    engine.matches.where((m) => m.isPerfectMatch).length;
                return Row(
                  children: [
                    Text(
                      'Discover Skills',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (perfectCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: MadiColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(MadiRadius.full),
                          border: Border.all(
                            color: MadiColors.gold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: MadiColors.gold, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '$perfectCount PERFECT MATCHES',
                              style: const TextStyle(
                                  color: MadiColors.gold, 
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
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
        Consumer<MatchEngine>(
          builder: (context, engine, _) {
            final matches = engine.matches;
            if (matches.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: MadiColors.bloodRed),
                      SizedBox(height: 16),
                      Text(
                        "Summoning compatible mentors...",
                        style: TextStyle(color: MadiColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SkillCard(
                      matchResult: matches[index],
                      onRequestSwap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Swap request sent to ${matches[index].user.name}!'),
                            backgroundColor: MadiColors.bloodRed,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  childCount: matches.length,
                ),
              ),
            );
          },
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: MadiColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Show Only "Single / Searching"', 
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              subtitle: const Text('Find mentors looking for new connections',
                  style: TextStyle(color: MadiColors.textMuted, fontSize: 12)),
              value: _filterStatus == 'single',
              activeColor: MadiColors.gold,
              onChanged: (val) {
                setState(() {
                  _filterStatus = val ? 'single' : null;
                });
                _runMatching();
                Navigator.pop(ctx);
              },
            ),
            const Divider(color: MadiColors.border, height: 32),
            Text(
              'Filter by Category',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: SkillCategories.catalog.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.key),
                  avatar: Icon(entry.value.icon,
                      size: 16, color: entry.value.color),
                  selected: false,
                  onSelected: (_) {
                    Navigator.pop(ctx);
                  },
                  backgroundColor: MadiColors.cardDark,
                  selectedColor: entry.value.color.withValues(alpha: 0.2),
                  side: BorderSide(
                      color: entry.value.color.withValues(alpha: 0.3)),
                  labelStyle: const TextStyle(color: MadiColors.textPrimary, fontSize: 13),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}
