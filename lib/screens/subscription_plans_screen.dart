import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription_plan.dart';
import '../providers/subscription_provider.dart';
import '../services/subscription_service.dart';

/// Tela de seleção de planos de assinatura
class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  SubscriptionTier? _selectedTier;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final currentTier = subscriptionProvider.currentTier;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos de Assinatura'),
        actions: [
          TextButton.icon(
            onPressed: _restorePurchases,
            icon: const Icon(Icons.restore),
            label: const Text('Restaurar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Escolha seu plano',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Desbloqueie recursos premium e remova anúncios',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Economia do Premium
            if (currentTier == SubscriptionTier.FREE)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.savings, color: Colors.green[700], size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Melhor Oferta!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            SubscriptionService.getSavingsDescription(),
                            style: TextStyle(color: Colors.green[800]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Lista de planos
            ...SubscriptionService.getAvailablePlans().map((tier) {
              final isSelected = _selectedTier == tier;
              final isCurrent = tier == currentTier;
              final isRecommended =
                  tier == SubscriptionService.getRecommendedPlan();

              return _PlanCard(
                tier: tier,
                isSelected: isSelected,
                isCurrent: isCurrent,
                isRecommended: isRecommended,
                onTap: tier == SubscriptionTier.FREE
                    ? null
                    : () {
                        setState(() {
                          _selectedTier = tier;
                        });
                      },
              );
            }).toList(),

            const SizedBox(height: 24),

            // Botão de assinatura
            if (_selectedTier != null && _selectedTier != currentTier)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _subscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'ASSINAR ${_selectedTier!.displayName.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Assinatura via ${Theme.of(context).platform == TargetPlatform.iOS ? 'App Store' : 'Google Play'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Renovação automática. Cancele quando quiser.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

            // Info sobre plano atual
            if (currentTier != SubscriptionTier.FREE) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              _CurrentSubscriptionInfo(
                subscription: subscriptionProvider.subscription,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _subscribe() async {
    if (_selectedTier == null) return;

    setState(() {
      _isProcessing = true;
    });

    final subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );

    final success = await subscriptionProvider.purchaseSubscription(
      _selectedTier!,
    );

    setState(() {
      _isProcessing = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assinatura ${_selectedTier!.displayName} ativada!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao processar assinatura. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restorePurchases() async {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );

    await subscriptionProvider.restorePurchases();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Compras restauradas!')));
  }
}

/// Card de plano individual
class _PlanCard extends StatelessWidget {
  final SubscriptionTier tier;
  final bool isSelected;
  final bool isCurrent;
  final bool isRecommended;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.tier,
    required this.isSelected,
    required this.isCurrent,
    required this.isRecommended,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : isCurrent
                ? Colors.green
                : Colors.grey[300]!,
            width: isSelected || isCurrent ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? Colors.blue[50]
              : isCurrent
              ? Colors.green[50]
              : Colors.white,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(tier.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tier.displayName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              tier.priceFormatted,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Atual',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tier.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ...tier.features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isRecommended && !isCurrent)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '⭐ RECOMENDADO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Info sobre assinatura atual
class _CurrentSubscriptionInfo extends StatelessWidget {
  final UserSubscription subscription;

  const _CurrentSubscriptionInfo({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sua Assinatura',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.card_membership,
          label: 'Plano',
          value: subscription.tier.displayName,
        ),
        _InfoRow(
          icon: Icons.calendar_today,
          label: 'Expira em',
          value: SubscriptionService.formatExpiryDate(subscription.expiryDate),
        ),
        _InfoRow(
          icon: Icons.timer,
          label: 'Dias restantes',
          value: '${subscription.daysRemaining} dias',
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            Provider.of<SubscriptionProvider>(
              context,
              listen: false,
            ).openSubscriptionManagement();
          },
          icon: const Icon(Icons.settings),
          label: const Text('Gerenciar Assinatura'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
