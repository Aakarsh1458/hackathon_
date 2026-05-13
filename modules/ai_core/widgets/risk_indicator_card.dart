import 'package:flutter/material.dart';

import '../models/risk_tier.dart';

class RiskIndicatorCard extends StatelessWidget {
  final String title;
  final RiskTier tier;
  final double confidence; // 0..1
  final List<String> factors;

  const RiskIndicatorCard({
    super.key,
    required this.title,
    required this.tier,
    required this.confidence,
    required this.factors,
  });

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(tier);
    final textTheme = Theme.of(context).textTheme;
    final confPct = (confidence.clamp(0, 1) * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.20),
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              _TierPill(tier: tier),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Confidence: $confPct%',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 10),
          if (factors.isEmpty)
            Text(
              'No strong contributing factors detected in this window.',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.72)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: factors
                  .take(5)
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                        ),
                        child: Text(
                          f,
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
                        ),
                      ))
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  Color _tierColor(RiskTier t) {
    return switch (t) {
      RiskTier.low => const Color(0xFF4ADE80), // green
      RiskTier.medium => const Color(0xFFFBBF24), // amber
      RiskTier.high => const Color(0xFFF87171), // red
    };
  }
}

class _TierPill extends StatelessWidget {
  final RiskTier tier;
  const _TierPill({required this.tier});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (tier) {
      RiskTier.low => ('LOW', const Color(0xFF4ADE80)),
      RiskTier.medium => ('MED', const Color(0xFFFBBF24)),
      RiskTier.high => ('HIGH', const Color(0xFFF87171)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: color,
            ),
      ),
    );
  }
}

