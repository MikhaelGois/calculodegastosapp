# 💎 Sistema Freemium - Documentação v3.2

**Data**: 27 de Janeiro, 2026  
**Status**: ✅ Implementado - Pronto para Testes

---

## 🎯 Visão Geral

Sistema de monetização freemium com 4 planos de assinatura, anúncios integrados e compra via lojas (Google Play / App Store).

### Modelo de Negócio

**Plano Gratuito** (com anúncios):
- ✅ Cálculo de gastos básico
- ✅ Gerenciamento de veículos
- ✅ Histórico de corridas
- 📢 Anúncio ao gerar cálculo
- 🔒 Sem sistema de semáforo
- 🔒 Sem controle financeiro

**Planos Pagos** (via assinatura mensal):
1. **Análise de Corridas**: R$ 4,99/mês
   - Sistema de semáforo 🚦 (v3.0)
   - Análise de rentabilidade
   - ✅ **SEM anúncios**

2. **Controle Financeiro**: R$ 4,99/mês
   - Controle financeiro completo 💰 (v3.1)
   - Receitas e despesas
   - ✅ **SEM anúncios**

3. **Premium Completo**: R$ 8,99/mês 👑
   - TUDO incluído
   - Sistema de semáforo + Controle financeiro
   - ✅ **SEM anúncios**
   - 💸 Economia de R$ 0,99 vs planos separados

---

## 📊 Estrutura de Planos

### Comparativo Completo

| Feature | Gratuito | Análise Corridas | Financeiro | Premium |
|---------|----------|------------------|------------|---------|
| **Preço** | Grátis | R$ 4,99 | R$ 4,99 | R$ 8,99 |
| Cálculo de Gastos | ✅ | ✅ | ✅ | ✅ |
| Veículos | ✅ | ✅ | ✅ | ✅ |
| Histórico | ✅ | ✅ | ✅ | ✅ |
| Sistema Semáforo 🚦 | ❌ | ✅ | ❌ | ✅ |
| Controle Financeiro 💰 | ❌ | ❌ | ✅ | ✅ |
| **Anúncios** | 📢 Vídeo | ✅ Não | ✅ Não | ✅ Não |
| Suporte | Normal | Normal | Normal | 🎁 Prioritário |

### Economia do Premium

```
Análise de Corridas: R$ 4,99
+ Controle Financeiro: R$ 4,99
= Total separado: R$ 9,98

Premium Completo: R$ 8,99
ECONOMIA: R$ 0,99/mês (10%)
```

---

## 🏗️ Arquitetura

### 1. Modelo de Dados

**SubscriptionTier** (`lib/models/subscription_plan.dart`)

Enum com 4 níveis:
```dart
enum SubscriptionTier {
  FREE,           // Gratuito
  RIDE_OFFERS,    // R$ 4,99 - Semáforo
  FINANCIAL,      // R$ 4,99 - Financeiro
  PREMIUM,        // R$ 8,99 - Completo
}
```

**Extensions do Enum**:
- `displayName`: Nome amigável
- `description`: Descrição do plano
- `priceMonthly`: Valor mensal (double)
- `priceFormatted`: Preço formatado (R$ X,XX)
- `icon`: Emoji do plano (🆓/🚦/💰/👑)
- `productId`: ID para store (ex: 'premium_monthly')
- `features`: Lista de features (List<String>)
- `hasAds`: Se tem anúncios (bool)
- `hasRideOffers`: Se tem sistema de semáforo (bool)
- `hasFinancial`: Se tem controle financeiro (bool)

**UserSubscription** (`lib/models/subscription_plan.dart`)

Classe que representa assinatura ativa:
```dart
class UserSubscription {
  final SubscriptionTier tier;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final bool isActive;
  final String? transactionId;
  
  // Getters
  bool get hasExpired;
  bool get isTrialing;
  int get daysRemaining;
  bool get canUseRideOffers;
  bool get canUseFinancial;
  bool get shouldShowAds;
}
```

