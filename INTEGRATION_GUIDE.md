# 🔧 Guia de Integração - Sistema Freemium

**Tempo estimado**: 30-60 minutos  
**Dificuldade**: Intermediária

---

## ✅ Checklist Rápido

```
[ ] 1. Registrar SubscriptionProvider no main.dart
[ ] 2. Adicionar paywall na tela de Ride Offers
[ ] 3. Adicionar paywall na tela Financeira
[ ] 4. Adicionar anúncio intersticial ao gerar cálculo
[ ] 5. Adicionar banners de anúncio nas telas gratuitas
[ ] 6. Adicionar menu de assinatura
[ ] 7. Testar fluxo completo
[ ] 8. Configurar stores (Google Play / App Store)
```

---

## Passo 1: Registrar Provider (5 min)

**Arquivo**: `lib/main.dart`

**Adicionar import**:
```dart
import 'providers/subscription_provider.dart';
```

**Atualizar MultiProvider**:
```dart
return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => VehicleProvider()),
    ChangeNotifierProvider(create: (_) => RideOfferProvider()), // Se existir
    ChangeNotifierProvider(create: (_) => FinancialProvider()), // Se existir
    ChangeNotifierProvider(create: (_) => SubscriptionProvider()), // ← NOVO
  ],
  child: MaterialApp(
    // ...
  ),
);
```

**Carregar assinatura no startup** (opcional mas recomendado):

No `main.dart` ou na `HomeScreen`:
```dart
@override
void initState() {
  super.initState();
  
  // Carregar assinatura ao iniciar
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<SubscriptionProvider>(context, listen: false)
      .loadSubscription();
  });
}
```

---

## Passo 2: Bloquear Tela de Ride Offers (10 min)

**Arquivo**: `lib/screens/ride_offers_screen.dart`

**Adicionar imports**:
```dart
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/paywall_widget.dart';
import '../models/subscription_plan.dart';
import '../screens/subscription_plans_screen.dart';
```

**Envolver tela com verificação**:
```dart
class RideOffersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        // Verificar se tem permissão
        if (!subscription.canUseRideOffers) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Sistema de Semáforo'),
            ),
            body: PaywallWidget(
              featureName: 'Sistema de Semáforo',
              featureDescription: 'Análise inteligente de ofertas de corridas com recomendações verde, amarelo e vermelho para maximizar seus ganhos.',
              featureIcon: Icons.traffic,
              requiredTier: SubscriptionTier.RIDE_OFFERS,
              onUpgrade: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubscriptionPlansScreen(),
                  ),
                );
              },
            ),
          );
        }

        // Feature liberada - continuar com conteúdo normal
        return _buildOriginalContent();
      },
    );
  }

  Widget _buildOriginalContent() {
    // Seu código original da tela
    return Scaffold(
      appBar: AppBar(title: Text('Sistema de Semáforo')),
      body: Center(
        child: Text('Conteúdo do sistema de semáforo'),
      ),
    );
  }
}
```

**Alternativa (verificação em método específico)**:

Se preferir bloquear apenas uma função:
```dart
void _openRideAnalysis() {
  final subscription = Provider.of<SubscriptionProvider>(
    context,
    listen: false,
  );

  if (!subscription.canUseRideOffers) {
    // Mostrar dialog explicando
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Feature Premium'),
        content: Text('O Sistema de Semáforo está disponível no plano Análise de Corridas (R\$ 4,99/mês).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubscriptionPlansScreen(),
                ),
              );
            },
            child: Text('VER PLANOS'),
          ),
        ],
      ),
    );
    return;
  }

  // Continuar com feature
  // ...
}
```

---

## Passo 3: Bloquear Tela Financeira (10 min)

**Arquivo**: `lib/screens/financial_dashboard_screen.dart`

**Mesmo processo do Passo 2**:
```dart
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/paywall_widget.dart';
import '../models/subscription_plan.dart';
import '../screens/subscription_plans_screen.dart';

class FinancialDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        // Verificar permissão
        if (!subscription.canUseFinancial) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Controle Financeiro'),
            ),
            body: PaywallWidget(
              featureName: 'Controle Financeiro',
              featureDescription: 'Gerencie suas receitas e despesas para saber exatamente quanto você está lucrando.',
              featureIcon: Icons.account_balance_wallet,
              requiredTier: SubscriptionTier.FINANCIAL,
              onUpgrade: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubscriptionPlansScreen(),
                  ),
                );
              },
            ),
          );
        }

        // Feature liberada
        return _buildFinancialDashboard();
      },
    );
  }

  Widget _buildFinancialDashboard() {
    // Seu código original
    return Scaffold(
      appBar: AppBar(title: Text('Controle Financeiro')),
      body: Center(
        child: Text('Dashboard financeiro'),
      ),
    );
  }
}
```

