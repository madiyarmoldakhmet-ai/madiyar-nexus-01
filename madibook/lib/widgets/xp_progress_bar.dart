import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Animated XP progress bar with level indicator.
class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int maxXp;
  final String label;
  final Color color;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.maxXp,
    this.label = 'XP',
    this.color = MadiColors.indigo,
  });

  double get _progress => maxXp > 0 ? (currentXp / maxXp).clamp(0.0, 1.0) : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: MadiColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$currentXp / $maxXp XP',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: MadiColors.scaffoldDark,
            borderRadius: BorderRadius.circular(MadiRadius.full),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * _progress,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(MadiRadius.full),
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
