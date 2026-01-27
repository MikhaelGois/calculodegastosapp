import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';

/// Tela para reproduzir vídeos gravados
class VideoPlaybackScreen extends StatefulWidget {
  final RecordedVideo video;

  const VideoPlaybackScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoPlaybackScreen> createState() => _VideoPlaybackScreenState();
}

class _VideoPlaybackScreenState extends State<VideoPlaybackScreen> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// Inicializar vídeo
  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.file(
        widget.video.filePath.startsWith('/')
            ? widget.video.filePath
            : widget.video.filePath,
      );

      await _videoController.initialize();

      _videoController.addListener(() {
        if (mounted) {
          setState(() => _isPlaying = _videoController.value.isPlaying);
        }
      });

      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Erro ao inicializar vídeo: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar vídeo: $e')));
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reproduzir Vídeo'),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _buildBody(),
      backgroundColor: Colors.black,
    );
  }

  /// Construir corpo
  Widget _buildBody() {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Player
          AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_videoController),
                _buildPlayButton(),
                _buildProgressBar(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Controles
          _buildControls(),

          const SizedBox(height: 24),

          // Informações
          _buildVideoInfo(),
        ],
      ),
    );
  }

  /// Botão de play/pause
  Widget _buildPlayButton() {
    if (_isPlaying) return const SizedBox.shrink();

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.white),
          iconSize: 64,
          onPressed: () => _videoController.play(),
        ),
      ),
    );
  }

  /// Barra de progresso
  Widget _buildProgressBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: VideoProgressIndicator(
        _videoController,
        allowScrubbing: true,
        colors: VideoProgressColors(
          playedColor: Colors.blue,
          bufferedColor: Colors.white30,
          backgroundColor: Colors.white10,
        ),
      ),
    );
  }

  /// Controles
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Retroceder 10s
          IconButton(
            icon: const Icon(Icons.replay_10, color: Colors.white),
            onPressed: () {
              final position = _videoController.value.position;
              final newPosition = Duration(
                milliseconds: (position.inMilliseconds - 10000)
                    .clamp(0, double.maxFinite)
                    .toInt(),
              );
              _videoController.seekTo(newPosition);
            },
          ),

          // Play/Pause
          FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.blue,
            onPressed: () {
              if (_videoController.value.isPlaying) {
                _videoController.pause();
              } else {
                _videoController.play();
              }
            },
            child: Icon(
              _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),

          // Avançar 10s
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.white),
            onPressed: () {
              final position = _videoController.value.position;
              final newPosition = Duration(
                milliseconds: (position.inMilliseconds + 10000)
                    .clamp(0, _videoController.value.duration.inMilliseconds)
                    .toInt(),
              );
              _videoController.seekTo(newPosition);
            },
          ),
        ],
      ),
    );
  }

  /// Informações do vídeo
  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Data',
                '${widget.video.createdAt.day}/${widget.video.createdAt.month}/${widget.video.createdAt.year}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Hora',
                '${widget.video.createdAt.hour.toString().padLeft(2, '0')}:${widget.video.createdAt.minute.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Duração', _formatDuration(widget.video.duration)),
              const SizedBox(height: 8),
              _buildInfoRow('Câmera', _getCameraName(widget.video.cameraUsed)),
              const SizedBox(height: 8),
              _buildInfoRow('Tamanho', _getFileSize(widget.video.filePath)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _shareVideo,
                    icon: const Icon(Icons.share),
                    label: const Text('Compartilhar'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveToGallery,
                    icon: const Icon(Icons.download),
                    label: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Linha de informação
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Compartilhar vídeo
  void _shareVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartilhamento em desenvolvimento')),
    );
  }

  /// Salvar para galeria
  Future<void> _saveToGallery() async {
    try {
      final cameraProvider = context.read<CameraProvider>();
      final success = await cameraProvider.saveVideoToGallery(
        widget.video.filePath,
      );

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vídeo salvo na galeria')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar na galeria')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  /// Formatar duração
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Obter nome da câmera
  String _getCameraName(String cameraUsed) {
    if (cameraUsed.toLowerCase().contains('front')) {
      return 'Câmera Frontal';
    } else if (cameraUsed.toLowerCase().contains('back')) {
      return 'Câmera Traseira';
    } else if (cameraUsed.toLowerCase().contains('both')) {
      return 'Ambas as Câmeras';
    }
    return cameraUsed;
  }

  /// Obter tamanho do arquivo
  String _getFileSize(String filePath) {
    // TODO: Implementar obtenção real do tamanho do arquivo
    return 'N/A';
  }
}

typedef RecordedVideo = CameraProvider.RecordedVideo;

class CameraProvider extends ChangeNotifier {
  final List<RecordedVideo> recordings = [];

  Future<bool> saveVideoToGallery(String videoPath) async {
    // TODO: Implementar salvamento na galeria
    return true;
  }
}

typedef ChangeNotifier = ValueNotifier<void>;