**Factory Constructors**:
- `UserSubscription.free()` - Cria assinatura gratuita
- `UserSubscription.fromMap()` - Desserialização

### 2. Camada de Serviço

**SubscriptionService** (`lib/services/subscription_service.dart`)

Métodos estáticos para gerenciar assinaturas:

```dart
// Verificação de status
Future<UserSubscription> checkSubscriptionStatus()

// Compra de assinatura
Future<bool> purchaseSubscription(SubscriptionTier tier)

// Restaurar compras
Future<UserSubscription> restorePurchases()

// Gerenciar assinatura (abre Store)
void openSubscriptionManagement()

// Verificar acesso a feature
bool canAccessFeature(UserSubscription subscription, String feature)

// Cálculos
double calculateSavings()  // Economia do Premium
String getSavingsDescription()

// Helpers
List<SubscriptionTier> getAvailablePlans()
SubscriptionTier getRecommendedPlan()
String formatExpiryDate(DateTime? date)
bool isInTrial(UserSubscription subscription)
String getTrialMessage(UserSubscription subscription)
```

**⚠️ IMPORTANTE**: A implementação atual é um mockup. Para produção, integrar com:
- `in_app_purchase` (pacote oficial Flutter)
- `purchases_flutter` (RevenueCat - recomendado)

### 3. Camada de Estado

**SubscriptionProvider** (`lib/providers/subscription_provider.dart`)

ChangeNotifier para gerenciar estado:

**State Variables**:
- `_subscription`: UserSubscription atual
- `_isLoading`: Se está processando
- `_errorMessage`: Mensagem de erro

**Getters Principais**:
- `currentTier`: Tier atual
- `isPremium`: Se é Premium
- `isFree`: Se é gratuito
- `canUseRideOffers`: Permissão para semáforo
- `canUseFinancial`: Permissão para financeiro
- `shouldShowAds`: Se deve mostrar anúncios
- `isTrialing`: Se está em trial
- `daysRemaining`: Dias restantes

**Métodos Principais**:
```dart
Future<void> loadSubscription()  // Carrega do storage/store
Future<bool> purchaseSubscription(SubscriptionTier tier)
Future<void> restorePurchases()
bool canAccessFeature(String feature)
void openSubscriptionManagement()

// Para testes
void simulateUpgrade(SubscriptionTier tier)
void simulateDowngrade()

// Persistência
Map<String, dynamic> export()
void import(Map<String, dynamic> data)
```

### 4. Camada de UI

#### Widgets de Anúncios

**AdBannerWidget** (`lib/widgets/ad_banner_widget.dart`)

⚠️ **IMPORTANTE**: Este widget **NÃO DEVE SER USADO**. 
Apenas anúncios de vídeo (InterstitialAdDialog) devem ser exibidos no app.

Banner de anúncio inline (DESCONTINUADO):
```dart
// NÃO USE - Apenas para referência
AdBannerWidget(
  placement: AdPlacement.BANNER,
)
```

**⚠️ NOTA**: Este componente existe apenas como referência e não deve ser utilizado na interface.

**InterstitialAdDialog** (`lib/widgets/ad_banner_widget.dart`)

✅ **ANÚNCIO DE VÍDEO** - Este é o ÚNICO tipo de anúncio usado no app:
```dart
await InterstitialAdDialog.show(
  context,
  onClosed: () {
    // Continuar com ação
  },
);
```

**Comportamento**:
- Mostra anúncio em vídeo fullscreen
- Contador de 5 segundos
- Botão "Fechar" após countdown
- ✅ **QUALQUER assinatura paga** remove este anúncio (não apenas Premium)

#### Widget de Paywall

**PaywallWidget** (`lib/widgets/paywall_widget.dart`)

Tela de bloqueio para features pagas:
```dart
PaywallWidget(
  featureName: 'Sistema de Semáforo',
  featureDescription: 'Análise inteligente de ofertas...',
  featureIcon: Icons.traffic,
  requiredTier: SubscriptionTier.RIDE_OFFERS,
  onUpgrade: () {
    // Abrir tela de planos
  },
)
```

