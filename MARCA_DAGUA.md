# 🎬 Marca D'Água em Vídeos

## 📋 Resumo

Sistema automático de marca d'água que adiciona **data, hora e localização** (endereço + coordenadas GPS) em todos os vídeos gravados de forma secreta.

---

## ✨ Características

### 1. **Dados Automáticos Capturados**
```
✅ Data de gravação (DD/MM/YYYY)
✅ Hora da gravação (HH:MM:SS)
✅ Endereço (rua e bairro)
✅ Coordenadas GPS (latitude, longitude)
✅ Tipo de câmera (Frontal/Traseira/Ambas)
```

### 2. **Visualização em Tempo Real**
- Marca d'água aparece durante a gravação
- Posicionável em qualquer canto da tela
- Animação suave com pulsação
- Fundo semi-transparente para legibilidade

### 3. **Armazenamento Seguro**
- Dados persistidos com cada vídeo
- Recuperáveis ao assistir o vídeo
- Formato JSON para fácil acesso

---

## 🏗️ Arquitetura

### Novos Arquivos

```
lib/services/
  ├── location_service.dart      ← Obter localização
  └── watermark_service.dart     ← Gerenciar marca d'água

lib/widgets/
  └── watermark_widgets.dart     ← Componentes visuais
```

### Arquivos Modificados

```
lib/services/camera_service.dart  ← Armazenar watermarkData
lib/providers/camera_provider.dart ← Registrar com marca d'água
pubspec.yaml                       ← Adicionar geocoding
```

---

## 🔍 Localização (GPS)

### Como Funciona

```dart
// Obter localização atual
LocationData? location = await LocationService.getCurrentLocation();

// Resultado:
// - latitude: -23.5505
// - longitude: -46.6333
// - address: "Av Paulista, São Paulo"
// - city: "São Paulo"
// - state: "SP"
```

### Permissões Necessárias

