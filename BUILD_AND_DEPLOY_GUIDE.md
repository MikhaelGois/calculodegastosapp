# 🚀 Guia de Execução e Build

## 🎯 Objetivo
Este guia fornece instruções passo a passo para compilar, testar e deployar o aplicativo Cálculo de Gastos v2.0.

---

## 📋 Pré-requisitos

### Instalações Obrigatórias
```bash
# Flutter SDK (3.10.7 ou superior)
flutter --version

# Dart SDK (3.10 ou superior)  
dart --version

# Git
git --version

# Android SDK (para Android)
# Ou Xcode (para iOS)
```

### Verificar Ambiente
```bash
flutter doctor
```

Todos os checkmarks devem estar verdes (✓) antes de prosseguir.

---

## 🔧 Setup Inicial

### 1. Clone o Repositório
```bash
git clone https://github.com/MikhaelGois/calculodegastosapp.git
cd calculodegastosapp
```

### 2. Instale Dependências
```bash
flutter pub get
```

### 3. Gere Código Hive (obrigatório!)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Este comando gera os adaptadores necessários para Hive.

### 4. Limpe Build Anterior (se necessário)
```bash
flutter clean
flutter pub get
```

---

## ▶️ Execução em Desenvolvimento

### Android
```bash
# Listar dispositivos disponíveis
flutter devices

# Executar em dispositivo específico
flutter run -d <device_id>

# Executar com output detalhado
flutter run -v

# Executar em modo hot reload
flutter run
```

### iOS
```bash
# Executar em iPhone
flutter run -d <device_id>

# Build para iOS
flutter build ios
```

### Web (Experimental)
```bash
flutter run -d chrome
```

---

## 🏗️ Build para Release

### Android APK
```bash
# Build APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Recomendado para Play Store)
```bash
# Build AAB
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA
```bash
# Build IPA
flutter build ios --release

# Output: build/ios/ipa/
```

---

## ✅ Testes

### Testes Unitários
```bash
flutter test
```

### Testes de Widget
```bash
flutter test test/widgets/
```

### Testes de Integração
```bash
flutter test integration_test/
```

### Build e Lint
```bash
# Analisar código
flutter analyze

# Formatar código
dart format lib/

# Verificar antes de commit
dart format --set-exit-if-changed lib/
flutter analyze
```

---

## 📊 Verificação Pré-Release

### Checklist de Build
- [ ] `flutter analyze` sem erros
- [ ] `flutter test` passando
- [ ] Sem warnings não documentados
- [ ] Build size < 50MB
- [ ] Startup time < 2s em dispositivo real

### Checklist Funcional
- [ ] Pode criar veículo
- [ ] Pode calcular custos
- [ ] Pode iniciar corrida em tempo real
- [ ] Histórico salva corretamente
- [ ] Google Maps abre endereços
- [ ] Notificações overlay funcionam

---

## 🐛 Debug

### Logs em Tempo Real
```bash
flutter logs
```

### Debug com VS Code
1. Abra o projeto em VS Code
2. Clique em "Run and Debug" (Ctrl+Shift+D)
3. Selecione "Flutter"
4. Clique em "Start Debugging" (F5)

### Debug com Android Studio
1. Abra projeto em Android Studio
2. Run → Debug 'main.dart'
3. Use breakpoints normalmente

### Inspector de Widget
```bash
flutter run --profile
# Em outra aba:
flutter attach
# Pode usar devtools
```

---

## 📦 Distribuição

### Play Store (Android)
1. Gere keystore:
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Configure assinatura em `android/app/build.gradle`:
```gradle
signingConfigs {
    release {
        keyAlias 'upload'
        keyPassword 'sua-senha'
        storeFile file('/path/to/key.jks')
        storePassword 'sua-senha'
    }
}
```

3. Build AAB:
```bash
flutter build appbundle --release
```

4. Upload em Google Play Console

### App Store (iOS)
1. Abra Xcode:
```bash
open ios/Runner.xcworkspace
```

2. Configure code signing
3. Build e upload via TestFlight/App Store Connect

---

## 🔍 Troubleshooting

### Erro: "No connected devices"
```bash
# Ativar debug mode no Android
# Conectar dispositivo via USB
# Autorizar no dispositivo
flutter devices
```

### Erro: "Build failed"
```bash
# Limpar build
flutter clean
flutter pub get

# Regerar código gerado
flutter pub run build_runner build --delete-conflicting-outputs

# Tentar novamente
flutter build apk --release
```

### Erro: Hive não encontra adaptadores
```bash
# Executar build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# Se ainda não funcionar:
flutter pub run build_runner clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro: "gradle build failed"
```bash
# Limpar gradle cache
cd android
./gradlew clean
cd ..

# Fazer clean no Flutter
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🎯 Versioning

### Atualizar Versão
Edite `pubspec.yaml`:
```yaml
version: 2.0.1+2  # version + build number
```

Formato: `major.minor.patch+buildNumber`

---

## 📱 Suporte a Versões

| Plataforma | Versão Mínima | Versão Testada |
|-----------|--------------|----------------|
| Android | API 21 (5.0) | API 34 (14.0) |
| iOS | 12.0 | 17.0 |
| Flutter | 3.10.7 | 3.13.0 |
| Dart | 3.10 | 3.13 |

---

## ⚙️ Otimizações

### Reduzir Tamanho de APK
```bash
# Build com shrinking
flutter build apk --split-per-abi --release
```

### Melhorar Performance
- Use `--profile` durante desenvolvimento
- Profiless com DevTools
- Use `const` widgets quando possível

---

## 📚 Recursos Adicionais

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Provider Documentation](https://pub.dev/packages/provider)

---

## 🤝 Contribuindo

Para contribuir:
1. Fork o repositório
2. Crie branch: `git checkout -b feature/sua-feature`
3. Commit: `git commit -m "feat: descrição"`
4. Push: `git push origin feature/sua-feature`
5. Abra Pull Request

---

## 📝 Changelog

### v2.0.0 (Atual)
- ✅ Histórico de corridas
- ✅ Rastreamento em tempo real
- ✅ Google Maps integration
- ✅ Notificações overlay

### v1.0.0 (Anterior)
- Migração de Android para Flutter
- Cálculo de custos
- Gerenciamento de veículos

---

## 📞 Suporte

Para dúvidas ou problemas:
1. Consulte `REAL_TIME_FEATURES.md`
2. Verifique `TEST_CHECKLIST_V2.md`
3. Abra issue no GitHub
4. Faça pull request com correções

---

**Data**: Dezembro 2024
**Versão**: 2.0.0
**Status**: Pronto para Deploy
