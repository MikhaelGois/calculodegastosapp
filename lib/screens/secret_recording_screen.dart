import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/camera_provider.dart';
import '../services/permission_service.dart';

/// Tela para gravar vídeos secretos
class SecretRecordingScreen extends StatefulWidget {
  const SecretRecordingScreen({Key? key}) : super(key: key);

  @override
  State<SecretRecordingScreen> createState() => _SecretRecordingScreenState();
}

class _SecretRecordingScreenState extends State<SecretRecordingScreen> {
  bool _permissionsGranted = false;
  bool _isInitializingCamera = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  /// Verificar permissões necessárias
  Future<void> _checkPermissions() async {
    setState(() => _isInitializingCamera = true);

    final cameraOk = await PermissionService.hasCameraPermission();
    final micOk = await PermissionService.hasMicrophonePermission();

    if (!cameraOk || !micOk) {
      final all = await PermissionService.requestAllPermissions();
      setState(() => _permissionsGranted = all);
    } else {
      setState(() => _permissionsGranted = true);
    }

    if (mounted && _permissionsGranted) {
      await _initializeCamera();
    }

    setState(() => _isInitializingCamera = false);
  }

  /// Inicializar câmera
  Future<void> _initializeCamera() async {
    if (!mounted) return;

    final cameraProvider = context.read<CameraProvider>();

    if (cameraProvider.selectedCamera != null) {
      await cameraProvider.selectCamera(cameraProvider.selectedCamera!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gravação Secreta'),
        elevation: 0,
        backgroundColor: Colors.black87,
      ),
      body: _buildBody(),
      backgroundColor: Colors.black,
    );
  }

  /// Construir corpo da tela
  Widget _buildBody() {
    if (!_permissionsGranted) {
      return _buildPermissionDenied();
    }

    if (_isInitializingCamera) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, _) {
        if (!cameraProvider.isInitialized) {
          return _buildInitializing(context);
        }

        return _buildRecordingInterface(context, cameraProvider);
      },
    );
  }

  /// Widget de permissões negadas
  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 64, color: Colors.white54),
          const SizedBox(height: 24),
          const Text(
            'Permissões Necessárias',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'A gravação de vídeo requer permissões\nde câmera e microfone',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _checkPermissions,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: PermissionService.openAppSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Abrir Configurações'),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }

  /// Widget inicializando câmera
  Widget _buildInitializing(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'Inicializando câmera...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Interface de gravação
  Widget _buildRecordingInterface(
    BuildContext context,
    CameraProvider cameraProvider,
  ) {
    return Stack(
      children: [
        // Preview da câmera
        SizedBox.expand(child: CameraPreview(cameraProvider.selectedCamera!)),

        // Overlay gradiente no topo
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
          ),
        ),

        // Informações de câmera e tempo
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Seleção de câmera
              _buildCameraSelector(context, cameraProvider),

              // Tempo de gravação
              if (cameraProvider.isRecording)
                _buildRecordingTimer(cameraProvider),
            ],
          ),
        ),

        // Overlay gradiente na base
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
          ),
        ),

        // Controles de gravação
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: _buildRecordingControls(context, cameraProvider),
        ),

        // Botão de fechar
        Positioned(
          bottom: 120,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white24,
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.close),
          ),
        ),

        // Indicador de gravação em andamento
        if (cameraProvider.isRecording)
          Positioned(top: 16, right: 16, child: _buildRecordingIndicator()),
      ],
    );
  }

  /// Seletor de câmera
  Widget _buildCameraSelector(
    BuildContext context,
    CameraProvider cameraProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
        backdropFilter: const BackdropFilterTransform(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            cameraProvider.selectedCamera?.lensDirection ==
                    CameraLensDirection.front
                ? Icons.face
                : Icons.videocam,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (cameraProvider.isRecording) {
                _showWarningSnackbar('Pare a gravação para mudar de câmera');
                return;
              }

              if (value == 'front') {
                final frontCamera = cameraProvider.getFrontCamera();
                if (frontCamera != null) {
                  await cameraProvider.selectCamera(frontCamera);
                }
              } else if (value == 'back') {
                final backCamera = cameraProvider.getBackCamera();
                if (backCamera != null) {
                  await cameraProvider.selectCamera(backCamera);
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'front',
                child: Row(
                  children: [
                    const Icon(Icons.face, size: 18),
                    const SizedBox(width: 8),
                    const Text('Câmera Frontal'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'back',
                child: Row(
                  children: [
                    const Icon(Icons.videocam, size: 18),
                    const SizedBox(width: 8),
                    const Text('Câmera Traseira'),
                  ],
                ),
              ),
            ],
            color: const Color(0xFF424242),
            child: const Text(
              'Mudar',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Timer de gravação
  Widget _buildRecordingTimer(CameraProvider cameraProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            cameraProvider.recordingTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  /// Indicador de gravação
  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: const SizedBox(
        width: 24,
        height: 24,
        child: Center(
          child: SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Controles de gravação
  Widget _buildRecordingControls(
    BuildContext context,
    CameraProvider cameraProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!cameraProvider.isRecording)
          FloatingActionButton(
            onPressed: _startRecording,
            backgroundColor: Colors.red,
            child: const Icon(Icons.circle, size: 32),
          )
        else
          FloatingActionButton(
            onPressed: _stopRecording,
            backgroundColor: Colors.red,
            child: const Icon(Icons.square, size: 24),
          ),
      ],
    );
  }

  /// Iniciar gravação
  Future<void> _startRecording() async {
    final cameraProvider = context.read<CameraProvider>();

    try {
      final success = await cameraProvider.startRecording();
      if (success) {
        _showSnackbar('Gravação iniciada');
      } else {
        _showWarningSnackbar('Erro ao iniciar gravação');
      }
    } catch (e) {
      _showWarningSnackbar('Erro: $e');
    }
  }

  /// Parar gravação
  Future<void> _stopRecording() async {
    final cameraProvider = context.read<CameraProvider>();

    try {
      await cameraProvider.stopRecording();
      _showSnackbar('Gravação salva');
    } catch (e) {
      _showWarningSnackbar('Erro ao parar gravação: $e');
    }
  }

  /// Mostrar snackbar
  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Mostrar snackbar de aviso
  void _showWarningSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Dummy BackdropFilterTransform para evitar erro
class BackdropFilterTransform extends Object {
  const BackdropFilterTransform();
}
