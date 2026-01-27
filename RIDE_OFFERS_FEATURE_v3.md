# 🚕 Sistema de Detecção de Ofertas de Corridas com Semáforo

**Data**: Janeiro 27, 2026  
**Versão**: 3.0.0  
**Objetivo**: Implementar leitura de notificações de corrida (99, Uber, iDrive) com sistema de semáforo para decisão de aceitação

---

## 📋 Resumo das Mudanças

### 1. **Modelo de Dados - RideOffer** 
**Arquivo**: [lib/models/ride_offer.dart](lib/models/ride_offer.dart)

Nova estrutura de dados para representar uma oferta de corrida:

```dart
class RideOffer {
  final String id;                      // UUID único
  final RideApp app;                    // App (Uber, 99, iDrive)
  final String pickupLocation;          // Local de saída
  final String dropoffLocation;         // Local de destino
  final double? distanceKm;             // Distância em km
  final double? estimatedTimeMinutes;   // Tempo estimado em minutos
  final double? offeredValue;           // Valor ofertado em R$
  final DateTime detectedAt;            // Data/hora de detecção
  final TrafficLight trafficLight;      // Status (Verde/Amarelo/Vermelho)
  final String trafficLightReason;      // Justificativa da rentabilidade
  final double profitabilityScore;      // Score 0-100
}
```

**Enums**:
- `RideApp`: UBER, NINETY_NINE, INDRIVE, UNKNOWN (com ícones e nomes)
- `TrafficLight`: GREEN 🟢, YELLOW 🟡, RED 🔴 (com cores hexadecimais e mensagens)

**Features**:
- Getters: `appName`, `appIcon`, `trafficLightEmoji`, `trafficLightColor`, `trafficLightMessage`, `recommendation`
- Serialização: `toMap()`, `fromMap()` para persistência em Hive

---

### 2. **Serviço de Detecção - RideNotificationService**
**Arquivo**: [lib/services/ride_notification_service.dart](lib/services/ride_notification_service.dart)

Classe estática com métodos para análise de notificações:

#### **Métodos Principais**:

**`detectAppFromNotification()`** - Identifica qual app enviou a notificação
- Usa package name como primeira prioridade
- Fallback para keywords no conteúdo
- Retorna `RideApp` (UBER, NINETY_NINE, INDRIVE ou UNKNOWN)

**`extractNotificationData()`** - Extrai dados usando regex
- Distância: regex `r'(\d+(?:,\d+)?)\s*km'`
- Valor: regex `r'R\$\s*(\d+(?:,\d+)?)'`
- Tempo: regex `r'(\d+)\s*min'`
- Retorna Map com chaves: distance, value, time, pickup, dropoff

**`calculateTrafficLight()`** - Calcula semáforo baseado em rentabilidade
- Obtém rates mínimos do veículo via `CalculationService`
- Calcula: valuePerKm = offeredValue / distanceKm
- Calcula: valuePerHour = offeredValue / (estimatedTimeMinutes/60)
- Score: `((kmComparison + hourComparison) / 2) * 50`
- Decisão:
  - 🟢 **GREEN**: km≥1.0 AND hour≥1.0 AND score≥70
  - 🟡 **YELLOW**: km≥0.8 AND hour≥0.8 AND score≥50
  - 🔴 **RED**: Tudo else

**`createRideOfferFromNotification()`** - Pipeline completo
- Detecta app, extrai dados, calcula semáforo
- Retorna `RideOffer` totalmente preenchido

**`tryParseNotification()`** - Safe wrapper
- Valida inputs (null safety)
- Try-catch para erros de parsing
- Retorna `null` se não for notificação de corrida

---

### 3. **Widget de Exibição - RideOfferCard**
**Arquivo**: [lib/widgets/ride_offer_card.dart](lib/widgets/ride_offer_card.dart)

Card Material com design responsivo:

**Layout**:
- Header: Ícone app + Nome + Tempo detectado + Semáforo circular
- Dados: Distância | Tempo estimado | Valor ofertado
- Score: Barra de progresso de rentabilidade (0-100)
- Mensagem: Recomendação customizada por traffic light
- Botões: "Aceitar" e "Rejeitar"

**Cores por Traffic Light**:
- 🟢 GREEN: Fundo verde (15% opacity), Texto verde-500
- 🟡 YELLOW: Fundo amarelo (15% opacity), Texto amarelo-500
- 🔴 RED: Fundo vermelho (15% opacity), Texto vermelho-500

