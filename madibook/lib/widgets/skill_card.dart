import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';
import '../view_models/match_engine.dart';

/// A premium skill card for the Discovery Feed.
///
/// Displays user info, matched skills with category badges,
/// a match quality indicator, and a "Request Swap" action button.
/// Uses a glassmorphism-inspired dark card with subtle gradient border.
class SkillCard extends StatefulWidget {
  final MatchResult matchResult;
  final VoidCallback onRequestSwap;

  const SkillCard({
    super.key,
    required this.matchResult,
    required this.onRequestSwap,
  });

  @override
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.matchResult.user;
    final matchedSkills = widget.matchResult.matchedSkills;
    final score = widget.matchResult.score;
    final isPerfect = widget.matchResult.isPerfectMatch;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: MadiSpacing.md),
            decoration: BoxDecoration(
              color: _isHovered
                  ? MadiColors.cardDark.withValues(alpha: 0.95)
                  : MadiColors.cardDark,
              borderRadius: BorderRadius.circular(MadiRadius.xl),
              border: Border.all(
                color: isPerfect
                    ? MadiColors.gold.withValues(alpha: 0.4)
                    : MadiColors.border,
                width: isPerfect ? 1.5 : 0.5,
              ),
              boxShadow: _isHovered ? MadiShadows.card : MadiShadows.subtle,
            ),
            child: Stack(
              children: [
                // Subtle gradient overlay for depth
                if (isPerfect)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(MadiRadius.xl),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            MadiColors.gold.withValues(alpha: 0.04),
                            Colors.transparent,
                            MadiColors.indigo.withValues(alpha: 0.03),
                          ],
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(MadiSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Avatar + User info + Match badge
                      Row(
                        children: [
                          _buildAvatar(user),
                          const SizedBox(width: MadiSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isPerfect) ...[
                                      const SizedBox(width: MadiSpacing.sm),
                                      _buildPerfectMatchBadge(),
                                    ],
                                    const SizedBox(width: MadiSpacing.sm),
                                    _buildRoleBadge(user),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: MadiColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      user.location.isNotEmpty
                                          ? user.location
                                          : 'Worldwide',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildScoreIndicator(score),
                        ],
                      ),

                      const SizedBox(height: MadiSpacing.md),

                      // Bio
                      if (user.bio.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: MadiSpacing.md),
                          child: Text(
                            user.bio,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Matched skill badges
                      Wrap(
                        spacing: MadiSpacing.sm,
                        runSpacing: MadiSpacing.sm,
                        children: matchedSkills
                            .map((skill) => _buildSkillBadge(context, skill))
                            .toList(),
                      ),

                      const SizedBox(height: MadiSpacing.lg),

                      // Action row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${matchedSkills.length} skill${matchedSkills.length != 1 ? 's' : ''} match your interests',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: MadiColors.textMuted),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: widget.onRequestSwap,
                            icon: const Icon(Icons.swap_horiz_rounded,
                                size: 18),
                            label: const Text('Request Swap'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(NexusUser user) {
    Color statusColor;
    IconData statusIcon;
    
    switch (user.relationshipStatus) {
      case 'in_relationship':
        statusColor = MadiColors.bloodRed;
        statusIcon = Icons.favorite_rounded;
        break;
      case 'complicated':
        statusColor = MadiColors.indigo;
        statusIcon = Icons.heart_broken_rounded;
        break;
      case 'single':
      default:
        statusColor = MadiColors.gold;
        statusIcon = Icons.favorite_outline_rounded;
        break;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [MadiColors.indigo, MadiColors.indigoLight],
            ),
            boxShadow: [
              BoxShadow(
                color: MadiColors.indigo.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              user.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: MadiColors.cardDark,
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(statusIcon, size: 10, color: statusColor),
          ),
        ),
      ],
    );
  }

  Widget _buildPerfectMatchBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MadiColors.gold, MadiColors.goldDark],
        ),
        borderRadius: BorderRadius.circular(MadiRadius.full),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: Colors.black),
          SizedBox(width: 3),
          Text(
            'PERFECT',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(double score) {
    final percentage = (score * 100).round();
    final color = score >= 0.8
        ? MadiColors.gold
        : score >= 0.5
            ? MadiColors.emerald
            : MadiColors.textMuted;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Center(
        child: Text(
          '$percentage%',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(NexusUser user) {
    final color = user.role == UserRole.expert
        ? Colors.purpleAccent
        : user.role == UserRole.mentor
            ? MadiColors.emerald
            : MadiColors.indigo;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MadiRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        user.role.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSkillBadge(BuildContext context, Skill skill) {
    final categoryData = SkillCategories.catalog[skill.category];
    final color = categoryData?.color ?? MadiColors.indigo;
    final icon = categoryData?.icon ?? Icons.star_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(MadiRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
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
  }
}