**Visual**:
- Ícone grande com cadeado
- Nome e descrição da feature
- Card do plano requerido
- Botão "FAZER UPGRADE"
- Link "Ver todos os planos"

#### Telas

**SubscriptionPlansScreen** (`lib/screens/subscription_plans_screen.dart`)

Tela principal de seleção de planos:

**Componentes**:
1. **Header**
   - Título "Escolha seu plano"
   - Botão "Restaurar" no AppBar

2. **Alert de Economia** (se FREE)
   - Destaque para economia do Premium

3. **Lista de Planos**
   - 4 cards (_PlanCard)
   - Badge "RECOMENDADO" no Premium
   - Badge "Atual" no plano ativo
   - Seleção visual

4. **Botão de Assinatura**
   - Só aparece se plano selecionado
   - Loading indicator durante compra
   - Texto informativo sobre Store

5. **Info de Assinatura Atual** (se não FREE)
   - Plano atual
   - Data de expiração
   - Dias restantes
   - Link "Gerenciar Assinatura"

**Fluxo de Compra**:
1. Usuário seleciona plano
2. Clica "ASSINAR [PLANO]"
3. Provider chama `purchaseSubscription()`
4. Store processa pagamento
5. Sucesso: SnackBar verde + fechar tela
6. Erro: SnackBar vermelho

---

## 🔒 Sistema de Bloqueio de Features

### Verificação de Permissão

**No Provider**:
```dart
final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

if (!subscriptionProvider.canUseRideOffers) {
  // Mostrar paywall
  return PaywallWidget(
    featureName: 'Sistema de Semáforo',
    requiredTier: SubscriptionTier.RIDE_OFFERS,
    onUpgrade: () {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => SubscriptionPlansScreen(),
      ));
    },
  );
}

// Continuar com feature
return RideOffersScreen();
```

**Com Consumer**:
```dart
Consumer<SubscriptionProvider>(
  builder: (context, subscription, child) {
    if (!subscription.canUseFinancial) {
      return PaywallWidget(...);
    }
    return FinancialDashboardScreen();
  },
)
```

### Exemplos de Integração

#### 1. Bloquear Tela de Ride Offers

```dart
// lib/screens/ride_offers_screen.dart

class RideOffersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        if (!subscription.canUseRideOffers) {
          return Scaffold(
            appBar: AppBar(title: Text('Sistema de Semáforo')),
            body: PaywallWidget(
              featureName: 'Sistema de Semáforo',
              featureDescription: 'Análise inteligente de ofertas de corridas com recomendações verde, amarelo e vermelho.',
              featureIcon: Icons.traffic,
              requiredTier: SubscriptionTier.RIDE_OFFERS,
              onUpgrade: () => _openPlansScreen(context),
            ),
          );
        }

        // Feature liberada
        return _buildRideOffersContent();
      },
    );
  }
}
```

#### 2. Bloquear Tela Financeira

```dart
// lib/screens/financial_dashboard_screen.dart

class FinancialDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        if (!subscription.canUseFinancial) {
          return Scaffold(
            appBar: AppBar(title: Text('Controle Financeiro')),
            body: PaywallWidget(
              featureName: 'Controle Financeiro',
              featureDescription: 'Gerencie receitas e despesas para saber seu lucro real.',
              featureIcon: Icons.account_balance_wallet,
              requiredTier: SubscriptionTier.FINANCIAL,
              onUpgrade: () => _openPlansScreen(context),
            ),
          );
        }

        return _buildFinancialDashboard();
      },
    );
  }
}
```

#### 3. Anúncio ao Gerar Cálculo

```dart
// lib/screens/calculation_screen.dart

Future<void> _generateCalculation() async {
  // Mostrar anúncio antes de gerar
  await InterstitialAdDialog.show(
    context,
    onClosed: () async {
      // Gerar cálculo após fechar anúncio
      final result = await calculateCosts();
      _showResult(result);
    },
  );
}
```

