# 🏗️ Arquitetura do Projeto

## 📊 Diagrama de Fluxo de Dados

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTAÇÃO (UI Layer)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │  HomeScreen  │  │HistoryScreen │  │RealTimeTripScreen    │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘   │
│         │                  │                      │               │
│         │  Ações           │  Querys              │  Eventos      │
│         │                  │                      │               │
└─────────┼──────────────────┼──────────────────────┼───────────────┘
          │                  │                      │
          ▼                  ▼                      ▼
┌─────────────────────────────────────────────────────────────────┐
│            ESTADO & LÓGICA (Provider Layer)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────┐              ┌──────────────────────────┐  │
│  │ VehicleProvider │              │   HistoryProvider        │  │
│  │                 │              │                          │  │
│  │ - vehicles[]    │              │ - trips[]                │  │
│  │ - selected      │              │ - notifications[]        │  │
│  │ - calculation   │              │ - statistics             │  │
│  └────────┬────────┘              └────────┬─────────────────┘  │
│           │                                │                     │
│           │ Notifica mudanças              │ Notifica mudanças   │
└───────────┼────────────────────────────────┼─────────────────────┘
            │                                │
            ▼                                ▼
┌─────────────────────────────────────────────────────────────────┐
│          LÓGICA DE NEGÓCIO (Services Layer)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────┐  ┌────────────────────────────────┐   │
│  │  CalculationService  │  │   StorageService               │   │
│  │  - calculateCosts()  │  │   - loadVehicles()             │   │
│  └──────────────────────┘  │   - saveTip()                  │   │
│                             │   - loadTrips()               │   │
│  ┌──────────────────────┐   │   - addNotification()         │   │
│  │    MapsService       │   │                                │   │
│  │ - openMapsWithAddr() │   └─────────────┬──────────────────┘   │
│  │ - generateMapsLink() │                 │                      │
│  └──────────────────────┘                 │                      │
│                                            │                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │     TripCalculationService                               │   │
│  │  - calculateTrip()                                       │   │
│  │  - generateTripMessage()                                 │   │
│  │  - addRating()                                           │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────────┬─────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│            DADOS & PERSISTÊNCIA (Model Layer)                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │   Vehicle    │  │     Trip     │  │   TripNotification     │ │
│  │              │  │              │  │                        │ │
│  │ - name       │  │ - distance   │  │ - id                   │ │
│  │ - costs      │  │ - duration   │  │ - message              │ │
│  │ - settings   │  │ - earnings   │  │ - createdAt            │ │
│  │              │  │ - rating     │  │                        │ │
│  └──────────────┘  └──────────────┘  └────────────────────────┘ │
│                                                                   │
│                    ┌─────────────────┐                           │
│                    │  CalculationResult                          │
│                    │                 │                           │
│                    │ - dailyProfit   │                           │
│                    │ - costs[]       │                           │
│                    └─────────────────┘                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│           PERSISTÊNCIA (Storage Layer)                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│        Hive Database (Local Storage)                             │
│        ┌──────────────────────────────────────────────────┐     │
│        │ Box: vehicles                                    │     │
│        │ Box: trips                                       │     │
│        │ Box: notifications                              │     │
│        └──────────────────────────────────────────────────┘     │
│                                                                   │
│   [Serialized to: /data/data/package/files/hive/]              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Estrutura de Diretórios

