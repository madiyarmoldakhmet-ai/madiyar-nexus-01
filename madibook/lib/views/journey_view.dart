import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/journey_model.dart';
import '../widgets/timeline_card.dart';

/// Journey View — Madi's personal project timeline.
class JourneyView extends StatelessWidget {
  const JourneyView({super.key});

  @override
  Widget build(BuildContext context) {
    final milestones = JourneyMilestone.madiJourney;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: MadiColors.scaffoldDark,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16, right: 20),
              title: const Text(
                "Madi's Journey",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: MadiColors.textPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      MadiColors.gold.withValues(alpha: 0.12),
                      MadiColors.scaffoldDark,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Intro
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From FPV racing drones to building the #1 learning platform in Kazakhstan.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),

                  // Category legend
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _legendChip('FPV Piloting', MadiColors.sky),
                      _legendChip('Robotics', MadiColors.emerald),
                      _legendChip('Hacking', MadiColors.rose),
                      _legendChip('Madibook', MadiColors.gold),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Timeline
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return TimelineCard(
                    milestone: milestones[index],
                    isLast: index == milestones.length - 1,
                  );
                },
                childCount: milestones.length,
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Container(
                padding: const EdgeInsets.all(MadiSpacing.lg),
                decoration: BoxDecoration(
                  color: MadiColors.gold.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(MadiRadius.lg),
                  border: Border.all(
                      color: MadiColors.gold.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.rocket_launch_rounded,
                        color: MadiColors.gold, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The journey continues. Every skill shared is a step toward a world where knowledge has no gatekeepers.',
                        style: TextStyle(
                          color: MadiColors.goldLight,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MadiRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