#### 4. Banner de Anúncio na Home

```dart
// lib/screens/home_screen.dart

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // Conteúdo principal
        Expanded(child: _buildContent()),
        
        // Banner de anúncio (só aparece se não Premium)
        AdBannerWidget(
          placement: AdPlacement.BANNER,
        ),
      ],
    ),
  );
}
```

---

## 🛠️ Integração com o App

### Passo 1: Registrar Provider

No `main.dart`:
```dart
import 'providers/subscription_provider.dart';

MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => VehicleProvider()),
    ChangeNotifierProvider(create: (_) => RideOfferProvider()),
    ChangeNotifierProvider(create: (_) => FinancialProvider()),
    ChangeNotifierProvider(create: (_) => SubscriptionProvider()), // NOVO
  ],
  child: MyApp(),
)
```

### Passo 2: Carregar Assinatura no Startup

No `main.dart` ou `HomeScreen`:
```dart
@override
void initState() {
  super.initState();
  _loadSubscription();
}

Future<void> _loadSubscription() async {
  final subscription = Provider.of<SubscriptionProvider>(
    context,
    listen: false,
  );
  await subscription.loadSubscription();
}
```

### Passo 3: Adicionar Rota de Planos

No `routes.dart`:
```dart
routes: {
  '/': (context) => HomeScreen(),
  '/subscription-plans': (context) => SubscriptionPlansScreen(),
  // ...
},
```

### Passo 4: Menu de Assinatura

Na `HomeScreen` ou drawer:
```dart
Consumer<SubscriptionProvider>(
  builder: (context, subscription, child) {
    return ListTile(
      leading: Icon(
        subscription.isPremium ? Icons.star : Icons.shopping_cart,
        color: subscription.isPremium ? Colors.amber : null,
      ),
      title: Text(
        subscription.isPremium ? 'Premium Ativo' : 'Fazer Upgrade',
      ),
      subtitle: Text(subscription.currentTier.displayName),
      trailing: subscription.isPremium
          ? Icon(Icons.check_circle, color: Colors.green)
          : Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pushNamed(context, '/subscription-plans');
      },
    );
  },
)
```

---

## 💳 Integração com Stores (Produção)

### Dependências Necessárias

Adicionar no `pubspec.yaml`:
```yaml
dependencies:
  in_app_purchase: ^3.1.11  # Oficial Flutter
  # OU
  purchases_flutter: ^6.0.0  # RevenueCat (recomendado)
```

### Opção 1: in_app_purchase (Oficial)

```dart
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService {
  static final InAppPurchase _iap = InAppPurchase.instance;

  static Future<bool> purchaseSubscription(SubscriptionTier tier) async {
    // 1. Verificar disponibilidade
    final available = await _iap.isAvailable();
    if (!available) return false;

    // 2. Obter produtos
    final productIds = {tier.productId};
    final response = await _iap.queryProductDetails(productIds);
    
    if (response.productDetails.isEmpty) return false;

    // 3. Iniciar compra
    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Escutar compras
  static StreamSubscription<List<PurchaseDetails>> listenToPurchases() {
    return _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          // Validar e ativar assinatura
          _deliverProduct(purchase);
        }
        
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    });
  }
}
```

### Opção 2: RevenueCat (Recomendado)

```dart
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static Future<void> initialize() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.configure(PurchasesConfiguration('YOUR_API_KEY'));
  }

  static Future<bool> purchaseSubscription(SubscriptionTier tier) async {
    try {
      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.getPackage(tier.productId);
      
      if (package != null) {
        final purchaserInfo = await Purchases.purchasePackage(package);
        return purchaserInfo.entitlements.active.isNotEmpty;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<UserSubscription> checkSubscriptionStatus() async {
    try {
      final purchaserInfo = await Purchases.getCustomerInfo();
      
      // Verificar entitlements
      if (purchaserInfo.entitlements.active.containsKey('premium')) {
        return UserSubscription(
          tier: SubscriptionTier.PREMIUM,
          startDate: purchaserInfo.entitlements.active['premium']!.originalPurchaseDate,
          expiryDate: purchaserInfo.entitlements.active['premium']!.expirationDate,
          isActive: true,
        );
      }
      
      return UserSubscription.free();
    } catch (e) {
      return UserSubscription.free();
    }
  }
}
```

