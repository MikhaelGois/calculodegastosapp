import '../models/subscription_plan.dart';

/// Serviço para gerenciar assinaturas e in-app purchases
///
/// NOTA: Esta é uma implementação de estrutura/mockup.
/// Para produção, integre com:
/// - in_app_purchase (Flutter oficial)
/// - purchases_flutter (RevenueCat)
class SubscriptionService {
  /// Simula verificação de assinatura via Store
  ///
  /// Em produção, substituir por verificação real via Store
  static Future<UserSubscription> checkSubscriptionStatus() async {
    // TODO: Implementar integração real com Google Play / App Store
    // Para desenvolvimento/teste, retorna FREE

    await Future.delayed(const Duration(milliseconds: 500));
    return UserSubscription.free();
  }

  /// Inicia processo de compra
  ///
  /// Em produção:
  /// ```dart
  /// final ProductDetails product = ...;
  /// final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
  /// await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  /// ```
  static Future<bool> purchaseSubscription(SubscriptionTier tier) async {
    if (tier == SubscriptionTier.FREE) {
      return true;
    }

    // TODO: Implementar compra via Store
    // 1. Obter ProductDetails do productId
    // 2. Iniciar compra
    // 3. Validar no backend
    // 4. Ativar assinatura

    // Simulação para desenvolvimento
    await Future.delayed(const Duration(seconds: 2));

    // Em dev, simula sucesso
    return true;
  }

  /// Restaura compras anteriores
  ///
  /// Em produção:
  /// ```dart
  /// await InAppPurchase.instance.restorePurchases();
  /// ```
  static Future<UserSubscription> restorePurchases() async {
    // TODO: Implementar restore via Store
    await Future.delayed(const Duration(seconds: 1));
    return UserSubscription.free();
  }

  /// Cancela assinatura
  ///
  /// NOTA: Cancelamento é feito pela própria Store (Google Play/App Store)
  /// O app apenas informa o usuário
  static void openSubscriptionManagement() {
    // TODO: Abrir tela de gerenciamento da Store
    // Android: Play Store subscriptions
    // iOS: App Store subscriptions
  }

  /// Valida se uma feature está disponível
  static bool canAccessFeature(UserSubscription subscription, String feature) {
    switch (feature) {
      case 'ride_offers':
        return subscription.canUseRideOffers;
      case 'financial':
        return subscription.canUseFinancial;
      case 'no_ads':
        return !subscription.shouldShowAds;
      default:
        return true;
    }
  }

  /// Calcula economia do plano Premium vs planos separados
  static double calculateSavings() {
    final separate =
        SubscriptionTier.RIDE_OFFERS.priceMonthly +
        SubscriptionTier.FINANCIAL.priceMonthly;
    final premium = SubscriptionTier.PREMIUM.priceMonthly;
    return separate - premium; // R$ 0,99 de economia
  }

  /// Retorna descrição de economia do Premium
  static String getSavingsDescription() {
    final savings = calculateSavings();
    return 'Economize R\$ ${savings.toStringAsFixed(2).replaceAll('.', ',')} por mês!';
  }

  /// Lista todos os planos disponíveis para compra
  static List<SubscriptionTier> getAvailablePlans() {
    return [
      SubscriptionTier.FREE,
      SubscriptionTier.RIDE_OFFERS,
      SubscriptionTier.FINANCIAL,
      SubscriptionTier.PREMIUM,
    ];
  }

  /// Retorna plano recomendado (Premium)
  static SubscriptionTier getRecommendedPlan() {
    return SubscriptionTier.PREMIUM;
  }

  /// Formata data de expiração
  static String formatExpiryDate(DateTime? date) {
    if (date == null) return 'Sem expiração';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    return '$day/$month/$year';
  }

  /// Verifica se está em período de trial
  static bool isInTrial(UserSubscription subscription) {
    return subscription.isTrialing;
  }

  /// Retorna mensagem de trial
  static String getTrialMessage(UserSubscription subscription) {
    if (!subscription.isTrialing) return '';

    final daysLeft =
        7 - DateTime.now().difference(subscription.startDate!).inDays;
    return 'Período de teste: $daysLeft dias restantes';
  }
}
