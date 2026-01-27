import 'package:flutter/material.dart';
import '../models/ride_offer.dart';

class RideOfferCard extends StatelessWidget {
  final RideOffer offer;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RideOfferCard({
    Key? key,
    required this.offer,
    this.onAccept,
    this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Card(
      margin: const EdgeInsets.all(8),
      child: Container(
        color: colors['bg'],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(offer.appIcon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      offer.appName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors['fg'],
                      ),
                    ),
                  ),
                  Text(
                    offer.trafficLightEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Distância: ${offer.distanceKm ?? "N/A"} km'),
              Text(
                'Valor: R\$ ${offer.offeredValue?.toStringAsFixed(2) ?? "N/A"}',
              ),
              Text(
                'Rentabilidade: ${offer.profitabilityScore.toStringAsFixed(0)}/100',
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: offer.profitabilityScore / 100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colors['fg'] as Color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                offer.trafficLightMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (onReject != null)
                    ElevatedButton(
                      onPressed: onReject,
                      child: const Text('Rejeitar'),
                    ),
                  if (onAccept != null)
                    ElevatedButton(
                      onPressed: onAccept,
                      child: const Text('Aceitar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getColors() {
    switch (offer.trafficLight) {
      case TrafficLight.GREEN:
        return {'bg': Colors.green.withOpacity(0.1), 'fg': Colors.green};
      case TrafficLight.YELLOW:
        return {'bg': Colors.amber.withOpacity(0.1), 'fg': Colors.amber};
      case TrafficLight.RED:
        return {'bg': Colors.red.withOpacity(0.1), 'fg': Colors.red};
    }
  }
}