---

## Passo 4: Anúncio ao Gerar Cálculo (10 min)

**Arquivo**: Tela onde o cálculo é gerado (ex: `lib/screens/calculation_screen.dart`)

**Adicionar imports**:
```dart
import '../widgets/ad_banner_widget.dart';
```

**Modificar método que gera cálculo**:
```dart
Future<void> _generateCalculation() async {
  // Calcular
  final result = await _calculateCosts();

  // Mostrar anúncio antes de exibir resultado
  await InterstitialAdDialog.show(
    context,
    onClosed: () {
      // Após fechar anúncio, mostrar resultado
      _showCalculationResult(result);
    },
  );
}

void _showCalculationResult(CalculationResult result) {
  // Navegar para tela de resultado ou mostrar dialog
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ResultScreen(result: result),
    ),
  );
}
```

**Nota**: Usuários Premium pulam o anúncio automaticamente (já implementado no `InterstitialAdDialog`).

---

## Passo 5: Banners de Anúncio (PULAR)

⚠️ **IMPORTANTE**: Este passo deve ser PULADO.

**Apenas anúncios de vídeo (InterstitialAdDialog) devem ser usados.**

NÃO adicione `AdBannerWidget` em nenhuma tela. O widget existe apenas como referência histórica.

✅ **O que fazer**: Use apenas o `InterstitialAdDialog` antes de mostrar resultados de cálculo (já implementado no Passo 4).

---

## Passo 6: Menu de Assinatura (10 min)

**Opção A: Na HomeScreen**

```dart
import '../screens/subscription_plans_screen.dart';
import '../providers/subscription_provider.dart';
import 'package:provider/provider.dart';

FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionPlansScreen(),
      ),
    );
  },
  child: Icon(Icons.workspace_premium),
  tooltip: 'Ver Planos Premium',
)
```

**Opção B: No Drawer/Menu Lateral**

```dart
Consumer<SubscriptionProvider>(
  builder: (context, subscription, child) {
    return Column(
      children: [
        // Cabeçalho do drawer
        DrawerHeader(
          child: Text('Menu'),
        ),
        
        // Item de assinatura
        ListTile(
          leading: Icon(
            subscription.isPremium ? Icons.star : Icons.workspace_premium,
            color: subscription.isPremium ? Colors.amber : Colors.grey,
          ),
          title: Text(
            subscription.isPremium ? 'Premium Ativo' : 'Fazer Upgrade',
            style: TextStyle(
              fontWeight: subscription.isPremium 
                ? FontWeight.bold 
                : FontWeight.normal,
            ),
          ),
          subtitle: Text(subscription.currentTier.displayName),
          trailing: subscription.isPremium
            ? Icon(Icons.check_circle, color: Colors.green, size: 20)
            : Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pop(context); // Fechar drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubscriptionPlansScreen(),
              ),
            );
          },
        ),
        
        Divider(),
        
        // Outros itens do menu
        // ...
      ],
    );
  },
)
```

**Opção C: Badge no AppBar**

```dart
AppBar(
  title: Text('Cálculo de Gastos'),
  actions: [
    Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        return IconButton(
          icon: subscription.isPremium
            ? Icon(Icons.star, color: Colors.amber)
            : Icon(Icons.workspace_premium),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubscriptionPlansScreen(),
              ),
            );
          },
          tooltip: subscription.isPremium ? 'Premium Ativo' : 'Ver Planos',
        );
      },
    ),
  ],
)
```

---

## Passo 7: Testar Fluxo (10 min)

### Cenário 1: Usuário Gratuito
1. ✅ Abrir app → Verificar que inicia em plano FREE
2. ✅ Ver anúncio banner na home
3. ✅ Tentar acessar Ride Offers → Ver paywall
4. ✅ Tentar acessar Financeiro → Ver paywall
5. ✅ Gerar cálculo → Ver anúncio intersticial
6. ✅ Clicar em "Ver Planos" → Abrir SubscriptionPlansScreen

