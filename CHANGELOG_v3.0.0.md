# 📱 App "Cálculo de Gastos" - v3.0.0 Changelog

**Data de Lançamento**: 27 de Janeiro, 2026  
**Versão anterior**: 2.0.0  
**Status**: ✅ Pronto para Testes

---

## 🎯 Nova Funcionalidade: Sistema de Semáforo para Ofertas de Corridas

### 📝 Resumo Executivo

Implementação completa de um sistema inteligente que:
- 📱 **Detecta notificações** de ofertas de corridas (Uber, 99 Táxis, iDriver)
- 🧮 **Analisa rentabilidade** em tempo real
- 🚦 **Exibe sistema de semáforo** (Verde/Amarelo/Vermelho) para decisão rápida
- 📊 **Registra estatísticas** de aceitar/rejeitar ofertas

---

## 🆕 Arquivos Adicionados

### 1. **lib/models/ride_offer.dart** (155 linhas)
Modelo de dados para ofertas de corrida com:
- `RideApp enum`: UBER, NINETY_NINE, INDRIVE, UNKNOWN
- `TrafficLight enum`: GREEN 🟢, YELLOW 🟡, RED 🔴
- `RideOffer class`: Dados completos da oferta + semáforo + score de rentabilidade
- Serialização/Desserialização para Hive

**Exemplo de uso**:
```dart
final offer = RideOffer(
  id: '12345',
  app: RideApp.UBER,
  distanceKm: 8.5,
  offeredValue: 35.00,
  estimatedTimeMinutes: 15,
  trafficLight: TrafficLight.GREEN,
  profitabilityScore: 85.5,
);

print('${offer.appIcon} ${offer.appName}'); // 🚗 Uber
print(offer.trafficLightEmoji);              // 🟢
print(offer.recommendation);                 // Excelente rentabilidade!
```

---

### 2. **lib/services/ride_notification_service.dart** (230 linhas)
Serviço estático de detecção e análise de notificações:

**Métodos**:

#### `detectAppFromNotification()`
- Identifica qual app enviou a notificação
- Priority: package name > keywords no conteúdo
- Returns: `RideApp`

#### `extractNotificationData()`
- Extrai distância, valor e tempo usando regex patterns
- Padrões suportados:
  - Distância: `r'(\d+(?:,\d+)?)\s*km'`
  - Valor: `r'R\$\s*(\d+(?:,\d+)?)'`
  - Tempo: `r'(\d+)\s*min'`
- Returns: `Map<String, dynamic>` com dados extraídos

#### `calculateTrafficLight()`
- Compara oferta contra valores mínimos do veículo
- Calcula: valuePerKm, valuePerHour, profitability score
- Decisão automática:
  - 🟢 GREEN: Excelente (≥70% score)
  - 🟡 YELLOW: Aceitável (≥50% score)
  - 🔴 RED: Baixo (< 50% score)
- Returns: `TrafficLightResult` com luz + razão + score

#### `createRideOfferFromNotification()`
- Pipeline completo: detecta → extrai → calcula → cria RideOffer
- Returns: `RideOffer` totalmente preenchido e analisado

#### `tryParseNotification()`
- Wrapper seguro com error handling
- Returns: `RideOffer?` (null se não for notificação de corrida)

**Exemplo**:
```dart
final offer = RideNotificationService.tryParseNotification(
  'Uber - Corrida disponível',
  'Distância: 8.5 km, Valor: R\$ 35.00, Tempo: 15 min',
  packageName: 'com.ubercab',
  vehicle: myVehicle,
);

if (offer != null) {
  print('🟢 ${offer.profitabilityScore}/100');
  print(offer.trafficLightMessage);
}
```

---

### 3. **lib/widgets/ride_offer_card.dart** (88 linhas)
Widget Material para exibição visual de ofertas:

**Layout**:
```
┌─────────────────────────────────────┐
│ 🚗 Uber          Há 2m         🟢   │
├─────────────────────────────────────┤
│ Distância: 8.5km │ Tempo: 15min     │
│                  │ Valor: R$ 35.00  │
├─────────────────────────────────────┤
│ Rentabilidade: 85/100               │
│ ████████████████░░░░░░░░░░░░░░░░   │
├─────────────────────────────────────┤
│ Excelente rentabilidade              │
│ R$4.12/km, R$140/h                  │
├─────────────────────────────────────┤
│ [Rejeitar]          [Aceitar]        │
└─────────────────────────────────────┘
```