### Configuração nas Stores

**Google Play Console**:
1. Criar produtos de assinatura
2. IDs: `ride_offers_monthly`, `financial_monthly`, `premium_monthly`
3. Preços: R$ 4,99, R$ 4,99, R$ 8,99
4. Período de teste: 7 dias (opcional)

**App Store Connect**:
1. Criar produtos de assinatura
2. Mesmos IDs e preços
3. Configurar grupos de assinatura

---

## 📊 Analytics e Métricas

### Eventos Importantes para Rastrear

```dart
// Visualizações
- 'subscription_plans_viewed'
- 'paywall_shown' (feature: ride_offers | financial)

// Ações
- 'subscription_selected' (tier: FREE | RIDE_OFFERS | FINANCIAL | PREMIUM)
- 'subscription_purchase_initiated' (tier, price)
- 'subscription_purchase_completed' (tier, price, transaction_id)
- 'subscription_purchase_failed' (tier, error)
- 'subscription_cancelled' (tier, reason)
- 'subscription_restored'

// Engajamento
- 'feature_blocked' (feature: ride_offers | financial)
- 'ad_shown' (placement: banner | interstitial)
- 'ad_closed' (placement, time_viewed)
- 'upgrade_button_clicked' (from: paywall | menu | ad)
```

### Métricas Chave (KPIs)

1. **Conversão**:
   - Taxa de conversão FREE → Pago
   - Taxa de conversão por plano
   - Tempo até primeira compra

2. **Retenção**:
   - Taxa de renovação mensal
   - Taxa de cancelamento (churn)
   - Lifetime Value (LTV)

3. **Receita**:
   - MRR (Monthly Recurring Revenue)
   - ARR (Annual Recurring Revenue)
   - ARPU (Average Revenue Per User)

4. **Engajamento**:
   - Visualizações de paywall
   - Cliques em upgrade
   - Features mais bloqueadas

---

## 🧪 Testes

### Testes Manuais

**Teste 1: Fluxo Gratuito**
1. ✅ App inicia em plano FREE
2. ✅ Anúncios aparecem na home
3. ✅ Ao gerar cálculo, mostra anúncio intersticial
4. ✅ Tela de Ride Offers bloqueada (paywall)
5. ✅ Tela Financeira bloqueada (paywall)

**Teste 2: Compra de Plano**
1. ✅ Abrir tela de planos
2. ✅ Selecionar "Análise de Corridas" (R$ 4,99)
3. ✅ Clicar "ASSINAR"
4. ✅ Simular compra bem-sucedida
5. ✅ Verificar plano atualizado
6. ✅ Tela de Ride Offers desbloqueada
7. ✅ Tela Financeira ainda bloqueada
8. ✅ **ANÚNCIOS REMOVIDOS** (qualquer assinatura remove anúncios)

**Teste 3: Plano Premium**
1. ✅ Selecionar "Premium Completo" (R$ 8,99)
2. ✅ Assinar
3. ✅ Todas as features desbloqueadas
4. ✅ NENHUM anúncio aparece

**Teste 4: Restaurar Compras**
1. ✅ Desinstalar app
2. ✅ Reinstalar
3. ✅ Clicar "Restaurar"
4. ✅ Assinatura restaurada

### Testes para Desenvolvimento

