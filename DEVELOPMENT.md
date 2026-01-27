# Guia de Desenvolvimento

## Configuração do Ambiente

### 1. Instalar Flutter
```bash
# No Windows, baixe de flutter.dev
# Ou use chocolatey:
choco install flutter
```

### 2. Clonar e Preparar
```bash
git clone https://github.com/MikhaelGois/calculodegastosapp.git
cd calculodegastosapp
flutter pub get
```

### 3. Executar em Desenvolvimento
```bash
flutter run -v  # com verbose para debug
```

## Estrutura de Arquivos

### Models (`lib/models/`)
- `vehicle.dart` - Modelo principal com Vehicle, FixedCosts, VariableCosts, OperationalSettings
- `calculation_result.dart` - Resultado de cálculos

### Providers (`lib/providers/`)
- `vehicle_provider.dart` - Gerenciamento de estado com ChangeNotifier

### Screens (`lib/screens/`)
- `home_screen.dart` - Tela inicial com lista de veículos
- `vehicle_form_screen.dart` - Formulário para adicionar/editar veículos
- `calculation_screen.dart` - Tela de visualização de dados antes do cálculo
- `results_screen.dart` - Tela com resultados e detalhamentos

### Services (`lib/services/`)
- `storage_service.dart` - Persistência com Hive
- `calculation_service.dart` - Lógica de cálculos

### Widgets (`lib/widgets/`)
- `custom_widgets.dart` - Componentes reutilizáveis (CustomInputField, CustomButton, ResultCard, etc)

### Utils (`lib/utils/`)
- `format_utils.dart` - Formatação de moeda, números, etc

## Adicionando Novas Funcionalidades

### 1. Adicionar um novo campo ao Veículo
```dart
// Em models/vehicle.dart
class Vehicle {
  // ... adicione o campo
  final String novoCompo;
}

// Atualize copyWith, toMap e fromMap
```

### 2. Adicionar uma nova tela
```dart
// Crie em lib/screens/nova_screen.dart
class NovaScreen extends StatefulWidget {
  const NovaScreen({Key? key}) : super(key: key);
  
  @override
  State<NovaScreen> createState() => _NovaScreenState();
}

class _NovaScreenState extends State<NovaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Tela')),
      body: // seu conteúdo
    );
  }
}

// Adicione em lib/screens/index.dart
export 'nova_screen.dart';
```

### 3. Adicionar um novo widget reutilizável
```dart
// Em lib/widgets/custom_widgets.dart
class NovoWidget extends StatelessWidget {
  const NovoWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // seu widget
    );
  }
}
```

## Build e Deploy

### APK (Android)
```bash
flutter build apk --release
# Arquivo gerado em: build/app/outputs/apk/release/app-release.apk
```

### App Bundle (Google Play)
```bash
flutter build appbundle --release
# Arquivo gerado em: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Use Xcode para submeter à App Store
```

## Testes

### Rodar testes de widget
```bash
flutter test
```

### Gerar coverage
```bash
flutter test --coverage
```

## Debugging

### Modo verbose
```bash
flutter run -v
```

### DevTools
```bash
flutter pub global activate devtools
devtools
```

### Hot Reload
- Pressione `r` durante `flutter run`

### Hot Restart
- Pressione `R` durante `flutter run`

## Formatação e Análise de Código

### Formatar código
```bash
dart format lib/
```

### Analisar código
```bash
dart analyze
```

### Lint rigoroso
```bash
flutter analyze --no-pub
```

## Principais Pacotes Utilizados

| Pacote | Versão | Uso |
|--------|--------|-----|
| provider | ^6.4.0 | State management |
| hive | ^2.2.3 | Banco de dados local |
| hive_flutter | ^1.1.0 | Integração Hive com Flutter |
| intl | ^0.19.0 | Localização e formatação |
| uuid | ^4.1.0 | Geração de IDs únicos |
| animations | ^2.0.11 | Animações Material |
| fl_chart | ^0.65.0 | Gráficos (futuro) |

## Melhorias Sugeridas

1. **Testes Unitários**: Adicione testes para `CalculationService`
2. **Testes de Widget**: Crie testes para as telas principais
3. **Firebase**: Implementar sync em nuvem
4. **Gráficos**: Implementar visualizações com fl_chart
5. **Modo Escuro**: Adicionar suporte a tema escuro
6. **Exportação**: PDF ou CSV com relatórios

## Troubleshooting

### Dependências não encontram
```bash
flutter pub get
flutter pub upgrade
```

### Hive não funciona
```bash
flutter pub add hive_generator
flutter pub add build_runner
flutter pub run build_runner build
```

### Erro ao rodar
```bash
flutter clean
flutter pub get
flutter run
```

## Contato e Suporte

Para dúvidas, abra uma issue no repositório!
