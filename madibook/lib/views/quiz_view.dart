import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../view_models/quiz_controller.dart';
import '../widgets/quiz_card.dart';
import '../widgets/xp_progress_bar.dart';

/// Full-screen quiz experience with progress bar and results.
class QuizView extends StatelessWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizController>(
      builder: (context, quiz, _) {
        if (quiz.activeTrack == null) {
          return const Scaffold(
            body: Center(child: Text('No active quiz.')),
          );
        }

        if (quiz.isSessionComplete) {
          return _buildResultsScreen(context, quiz);
        }

        return _buildQuizScreen(context, quiz);
      },
    );
  }

  Widget _buildQuizScreen(BuildContext context, QuizController quiz) {
    final question = quiz.currentQuestion!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MadiColors.scaffoldDark,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            quiz.endSession();
            Navigator.pop(context);
          },
        ),
        title: Text(quiz.activeTrack!.title,
            style: Theme.of(context).textTheme.titleMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: quiz.progress,
                backgroundColor: MadiColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(MadiColors.gold),
                minHeight: 6,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            QuizCard(
              question: question,
              questionNumber: quiz.currentIndex + 1,
              totalQuestions: quiz.activeTrack!.totalQuestions,
              selectedOption: quiz.selectedOption,
              hasAnswered: quiz.hasAnswered,
              onSelectOption: (index) => quiz.submitAnswer(index),
            ),
            const SizedBox(height: MadiSpacing.xl),

            // Action button
            if (quiz.hasAnswered)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    quiz.nextQuestion();
                    if (quiz.isSessionComplete) {
                      // Stay on this screen, it will show results
                    }
                  },
                  child: Text(
                    quiz.currentIndex + 1 >= quiz.activeTrack!.totalQuestions
                        ? 'See Results'
                        : 'Next Question',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              )
            else if (quiz.selectedOption == null)
              Text(
                'Select an answer above',
                style: TextStyle(color: MadiColors.textMuted, fontSize: 14),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context, QuizController quiz) {
    final score = quiz.correctAnswers;
    final total = quiz.activeTrack!.totalQuestions;
    final percentage = (score / total * 100).round();
    final isPassing = percentage >= 60;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Result icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isPassing ? MadiColors.gold : MadiColors.rose)
                        .withValues(alpha: 0.1),
                    border: Border.all(
                      color: (isPassing ? MadiColors.gold : MadiColors.rose)
                          .withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    isPassing
                        ? Icons.emoji_events_rounded
                        : Icons.refresh_rounded,
                    size: 48,
                    color: isPassing ? MadiColors.gold : MadiColors.rose,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  isPassing ? 'Well Done!' : 'Keep Practicing!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  '$score out of $total correct ($percentage%)',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: 32),

                // XP and Credits earned
                Container(
                  padding: const EdgeInsets.all(MadiSpacing.lg),
                  decoration: BoxDecoration(
                    color: MadiColors.cardDark,
                    borderRadius: BorderRadius.circular(MadiRadius.xl),
                    border:
                        Border.all(color: MadiColors.border, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _resultStat(
                            icon: Icons.bolt_rounded,
                            label: 'XP Earned',
                            value: '+${quiz.sessionXp}',
                            color: MadiColors.indigo,
                          ),
                          Container(
                              width: 1,
                              height: 40,
                              color: MadiColors.border),
                          _resultStat(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Credits',
                            value: '+${quiz.sessionCreditsEarned} NC',
                            color: MadiColors.gold,
                          ),
                        ],
                      ),
                      const SizedBox(height: MadiSpacing.md),
                      XpProgressBar(
                        currentXp: quiz.sessionXp,
                        maxXp: quiz.activeTrack!.maxXp,
                        label: 'Session Progress',
                        color: MadiColors.emerald,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Actions
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      quiz.endSession();
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Academy',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: MadiColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