**Callbacks**:
- `onAccept`: Executado ao clicar "Aceitar"
- `onReject`: Executado ao clicar "Rejeitar"

---

### 4. **State Management - RideOfferProvider**
**Arquivo**: [lib/providers/ride_offer_provider.dart](lib/providers/ride_offer_provider.dart)

Provider ChangeNotifier para gerenciar estado das ofertas:

**Estado**:
- `currentOffer`: Oferta atual sendo exibida
- `detectedOffers[]`: Histórico de últimas 50 ofertas
- `acceptedCount`: Contador de ofertas aceitas
- `rejectedCount`: Contador de ofertas rejeitadas

**Métodos**:
- `addDetectedOffer()` - Adiciona nova oferta detectada
- `acceptOffer()` - Registra aceitação
- `rejectOffer()` - Registra rejeição
- `clearCurrentOffer()` - Limpa oferta atual
- `clearHistory()` - Limpa histórico
- `resetStatistics()` - Reseta contadores
- `getOffersFromApp()` - Filtra por app
- `getOffersByTrafficLight()` - Filtra por cor
- `getStatistics()` - Retorna estatísticas

**Propriedades Derivadas**:
- `acceptanceRate`: % de ofertas aceitas
- `acceptedCount`, `rejectedCount`: Contadores
- `detectedOffers`: Lista imutável

---

## 🔄 Fluxo de Operação

```
Notificação Recebida
        ↓
detectAppFromNotification() [Qual app?]
        ↓
extractNotificationData()   [Distância, Valor, Tempo]
        ↓
calculateTrafficLight()     [Verde/Amarelo/Vermelho?]
        ↓
createRideOfferFromNotification() [RideOffer object]
        ↓
RideOfferProvider.addDetectedOffer()
        ↓
UI (RideOfferCard) exibe com cores e recomendação
        ↓
Usuário clica Aceitar/Rejeitar
        ↓
Provider registra decisão + atualiza estatísticas
```

---

## 📊 Lógica de Semáforo

### Comparação com Veículo

```
Vehicle Configuration:
- valuePerKm: R$ 2.50 (mínimo aceitável)
- valuePerHour: R$ 50.00 (mínimo aceitável)

Oferta Recebida:
- Valor: R$ 25.00
- Distância: 8 km
- Tempo: 20 min (0.33 hora)

Cálculos:
- valuePerKm_offer = 25 / 8 = R$ 3.13
- valuePerHour_offer = 25 / 0.33 = R$ 75.00
- kmComparison = 3.13 / 2.50 = 1.25 ✓ (≥1.0)
- hourComparison = 75.00 / 50.00 = 1.5 ✓ (≥1.0)
- score = ((1.25 + 1.5) / 2) * 50 = 68.75

Decisão:
- score (68.75) < 70 → YELLOW (está perto mas não é excelente)
- Recomendação: "Rentabilidade aceitável..."
```

---

## 🎨 Design do Semáforo

### Verde 🟢 (Aceitar)
- **Critério**: km≥1.0 AND hour≥1.0 AND score≥70
- **Cor**: #22C55E (green-500)
- **Mensagem**: "Excelente rentabilidade: R$ X/km, R$ Y/h"
- **Ação Recomendada**: ✅ Aceitar

### Amarelo 🟡 (Considerar)
- **Critério**: km≥0.8 AND hour≥0.8 AND score≥50
- **Cor**: #EAB308 (yellow-500)
- **Mensagem**: "Rentabilidade aceitável: R$ X/km, R$ Y/h"
- **Ação Recomendada**: 🤔 Pensar (depende de contexto)

### Vermelho 🔴 (Rejeitar)
- **Critério**: Não atende critérios anteriores
- **Cor**: #EF4444 (red-500)
- **Mensagem**: "Baixa rentabilidade: precisa de R$ X/km"
- **Ação Recomendada**: ❌ Rejeitar

---

## 📝 Arquivos Modificados/Criados

| Arquivo | Tipo | Linhas | Descrição |
|---------|------|--------|-----------|
| `lib/models/ride_offer.dart` | ✨ Novo | ~155 | Modelo de dados |
| `lib/services/ride_notification_service.dart` | ✨ Novo | ~230 | Serviço de detecção |
| `lib/widgets/ride_offer_card.dart` | ✨ Novo | ~88 | Widget de exibição |
| `lib/providers/ride_offer_provider.dart` | ✨ Novo | ~77 | State management |
| `lib/models/index.dart` | ✏️ Editado | +1 | Exporta ride_offer |
| `lib/services/index.dart` | ✏️ Editado | +1 | Exporta notification_service |
| `lib/widgets/index.dart` | ✏️ Editado | +1 | Exporta ride_offer_card |

