import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';
import 'secret_recording_screen.dart';
import 'video_playback_screen.dart';

/// Tela para gerenciar vídeos gravados secretamente
class RecordedVideosScreen extends StatefulWidget {
  const RecordedVideosScreen({Key? key}) : super(key: key);

  @override
  State<RecordedVideosScreen> createState() => _RecordedVideosScreenState();
}

class _RecordedVideosScreenState extends State<RecordedVideosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vídeos Gravados'),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: Consumer<CameraProvider>(
        builder: (context, cameraProvider, _) {
          final recordings = cameraProvider.getRecordings();

          if (recordings.isEmpty) {
            return _buildEmptyState();
          }

          return _buildVideosList(recordings, cameraProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SecretRecordingScreen(),
          ),
        ),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.videocam),
      ),
    );
  }

  /// Estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Nenhum vídeo gravado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Toque no botão para gravar seu primeiro vídeo',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Lista de vídeos
  Widget _buildVideosList(
    List<RecordedVideo> recordings,
    CameraProvider cameraProvider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final video = recordings[index];
        return _buildVideoCard(context, video, cameraProvider);
      },
    );
  }

  /// Card de vídeo
  Widget _buildVideoCard(
    BuildContext context,
    RecordedVideo video,
    CameraProvider cameraProvider,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.videocam, color: Colors.blue, size: 32),
        ),
        title: Text(
          'Vídeo - ${video.createdAt.hour.toString().padLeft(2, '0')}:${video.createdAt.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(
              'Duração: ${_formatDuration(video.duration)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Câmera: ${_getCameraName(video.cameraUsed)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(video.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              child: Row(
                children: const [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Reproduzir'),
                ],
              ),
              onTap: () => _playVideo(context, video),
            ),
            PopupMenuItem(
              child: Row(
                children: const [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Compartilhar'),
                ],
              ),
              onTap: () => _shareVideo(video),
            ),
            PopupMenuItem(
              child: Row(
                children: const [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Deletar', style: TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () => _deleteVideo(context, video, cameraProvider),
            ),
          ],
        ),
      ),
    );
  }

  /// Reproduzir vídeo
  void _playVideo(BuildContext context, RecordedVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlaybackScreen(video: video),
      ),
    );
  }

  /// Compartilhar vídeo
  void _shareVideo(RecordedVideo video) {
    // TODO: Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartilhamento em desenvolvimento')),
    );
  }

  /// Deletar vídeo
  void _deleteVideo(
    BuildContext context,
    RecordedVideo video,
    CameraProvider cameraProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Vídeo?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await cameraProvider.deleteRecording(video);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Vídeo deletado')));
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Formatar duração
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Obter nome da câmera
  String _getCameraName(String cameraUsed) {
    if (cameraUsed.toLowerCase().contains('front')) {
      return 'Frontal';
    } else if (cameraUsed.toLowerCase().contains('back')) {
      return 'Traseira';
    } else if (cameraUsed.toLowerCase().contains('both')) {
      return 'Ambas';
    }
    return cameraUsed;
  }

  /// Formatar data
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

typedef RecordedVideo = CameraProvider.RecordedVideo;