```dart
// Simular upgrade
final subscription = Provider.of<SubscriptionProvider>(context, listen: false);
subscription.simulateUpgrade(SubscriptionTier.PREMIUM);

// Simular downgrade
subscription.simulateDowngrade();

// Testar paywall
if (true) {  // Forçar bloqueio
  return PaywallWidget(...);
}
```

---

## 🎁 Estratégias de Monetização

### 1. Trial Grátis de 7 Dias

```dart
// Configurar trial na Store
// Usuário pode testar Premium por 7 dias antes de pagar
```

### 2. Oferta de Lançamento

```dart
// Primeiro mês: 50% off
// Premium: R$ 8,99 → R$ 4,49
```

### 3. Black Friday / Promoções

```dart
// Desconto anual
// 12 meses por R$ 89,90 (economize 15%)
```

### 4. Programa de Indicação

```dart
// Indique um amigo, ganhe 1 mês grátis
```

### 5. Upsell Inteligente

```dart
// Se usar muito Ride Offers: sugerir upgrade para Premium
// "Você acessa ofertas 20x por dia. Economize com Premium!"
```

---

## 📋 Checklist de Go-Live

### Código
- [ ] Provider registrado no main.dart
- [ ] Rotas configuradas
- [ ] Paywalls integrados nas features
- [ ] Anúncios configurados nas telas
- [ ] Loading states implementados

### Stores
- [ ] Produtos criados no Google Play
- [ ] Produtos criados no App Store
- [ ] IDs de produtos configurados no código
- [ ] Testes de sandbox realizados
- [ ] Certificados e assinaturas configurados

### Legal
- [ ] Termos de Uso atualizados
- [ ] Política de Privacidade atualizada
- [ ] Política de Cancelamento documentada
- [ ] Política de Reembolso definida

### UX
- [ ] Descrições de planos claras
- [ ] Preços visíveis
- [ ] Benefícios destacados
- [ ] CTAs claros ("ASSINAR", "FAZER UPGRADE")
- [ ] Processo de compra testado

### Analytics
- [ ] Eventos configurados
- [ ] Dashboard de métricas criado
- [ ] Alertas de churn configurados
- [ ] A/B tests planejados

---

## 🚀 Lançamento Faseado

### Fase 1: Soft Launch (Semana 1)
- Lançar para 10% dos usuários
- Monitorar métricas
- Coletar feedback
- Ajustar preços se necessário

### Fase 2: Rollout (Semana 2-4)
- Aumentar para 50% → 100%
- Campanhas de marketing
- Push notifications sobre features Premium

### Fase 3: Otimização (Mês 2+)
- A/B tests de preços
- Testes de messaging
- Otimizar paywalls
- Adicionar ofertas especiais

---

## 📞 Suporte ao Usuário

### FAQs Comuns

**P: Como cancelo minha assinatura?**
R: Acesse a Google Play / App Store → Assinaturas → Cálculo de Gastos → Cancelar

**P: Posso mudar de plano?**
R: Sim! Acesse "Planos" no app e selecione outro plano. A mudança é proporcional.

**P: Há reembolso?**
R: Seguimos a política da loja (Google/Apple). Geralmente 48h para solicitar.

**P: O que acontece quando cancelo?**
R: Você continua com acesso até o fim do período pago.

**P: Posso usar em vários dispositivos?**
R: Sim! Basta fazer login com a mesma conta da loja.

---

## 🎉 Conclusão

O sistema freemium está completo e pronto para gerar receita recorrente! 💰

**Próximos Passos**:
1. Integrar com stores reais (Google Play / App Store)
2. Configurar produtos de assinatura
3. Testar em sandbox
4. Lançar para produção
5. Monitorar métricas
6. Otimizar conversão

**Receita Estimada** (1000 usuários ativos):
- 70% FREE: 700 usuários → R$ 0
- 20% Individual: 200 usuários × R$ 4,99 = R$ 998
- 10% Premium: 100 usuários × R$ 8,99 = R$ 899
- **Total: R$ 1.897/mês** 💸

Com crescimento e otimização, o potencial é enorme! 🚀
