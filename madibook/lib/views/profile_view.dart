import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/skill_model.dart';
import '../view_models/app_state.dart';
import '../view_models/quiz_controller.dart';
import '../core/auth_service.dart';
import '../widgets/credit_wallet.dart';
import 'profile_editor_view.dart';
import 'ai_chat_view.dart';

/// Profile View — user identity, Nexus-Credit wallet, achievements, skill lists.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, QuizController>(
      builder: (context, appState, quiz, _) {
        final user = appState.currentUser;
        if (user == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                pinned: true,
                backgroundColor: MadiColors.scaffoldDark,
                title: Text('My Profile',
                    style: Theme.of(context).textTheme.headlineSmall),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Edit Profile',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfileEditorView()),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildProfileCard(context, user),
                      const SizedBox(height: MadiSpacing.lg),
                      CreditWallet(balance: user.madiCredits),
                      const SizedBox(height: MadiSpacing.lg),

                      // AI Mentor quick access
                      _buildAiMentorCard(context),
                      const SizedBox(height: MadiSpacing.lg),

                      _buildStatsRow(context, user, quiz),
                      const SizedBox(height: MadiSpacing.xl),

                      // Achievements
                      _buildAchievements(context),
                      const SizedBox(height: MadiSpacing.xl),

                      _buildSkillSection(context,
                          title: 'Skills I Offer',
                          icon: Icons.lightbulb_rounded,
                          iconColor: MadiColors.emerald,
                          skills: user.offerings),
                      const SizedBox(height: MadiSpacing.lg),
                      _buildSkillSection(context,
                          title: 'Skills I Want to Learn',
                          icon: Icons.search_rounded,
                          iconColor: MadiColors.amber,
                          skills: user.seekings),
                      const SizedBox(height: MadiSpacing.lg),

                      // Sign out button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.read<AuthService>().signOut();
                          },
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MadiColors.rose,
                            side: BorderSide(
                                color: MadiColors.rose.withValues(alpha: 0.3)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 120),
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

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(MadiSpacing.lg),
      decoration: BoxDecoration(
        color: MadiColors.cardDark,
        borderRadius: BorderRadius.circular(MadiRadius.xl),
        border: Border.all(color: MadiColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [MadiColors.gold, MadiColors.goldDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: MadiColors.gold.withValues(alpha: 0.25),
                  blurRadius: 16, offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(user.initials,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 26)),
            ),
          ),
          const SizedBox(width: MadiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: Theme.of(context).textTheme.headlineMedium),
                if (user.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: MadiColors.textMuted),
                    const SizedBox(width: 4),
                    Text(user.location,
                        style: Theme.of(context).textTheme.labelMedium),
                  ]),
                ],
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(user.bio,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMentorCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(MadiRadius.lg),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiChatView()),
        ),
        child: Container(
          padding: const EdgeInsets.all(MadiSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MadiColors.gold.withValues(alpha: 0.08),
                MadiColors.indigo.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(MadiRadius.lg),
            border: Border.all(
                color: MadiColors.gold.withValues(alpha: 0.2)),
          ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [MadiColors.gold, MadiColors.goldDark],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_awesome, size: 22, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: MadiSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Mentor',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          'AI-powered tutor for Math, Physics & more',
                          style: TextStyle(
                              color: MadiColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: MadiColors.gold),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, dynamic user, QuizController quiz) {
    return Row(children: [
      _stat(context, Icons.school_rounded, 'Teaching',
          '${user.offerings.length}', MadiColors.emerald),
      const SizedBox(width: MadiSpacing.md),
      _stat(context, Icons.auto_stories_rounded, 'Learning',
          '${user.seekings.length}', MadiColors.indigo),
      const SizedBox(width: MadiSpacing.md),
      _stat(context, Icons.bolt_rounded, 'Total XP',
          '${quiz.totalXp}', MadiColors.gold),
    ]);
  }

  Widget _stat(BuildContext context, IconData icon, String label,
      String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(MadiSpacing.md),
        decoration: BoxDecoration(
          color: MadiColors.cardDark,
          borderRadius: BorderRadius.circular(MadiRadius.lg),
          border: Border.all(color: MadiColors.border, width: 0.5),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: MadiColors.textPrimary,
                  fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme.labelMedium?.copyWith(fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    // Demo achievements for the profile view.
    final achievements = [
      ('WorldSkills Winner', Icons.emoji_events_rounded, MadiColors.gold),
      ('FPV Pilot — Freestyle', Icons.flight_rounded, MadiColors.sky),
      ('Robotics Olympiad — 1st', Icons.smart_toy_rounded, MadiColors.emerald),
      ('CTF Hacker', Icons.security_rounded, MadiColors.rose),
      ('Nexus Lead Dev', Icons.code_rounded, MadiColors.indigo),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.emoji_events_rounded, color: MadiColors.gold, size: 20),
          const SizedBox(width: 8),
          Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
        ]),
        const SizedBox(height: MadiSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: achievements.map((a) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: a.$3.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(MadiRadius.full),
                border: Border.all(color: a.$3.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(a.$2, size: 14, color: a.$3),
                  const SizedBox(width: 6),
                  Text(a.$1,
                      style: TextStyle(
                          color: a.$3,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillSection(BuildContext context,
      {required String title,
      required IconData icon,
      required Color iconColor,
      required List<Skill> skills}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ]),
        const SizedBox(height: MadiSpacing.md),
        if (skills.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MadiSpacing.lg),
            decoration: BoxDecoration(
              color: MadiColors.cardDark,
              borderRadius: BorderRadius.circular(MadiRadius.lg),
              border: Border.all(color: MadiColors.border, width: 0.5),
            ),
            child: Column(children: [
              Icon(Icons.add_circle_outline_rounded,
                  color: MadiColors.textMuted, size: 32),
              const SizedBox(height: 8),
              Text('Add skills to get started',
                  style: Theme.of(context).textTheme.bodyMedium),
            ]),
          )
        else
          Wrap(
            spacing: 8, runSpacing: 8,
            children: skills.map((skill) {
              final cat = SkillCategories.catalog[skill.category];
              final c = cat?.color ?? MadiColors.indigo;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MadiRadius.full),
                  border: Border.all(color: c.withValues(alpha: 0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(cat?.icon ?? Icons.star_rounded,
                      size: 16, color: c),
                  const SizedBox(width: 8),
                  Text(skill.name,
                      style: TextStyle(
                          color: c,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ]),
              );
            }).toList(),
          ),
      ],
    );
  }
}
