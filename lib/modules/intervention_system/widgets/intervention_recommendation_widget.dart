import 'package:flutter/material.dart';

class InterventionRecommendationWidget extends StatelessWidget {
  const InterventionRecommendationWidget({
    super.key,
    required this.recommendations,
    this.onSelected,
  });

  final List<String> recommendations;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Recommended support',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...recommendations.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilledButton.tonal(
                  onPressed: onSelected == null ? null : () => onSelected!(item),
                  style: FilledButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(item),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
