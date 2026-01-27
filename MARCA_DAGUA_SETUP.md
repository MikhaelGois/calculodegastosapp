# ⚡ Marca D'Água - Setup Rápido

## 1️⃣ Instalar Dependências

```bash
flutter pub get
```

Principais dependências adicionadas:
- `geocoding: ^2.1.1` - Converter coordenadas em endereços

---

## 2️⃣ Configurar Permissões

### Android

Adicione a `AndroidManifest.xml`:

```xml
<!-- Localização -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS

Adicione à `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necessário para marcar localização nos vídeos</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Necessário para marcar localização nos vídeos</string>
```

---

## 3️⃣ Usar na Sua Tela de Gravação

### Importar

```dart
import 'services/watermark_service.dart';
import 'services/location_service.dart';
import 'widgets/watermark_widgets.dart';
```

### Gerar Marca D'Água

```dart
// No initState ou ao iniciar gravação
WatermarkData watermark = await WatermarkService.generateWatermarkData(
  cameraType: 'Frontal',  // Ou 'Traseira', 'Ambas'
);
```

### Exibir na Tela

```dart
// No Stack de gravação
Stack(
  children: [
    CameraPreview(_controller),
    
    // Marca d'água
    RecordingWatermarkWidget(
      watermarkData: watermark,
      alignment: Alignment.bottomLeft,
      isRecording: true,
    ),
  ],
)
```

### Salvar com Dados

```dart
// Ao registrar o vídeo
cameraProvider.registerRecording(
  filePath: videoPath,
  duration: duration,
  cameraUsed: 'Frontal',
  watermarkData: watermark,  // ✅ Novo
);
```

---

## 4️⃣ Visualizar Marca D'Água

### Ao Reproduzir

```dart
// Na tela de reprodução
if (video.watermarkData != null) {
  WatermarkPreviewCard(
    watermarkData: video.watermarkData!,
    showCamera: true,
  );
}
```

---

## 🧪 Testar

### 1. Compilar
```bash
flutter run
```

### 2. Gravar vídeo
- Clique em "Gravar"
- Veja a marca d'água no canto inferior esquerdo
- Observe data, hora e localização

### 3. Verificar dados
- Vá para "Vídeos"
- Toque em um vídeo
- Veja os dados da marca d'água

---

## ❌ Solucionar Problemas

### Erro: "Undefined class 'Geocoding'"
```bash
# Instalar novamente
flutter pub get
flutter clean
flutter pub get
```

### Erro: "Permission denied"
```dart
// Verificar e solicitar permissão
bool hasPermission = await LocationService.hasLocationPermission();
if (!hasPermission) {
  await LocationService.requestLocationPermission();
}
```

### GPS não funciona
- Verificar se GPS está ativado no dispositivo
- Verificar permissões do app
- Testar em dispositivo físico (emulador pode ter limitações)

---

## 📊 Dados Capturados

```
✅ Data: 27/01/2026
✅ Hora: 14:30:45
✅ Endereço: Av Paulista, São Paulo
✅ Coordenadas: (-23.5505, -46.6333)
✅ Câmera: Frontal/Traseira/Ambas
```

---

## 🚀 Próximo Passo

Leia `MARCA_DAGUA.md` para detalhes técnicos completos!

---

**Pronto em 5 minutos! ⚡**
