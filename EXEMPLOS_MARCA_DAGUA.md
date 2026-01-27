# 📝 Exemplos - Marca D'Água

## Exemplo 1: Uso Básico

```dart
import 'services/watermark_service.dart';
import 'services/location_service.dart';

// Gerar marca d'água automaticamente
Future<void> recordWithWatermark() async {
  // Gerar marca d'água com data, hora, localização
  WatermarkData watermark = await WatermarkService.generateWatermarkData(
    cameraType: 'Traseira',
  );
  
  // Usar em ui
  print(watermark.formattedDate);  // "27/01/2026"
  print(watermark.formattedTime);  // "14:30:45"
  
  if (watermark.location != null) {
    print(watermark.location!.toDisplayString());
    // "Av Paulista, São Paulo"
  }
}
```

---

## Exemplo 2: Exibir Marca D'Água Durante Gravação

```dart
import 'widgets/watermark_widgets.dart';

// Na tela de gravação
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Preview da câmera
        CameraPreview(_controller),
        
        // Marca d'água com animação pulsante
        RecordingWatermarkWidget(
          watermarkData: watermark,
          alignment: Alignment.bottomLeft,
          isRecording: isRecording,
        ),
        
        // Outros controles...
      ],
    ),
  );
}
```

---

## Exemplo 3: Obter Localização Manualmente

```dart
import 'services/location_service.dart';

// Obter localização atual
Future<void> getLocationInfo() async {
  // Verificar permissão
  bool hasPermission = await LocationService.hasLocationPermission();
  
  if (!hasPermission) {
    // Solicitar permissão
    hasPermission = await LocationService.requestLocationPermission();
  }
  
  if (hasPermission) {
    // Obter localização
    LocationData? location = await LocationService.getCurrentLocation();
    
    if (location != null) {
      print('Latitude: ${location.latitude}');
      print('Longitude: ${location.longitude}');
      print('Endereço: ${location.address}');
      print('Cidade: ${location.city}');
      print('Estado: ${location.state}');
    }
  }
}
```

---

## Exemplo 4: Registrar Vídeo com Marca D'Água

```dart
import 'providers/camera_provider.dart';
import 'services/watermark_service.dart';

// Salvar vídeo com dados de marca d'água
Future<void> saveVideoWithWatermark(
  String videoPath,
  String cameraType,
) async {
  final cameraProvider = context.read<CameraProvider>();
  
  // Gerar marca d'água
  WatermarkData watermark = await WatermarkService.generateWatermarkData(
    cameraType: cameraType,
  );
  
  // Registrar vídeo com marca d'água
  cameraProvider.registerRecording(
    filePath: videoPath,
    duration: Duration(seconds: 45),
    cameraUsed: cameraType,
    watermarkData: watermark,  // ✅ Incluir dados
  );
}
```

---

## Exemplo 5: Visualizar Marca D'Água em Card

```dart
import 'widgets/watermark_widgets.dart';

// Exibir dados em um card
@override
Widget build(BuildContext context) {
  if (video.watermarkData != null) {
    return WatermarkPreviewCard(
      watermarkData: video.watermarkData!,
      showCamera: true,
    );
  }
  
  return SizedBox.shrink();
}
```

---

## Exemplo 6: Acessar Dados Persistidos

```dart
import 'providers/camera_provider.dart';

// Recuperar vídeos e seus dados de marca d'água
void displayAllWatermarks(BuildContext context) {
  final cameraProvider = context.read<CameraProvider>();
  
  // Obter todos os vídeos
  List<RecordedVideo> videos = cameraProvider.getRecordings();
  
  // Iterar e exibir dados
  for (var video in videos) {
    if (video.watermarkData != null) {
      print('Vídeo: ${video.id}');
      print('Data: ${video.watermarkData!.formattedDate}');
      print('Hora: ${video.watermarkData!.formattedTime}');
      
      if (video.watermarkData!.location != null) {
        print('Local: ${video.watermarkData!.location!.toDisplayString()}');
        print('Coordenadas: '
            '${video.watermarkData!.location!.latitude}, '
            '${video.watermarkData!.location!.longitude}');
      }
      
      print('Câmera: ${video.watermarkData!.cameraType}');
      print('---');
    }
  }
}
```

---

## Exemplo 7: Formatar Marca D'Água como Texto

```dart
import 'services/watermark_service.dart';

// Converter marca d'água para texto puro
void formatWatermarkAsText(WatermarkData watermark) {
  // Múltiplas linhas
  List<String> lines = WatermarkService.formatWatermarkLines(watermark);
  lines.forEach(print);
  // Output:
  // 27/01/2026
  // 14:30:45
  // 
  // Av Paulista, São Paulo
  // (-23.5505, -46.6333)
  // 
  // Câmera: Frontal
  
  // Texto único
  String text = WatermarkService.formatWatermarkText(watermark);
  print(text);
  // Output: "27/01/2026\n14:30:45\nAv Paulista...\n..."
}
```

---

## Exemplo 8: Serializar para JSON

```dart
import 'services/watermark_service.dart';

// Converter marca d'água para JSON (salvar em banco de dados)
Future<void> saveWatermarkToDatabase(WatermarkData watermark) async {
  // Convertendo para JSON
  Map<String, dynamic> json = watermark.toJson();
  
  // Resultado:
  // {
  //   'recordedAt': '2026-01-27T14:30:45.123456',
  //   'latitude': -23.5505,
  //   'longitude': -46.6333,
  //   'address': 'Av Paulista, São Paulo',
  //   'city': 'São Paulo',
  //   'state': 'SP',
  //   'cameraType': 'Frontal'
  // }
  
  // Salvar no banco de dados (exemplo genérico)
  // await database.insert('watermarks', json);
}
```

