import 'package:flutter/material.dart';

class QuotaCard extends StatelessWidget {
  const QuotaCard({required this.quota, required this.onUpgrade, super.key});

  final Map<String, dynamic> quota;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final premium = quota['tier'] == 'premium';
    final remaining = (quota['remaining'] as num? ?? 0).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: colors.onPrimary, size: 27),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  premium
                      ? 'Premium activé'
                      : '$remaining recette${remaining == 1 ? '' : 's'} IA aujourd’hui',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  premium
                      ? 'Place à toutes tes envies.'
                      : 'Ton quota se renouvelle chaque jour.',
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.78),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!premium)
            TextButton(
              onPressed: onUpgrade,
              style: TextButton.styleFrom(foregroundColor: colors.onPrimary),
              child: const Text('Premium'),
            ),
        ],
      ),
    );
  }
}
