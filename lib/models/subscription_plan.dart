import 'package:flutter/foundation.dart';

/// Tipos de planos de assinatura
enum SubscriptionTier {
  FREE, // Gratuito com anúncios
  RIDE_OFFERS, // R$ 4,99 - Sistema de Semáforo
  FINANCIAL, // R$ 4,99 - Controle Financeiro
  PREMIUM, // R$ 8,99 - Tudo incluído
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.FREE:
        return 'Gratuito';
      case SubscriptionTier.RIDE_OFFERS:
        return 'Análise de Corridas';
      case SubscriptionTier.FINANCIAL:
        return 'Controle Financeiro';
      case SubscriptionTier.PREMIUM:
        return 'Premium Completo';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionTier.FREE:
        return 'RodaLucro básico com anúncios';
      case SubscriptionTier.RIDE_OFFERS:
        return 'Sistema de semáforo sem anúncios';
      case SubscriptionTier.FINANCIAL:
        return 'Controle financeiro sem anúncios';
      case SubscriptionTier.PREMIUM:
        return 'Todos os recursos sem anúncios';
    }
  }

  double get priceMonthly {
    switch (this) {
      case SubscriptionTier.FREE:
        return 0.0;
      case SubscriptionTier.RIDE_OFFERS:
        return 4.99;
      case SubscriptionTier.FINANCIAL:
        return 4.99;
      case SubscriptionTier.PREMIUM:
        return 8.99;
    }
  }

  String get priceFormatted {
    if (this == SubscriptionTier.FREE) {
      return 'Grátis';
    }
    return 'R\$ ${priceMonthly.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get icon {
    switch (this) {
      case SubscriptionTier.FREE:
        return '🆓';
      case SubscriptionTier.RIDE_OFFERS:
        return '🚦';
      case SubscriptionTier.FINANCIAL:
        return '💰';
      case SubscriptionTier.PREMIUM:
        return '👑';
    }
  }

  String get productId {
    switch (this) {
      case SubscriptionTier.FREE:
        return '';
      case SubscriptionTier.RIDE_OFFERS:
        return 'ride_offers_monthly';
      case SubscriptionTier.FINANCIAL:
        return 'financial_monthly';
      case SubscriptionTier.PREMIUM:
        return 'premium_monthly';
    }
  }

  List<String> get features {
    switch (this) {
      case SubscriptionTier.FREE:
        return [
          '✅ RodaLucro básico (custos, veículos)',
          '✅ Gerenciamento de veículos',
          '✅ Histórico de corridas',
          '📢 Com anúncios',
          '🔒 Sem análise de ofertas',
          '🔒 Sem controle financeiro',
        ];
      case SubscriptionTier.RIDE_OFFERS:
        return [
          '✅ Tudo do plano gratuito',
          '✅ Sistema de semáforo 🚦',
          '✅ Análise de rentabilidade',
          '✅ Recomendações inteligentes',
          '✅ Estatísticas de ofertas',
          '✅ Sem anúncios',
          '🔒 Sem controle financeiro',
        ];
      case SubscriptionTier.FINANCIAL:
        return [
          '✅ Tudo do plano gratuito',
          '✅ Controle financeiro completo',
          '✅ Receitas e despesas',
          '✅ Lucro líquido real',
          '✅ Análises e previsões',
          '✅ Sem anúncios',
          '🔒 Sem análise de ofertas',
        ];
      case SubscriptionTier.PREMIUM:
        return [
          '✅ TUDO LIBERADO',
          '✅ RodaLucro completo (custos, veículos)',
          '✅ Sistema de semáforo 🚦',
          '✅ Controle financeiro 💰',
          '✅ Análises avançadas',
          '✅ Sem anúncios',
          '🎁 Suporte prioritário',
        ];
    }
  }

  bool get hasAds {
    return this == SubscriptionTier.FREE;
  }

  bool get hasRideOffers {
    return this == SubscriptionTier.RIDE_OFFERS ||
        this == SubscriptionTier.PREMIUM;
  }

  bool get hasFinancial {
    return this == SubscriptionTier.FINANCIAL ||
        this == SubscriptionTier.PREMIUM;
  }
}

/// Modelo de assinatura do usuário
class UserSubscription {
  final SubscriptionTier tier;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final bool isActive;
  final String? transactionId;

  const UserSubscription({
    required this.tier,
    this.startDate,
    this.expiryDate,
    required this.isActive,
    this.transactionId,
  });

  factory UserSubscription.free() {
    return const UserSubscription(tier: SubscriptionTier.FREE, isActive: true);
  }

  bool get hasExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isTrialing {
    if (startDate == null) return false;
    final trialEnd = startDate!.add(const Duration(days: 7));
    return DateTime.now().isBefore(trialEnd) && tier != SubscriptionTier.FREE;
  }

  int get daysRemaining {
    if (expiryDate == null) return 0;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  // Verifica permissões
  bool get canUseRideOffers => tier.hasRideOffers && isActive && !hasExpired;
  bool get canUseFinancial => tier.hasFinancial && isActive && !hasExpired;
  bool get shouldShowAds => tier.hasAds || !isActive || hasExpired;

  Map<String, dynamic> toMap() {
    return {
      'tier': tier.toString(),
      'startDate': startDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'transactionId': transactionId,
    };
  }

  factory UserSubscription.fromMap(Map<String, dynamic> map) {
    return UserSubscription(
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.toString() == map['tier'],
        orElse: () => SubscriptionTier.FREE,
      ),
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'])
          : null,
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'])
          : null,
      isActive: map['isActive'] ?? false,
      transactionId: map['transactionId'],
    );
  }

  UserSubscription copyWith({
    SubscriptionTier? tier,
    DateTime? startDate,
    DateTime? expiryDate,
    bool? isActive,
    String? transactionId,
  }) {
    return UserSubscription(
      tier: tier ?? this.tier,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}