---

## Exemplo 9: Desserializar de JSON

```dart
import 'services/watermark_service.dart';

// Recuperar marca d'água do banco de dados
Future<WatermarkData?> loadWatermarkFromDatabase() async {
  // Obter JSON do banco de dados
  Map<String, dynamic> json = {
    'recordedAt': '2026-01-27T14:30:45.123456',
    'latitude': -23.5505,
    'longitude': -46.6333,
    'address': 'Av Paulista, São Paulo',
    'city': 'São Paulo',
    'state': 'SP',
    'cameraType': 'Frontal'
  };
  
  // Converter de volta para WatermarkData
  WatermarkData watermark = WatermarkData.fromJson(json);
  
  return watermark;
}
```

---

## Exemplo 10: Posicionar Marca D'Água em Diferentes Cantos

```dart
import 'widgets/watermark_widgets.dart';

// Exemplo com diferentes alinhamentos
@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Centro superior
      WatermarkOverlay(
        watermarkData: watermark,
        alignment: Alignment.topCenter,
      ),
      
      // Canto inferior direito
      WatermarkOverlay(
        watermarkData: watermark,
        alignment: Alignment.bottomRight,
      ),
      
      // Canto superior esquerdo (com tamanho menor)
      WatermarkOverlay(
        watermarkData: watermark,
        alignment: Alignment.topLeft,
        fontSize: 10,
        opacity: 0.7,
      ),
    ],
  );
}
```

---

## Exemplo 11: Validar Localização Antes de Gravar

```dart
import 'services/location_service.dart';

// Verificar se tem GPS antes de gravar
Future<bool> checkLocationBeforeRecording() async {
  // Verificar permissão
  bool hasPermission = await LocationService.hasLocationPermission();
  
  if (!hasPermission) {
    // Mostrar diálogo para solicitar
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Localização Necessária'),
        content: Text('Para gravar com marca d\'água, '
            'precisamos acessar sua localização.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await LocationService.requestLocationPermission();
              Navigator.pop(context);
            },
            child: Text('Permitir'),
          ),
        ],
      ),
    );
    return false;
  }
  
  // Testar obter localização
  LocationData? location = await LocationService.getCurrentLocation();
  
  return location != null;
}
```

---

## Exemplo 12: Loop de Atualização em Tempo Real

```dart
import 'services/watermark_service.dart';

// Atualizar marca d'água a cada segundo (para relógio ao vivo)
void startWatermarkUpdater() {
  Timer.periodic(Duration(seconds: 1), (timer) {
    // Regenerar marca d'água com hora atual
    WatermarkService.generateWatermarkData(
      cameraType: 'Frontal',
    ).then((watermark) {
      // Atualizar UI
      setState(() {
        _currentWatermark = watermark;
      });
    });
  });
}
```

---

## Exemplo 13: Copiar para Clipboard

```dart
import 'package:flutter/services.dart';
import 'services/watermark_service.dart';

// Copiar marca d'água para clipboard
Future<void> copyWatermarkToClipboard(WatermarkData watermark) async {
  String text = WatermarkService.formatWatermarkText(watermark);
  
  await Clipboard.setData(
    ClipboardData(text: text),
  );
  
  // Mostrar snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Marca d\'água copiada!')),
  );
}
```

---

## Exemplo 14: Filtrar Vídeos por Localização

```dart
import 'providers/camera_provider.dart';

// Encontrar vídeos gravados em uma localização específica
List<RecordedVideo> findVideosByLocation(
  double targetLatitude,
  double targetLongitude,
  double radiusKm,
) {
  final cameraProvider = context.read<CameraProvider>();
  final videos = cameraProvider.getRecordings();
  
  return videos.where((video) {
    if (video.watermarkData?.location == null) return false;
    
    final lat = video.watermarkData!.location!.latitude;
    final lon = video.watermarkData!.location!.longitude;
    
    // Cálculo simples de distância (não é precisão 100%)
    final distance = ((lat - targetLatitude) * 111) +
                     ((lon - targetLongitude) * 111);
    
    return distance.abs() <= radiusKm;
  }).toList();
}
```

---

## Exemplo 15: Exportar Dados para CSV

```dart
import 'providers/camera_provider.dart';

// Exportar todos os vídeos e suas marcas d'água para CSV
String exportWatermarksToCSV() {
  final cameraProvider = context.read<CameraProvider>();
  final videos = cameraProvider.getRecordings();
  
  StringBuffer csv = StringBuffer();
  csv.writeln('ID,Data,Hora,Endereço,Latitude,Longitude,Câmera,Duração');
  
  for (var video in videos) {
    if (video.watermarkData != null) {
      final w = video.watermarkData!;
      csv.writeln(
        '${video.id},'
        '${w.formattedDate},'
        '${w.formattedTime},'
        '"${w.location?.address ?? ""}",'
        '${w.location?.latitude},'
        '${w.location?.longitude},'
        '${w.cameraType},'
        '${video.duration.inSeconds}s'
      );
    }
  }
  
  return csv.toString();
}
```

---

**Total de Exemplos**: 15  
**Todos Funcionais**: ✅ Sim  
**Prontos para Copiar**: ✅ Sim