**Android** (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** (`Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necessário para marcar localização nos vídeos</string>
```

---

## 📝 Serviço de Marca D'Água

### LocationService

```dart
// Solicitar permissão
bool granted = await LocationService.requestLocationPermission();

// Verificar permissão
bool hasPermission = await LocationService.hasLocationPermission();

// Obter localização
LocationData? location = await LocationService.getCurrentLocation();

// Formatar para exibição
String display = location!.toDisplayString();
// "Av Paulista, São Paulo"
// "(−23.5505, −46.6333)"

// Formatar para marca d'água
String watermark = location!.toWatermarkString();
// "Av Paulista, São Paulo"
// "(−23.5505, −46.6333)"
```

### WatermarkService

```dart
// Gerar dados de marca d'água
WatermarkData watermark = await WatermarkService.generateWatermarkData(
  cameraType: 'Frontal',
);

// Resultado:
// - recordedAt: DateTime.now()
// - location: LocationData
// - cameraType: 'Frontal'

// Formatar para exibição (múltiplas linhas)
List<String> lines = WatermarkService.formatWatermarkLines(watermark);
// ['27/01/2026', '14:30:45', '', 'Av Paulista', '(−23.5505, −46.6333)']

// Formatar como texto único
String text = WatermarkService.formatWatermarkText(watermark);
// '27/01/2026\n14:30:45\nAv Paulista\n(−23.5505, −46.6333)'

// Serializar para JSON
Map<String, dynamic> json = watermark.toJson();

// Desserializar de JSON
WatermarkData watermark2 = WatermarkData.fromJson(json);
```

---

## 🎨 Componentes Visuais

### WatermarkOverlay

Posiciona marca d'água na tela durante gravação:

```dart
WatermarkOverlay(
  watermarkData: watermark,
  alignment: Alignment.bottomLeft,  // Canto inferior esquerdo
  fontSize: 12,
  textColor: Colors.white,
  opacity: 0.9,
)
```

### RecordingWatermarkWidget

Marca d'água com animação pulsante:

```dart
RecordingWatermarkWidget(
  watermarkData: watermark,
  alignment: Alignment.bottomLeft,
  isRecording: true,
)
```

### WatermarkPreviewCard

Card para visualizar marca d'água em detalhes:

```dart
WatermarkPreviewCard(
  watermarkData: watermark,
  showCamera: true,
)
```

---

## 📱 Integração com CameraProvider

### Fluxo de Gravação

```dart
// 1. Iniciar gravação
await cameraProvider.startRecording();

// 2. Gerar marca d'água automaticamente
WatermarkData watermark = await WatermarkService.generateWatermarkData(
  cameraType: cameraProvider.cameraSelection.toString(),
);

// 3. Exibir sobreposição
// (Usar RecordingWatermarkWidget na tela)

// 4. Parar gravação
await cameraProvider.stopRecording();

// 5. Registrar com marca d'água
cameraProvider.registerRecording(
  filePath: videoPath,
  duration: duration,
  cameraUsed: camera,
  watermarkData: watermark,  // ✅ Novo parâmetro
);
```

---

## 💾 Armazenamento

### Dados Persistidos

```dart
class RecordedVideo {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;
  final String cameraUsed;
  final WatermarkData? watermarkData;  // ✅ Novo campo
}
```

### Recuperação

```dart
// Obter vídeos com marca d'água
List<RecordedVideo> videos = cameraProvider.getRecordings();

for (var video in videos) {
  if (video.watermarkData != null) {
    print('Data: ${video.watermarkData!.formattedDate}');
    print('Hora: ${video.watermarkData!.formattedTime}');
    print('Local: ${video.watermarkData!.location?.toDisplayString()}');
  }
}
```

---

## 🔐 Privacidade e Segurança

### Considerações Importantes

1. **Localização Precisa**
   - GPS fornece coordenadas em tempo real
   - Precisão típica: 5-10 metros
   - Pode ser bloqueada pelo usuário

2. **Permissões Granulares**
   - Solicitar apenas quando necessário
   - "enquanto usando o app"
   - Respeitar configurações do usuário

3. **Dados Sensíveis**
   - Localização é dado sensível
   - Armazenar localmente
   - Nunca enviar sem consentimento

---

## 📊 Exemplos de Marca D'Água

### Exemplo 1: Completo
```
27/01/2026
14:30:45

Av Paulista, 1000, São Paulo
(-23.5505, -46.6333)

Câmera: Traseira
```

### Exemplo 2: Sem Localização
```
27/01/2026
14:30:45

Câmera: Frontal
```

### Exemplo 3: Apenas GPS
```
27/01/2026
14:30:45

(-23.5505, -46.6333)
```

---

## 🛠️ Troubleshooting

### Problema: Localização não obtida
```dart
LocationData? location = await LocationService.getCurrentLocation();
if (location == null) {
  // GPS desativado ou permissão negada
  // Marca d'água continua com data/hora
}
```

### Problema: Endereço não resolvido
```dart
// Se o geocoding falhar, apenas coordenadas são exibidas
if (location?.address == null) {
  // Usar coordenadas GPS como fallback
}
```

### Problema: Permissão negada
```dart
bool hasPermission = await LocationService.hasLocationPermission();
if (!hasPermission) {
  await LocationService.requestLocationPermission();
}
```

---

## 📈 Próximas Melhorias

### v3.2.4 (Planned)
- [ ] Renderização de marca d'água diretamente no arquivo MP4
- [ ] Customização de posição, cor e tamanho
- [ ] Múltiplos idiomas
- [ ] Histórico de localizações

### v3.3.0 (Planned)
- [ ] Sincronizar dados com cloud
- [ ] Compartilhar com metadados
- [ ] Buscar por localização

---

## 📚 Referência Completa

| Classe | Método | Descrição |
|--------|--------|-----------|
| `LocationService` | `getCurrentLocation()` | Obter localização atual |
| `LocationService` | `hasLocationPermission()` | Verificar permissão |
| `LocationService` | `requestLocationPermission()` | Solicitar permissão |
| `WatermarkService` | `generateWatermarkData()` | Gerar marca d'água |
| `WatermarkService` | `formatWatermarkLines()` | Formatar como linhas |
| `WatermarkService` | `formatWatermarkText()` | Formatar como texto |

---

## ✅ Checklist de Implementação

```
✅ LocationService criado
✅ WatermarkService criado
✅ RecordedVideo atualizado com watermarkData
✅ CameraProvider integrado
✅ Widgets de visualização criados
✅ Permissões configuradas
✅ Documentação completa
```

---

**Data de Criação**: 27/01/2026  
**Versão**: 3.2.3 com Marca D'Água  
**Status**: ✅ Pronto para Usar
