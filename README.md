# Cálculo de Gastos - App Flutter

Um aplicativo moderno e intuitivo para calcular gastos de frota de veículos, desenvolvido com Flutter e Material Design 3.

## ✨ Características

- ✅ **Cálculo Automatizado**: Custos fixos, variáveis, valor/hora e valor/km
- ✅ **Interface Moderna**: Design Material 3 com tema responsivo
- ✅ **Gerenciamento de Veículos**: Adicionar, editar e deletar múltiplos veículos
- ✅ **Análise Detalhada**: Visualize breakdown completo de custos
- ✅ **Persistência Local**: Dados salvos localmente com Hive
- ✅ **Multi-plataforma**: Android e iOS suportados
- ✅ **Português Brasileiro**: Totalmente localizado

## 🎯 Funcionalidades

### Custos Fixos
- Parcela mensal (financiamento)
- IPVA anual
- Seguro anual
- Troca de óleo
- Pneus
- Manutenção e revisão

### Combustível
- Preço do combustível
- Tamanho do tanque
- Consumo na cidade (km/l)
- Consumo na rodovia (km/l)

### Configurações Operacionais
- Limite de KM semanal
- Dias de trabalho por semana
- Horas de trabalho por dia
- Lucro desejado (semanal)

## 📱 Plataformas Suportadas
- Android (API 21+)
- iOS (12.0+)

## 🔧 Requisitos
- Flutter 3.10.7 ou superior
- Dart 3.10 ou superior

## 🚀 Instalação

### 1. Clone o repositório
```bash
git clone https://github.com/MikhaelGois/calculodegastosapp.git
cd calculodegastosapp
```

### 2. Instale dependências
```bash
flutter pub get
```

### 3. Execute o aplicativo
```bash
flutter run
```

### 4. Build para produção

**Android:**
```bash
flutter build apk
# ou para AAB (Google Play)
flutter build appbundle
```

**iOS:**
```bash
flutter build ios
```

## 📦 Dependências Principais

- **provider**: Gerenciamento de estado
- **hive**: Banco de dados local
- **intl**: Localização e formatação
- **fl_chart**: Gráficos (preparado para futuro)
- **uuid**: Geração de IDs únicos
- **animations**: Animações Material

## 🏗️ Arquitetura

```
lib/
├── main.dart                 # Entrada da aplicação
├── models/                   # Modelos de dados
│   ├── vehicle.dart
│   └── calculation_result.dart
├── providers/                # State management
│   └── vehicle_provider.dart
├── screens/                  # Telas da aplicação
│   ├── home_screen.dart
│   ├── vehicle_form_screen.dart
│   ├── calculation_screen.dart
│   └── results_screen.dart
├── services/                 # Serviços
│   ├── storage_service.dart  # Persistência de dados
│   └── calculation_service.dart
├── widgets/                  # Widgets reutilizáveis
│   └── custom_widgets.dart
└── utils/                    # Utilitários
    └── format_utils.dart
```

## 🎨 Design

- **Material Design 3**: Tema moderno e responsivo
- **Cor primária**: #1F77D2 (Azul)
- **Tipografia**: Família Roboto (padrão Material)
- **Ícones**: Material Icons

## 🔄 Fluxo de Uso

1. **Adicionar Veículo**: Insira informações do veículo
2. **Preencher Dados**: Configure custos e operacional
3. **Calcular**: Calcule os resultados
4. **Visualizar**: Veja ganhos, custos e detalhes
5. **Gerenciar**: Edite ou delete veículos conforme necessário

## 💾 Persistência de Dados

Os dados são armazenados localmente usando Hive (banco de dados NoSQL para Flutter):
- Veículos são salvos automaticamente
- Cada veículo mantém histórico de configurações
- Sem sincronização em nuvem (pode ser implementado)

## 🚀 Melhorias Futuras

- [ ] Gráficos de análise de gastos
- [ ] Sincronização em nuvem (Firebase)
- [ ] Exportação de relatórios (PDF)
- [ ] Modo escuro
- [ ] Multi-idiomas
- [ ] Backup e restore
- [ ] Histórico de cálculos
- [ ] Compartilhamento de dados

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a Licença MIT - veja o arquivo LICENSE para detalhes.

## 👨‍💻 Autor

**Mikhael Gois**

## 📞 Suporte

Para questões e sugestões, abra uma issue no repositório.

---

Desenvolvido com ❤️ usando Flutter

### Requisitos

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
