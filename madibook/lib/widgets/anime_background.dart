import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/app_state.dart';

/// A dynamic premium background adaptible to WhatsApp / Instagram Light & Dark themes.
class AnimeBackground extends StatelessWidget {
  final Widget child;
  final String assetPath;
  final double opacity;

  const AnimeBackground({
    super.key,
    required this.child,
    required this.assetPath,
    this.opacity = 0.65,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDarkMode;

    return Container(
      // High-end dynamic transition colors
      color: isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // If we want subtle premium gradients like Instagram
          if (!isDark)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF7F8FA),
                    Color(0xFFE9EBEE),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF121212),
                    Color(0xFF1E1E1E),
                    Color(0xFF0F0F0F),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),

          // 2. Content Layer
          child,
        ],
      ),
    );
  }
}
