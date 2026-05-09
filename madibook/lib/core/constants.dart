import 'package:flutter/material.dart';

/// Madibook Design System Constants
/// All design tokens live here for global consistency.
class MadiColors {
  MadiColors._();

  // Primary palette — warm gold + deep indigo
  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFF5E6A3);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldShimmer = Color(0xFFFFD700);

  // Background system
  static const Color scaffoldDark = Color(0xFF0D0D1A);
  static const Color surfaceDark = Color(0xFF161625);
  static const Color cardDark = Color(0xFF1E1E32);
  static const Color cardGlass = Color(0x1AFFFFFF);

  // Accent palette
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoLight = Color(0xFF818CF8);
  static const Color emerald = Color(0xFF10B981);
  static const Color rose = Color(0xFFF43F5E);
  static const Color amber = Color(0xFFF59E0B);
  static const Color sky = Color(0xFF0EA5E9);

  // Text colors
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Border & divider
  static const Color border = Color(0xFF2D2D44);
  static const Color divider = Color(0xFF1E293B);
}

class MadiSpacing {
  MadiSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class MadiRadius {
  MadiRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

class MadiShadows {
  MadiShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: MadiColors.indigo.withValues(alpha: 0.05),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get glow => [
        BoxShadow(
          color: MadiColors.gold.withValues(alpha: 0.3),
          blurRadius: 24,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}

/// Skill categories with their associated colors and icons.
class SkillCategories {
  SkillCategories._();

  static const Map<String, ({Color color, IconData icon})> catalog = {
    'Programming': (color: MadiColors.indigo, icon: Icons.code_rounded),
    'Design': (color: MadiColors.rose, icon: Icons.palette_rounded),
    'Music': (color: MadiColors.amber, icon: Icons.music_note_rounded),
    'Languages': (color: MadiColors.emerald, icon: Icons.translate_rounded),
    'Cooking': (color: Color(0xFFEF4444), icon: Icons.restaurant_rounded),
    'Fitness': (color: Color(0xFF8B5CF6), icon: Icons.fitness_center_rounded),
    'Photography': (color: MadiColors.sky, icon: Icons.camera_alt_rounded),
    'Business': (color: Color(0xFF14B8A6), icon: Icons.trending_up_rounded),
    'Math': (color: Color(0xFFF97316), icon: Icons.calculate_rounded),
    'Art': (color: Color(0xFFEC4899), icon: Icons.brush_rounded),
  };
}