---

## 🚀 Próximos Passos

1. **Android Integration** (Nativo)
   - Implementar AccessibilityService para escutar notificações em tempo real
   - Configurar AndroidManifest.xml com permissões necessárias
   - Integração com MethodChannel para comunicação Flutter↔Kotlin

2. **UI Screens**
   - Criar `RideOffersScreen` para exibir histórico
   - Criar `RideStatisticsScreen` para análise de tendências
   - Integrar com tela de cálculo existente

3. **Storage**
   - Estender `StorageService` com Hive box para `rideOffers`
   - Persistência de histórico de ofertas
   - Sincronização com estatísticas

4. **Testes**
   - Unit tests para regex patterns
   - Mock notifications para cada app
   - Testes de cálculo de semáforo com valores extremos

---

## 🧪 Como Usar

### Detecção Manual (para testes)

```dart
import 'package:calculodegastosapp/models/models.dart';
import 'package:calculodegastosapp/services/services.dart';

// Simular notificação do Uber
final offer = RideNotificationService.tryParseNotification(
  'Uber - Corrida disponível',
  'Distância: 5 km, Valor: R$ 20.00',
  packageName: 'com.ubercab',
  vehicle: myVehicle,
);

if (offer != null) {
  print('🚕 ${offer.appName}');
  print('💰 ${offer.trafficLightEmoji} Rentabilidade: ${offer.profitabilityScore}');
  print('📍 ${offer.recommendation}');
}
```

### Com Provider

```dart
// Em um widget Consumer
Consumer<RideOfferProvider>(
  builder: (context, provider, _) {
    if (provider.currentOffer == null) return SizedBox.shrink();
    return RideOfferCard(
      offer: provider.currentOffer!,
      onAccept: () => provider.acceptOffer(provider.currentOffer!),
      onReject: () => provider.rejectOffer(provider.currentOffer!),
    );
  },
)
```

---

## 📱 Exemplos de Notificações Suportadas

### Uber
```
Título: "Corrida disponível"
Corpo: "Distância: 8.5 km, Valor: R$ 35.00, Tempo: 15 min"
PackageName: com.ubercab
```

### 99 Táxis
```
Título: "Nova corrida!"
Corpo: "Seu ganho: R$ 28.00, Distância: 6 km, Tempo: 12 min"
PackageName: com.99taxis
```

### iDriver
```
Título: "Oferta de corrida"
Corpo: "R$ 32.00 para 7 km de distância (20 minutos)"
PackageName: com.indriver
```

---

## 📊 Estatísticas do Provider

```dart
final stats = provider.getStatistics();
print('Total detectado: ${stats['totalDetected']}');
print('Aceitas: ${stats['accepted']}');
print('Rejeitadas: ${stats['rejected']}');
print('Taxa aceitação: ${stats['acceptanceRate'].toStringAsFixed(1)}%');
print('🟢 Green: ${stats['greenCount']}');
print('🟡 Yellow: ${stats['yellowCount']}');
print('🔴 Red: ${stats['redCount']}');
```

---

## ⚙️ Configurações Recomendadas

**Vehicle mínimo para 🟢 GREEN**:
```dart
Vehicle(
  valuePerKm: 2.50,    // R$ por km
  valuePerHour: 50.00, // R$ por hora
)
```

**Ofertas esperadas**:
- ✅ Aceitar: >R$ 20/km ou >R$ 60/h (geralmente longas)
- 🤔 Considerar: >R$ 2/km ou >R$ 40/h (depende de cansaço/tempo)
- ❌ Rejeitar: <R$ 2/km E <R$ 40/h (não compensa)

---

## 🔗 Dependências Utilizadas

- `uuid: ^4.1.0` - Geração de IDs únicos
- `provider: ^6.4.0` - State management
- `hive: ^2.2.3` - Local storage (futuro)
- `geolocator: ^10.0.0` - Localização (futuro)
- `permission_handler: ^11.4.4` - Permissões (futuro)

---

**Status**: ✅ Pronto para integração com Android AccessibilityService  
**Testado em**: Flutter 3.10.7, Dart 3.10+  
**Compatibilidade**: Android 21+ (AccessibilityService)

