import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/quiz_model.dart';

/// A quiz question card with animated option buttons and feedback.
class QuizCard extends StatelessWidget {
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedOption;
  final bool hasAnswered;
  final ValueChanged<int> onSelectOption;

  const QuizCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedOption,
    required this.hasAnswered,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question number badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: MadiColors.indigo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MadiRadius.full),
            border: Border.all(color: MadiColors.indigo.withValues(alpha: 0.25)),
          ),
          child: Text(
            'Question $questionNumber of $totalQuestions',
            style: TextStyle(
              color: MadiColors.indigo,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: MadiSpacing.lg),

        // Question text
        Text(
          question.question,
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: MadiSpacing.xl),

        // Options
        ...List.generate(question.options.length, (index) {
          final isSelected = selectedOption == index;
          final isCorrect = question.correctIndex == index;
          final showResult = hasAnswered;

          Color bgColor = MadiColors.cardDark;
          Color borderColor = MadiColors.border;
          Color textColor = MadiColors.textPrimary;
          IconData? trailingIcon;

          if (showResult && isCorrect) {
            bgColor = MadiColors.emerald.withValues(alpha: 0.1);
            borderColor = MadiColors.emerald;
            textColor = MadiColors.emerald;
            trailingIcon = Icons.check_circle_rounded;
          } else if (showResult && isSelected && !isCorrect) {
            bgColor = MadiColors.rose.withValues(alpha: 0.1);
            borderColor = MadiColors.rose;
            textColor = MadiColors.rose;
            trailingIcon = Icons.cancel_rounded;
          } else if (isSelected && !showResult) {
            bgColor = MadiColors.gold.withValues(alpha: 0.1);
            borderColor = MadiColors.gold;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: MadiSpacing.sm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasAnswered ? null : () => onSelectOption(index),
                borderRadius: BorderRadius.circular(MadiRadius.md),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(MadiSpacing.md),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(MadiRadius.md),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      // Option letter
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? borderColor.withValues(alpha: 0.2)
                              : MadiColors.scaffoldDark,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              color: isSelected ? borderColor : MadiColors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: MadiSpacing.md),
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (trailingIcon != null)
                        Icon(trailingIcon, color: borderColor, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        // Explanation
        if (hasAnswered && question.explanation != null) ...[
          const SizedBox(height: MadiSpacing.md),
          Container(
            padding: const EdgeInsets.all(MadiSpacing.md),
            decoration: BoxDecoration(
              color: MadiColors.indigo.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(MadiRadius.md),
              border: Border.all(color: MadiColors.indigo.withValues(alpha: 0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: MadiColors.indigo, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question.explanation!,
                    style: TextStyle(
                      color: MadiColors.indigoLight,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
