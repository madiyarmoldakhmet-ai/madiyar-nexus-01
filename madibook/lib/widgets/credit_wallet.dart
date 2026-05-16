import 'package:flutter/material.dart';
import '../core/constants.dart';

/// A premium gold-styled digital wallet widget showing the user's
/// Nexus-Credit balance with a shimmering gradient and subtle animation.
class CreditWallet extends StatefulWidget {
  final double balance;

  const CreditWallet({super.key, required this.balance});

  @override
  State<CreditWallet> createState() => _CreditWalletState();
}

class _CreditWalletState extends State<CreditWallet>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MadiSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MadiRadius.xl),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF1A1530),
                Color(0xFF2A1F45),
                Color(0xFF1A1530),
              ],
            ),
            border: Border.all(
              color: MadiColors.gold.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: MadiColors.gold.withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Shimmer effect overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(MadiRadius.xl),
                  child: CustomPaint(
                    painter: _ShimmerPainter(
                      progress: _shimmerController.value,
                      color: MadiColors.gold.withValues(alpha: 0.06),
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: MadiColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(MadiRadius.md),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: MadiColors.gold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: MadiSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nexus-Credits',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: MadiColors.goldLight,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your learning currency',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: MadiColors.textMuted,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: MadiColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(MadiRadius.full),
                          border: Border.all(
                            color: MadiColors.emerald.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: MadiColors.emerald,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Active',
                              style: TextStyle(
                                color: MadiColors.emerald,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: MadiSpacing.xl),

                  // Balance display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            MadiColors.goldShimmer,
                            MadiColors.gold,
                            MadiColors.goldLight,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          widget.balance.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                      const SizedBox(width: MadiSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'NC',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: MadiColors.gold.withValues(alpha: 0.6),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: MadiSpacing.lg),

                  // Divider
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          MadiColors.gold.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: MadiSpacing.md),

                  // Footer info
                  Row(
                    children: [
                      _buildWalletStat(
                        context,
                        icon: Icons.arrow_upward_rounded,
                        label: 'Earned',
                        value: '1h = 1 NC',
                        color: MadiColors.emerald,
                      ),
                      const SizedBox(width: MadiSpacing.xl),
                      _buildWalletStat(
                        context,
                        icon: Icons.arrow_downward_rounded,
                        label: 'Spend',
                        value: '1 NC = 1h',
                        color: MadiColors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: MadiColors.textMuted,
                    fontSize: 10,
                  ),
            ),
            Text(
              value,
              style: TextStyle(
                color: MadiColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom painter for the shimmer sweep effect across the wallet.
class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          color,
          Colors.transparent,
        ],
        stops: [
          (progress - 0.3).clamp(0.0, 1.0),
          progress,
          (progress + 0.3).clamp(0.0, 1.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