### Cenário 2: Comprar Plano
1. ✅ Na tela de planos, selecionar "Análise de Corridas"
2. ✅ Clicar "ASSINAR ANÁLISE DE CORRIDAS"
3. ✅ Simular compra bem-sucedida
4. ✅ Ver mensagem de sucesso
5. ✅ Verificar que Ride Offers está desbloqueado
6. ✅ Verificar que Financeiro ainda está bloqueado
7. ✅ **Verificar que NENHUM anúncio aparece** (qualquer assinatura remove anúncios)

### Cenário 3: Upgrade para Premium
1. ✅ Selecionar "Premium Completo"
2. ✅ Verificar badge "RECOMENDADO"
3. ✅ Verificar mensagem de economia (R$ 0,99)
4. ✅ Assinar
5. ✅ Verificar que todas as features estão desbloqueadas
6. ✅ Verificar que NENHUM anúncio aparece

### Cenário 4: Info de Assinatura
1. ✅ Com assinatura ativa, abrir tela de planos
2. ✅ Ver card "Assinatura Atual"
3. ✅ Ver data de expiração
4. ✅ Ver dias restantes
5. ✅ Clicar "Gerenciar Assinatura" → Abrir store

### Simular Planos (Para Teste)

No código temporário (remover depois):
```dart
// Para testar Premium
Provider.of<SubscriptionProvider>(context, listen: false)
  .simulateUpgrade(SubscriptionTier.PREMIUM);

// Para testar FREE
Provider.of<SubscriptionProvider>(context, listen: false)
  .simulateDowngrade();
```

---

## Passo 8: Configurar Stores (Produção)

### Google Play Console

1. **Acessar**: https://play.google.com/console
2. **Navegue**: Seu App → Monetizar → Produtos → Assinaturas
3. **Criar 3 assinaturas**:

**Assinatura 1: Análise de Corridas**
- ID: `ride_offers_monthly`
- Nome: Análise de Corridas
- Descrição: Sistema de semáforo para corridas
- Preço: R$ 4,99
- Período: 1 mês
- Renovação: Automática
- Trial (opcional): 7 dias grátis

**Assinatura 2: Controle Financeiro**
- ID: `financial_monthly`
- Nome: Controle Financeiro
- Descrição: Gerencie receitas e despesas
- Preço: R$ 4,99
- Período: 1 mês
- Renovação: Automática
- Trial (opcional): 7 dias grátis

**Assinatura 3: Premium Completo**
- ID: `premium_monthly`
- Nome: Premium Completo
- Descrição: Todos os recursos sem anúncios
- Preço: R$ 8,99
- Período: 1 mês
- Renovação: Automática
- Trial (opcional): 7 dias grátis

4. **Testar em Sandbox**:
   - Adicionar email de teste em "Configurações → Testers de licença"
   - Instalar app em modo debug
   - Testar compras (não será cobrado)

### App Store Connect

1. **Acessar**: https://appstoreconnect.apple.com
2. **Navegue**: Seu App → Recursos → Compras no App
3. **Criar Grupo de Assinaturas**:
   - Nome: "Planos Premium"

4. **Adicionar 3 Assinaturas** (mesmo processo do Google Play):
   - `ride_offers_monthly` - R$ 4,99
   - `financial_monthly` - R$ 4,99
   - `premium_monthly` - R$ 8,99

5. **Configurar Preços**:
   - Selecionar Brasil (BRL)
   - R$ 4,99 e R$ 8,99

6. **Testar em Sandbox**:
   - Configurações → Usuários e Acesso → Sandbox Testers
   - Criar usuário de teste
   - Testar no dispositivo

---

## 🔧 Integração com in_app_purchase

**Adicionar dependência** (`pubspec.yaml`):
```yaml
dependencies:
  in_app_purchase: ^3.1.11
```

**Atualizar SubscriptionService** (`lib/services/subscription_service.dart`):