```
calculodegastosapp/
│
├── lib/
│   ├── main.dart                          # Entry point
│   │
│   ├── models/                            # Modelos de dados
│   │   ├── vehicle.dart                   # Veículo + custos
│   │   ├── calculation_result.dart        # Resultado de cálculo
│   │   ├── trip.dart                      # Trip + PassengerRating
│   │   └── index.dart                     # Exports
│   │
│   ├── providers/                         # State Management
│   │   ├── vehicle_provider.dart          # VehicleProvider
│   │   ├── history_provider.dart          # HistoryProvider (NOVO)
│   │   └── index.dart                     # Exports
│   │
│   ├── services/                          # Lógica de negócio
│   │   ├── calculation_service.dart       # Cálculos de custo
│   │   ├── storage_service.dart           # Hive storage (expandido)
│   │   ├── maps_service.dart              # Google Maps (NOVO)
│   │   ├── trip_calculation_service.dart  # Trip calculations (NOVO)
│   │   └── index.dart                     # Exports
│   │
│   ├── screens/                           # Telas UI
│   │   ├── home_screen.dart               # Tela inicial (modificada)
│   │   ├── vehicle_form_screen.dart       # Form de veículo
│   │   ├── calculation_screen.dart        # Cálculo
│   │   ├── results_screen.dart            # Resultados
│   │   ├── history_screen.dart            # Histórico (NOVO)
│   │   ├── realtime_trip_screen.dart      # Tempo real (NOVO)
│   │   └── index.dart                     # Exports
│   │
│   ├── widgets/                           # Widgets reutilizáveis
│   │   ├── custom_widgets.dart            # Widgets customizados
│   │   ├── overlay_notification_widget.dart # Overlay (NOVO)
│   │   └── index.dart                     # Exports
│   │
│   └── utils/                             # Utilitários
│       ├── format_utils.dart              # Formatação
│       └── index.dart                     # Exports
│
├── test/                                  # Testes unitários
│
├── integration_test/                      # Testes de integração
│
├── android/                               # Código Android nativo
│   ├── app/
│   └── build.gradle
│
├── ios/                                   # Código iOS nativo
│   └── Runner.xcodeproj
│
├── pubspec.yaml                           # Dependências (modificado)
│
├── README.md                              # README principal (atualizado)
├── REAL_TIME_FEATURES.md                  # Guia de recursos (NOVO)
├── IMPLEMENTATION_SUMMARY_V2.md           # Resumo implementação (NOVO)
├── TEST_CHECKLIST_V2.md                   # Checklist testes (NOVO)
├── BUILD_AND_DEPLOY_GUIDE.md              # Guia build (NOVO)
│
└── .gitignore                             # Arquivos ignorados
```

---

## 🔄 Fluxo de Dados - Exemplo: Finalizar Corrida

```
1. RealTimeTripScreen
   └─> _endTrip()
       │
       ├─> Validar distância
       ├─> Ler dados: startTime, endTime, distância, endereços
       │
       └─> Criar Trip com:
           - calculateTrip() do TripCalculationService
           - Calcular valor/km e valor/hora
           - Calcular earnings (70% do custo)
           │
           ▼
2. HistoryProvider.addTrip(trip)
   │
   ├─> notifyListeners() (avisa UI de mudança)
   │
   └─> StorageService.addTrip(trip)
       │
       ▼
3. StorageService (Hive)
   │
   ├─> Abrir caixa 'trips'
   ├─> Serializar Trip com toMap()
   ├─> Salvar no Hive
   │
   └─> Caixa 'trips' atualizada
       │
       ▼
4. TripCalculationService.generateTripMessage(trip)
   │
   └─> Retorna: "Corrida: 15.2km em 1h 30min | R$ 45.00/h | R$ 3.50/km"
       │
       ▼
5. HistoryProvider.addNotification(notification)
   │
   ├─> Criar TripNotification com mensagem
   ├─> notifyListeners()
   │
   └─> StorageService.addNotification(notification)
       │
       ▼
6. StorageService (Hive)
   │
   ├─> Abrir caixa 'notifications'
   ├─> Serializar TripNotification
   ├─> Salvar no Hive
   │
   └─> Caixa 'notifications' atualizada

7. OverlayNotificationManager.showNotification()
   │
   ├─> Criar OverlayEntry
   ├─> Inserir no Overlay
   ├─> Animar slide-in
   │
   └─> Exibir por 5 segundos, depois auto-fechar

8. UI atualiza automaticamente
   │
   ├─> HomeScreen vê notificação via Provider
   ├─> HistoryScreen vê nova corrida se aberto
   │
   └─> Dados persistem no Hive
```

