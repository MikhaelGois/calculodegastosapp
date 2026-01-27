import 'package:flutter/foundation.dart';
import '../models/ride_offer.dart';

/// Provider para gerenciar ofertas de corridas detectadas
class RideOfferProvider extends ChangeNotifier {
  final List<RideOffer> _detectedOffers = [];
  RideOffer? _currentOffer;
  int _acceptedCount = 0;
  int _rejectedCount = 0;

  List<RideOffer> get detectedOffers => List.unmodifiable(_detectedOffers);
  RideOffer? get currentOffer => _currentOffer;
  int get acceptedCount => _acceptedCount;
  int get rejectedCount => _rejectedCount;
  double get acceptanceRate => _rejectedCount + _acceptedCount > 0
      ? _acceptedCount / (_acceptedCount + _rejectedCount) * 100
      : 0;

  /// Adiciona nova oferta de corrida detectada
  void addDetectedOffer(RideOffer offer) {
    _currentOffer = offer;
    _detectedOffers.insert(0, offer);
    // Manter apenas últimas 50 ofertas
    if (_detectedOffers.length > 50) {
      _detectedOffers.removeLast();
    }
    notifyListeners();
  }

  /// Marca oferta como aceita
  void acceptOffer(RideOffer offer) {
    _acceptedCount++;
    _currentOffer = null;
    notifyListeners();
  }

  /// Marca oferta como rejeitada
  void rejectOffer(RideOffer offer) {
    _rejectedCount++;
    _currentOffer = null;
    notifyListeners();
  }

  /// Limpa oferta atual
  void clearCurrentOffer() {
    _currentOffer = null;
    notifyListeners();
  }

  /// Limpa histórico
  void clearHistory() {
    _detectedOffers.clear();
    _currentOffer = null;
    notifyListeners();
  }

  /// Reseta estatísticas
  void resetStatistics() {
    _acceptedCount = 0;
    _rejectedCount = 0;
    notifyListeners();
  }

  /// Retorna ofertas de um app específico
  List<RideOffer> getOffersFromApp(RideApp app) {
    return _detectedOffers.where((offer) => offer.app == app).toList();
  }

  /// Retorna ofertas com traffic light específico
  List<RideOffer> getOffersByTrafficLight(TrafficLight light) {
    return _detectedOffers
        .where((offer) => offer.trafficLight == light)
        .toList();
  }

  /// Calcula estatísticas
  Map<String, dynamic> getStatistics() {
    return {
      'totalDetected': _detectedOffers.length,
      'accepted': _acceptedCount,
      'rejected': _rejectedCount,
      'acceptanceRate': acceptanceRate,
      'greenCount': getOffersByTrafficLight(TrafficLight.GREEN).length,
      'yellowCount': getOffersByTrafficLight(TrafficLight.YELLOW).length,
      'redCount': getOffersByTrafficLight(TrafficLight.RED).length,
    };
  }
}
