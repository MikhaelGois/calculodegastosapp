import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';

/// Widget para exibir botão de acesso rápido à gravação secreta
class SecretRecordingButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;
  final bool showBadge;

  const SecretRecordingButton({
    Key? key,
    this.onTap,
    this.color,
    this.showBadge = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, _) {
        final recordingCount = cameraProvider.getRecordings().length;

        return Stack(
          alignment: Alignment.topRight,
          children: [
            FloatingActionButton(
              onPressed: onTap,
              backgroundColor: color ?? Colors.red,
              child: const Icon(Icons.videocam),
            ),
            if (showBadge && recordingCount > 0)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  recordingCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Widget para exibir ícone de câmera com badge na AppBar
class SecretRecordingAppBarIcon extends StatelessWidget {
  final VoidCallback onTap;

  const SecretRecordingAppBarIcon({Key? key, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, _) {
        final recordingCount = cameraProvider.getRecordings().length;

        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: onTap,
              tooltip: 'Vídeos Gravados',
            ),
            if (recordingCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    recordingCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Widget para mostrar status de gravação
class RecordingStatusBadge extends StatelessWidget {
  const RecordingStatusBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, _) {
        if (!cameraProvider.isRecording) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Gravando...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget para exibir mini preview de gravação
class RecordingMiniPreview extends StatelessWidget {
  const RecordingMiniPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, _) {
        if (!cameraProvider.isRecording) {
          return const SizedBox.shrink();
        }

        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.videocam, color: Colors.red, size: 48),
              Positioned(
                bottom: 8,
                child: Text(
                  cameraProvider.recordingTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget para menu rápido de ações da câmera
class CameraQuickMenu extends StatelessWidget {
  final VoidCallback onRecord;
  final VoidCallback onViewVideos;
  final VoidCallback onClose;

  const CameraQuickMenu({
    Key? key,
    required this.onRecord,
    required this.onViewVideos,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Câmera Secreta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRecord,
              icon: const Icon(Icons.circle),
              label: const Text('Iniciar Gravação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Consumer<CameraProvider>(
              builder: (context, cameraProvider, _) {
                final count = cameraProvider.getRecordings().length;
                return ElevatedButton.icon(
                  onPressed: onViewVideos,
                  icon: const Icon(Icons.video_library),
                  label: Text('Ver Vídeos ($count)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onClose, child: const Text('Fechar')),
          ],
        ),
      ),
    );
  }
}

/// Widget com informações de espaço em disco
class StorageInfoWidget extends StatelessWidget {
  const StorageInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar obtenção de informações de armazenamento
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(Icons.storage, size: 16),
          SizedBox(width: 8),
          Text('Espaço: --'),
        ],
      ),
    );
  }
}
