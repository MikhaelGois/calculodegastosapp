import 'package:flutter/material.dart';
import '../models/subscription_plan.dart';

/// Widget de paywall para bloquear features
class PaywallWidget extends StatelessWidget {
  final String featureName;
  final String featureDescription;
  final IconData featureIcon;
  final SubscriptionTier requiredTier;
  final VoidCallback onUpgrade;

  const PaywallWidget({
    Key? key,
    required this.featureName,
    required this.featureDescription,
    required this.featureIcon,
    required this.requiredTier,
    required this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone com efeito de bloqueio
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(featureIcon, size: 100, color: Colors.grey[300]),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, size: 40, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nome da feature
            Text(
              featureName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Descrição
            Text(
              featureDescription,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Card do plano requerido
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      requiredTier.icon,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      requiredTier.displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${requiredTier.priceFormatted}/mês',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      requiredTier.description,
                      style: TextStyle(color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botão de upgrade
            ElevatedButton(
              onPressed: onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(requiredTier.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  const Text(
                    'FAZER UPGRADE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Link para ver todos os planos
            TextButton(
              onPressed: onUpgrade,
              child: const Text('Ver todos os planos'),
            ),
          ],
        ),
      ),
    );
  }
}
