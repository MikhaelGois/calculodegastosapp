import 'package:permission_handler/permission_handler.dart';

/// Serviço para gerenciar permissões necessárias
class PermissionService {
  /// Solicitar permissão de câmera
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted || status.isDenied;
  }

  /// Solicitar permissão de microfone
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted || status.isDenied;
  }

  /// Solicitar permissão de armazenamento
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted || status.isDenied;
  }

  /// Verificar se tem permissão de câmera
  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Verificar se tem permissão de microfone
  static Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Verificar se tem permissão de armazenamento
  static Future<bool> hasStoragePermission() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  /// Solicitar todas as permissões necessárias
  static Future<bool> requestAllPermissions() async {
    final results = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();

    return results[Permission.camera]!.isGranted &&
        results[Permission.microphone]!.isGranted &&
        results[Permission.storage]!.isGranted;
  }

  /// Abrir configurações de app
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
