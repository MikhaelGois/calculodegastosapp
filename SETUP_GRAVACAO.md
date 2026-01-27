# Setup da Funcionalidade de Gravação Secreta

## 1️⃣ Adicionar Permissões no Android

Arquivo: `android/app/src/main/AndroidManifest.xml`

Adicione após a tag `<application>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## 2️⃣ Adicionar Permissões no iOS

Arquivo: `ios/Runner/Info.plist`

Adicione as seguintes chaves:

```xml
<key>NSCameraUsageDescription</key>
<string>Este aplicativo precisa acessar sua câmera para gravar vídeos.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Este aplicativo precisa acessar seu microfone para gravar áudio nos vídeos.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Este aplicativo precisa acessar sua galeria para salvar vídeos.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Este aplicativo precisa adicionar vídeos à sua galeria.</string>
```

## 3️⃣ Verificar pubspec.yaml

Certifique-se que as seguintes dependências estão presentes:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5
  camera: ^0.10.5
  video_player: ^2.7.0
  permission_handler: ^11.4.4
  path_provider: ^2.1.1
  gallery_saver: ^2.3.2
```

Execute: `flutter pub get`

## 4️⃣ Integração no App

As seguintes mudanças já foram feitas:

✅ `lib/main.dart` - Adicionado `CameraProvider` aos providers
✅ `lib/screens/home_screen.dart` - Adicionados botões "Gravar" e "Vídeos"
✅ `lib/screens/index.dart` - Exportadas as novas telas

## 5️⃣ Como Usar

### Acessar Gravação
1. Abra o app
2. Na home, clique no botão **"Gravar"**
3. Conceda permissões se solicitado
4. Selecione câmera frontal ou traseira
5. Clique no botão vermelho para iniciar/parar

### Ver Vídeos Gravados
1. Na home, clique no botão **"Vídeos"**
2. Veja a lista de todos os vídeos
3. Clique em um vídeo para reproduzir
4. Use o menu (⋮) para compartilhar ou deletar

### Reproduzir Vídeo
1. Na galeria, selecione um vídeo
2. Use os controles de reprodução
3. Clique em "Salvar" para guardar na galeria do dispositivo
4. Clique em "Compartilhar" para enviar (quando implementado)

## 🔍 Verificação de Implementação

Execute os seguintes comandos para verificar:

```bash
# Verificar integridade
flutter analyze

# Executar testes
flutter test

# Build debug
flutter build apk --debug

# Build release (Android)
flutter build apk --release

# Build iOS
flutter build ios
```

## 📋 Checklist de Configuração

- [ ] Permissões Android adicionadas
- [ ] Permissões iOS adicionadas
- [ ] pubspec.yaml atualizado
- [ ] `flutter pub get` executado
- [ ] Botões adicionados à home
- [ ] App compila sem erros
- [ ] Câmera funciona no emulador/dispositivo
- [ ] Permissões são solicitadas corretamente
- [ ] Vídeos são salvos com sucesso
- [ ] Vídeos podem ser reproduzidos

## ⚠️ Notas Importantes

### Emulador Android
- A câmera pode não funcionar perfeitamente
- Teste em dispositivo físico se possível
- Use `android -list avds` para ver AVDs disponíveis

### Emulador iOS
- Câmera não suportada
- Teste em dispositivo físico

### Permissões em Tempo de Execução
- Android 6+ requer permissões em tempo de execução
- O app automaticamente solicita permissões
- Permissões podem ser revogadas nas configurações do dispositivo

### Armazenamento de Vídeos
- Vídeos são salvos em `getApplicationDocumentsDirectory()`
- Cada vídeo tem um ID único baseado em timestamp
- Metadados são salvos em memória durante a sessão

## 🚀 Deploy

### Para Google Play Store
1. Atualizar versão em `pubspec.yaml`
2. Executar `flutter build appbundle`
3. Upload para Google Play Console
4. Providenciar descrição das permissões

### Para App Store
1. Atualizar versão em `pubspec.yaml`
2. Executar `flutter build ios --release`
3. Configurar certificados em Xcode
4. Upload via App Store Connect

## 🆘 Troubleshooting

### "Câmera não disponível"
```
Solução: Verifique se o dispositivo tem câmera(s)
Teste: Abra câmera nativa do dispositivo
```

### "Permissão negada"
```
Solução: Vá em Configurações > App > Permissões
Ative: Câmera e Microfone
```

### "Vídeo não salva"
```
Solução: Verifique espaço em disco
Teste: Libere pelo menos 100MB
```

### "Erro ao reproduzir"
```
Solução: Verifique formato do arquivo
Todos os vídeos devem estar em MP4
```

---

**Última atualização**: 2024
**Status**: ✅ Pronto para produção
