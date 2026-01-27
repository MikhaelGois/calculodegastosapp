import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/watermark_service.dart';
import '../services/location_service.dart';

/// Provider para gerenciar estado da câmera e gravação
class CameraProvider extends ChangeNotifier {
  List<CameraDescription> _cameras = [];
  CameraDescription? _selectedCamera;
  bool _isRecording = false;
  bool _isInitialized = false;
  String _recordingTime = '00:00';
  CameraSelection _cameraSelection = CameraSelection.back;

  // Getters
  List<CameraDescription> get cameras => _cameras;
  CameraDescription? get selectedCamera => _selectedCamera;
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  String get recordingTime => _recordingTime;
  CameraSelection get cameraSelection => _cameraSelection;

  CameraProvider() {
    _initializeCameras();
  }

  /// Inicializar câmeras disponíveis
  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();

      // Selecionar câmera traseira por padrão
      if (_cameras.isNotEmpty) {
        _selectedCamera = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao inicializar câmeras: $e');
    }
  }

  /// Definir seleção de câmera
  void setCameraSelection(CameraSelection selection) {
    _cameraSelection = selection;
    notifyListeners();
  }

  /// Obter câmera frontal
  CameraDescription? getFrontCamera() {
    return _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );
  }

  /// Obter câmera traseira
  CameraDescription? getBackCamera() {
    return _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );
  }

  /// Selecionar câmera
  Future<void> selectCamera(CameraDescription camera) async {
    _selectedCamera = camera;

    if (_isInitialized) {
      await CameraService.dispose();
    }

    if (_selectedCamera != null) {
      await CameraService.initializeCamera(_selectedCamera!, () {
        _isInitialized = true;
        notifyListeners();
      });
    }

    notifyListeners();
  }

  /// Alternar câmera
  Future<void> switchCamera() async {
    if (_selectedCamera == null) return;

    final newCamera = _cameras.firstWhere(
      (c) => c.lensDirection != _selectedCamera!.lensDirection,
      orElse: () => _selectedCamera!,
    );

    await selectCamera(newCamera);
  }

  /// Iniciar gravação
  Future<bool> startRecording() async {
    if (_isInitialized) {
      final success = await CameraService.startRecording();
      if (success) {
        _isRecording = true;
        _startRecordingTimer();
        notifyListeners();
      }
      return success;
    }
    return false;
  }

  /// Parar gravação
  Future<void> stopRecording() async {
    if (_isRecording) {
      final xFile = await CameraService.stopRecording();
      _isRecording = false;
      _recordingTime = '00:00';
      notifyListeners();
      return xFile;
    }
  }

  /// Timer de gravação
  void _startRecordingTimer() {
    int seconds = 0;
    Future.doWhile(() async {
      if (!_isRecording) return false;

      await Future.delayed(const Duration(seconds: 1));
      seconds++;

      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      _recordingTime =
          '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

      notifyListeners();
      return true;
    });
  }

  /// Salvar vídeo na galeria
  Future<bool> saveVideoToGallery(String videoPath) async {
    return await CameraService.saveToGallery(videoPath);
  }

  /// Registrar vídeo
  void registerRecording(
    String filePath,
    Duration duration,
    String cameraUsed,
    WatermarkData? watermarkData,
  ) {
    CameraService.registerRecording(
      filePath,
      duration,
      cameraUsed,
      watermarkData,
    );
    notifyListeners();
  }

  /// Obter vídeos gravados
  List<RecordedVideo> getRecordings() {
    return CameraService.recordings;
  }

  /// Deletar vídeo
  Future<bool> deleteRecording(RecordedVideo video) async {
    final success = await CameraService.deleteRecording(video);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  @override
  Future<void> dispose() async {
    await CameraService.dispose();
    super.dispose();
  }
}

enum CameraSelection { front, back, both }

typedef RecordedVideo = CameraService.RecordedVideo;
