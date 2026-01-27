# 💡 Exemplos Práticos: Usando o Sistema de Gravação Secreta

## Exemplo 1: Acessar a Funcionalidade de Gravação

### Opção 1 - Via Botão na Home
```dart
// Na HomeScreen, o usuário vê dois botões:
// 1. Botão "Gravar" (vermelho)
// 2. Botão "Vídeos" (azul)

// Fluxo automático:
// HomeScreen → SecretRecordingScreen
```

### Opção 2 - Via Widget Customizado
```dart
import 'package:seu_app/widgets/camera_widgets.dart';

// Usar SecretRecordingButton
SecretRecordingButton(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SecretRecordingScreen(),
    ),
  ),
  color: Colors.red,
)

// Ou com ícone na AppBar
AppBar(
  title: const Text('Seu App'),
  actions: [
    SecretRecordingAppBarIcon(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RecordedVideosScreen(),
        ),
      ),
    ),
  ],
)
```

---

## Exemplo 2: Gravar um Vídeo Simples

### Passo a Passo
```dart
import 'package:seu_app/providers/camera_provider.dart';
import 'package:seu_app/services/permission_service.dart';

// 1. Obter o provider
final cameraProvider = context.read<CameraProvider>();

// 2. Verificar permissões
bool hasPermissions = await PermissionService.hasCameraPermission();
if (!hasPermissions) {
  await PermissionService.requestCameraPermission();
}

// 3. Inicializar câmera
await cameraProvider.selectCamera(cameraProvider.getBackCamera()!);

// 4. Iniciar gravação
final success = await cameraProvider.startRecording();
if (success) {
  print('Gravação iniciada');
}

// 5. Parar gravação (após alguns segundos/ações)
await cameraProvider.stopRecording();
print('Gravação parada');

// 6. Acessar vídeos gravados
final recordings = cameraProvider.getRecordings();
for (var video in recordings) {
  print('Vídeo: ${video.id}');
  print('Câmera: ${video.cameraUsed}');
  print('Duração: ${video.duration.inSeconds}s');
}
```

---

## Exemplo 3: Usar Câmera Frontal (Selfie)

```dart
final cameraProvider = context.read<CameraProvider>();

// Obter câmera frontal
final frontCamera = cameraProvider.getFrontCamera();

if (frontCamera != null) {
  // Selecionar câmera frontal
  await cameraProvider.selectCamera(frontCamera);
  
  // Agora a preview será da câmera frontal
  // Usuário pode gravar normalmente
  await cameraProvider.startRecording();
  
  // ... após alguns segundos ...
  
  await cameraProvider.stopRecording();
}
```

---

## Exemplo 4: Alternar Entre Câmeras

```dart
final cameraProvider = context.read<CameraProvider>();

// Selecionar câmera traseira
var backCamera = cameraProvider.getBackCamera();
await cameraProvider.selectCamera(backCamera!);

// ... gravando ...

// Depois, alternar para frontal
var frontCamera = cameraProvider.getFrontCamera();
await cameraProvider.selectCamera(frontCamera!);

// Ou usar método direto para alternar
await cameraProvider.switchCamera();
```

---

## Exemplo 5: Reproduzir um Vídeo Gravado

```dart
import 'package:seu_app/screens/video_playback_screen.dart';

final cameraProvider = context.read<CameraProvider>();
final recordings = cameraProvider.getRecordings();

if (recordings.isNotEmpty) {
  final firstVideo = recordings[0];
  
  // Navegar para tela de reprodução
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VideoPlaybackScreen(
        video: firstVideo,
      ),
    ),
  );
}
```

---

## Exemplo 6: Deletar um Vídeo

```dart
final cameraProvider = context.read<CameraProvider>();
final recordings = cameraProvider.getRecordings();

if (recordings.isNotEmpty) {
  final videoToDelete = recordings[0];
  
  // Deletar vídeo
  final success = await cameraProvider.deleteRecording(videoToDelete);
  
  if (success) {
    print('Vídeo deletado com sucesso');
  } else {
    print('Erro ao deletar vídeo');
  }
}
```

