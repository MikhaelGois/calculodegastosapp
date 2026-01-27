# 🏗️ Arquitetura do Sistema de Semáforo - v3.0.0

## Diagrama de Fluxo Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                    NOTIFICAÇÃO DO SISTEMA                        │
│     (Uber, 99 Táxis, iDriver enviaram notificação)              │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              RIDE NOTIFICATION SERVICE                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. detectAppFromNotification()                          │  │
│  │    └─> Identifica: UBER | NINETY_NINE | INDRIVE        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 2. extractNotificationData()                            │  │
│  │    └─> Regex parsing: km, R$, min                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 3. calculateTrafficLight()                              │  │
│  │    ├─> Compara vs Vehicle.valuePerKm/Hour              │  │
│  │    └─> Retorna: 🟢 | 🟡 | 🔴 + score                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 4. createRideOfferFromNotification()                    │  │
│  │    └─> RideOffer object completo                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼ RideOffer
┌─────────────────────────────────────────────────────────────────┐
│              RIDE OFFER PROVIDER                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ addDetectedOffer(offer)                                 │  │
│  │ ├─> currentOffer = offer                                │  │
│  │ ├─> detectedOffers.add(offer)                           │  │
│  │ └─> notifyListeners()                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              RIDE OFFER CARD WIDGET                              │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 🚗 Uber          Há 2m               🟢                  │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ Distância: 8.5km  │  Tempo: 15min  │  Valor: R$ 35.00  │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ Rentabilidade: 85/100                                    │  │
│  │ ████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░           │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │ Excelente rentabilidade: R$4.12/km, R$140/h            │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │         [Rejeitar]           [Aceitar]                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────┬──────────────────────────┬─────────────┘
                         │                          │
                    Rejeitar              Aceitar
                         │                          │
                         ▼                          ▼
         Provider.rejectOffer()      Provider.acceptOffer()
```

## Estrutura de Classes

```
RideOffer
├── id: String (UUID)
├── app: RideApp (ENUM: UBER, NINETY_NINE, INDRIVE, UNKNOWN)
├── trafficLight: TrafficLight (ENUM: GREEN, YELLOW, RED)
├── distanceKm: double?
├── offeredValue: double?
├── estimatedTimeMinutes: double?
├── profitabilityScore: double (0-100)
└── Getters: appName, appIcon, trafficLightEmoji, recommendation

RideOfferProvider extends ChangeNotifier
├── currentOffer: RideOffer?
├── detectedOffers: List<RideOffer>
├── Methods: addDetectedOffer, acceptOffer, rejectOffer, getStatistics()
└── Properties: acceptanceRate, acceptedCount, rejectedCount

RideNotificationService (STATIC)
├── detectAppFromNotification()
├── extractNotificationData()
├── calculateTrafficLight()
├── createRideOfferFromNotification()
└── tryParseNotification()

RideOfferCard extends StatelessWidget
├── offer: RideOffer
├── onAccept: VoidCallback?
└── onReject: VoidCallback?
```

---

**Documentação: Architecture v3.0.0**  
**Data: 27 de Janeiro, 2026**