**Cores dinâmicas**:
- 🟢 GREEN: Fundo verde claro, texto green-500
- 🟡 YELLOW: Fundo amarelo claro, texto yellow-500
- 🔴 RED: Fundo vermelho claro, texto red-500

**Props**:
- `offer`: RideOffer a exibir
- `onAccept`: Callback ao aceitar
- `onReject`: Callback ao rejeitar

---

### 4. **lib/providers/ride_offer_provider.dart** (77 linhas)
Provider ChangeNotifier para gerenciar estado:

**Estado**:
- `currentOffer`: Oferta atual sendo exibida
- `detectedOffers[]`: Histórico (últimas 50)
- `acceptedCount`, `rejectedCount`: Contadores

**Métodos**:
- `addDetectedOffer(offer)` - Adiciona nova oferta
- `acceptOffer(offer)` - Registra aceitação
- `rejectOffer(offer)` - Registra rejeição
- `clearCurrentOffer()` - Limpa oferta atual
- `clearHistory()` - Limpa histórico
- `resetStatistics()` - Reseta contadores
- `getOffersFromApp(app)` - Filtra por app
- `getOffersByTrafficLight(light)` - Filtra por cor
- `getStatistics()` - Retorna dict com dados

**Propriedades Derivadas**:
- `acceptanceRate`: % de aceitas
- `detectedOffers`: Lista imutável

**Exemplo**:
```dart
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

## 📝 Arquivos Modificados

| Arquivo | Mudança | Linhas |
|---------|---------|--------|
| `lib/models/index.dart` | Adicionado export | +1 |
| `lib/services/index.dart` | Adicionado export | +1 |
| `lib/widgets/index.dart` | Adicionado export | +1 |
| `pubspec.yaml` | Ajustadas versões de dependências | ±2 |

---

## 🔧 Lógica de Semáforo (Algoritmo)

### Comparação com Veículo

```
VEÍCULO CONFIGURADO:
├─ Valor Mínimo por KM: R$ 2.50
└─ Valor Mínimo por HORA: R$ 50.00

OFERTA RECEBIDA:
├─ Distância: 8 km
├─ Tempo: 20 minutos
├─ Valor Total: R$ 25.00
└─ Ganho Bruto (30%): R$ 7.50

CÁLCULOS:
├─ valuePerKm_oferta = 25 / 8 = R$ 3.13/km
├─ valuePerHour_oferta = 25 / (20/60) = R$ 75.00/h
├─ kmComparison = 3.13 / 2.50 = 1.25 ✓
├─ hourComparison = 75.00 / 50.00 = 1.5 ✓
└─ profitabilityScore = ((1.25 + 1.5) / 2) * 50 = 68.75

