import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../models/journey_model.dart';

/// A premium timeline card for Madi's Journey view.
class TimelineCard extends StatelessWidget {
  final JourneyMilestone milestone;
  final bool isLast;

  const TimelineCard({
    super.key,
    required this.milestone,
    this.isLast = false,
  });

  Color get _categoryColor {
    return switch (milestone.category) {
      'FPV Piloting' => MadiColors.sky,
      'Robotics' => MadiColors.emerald,
      'Hacking' => MadiColors.rose,
      'Nexus' => MadiColors.gold,
      _ => MadiColors.indigo,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;
    final dateStr = DateFormat('MMM yyyy').format(milestone.date);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color.withValues(alpha: 0.5),
                            color.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: MadiSpacing.md),

          // Card content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: MadiSpacing.lg),
              padding: const EdgeInsets.all(MadiSpacing.md),
              decoration: BoxDecoration(
                color: MadiColors.cardDark,
                borderRadius: BorderRadius.circular(MadiRadius.lg),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: category + date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(MadiRadius.full),
                          border: Border.all(
                              color: color.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(milestone.icon, size: 12, color: color),
                            const SizedBox(width: 4),
                            Text(
                              milestone.category,
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateStr,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),

                  const SizedBox(height: MadiSpacing.md),

                  // Title
                  Text(
                    milestone.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: MadiSpacing.sm),

                  // Description
                  Text(
                    milestone.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  // Tags
                  if (milestone.tags.isNotEmpty) ...[
                    const SizedBox(height: MadiSpacing.md),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: milestone.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: MadiColors.scaffoldDark,
                            borderRadius:
                                BorderRadius.circular(MadiRadius.full),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              color: MadiColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
