import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../view_models/quiz_controller.dart';
import '../widgets/xp_progress_bar.dart';
import 'quiz_view.dart';
import '../widgets/anime_background.dart';

/// Academy View — Duolingo-style subject selector with progress.
class AcademyView extends StatelessWidget {
  const AcademyView({super.key});

  static const _subjects = [
    (name: 'Math', icon: Icons.calculate_rounded, color: Color(0xFFF97316)),
    (name: 'Physics', icon: Icons.science_rounded, color: MadiColors.indigo),
    (name: 'English', icon: Icons.translate_rounded, color: MadiColors.emerald),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizController>(
      builder: (context, quiz, _) {
        return AnimeBackground(
          assetPath: 'assets/images/kaneki_v2.jpg',
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                pinned: true,
                backgroundColor: Colors.transparent,
                title: Text('The Academy',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // XP Summary card
                      _buildXpSummary(context, quiz),
                      const SizedBox(height: MadiSpacing.xl),

                      // Subject tracks
                      Text('Learning Tracks',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: MadiSpacing.md),

                      ...QuizController.demoTracks.map((track) {
                        final subjectData = _subjects.firstWhere(
                          (s) => s.name == track.subject,
                          orElse: () => _subjects.first,
                        );
                        final progress =
                            quiz.getSubjectProgress(track.subject);

                        return _buildTrackCard(
                          context,
                          track: track,
                          icon: subjectData.icon,
                          color: subjectData.color,
                          progress: progress,
                          onTap: () {
                            quiz.startQuiz(track);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const QuizView(),
                              ),
                            );
                          },
                        );
                      }),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildXpSummary(BuildContext context, QuizController quiz) {
    return Container(
      padding: const EdgeInsets.all(MadiSpacing.lg),
      decoration: BoxDecoration(
        color: MadiColors.cardDark,
        borderRadius: BorderRadius.circular(MadiRadius.xl),
        border: Border.all(color: MadiColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // XP circle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  MadiColors.indigo,
                  MadiColors.indigoLight,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: MadiColors.indigo.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${quiz.totalXp}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'XP',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: MadiSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Experience',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        size: 14, color: MadiColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      '${quiz.nexusCreditsEarned} Nexus-Credits earned',
                      style: TextStyle(
                        color: MadiColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '10 XP = 1 Nexus-Credit',
                  style: TextStyle(
                    color: MadiColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard(
    BuildContext context, {
    required dynamic track,
    required IconData icon,
    required Color color,
    required dynamic progress,
    required VoidCallback onTap,
  }) {
    final isCompleted = progress?.isCompleted == true;
    final xpEarned = progress?.xpEarned ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: MadiSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MadiRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(MadiSpacing.md),
            decoration: BoxDecoration(
              color: MadiColors.cardDark,
              borderRadius: BorderRadius.circular(MadiRadius.lg),
              border: Border.all(
                color: isCompleted
                    ? color.withValues(alpha: 0.4)
                    : MadiColors.border,
                width: isCompleted ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                // Subject icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(MadiRadius.md),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: MadiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(track.title,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                          ),
                          if (isCompleted)
                            Icon(Icons.check_circle_rounded,
                                color: color, size: 20),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${track.totalQuestions} questions · Difficulty ${track.difficulty}/5',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      if (xpEarned > 0) ...[
                        const SizedBox(height: 8),
                        XpProgressBar(
                          currentXp: xpEarned as int,
                          maxXp: track.maxXp as int,
                          color: color,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: MadiColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
