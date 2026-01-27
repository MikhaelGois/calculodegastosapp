import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'watermark_service.dart';

/// Enum para seleção de câmera
enum CameraSelection {
  front, // Câmera frontal
  back, // Câmera traseira
  both, // Ambas (selecionar ao gravar)
}

/// Modelo de vídeo gravado
class RecordedVideo {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;
  final String cameraUsed; // 'front', 'back', 'both'
  final WatermarkData? watermarkData; // Dados de marca d'água

  RecordedVideo({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.duration,
    required this.cameraUsed,
    this.watermarkData,
  });
}

/// Serviço de gravação de vídeo
class CameraService {
  static CameraController? _controller;
  static bool _isRecording = false;
  static String? _recordingPath;
  static final List<RecordedVideo> _recordings = [];

  static bool get isRecording => _isRecording;
  static bool get isInitialized => _controller?.value.isInitialized ?? false;
  static CameraController? get controller => _controller;
  static List<RecordedVideo> get recordings => List.unmodifiable(_recordings);

  /// Inicializar câmera
  static Future<void> initializeCamera(
    CameraDescription camera,
    VoidCallback onInit,
  ) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      onInit();
    } catch (e) {
      debugPrint('Erro ao inicializar câmera: $e');
    }
  }

  /// Iniciar gravação
  static Future<bool> startRecording() async {
    if (!isInitialized) return false;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/secret_videos');

      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${videoDir.path}/video_$timestamp.mp4';

      await _controller!.startVideoRecording();
      _isRecording = true;
      return true;
    } catch (e) {
      debugPrint('Erro ao iniciar gravação: $e');
      return false;
    }
  }

  /// Parar gravação
  static Future<XFile?> stopRecording() async {
    if (!isRecording) return null;

    try {
      final xFile = await _controller!.stopVideoRecording();
      _isRecording = false;

      // Salvar no caminho especificado
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        await file.writeAsBytes(await xFile.readAsBytes());
      }

      return xFile;
    } catch (e) {
      debugPrint('Erro ao parar gravação: $e');
      return null;
    }
  }

  /// Adicionar vídeo à galeria do dispositivo
  static Future<bool> saveToGallery(String videoPath) async {
    try {
      final result = await GallerySaver.saveVideo(videoPath);
      return result ?? false;
    } catch (e) {
      debugPrint('Erro ao salvar na galeria: $e');
      return false;
    }
  }

  /// Registrar vídeo gravado
  static void registerRecording(
    String filePath,
    Duration duration,
    String cameraUsed,
    WatermarkData? watermarkData,
  ) {
    _recordings.insert(
      0,
      RecordedVideo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: filePath,
        createdAt: DateTime.now(),
        duration: duration,
        cameraUsed: cameraUsed,
        watermarkData: watermarkData,
      ),
    );
  }

  /// Deletar vídeo
  static Future<bool> deleteRecording(RecordedVideo video) async {
    try {
      final file = File(video.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      _recordings.removeWhere((r) => r.id == video.id);
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar vídeo: $e');
      return false;
    }
  }

  /// Limpar recursos
  static Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _isRecording = false;
  }
}