---

## Exemplo 7: Salvar Vídeo na Galeria

```dart
final cameraProvider = context.read<CameraProvider>();
final recordings = cameraProvider.getRecordings();

if (recordings.isNotEmpty) {
  final video = recordings[0];
  
  // Salvar na galeria do dispositivo
  bool saved = await cameraProvider.saveVideoToGallery(
    video.filePath,
  );
  
  if (saved) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vídeo salvo na galeria')),
    );
  }
}
```

---

## Exemplo 8: Monitorar Estado de Gravação

```dart
import 'package:seu_app/providers/camera_provider.dart';

// Usar Consumer para reagir a mudanças
Consumer<CameraProvider>(
  builder: (context, cameraProvider, _) {
    return Column(
      children: [
        if (cameraProvider.isRecording)
          Text(
            'Gravando: ${cameraProvider.recordingTime}',
            style: const TextStyle(color: Colors.red),
          )
        else
          const Text('Não está gravando'),
        
        if (cameraProvider.selectedCamera != null)
          Text(
            'Câmera: ${cameraProvider.selectedCamera!.name}',
          ),
      ],
    );
  },
)
```

---

## Exemplo 9: Integrar com Seu Próprio Widget

```dart
import 'package:seu_app/widgets/camera_widgets.dart';

// Usar o CameraQuickMenu customizado
class MyCustomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CameraQuickMenu(
              onRecord: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecretRecordingScreen(),
                  ),
                );
              },
              onViewVideos: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecordedVideosScreen(),
                  ),
                );
              },
              onClose: () => Navigator.pop(context),
            ),
          );
        },
        child: const Text('Câmera Secreta'),
      ),
    );
  }
}
```

---

## Exemplo 10: Verificar Permissões e Solicitar

```dart
import 'package:seu_app/services/permission_service.dart';

class PermissionChecker {
  static Future<void> checkAndRequestPermissions() async {
    // Verificar câmera
    bool hasCamera = await PermissionService.hasCameraPermission();
    bool hasMic = await PermissionService.hasMicrophonePermission();
    
    if (!hasCamera || !hasMic) {
      // Solicitar todas de uma vez
      bool allGranted = await PermissionService.requestAllPermissions();
      
      if (!allGranted) {
        // Abrir configurações
        await PermissionService.openAppSettings();
      }
    }
  }
}

// Usar em InitState
void initState() {
  super.initState();
  PermissionChecker.checkAndRequestPermissions();
}
```

---

## Exemplo 11: Custom Hook - Auto-Parar Após Tempo

```dart
Future<void> recordAndStopAfter({
  required CameraProvider cameraProvider,
  required Duration duration,
}) async {
  // Iniciar gravação
  await cameraProvider.startRecording();
  
  // Aguardar tempo especificado
  await Future.delayed(duration);
  
  // Parar gravação
  await cameraProvider.stopRecording();
  
  print('Vídeo de ${duration.inSeconds}s gravado');
}

// Usar
await recordAndStopAfter(
  cameraProvider: cameraProvider,
  duration: const Duration(seconds: 10),
);
```

---

## Exemplo 12: Criar Extensão Helper

```dart
extension CameraProviderHelper on CameraProvider {
  /// Gravar vídeo em modo contínuo
  Future<void> recordContinuous() async {
    if (!isRecording) {
      await startRecording();
    }
  }
  
  /// Parar e salvar automaticamente
  Future<void> stopAndSave() async {
    if (isRecording) {
      await stopRecording();
      
      final lastVideo = getRecordings().last;
      await saveVideoToGallery(lastVideo.filePath);
    }
  }
  
  /// Contar vídeos
  int getVideoCount() => getRecordings().length;
  
  /// Duração total
  Duration getTotalDuration() {
    return getRecordings().fold<Duration>(
      Duration.zero,
      (total, video) => total + video.duration,
    );
  }
}

// Usar extensão
await cameraProvider.recordContinuous();
// ... depois
await cameraProvider.stopAndSave();

int count = cameraProvider.getVideoCount();
Duration total = cameraProvider.getTotalDuration();
```

