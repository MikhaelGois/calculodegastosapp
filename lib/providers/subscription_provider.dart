import 'package:flutter/foundation.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';

/// Provider para gerenciar estado de assinatura
class SubscriptionProvider extends ChangeNotifier {
  UserSubscription _subscription = UserSubscription.free();
  bool _isLoading = false;
  String? _errorMessage;

  UserSubscription get subscription => _subscription;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters de conveniência
  SubscriptionTier get currentTier => _subscription.tier;
  bool get isPremium => currentTier == SubscriptionTier.PREMIUM;
  bool get isFree => currentTier == SubscriptionTier.FREE;

  // Permissões
  bool get canUseRideOffers => _subscription.canUseRideOffers;
  bool get canUseFinancial => _subscription.canUseFinancial;
  bool get shouldShowAds => _subscription.shouldShowAds;

  // Trial
  bool get isTrialing => _subscription.isTrialing;
  int get daysRemaining => _subscription.daysRemaining;

  /// Carrega status de assinatura
  Future<void> loadSubscription() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subscription = await SubscriptionService.checkSubscriptionStatus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar assinatura: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Compra assinatura
  Future<bool> purchaseSubscription(SubscriptionTier tier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await SubscriptionService.purchaseSubscription(tier);

      if (success) {
        // Atualizar assinatura local
        _subscription = UserSubscription(
          tier: tier,
          startDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
          transactionId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao processar compra: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restaura compras
  Future<void> restorePurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subscription = await SubscriptionService.restorePurchases();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao restaurar compras: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifica se pode acessar feature
  bool canAccessFeature(String feature) {
    return SubscriptionService.canAccessFeature(_subscription, feature);
  }

  /// Abre gerenciamento de assinatura
  void openSubscriptionManagement() {
    SubscriptionService.openSubscriptionManagement();
  }

  /// Simula upgrade de plano (para testes)
  void simulateUpgrade(SubscriptionTier tier) {
    _subscription = UserSubscription(
      tier: tier,
      startDate: DateTime.now(),
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
      transactionId: 'sim_${DateTime.now().millisecondsSinceEpoch}',
    );
    notifyListeners();
  }

  /// Simula downgrade para FREE (para testes)
  void simulateDowngrade() {
    _subscription = UserSubscription.free();
    notifyListeners();
  }

  /// Exporta para salvar
  Map<String, dynamic> export() {
    return _subscription.toMap();
  }

  /// Importa de storage
  void import(Map<String, dynamic> data) {
    _subscription = UserSubscription.fromMap(data);
    notifyListeners();
  }
}