DECISÃO FINAL:
├─ score (68.75) >= 70? NÃO
├─ score (68.75) >= 50? SIM
├─ km (1.25) >= 0.8? SIM
├─ hour (1.5) >= 0.8? SIM
└─ RESULTADO: 🟡 YELLOW (Considerável)
```

### Matriz de Decisão

| Critério | GREEN 🟢 | YELLOW 🟡 | RED 🔴 |
|----------|---------|----------|---------|
| Score | ≥70 | 50-70 | <50 |
| km/km_min | ≥1.0 | 0.8-1.0 | <0.8 |
| h/h_min | ≥1.0 | 0.8-1.0 | <0.8 |
| Ação | Aceitar | Pensar | Rejeitar |

---

## 📊 Exemplos de Notificações Suportadas

### Uber
```
TITLE: "Corrida disponível"
BODY: "Distância: 8.5 km, Valor: R$ 35.00, Tempo: 15 min"
PACKAGE: com.ubercab
```

### 99 Táxis
```
TITLE: "Nova corrida!"
BODY: "Seu ganho: R$ 28.00, Distância: 6 km, Tempo: 12 min"
PACKAGE: com.99taxis
```

### iDriver
```
TITLE: "Oferta de corrida"
BODY: "R$ 32.00 para 7 km de distância (20 minutos)"
PACKAGE: com.indriver
```

---

## 🚀 Roadmap Futuro

### Fase 1: Android Integration (Próxima)
- [ ] Implementar AccessibilityService (Kotlin)
- [ ] Escuta em tempo real de notificações
- [ ] Method Channel para Flutter↔Native
- [ ] Configurar AndroidManifest.xml

### Fase 2: UI Avançada
- [ ] Tela de histórico de ofertas
- [ ] Dashboard de estatísticas
- [ ] Gráficos de aceitação/rejeição
- [ ] Filtros por app/traffic light

### Fase 3: Persistência & Analytics
- [ ] Hive box para rideOffers history
- [ ] Sincronização com CalculationService
- [ ] Análise de tendências
- [ ] Recomendações de horários melhores

### Fase 4: IA & Automação
- [ ] Sugestões automáticas baseadas em histórico
- [ ] Alertas de ofertas especialmente boas
- [ ] Previsão de rentabilidade horária
- [ ] Integração com MapsService

---

## ✅ Checklist de Implementação

- [x] Modelo RideOffer com enums
- [x] Serialização/Desserialização
- [x] Serviço de detecção com regex
- [x] Cálculo de semáforo
- [x] Widget de exibição
- [x] Provider ChangeNotifier
- [x] Exports em index files
- [x] Documentação completa
- [ ] Testes unitários (pendente)
- [ ] Integração Android (pendente)
- [ ] Telas de UI (pendente)
- [ ] Persistência Hive (pendente)

---

## 🔒 Segurança & Performance

### Segurança
- ✅ Null safety em toda a base
- ✅ Validação de entradas (tryParseNotification)
- ✅ Tratamento de exceções
- ✅ Sem acesso a permissões sensíveis (por enquanto)

### Performance
- ✅ Métodos estáticos (sem instância)
- ✅ Limite de 50 ofertas no histórico
- ✅ Regex compilado eficientemente
- ✅ ChangeNotifier para UI updates otimizados

---

## 📦 Dependências Utilizadas

```yaml
uuid: ^4.1.0              # Geração de IDs
provider: ^6.1.5          # State management
hive: ^2.2.3              # Local storage (futuro)
hive_flutter: ^1.1.0      # Hive para Flutter
geolocator: ^9.0.2        # Localização (futuro)
```

---

## 🧪 Como Testar

### Teste Manual (em main.dart ou debug)

```dart
// Simular notificação de teste
final testVehicle = Vehicle(
  name: 'Teste',
  valuePerKm: 2.50,
  valuePerHour: 50.00,
  // ... outros campos
);

final offer = RideNotificationService.tryParseNotification(
  'Uber - Corrida disponível',
  'Distância: 8.5 km, Valor: R\$ 35.00, Tempo: 15 min',
  packageName: 'com.ubercab',
  vehicle: testVehicle,
);

debugPrint('Oferta: ${offer?.appIcon} ${offer?.appName}');
debugPrint('Semáforo: ${offer?.trafficLightEmoji}');
debugPrint('Score: ${offer?.profitabilityScore}');
debugPrint('Mensagem: ${offer?.trafficLightMessage}');
```

### Teste com Provider

```dart
// Em um widget test
testWidgets('RideOfferCard displays correctly', (tester) async {
  final offer = RideOffer(
    id: '1',
    app: RideApp.UBER,
    distanceKm: 8.5,
    offeredValue: 35.0,
    estimatedTimeMinutes: 15,
    trafficLight: TrafficLight.GREEN,
    profitabilityScore: 85.5,
    // ... outros campos
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RideOfferCard(offer: offer),
      ),
    ),
  );

  expect(find.text('Uber'), findsOneWidget);
  expect(find.text('🟢'), findsOneWidget);
});
```

---

## 📞 Suporte & Perguntas

Para mais informações sobre como integrar com o Android AccessibilityService ou usar o Provider em suas telas, consulte:
- [RIDE_OFFERS_FEATURE_v3.md](RIDE_OFFERS_FEATURE_v3.md) - Documentação técnica completa
- [lib/models/ride_offer.dart](lib/models/ride_offer.dart) - Implementação detalhada
- [lib/services/ride_notification_service.dart](lib/services/ride_notification_service.dart) - Lógica de detecção

---

**Versão**: 3.0.0  
**Data**: 27 de Janeiro, 2026  
**Status**: ✅ Pronto para Testes / Integração Android  
**Próxima Versão**: 3.1.0 (Com AccessibilityService)