---

## Exemplo 13: Gerenciar Múltiplos Vídeos

```dart
class VideoManager {
  final CameraProvider cameraProvider;
  
  VideoManager(this.cameraProvider);
  
  /// Deletar vídeos antigos (mais de N dias)
  Future<void> deleteOldVideos(int days) async {
    final now = DateTime.now();
    final recordings = cameraProvider.getRecordings();
    
    for (var video in recordings) {
      final diff = now.difference(video.createdAt).inDays;
      
      if (diff > days) {
        await cameraProvider.deleteRecording(video);
      }
    }
  }
  
  /// Obter vídeos de hoje
  List<RecordedVideo> getVideosFromToday() {
    final today = DateTime.now();
    return cameraProvider.getRecordings().where((v) {
      return v.createdAt.year == today.year &&
             v.createdAt.month == today.month &&
             v.createdAt.day == today.day;
    }).toList();
  }
  
  /// Exportar lista de vídeos
  String exportVideosList() {
    final recordings = cameraProvider.getRecordings();
    return recordings.map((v) {
      return 'ID: ${v.id}\n'
             'Data: ${v.createdAt}\n'
             'Duração: ${v.duration.inSeconds}s\n'
             'Câmera: ${v.cameraUsed}\n'
             '---\n';
    }).join();
  }
}

// Usar
final manager = VideoManager(cameraProvider);

// Deletar vídeos com mais de 7 dias
await manager.deleteOldVideos(7);

// Obter vídeos de hoje
final todayVideos = manager.getVideosFromToday();

// Exportar
print(manager.exportVideosList());
```

---

## Exemplo 14: Stream de Eventos de Gravação

```dart
// Criar um StreamController para eventos
StreamController<RecordingEvent> recordingEvents = 
    StreamController<RecordingEvent>.broadcast();

enum RecordingEvent { started, stopped, paused }

// Disparar eventos
Future<void> recordWithEvents() async {
  final cameraProvider = context.read<CameraProvider>();
  
  await cameraProvider.startRecording();
  recordingEvents.add(RecordingEvent.started);
  
  // ... gravando ...
  
  await cameraProvider.stopRecording();
  recordingEvents.add(RecordingEvent.stopped);
}

// Escutar eventos
recordingEvents.stream.listen((event) {
  switch (event) {
    case RecordingEvent.started:
      print('Gravação iniciada');
      break;
    case RecordingEvent.stopped:
      print('Gravação parada');
      break;
    case RecordingEvent.paused:
      print('Gravação pausada');
      break;
  }
});
```

---

## Exemplo 15: Notificação de Gravação em Background

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RecordingNotifications {
  static final plugin = FlutterLocalNotificationsPlugin();
  
  static Future<void> showRecordingNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'recording',
        'Recording',
        channelDescription: 'Notificações de gravação',
        ongoing: true,
        priority: Priority.high,
      ),
    );
    
    await plugin.show(
      0,
      'Gravando vídeo',
      'Toque para voltar ao app',
      details,
    );
  }
  
  static Future<void> cancelNotification() async {
    await plugin.cancel(0);
  }
}

// Usar
await RecordingNotifications.showRecordingNotification();
await cameraProvider.startRecording();

// ... depois
await cameraProvider.stopRecording();
await RecordingNotifications.cancelNotification();
```

---

## 📝 Notas Importantes

### Performance
- Câmera consome muita memória
- Sempre chame `dispose()` quando não precisar
- Use `ConsumerWidget` para otimizar rebuilds

### Segurança
- Sempre solicite permissões
- Valide caminhos de arquivo
- Criptografe dados sensíveis se necessário

### UX
- Mostre indicadores visuais
- Forneça feedback de erros
- Use snackbars para confirmações

---

## 🎓 Conclusão

Esses exemplos cobrem os principais casos de uso do sistema de gravação secreta. Adapte-os conforme sua necessidade específica!

---

**Desenvolvido**: 2024
**Status**: ✅ Pronto para uso
