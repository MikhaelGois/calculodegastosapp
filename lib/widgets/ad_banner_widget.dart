import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

/// Tipos de posicionamento de anúncio
enum AdPlacement {
  BANNER, // 320x50
  MEDIUM_RECTANGLE, // 300x250
  LARGE_BANNER, // 320x100
}

/// Widget de banner de anúncio
///
/// ⚠️ IMPORTANTE: Este widget não deve ser usado.
/// Apenas anúncios de vídeo (InterstitialAdDialog) devem ser exibidos.
///
/// NOTA: Este é um placeholder. Para produção, integre com:
/// - Google AdMob (google_mobile_ads)
/// - Facebook Audience Network
class AdBannerWidget extends StatelessWidget {
  final AdPlacement placement;

  const AdBannerWidget({Key? key, required this.placement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    // Não mostrar anúncio se for Premium
    if (!subscriptionProvider.shouldShowAds) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: _getHeight(),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.ad_units, size: 32, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            'Espaço para Anúncio',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            _getPlacementName(),
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ],
      ),
    );
  }

  double _getHeight() {
    switch (placement) {
      case AdPlacement.BANNER:
        return 60;
      case AdPlacement.MEDIUM_RECTANGLE:
        return 250;
      case AdPlacement.LARGE_BANNER:
        return 100;
    }
  }

  String _getPlacementName() {
    switch (placement) {
      case AdPlacement.BANNER:
        return 'Banner (320x50)';
      case AdPlacement.MEDIUM_RECTANGLE:
        return 'Retângulo Médio (300x250)';
      case AdPlacement.LARGE_BANNER:
        return 'Banner Grande (320x100)';
    }
  }
}

/// Widget de anúncio intersticial em vídeo (tela cheia)
///
/// Este é o ÚNICO tipo de anúncio que deve ser exibido no app.
/// Aparece antes de mostrar o resultado do cálculo.
/// Qualquer assinatura paga remove este anúncio.
class InterstitialAdDialog extends StatelessWidget {
  final VoidCallback onAdClosed;

  const InterstitialAdDialog({Key? key, required this.onAdClosed})
    : super(key: key);

  static Future<void> show(BuildContext context, VoidCallback onClosed) async {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );

    // Não mostrar anúncio se for Premium
    if (!subscriptionProvider.shouldShowAds) {
      onClosed();
      return;
    }

    // Mostrar dialog de anúncio
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InterstitialAdDialog(onAdClosed: onClosed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simulação de anúncio
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ad_units, size: 80, color: Colors.grey[600]),
                    const SizedBox(height: 16),
                    Text(
                      'Anúncio em Vídeo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Simulação de anúncio em vídeo',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Remova anúncios com Premium 👑',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Contador e botão fechar
            _AdCloseButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAdClosed();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão de fechar anúncio com contador
class _AdCloseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AdCloseButton({required this.onPressed});

  @override
  State<_AdCloseButton> createState() => _AdCloseButtonState();
}

class _AdCloseButtonState extends State<_AdCloseButton> {
  int _countdown = 5;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_countdown > 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Aguarde $_countdown segundos...',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: widget.onPressed,
      icon: const Icon(Icons.close),
      label: const Text('Fechar anúncio'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
