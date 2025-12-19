# Project Calculo de Gastos - Android

Um app Android completo para calcular gastos e lucros de uma frota de veículos.

## Funcionalidades

✅ Cálculo automatizado de custos fixos e variáveis
✅ Análise de consumo de combustível (cidade e rodovia)
✅ Cálculo de valor/hora e valor/km
✅ Interface limpa e intuitiva
✅ Suporte a português brasileiro

## Campos de Entrada

### Custos Fixos
- Valor da parcela (veículo financiado)
- Valor IPVA (anual)
- Valor Seguro (anual)
- Valor Troca de Óleo
- Valor Pneu (unitário)
- Custo manutenção/revisão

### Combustível
- Valor do combustível
- Tamanho do tanque
- Consumo na cidade (km/l)
- Consumo na rodovia (km/l)

### Operacional
- Limite de KM semanal
- Dias de trabalho por semana
- Horas de trabalho por dia
- Lucro desejado

## Resultados

- **Ganhos por dia**: Lucro diário necessário
- **Ganho semanal**: Lucro semanal total
- **Valor/HR**: Preço por hora de trabalho
- **Valor/KM**: Preço por quilômetro

## Como Compilar e Rodar

### Requisitos
- Android Studio 2023.1 ou superior
- Java 8+
- Android SDK 24+

### Passos

1. Abra o projeto no Android Studio
2. Sincronize o Gradle
3. Conecte um emulador ou dispositivo Android
4. Clique em "Run" (Shift + F10)

## Estrutura do Projeto

```
app/
├── src/
│   ├── main/
│   │   ├── java/com/example/calculogastos/
│   │   │   └── MainActivity.kt
│   │   ├── res/
│   │   │   ├── layout/
│   │   │   │   └── activity_main.xml
│   │   │   ├── values/
│   │   │   │   ├── strings.xml
│   │   │   │   ├── colors.xml
│   │   │   │   └── themes.xml
│   │   └── AndroidManifest.xml
│   └── build.gradle
└── proguard-rules.pro
```

## Dependências

- AndroidX Core KTX 1.12.0
- AndroidX AppCompat 1.6.1
- Material Components 1.11.0
- ConstraintLayout 2.1.4

## Licença

MIT