```dart
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService {
  static final InAppPurchase _iap = InAppPurchase.instance;

  // Inicializar no main.dart
  static Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) {
      print('In-App Purchase não disponível neste dispositivo');
    }
  }

  // Substituir método mockup
  static Future<bool> purchaseSubscription(SubscriptionTier tier) async {
    try {
      // 1. Obter detalhes do produto
      final productIds = {tier.productId};
      final response = await _iap.queryProductDetails(productIds);
      
      if (response.productDetails.isEmpty) {
        print('Produto não encontrado: ${tier.productId}');
        return false;
      }

      // 2. Iniciar compra
      final product = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: product);
      
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      
      // 3. Aguardar confirmação via purchaseStream
      return true;
    } catch (e) {
      print('Erro ao comprar: $e');
      return false;
    }
  }

  // Escutar compras completadas
  static Stream<List<PurchaseDetails>> get purchaseStream {
    return _iap.purchaseStream;
  }
}
```

**Escutar compras no Provider**:

```dart
// lib/providers/subscription_provider.dart

class SubscriptionProvider extends ChangeNotifier {
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  SubscriptionProvider() {
    _listenToPurchaseUpdates();
  }

  void _listenToPurchaseUpdates() {
    _subscription = SubscriptionService.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          _handlePurchaseUpdate(purchase);
        }
        
        if (purchase.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(purchase);
        }
      }
    });
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchase) async {
    // Validar e ativar assinatura
    // Atualizar _subscription
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

---

## 📊 Analytics (Opcional mas Recomendado)

**Firebase Analytics**:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

// Quando usuário visualiza planos
FirebaseAnalytics.instance.logEvent(
  name: 'subscription_plans_viewed',
);

// Quando usuário clica em plano
FirebaseAnalytics.instance.logEvent(
  name: 'subscription_selected',
  parameters: {
    'tier': tier.name,
    'price': tier.priceMonthly,
  },
);

// Quando compra é concluída
FirebaseAnalytics.instance.logEvent(
  name: 'purchase',
  parameters: {
    'item_id': tier.productId,
    'item_name': tier.displayName,
    'value': tier.priceMonthly,
    'currency': 'BRL',
  },
);
```

---

## ⚠️ Problemas Comuns

### 1. Provider não encontrado

**Erro**: `Could not find the correct Provider<SubscriptionProvider>`

**Solução**: Verificar se `SubscriptionProvider` está registrado no `MultiProvider` no `main.dart`.

### 2. Produtos não carregam na Store

**Erro**: `queryProductDetails` retorna vazio

**Solução**: 
- Verificar que IDs no código coincidem com IDs na Store
- Aguardar aprovação dos produtos (pode levar 24h)
- Testar em dispositivo real (não funciona em emulador)

### 3. Anúncios não aparecem

**Causa**: Ainda é placeholder mockup

**Solução**: Integrar AdMob (ver seção de AdMob abaixo)

### 4. Assinatura não restaura

**Solução**: Implementar validação no backend (recomendado)

---

## 🎯 Próximos Passos Opcionais

### 1. Integrar AdMob (Anúncios Reais)

```yaml
dependencies:
  google_mobile_ads: ^4.0.0
```

Substituir `AdBannerWidget` com:
```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

BannerAd(
  adUnitId: 'ca-app-pub-XXXXXXXX/XXXXXXXXXX',
  size: AdSize.banner,
  request: AdRequest(),
  listener: BannerAdListener(),
)..load();
```

### 2. Backend de Validação

Criar endpoint para validar compras:
```
POST /api/validate-purchase
{
  "purchaseToken": "...",
  "productId": "premium_monthly",
  "userId": "..."
}
```

### 3. Push Notifications

Lembrar usuários:
- Dia 7 do trial: "Trial acaba amanhã!"
- Assinatura próxima do fim: "Renove sua assinatura"
- Oferta especial: "50% off este mês!"

### 4. A/B Testing

Testar:
- Preços diferentes
- Descrições de planos
- Posicionamento de paywalls
- Timing de anúncios

---

## 📞 Suporte

Dúvidas? Consulte:
- [FREEMIUM_SYSTEM_v3.2.md](FREEMIUM_SYSTEM_v3.2.md) - Documentação completa
- [Código fonte](lib/models/subscription_plan.dart) - Implementação

---

## ✅ Checklist Final

```
[ ] SubscriptionProvider registrado
[ ] Paywalls adicionados (Ride Offers + Financeiro)
[ ] Anúncio intersticial ao gerar cálculo
[ ] Banners em telas gratuitas
[ ] Menu de assinatura
[ ] Testes manuais passando
[ ] Produtos criados no Google Play
[ ] Produtos criados no App Store
[ ] in_app_purchase integrado
[ ] Testes em sandbox realizados
```

**Parabéns! Sistema freemium integrado! 🎉**
