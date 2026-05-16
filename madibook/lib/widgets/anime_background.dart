import 'package:flutter/material.dart';

/// A debug-focused atmospheric anime background widget.
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
    const githubUrl = 'https://raw.githubusercontent.com/madiyarmoldakhmet-ai/madibook01/main/assets/images/kaneki_v2.jpg';

    return Container(
      // Nuked solid black background overlays
      color: Colors.transparent, 
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Primary Layer: Image (Tried via Network first for reliability)
          Image.network(
            githubUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint('AnimeBackground: Network image failed: $error');
              return Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) {
                  return Image.asset(
                    'assets/$assetPath',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.red),
                  );
                },
              );
            },
          ),

          // 2. Overlay Layer: Darkening and Atmospheric Tint
          // Setting alpha very low for debugging visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: opacity * 0.1), 
                  Colors.black.withValues(alpha: opacity * 0.2),
                ],
              ),
            ),
          ),

          // 3. Content Layer
          child,
        ],
      ),
    );
  }
}