---

## 🏛️ Padrões de Design Utilizados

### 1. **Provider Pattern** (State Management)
```dart
// VehicleProvider
ChangeNotifierProvider(create: (_) => VehicleProvider())

// HistoryProvider
ChangeNotifierProvider(create: (_) => HistoryProvider())

// Consumo
Consumer<VehicleProvider>(
  builder: (context, provider, _) {
    // Acessa estado
  }
)
```

### 2. **Service Locator** (Services)
```dart
// StorageService singleton
static final StorageService _instance = StorageService._internal();

// MapsService métodos estáticos
class MapsService {
  static Future<void> openMapsWithAddress(String address) async { }
}
```

### 3. **Repository Pattern** (Storage)
```dart
// StorageService atua como repositório
class StorageService {
  Future<void> addTrip(Trip trip) async { }
  Future<Trip?> getTrip(String id) async { }
  Future<List<Trip>> getAllTrips() async { }
}
```

### 4. **Observer Pattern** (Hive - Stream)
```dart
// Hive fornece ValueListenableBuilder para reatividade
ValueListenableBuilder(
  valueListenable: vehiclesBox.listenable(),
  builder: (context, Box box, _) {
    // Reconstrói quando dados mudam
  }
)
```

### 5. **Builder Pattern** (UI)
```dart
// Custom builders para layouts complexos
_buildStaticsGrid(context, stats)
_buildTripCard(context, trip)
_buildActionButton(context, label, icon, color, onPressed)
```

---

## 📱 Responsividade

### Breakpoints Utilizados
```dart
// Mobile (< 600dp)
GridView.count(crossAxisCount: 3) // 3 botões

// Tablet (>= 600dp)
GridView.count(crossAxisCount: 4) // 4 botões

// Desktop (>= 900dp)
// Não configurado (app é mobile-first)
```

---

## 🎨 Tema Material Design 3

```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFF1F77D2), // Azul primário
  brightness: Brightness.light,
)

// Cores derivadas automaticamente
Primary: #1F77D2
Secondary: #6750A4 (automático)
Error: #B3261E (automático)
```

---

## 🔐 Segurança

### Dados Sensíveis
```dart
// Não armazenar em SharedPreferences
// Usar Hive com criptografia opcional

// Validar entrada de usuário
if (distanceController.text.isEmpty) {
  // Mostrar erro
}

// Confirmar ações críticas
showDialog(AlertDialog)
```

---

## ⚡ Performance

### Otimizações Implementadas
```dart
// 1. NeverScrollableScrollPhysics para nested lists
ListView(
  physics: NeverScrollableScrollPhysics(),
  shrinkWrap: true,
)

// 2. Lazy loading com ExpansionTile
ExpansionTile(
  title: Resumo,
  children: [Detalhes] // Carrega sob demanda
)

// 3. Const widgets quando possível
const Icon(Icons.history)
const SizedBox(height: 16)

// 4. CachedNetworkImage para imagens (preparado)

// 5. Provider seletivo - Consumer ao invés de Consumer2
Consumer<HistoryProvider>(
  builder: (context, history, _) {
    // Só reconstrói se HistoryProvider muda
  }
)
```

---

## 📊 Complexidade Computacional

| Operação | Complexidade | Tempo Estimado |
|----------|-------------|---|
| Carregar 100 viagens | O(n) | < 100ms |
| Calcular estatísticas | O(n) | < 50ms |
| Filtrar por data | O(n) | < 100ms |
| Abrir Google Maps | O(1) | ~500ms (network) |
| Serializar Trip | O(1) | < 5ms |

---

**Última atualização**: Dezembro 2024
