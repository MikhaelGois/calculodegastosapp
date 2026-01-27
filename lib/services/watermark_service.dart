import 'package:intl/intl.dart';
import 'location_service.dart';

/// Modelo de marca d'água
class WatermarkData {
  final DateTime recordedAt;
  final LocationData? location;
  final String? cameraType; // 'Frontal', 'Traseira', 'Ambas'

  WatermarkData({
    required this.recordedAt,
    this.location,
    this.cameraType,
  });

  /// Formatar data para exibição
  String get formattedDate =>
      DateFormat('dd/MM/yyyy').format(recordedAt);

  /// Formatar hora para exibição
  String get formattedTime =>
      DateFormat('HH:mm:ss').format(recordedAt);

  /// Gerar string de marca d'água completa
  String toWatermarkString() {
    final dateTime = '$formattedDate $formattedTime';
    final locationStr = location != null 
        ? '\n${location!.toWatermarkString()}'
        : '';
    final cameraStr = cameraType != null ? '\n$cameraType' : '';
    
    return '$dateTime$locationStr$cameraStr';
  }

  /// Gerar string curta para exibição
  String toShortString() {
    return '$formattedDate $formattedTime';
  }

  /// Gerar JSON para armazenamento
  Map<String, dynamic> toJson() {
    return {
      'recordedAt': recordedAt.toIso8601String(),
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      'address': location?.address,
      'city': location?.city,
      'state': location?.state,
      'cameraType': cameraType,
    };
  }

  /// Criar a partir de JSON
  factory WatermarkData.fromJson(Map<String, dynamic> json) {
    LocationData? location;
    if (json['latitude'] != null && json['longitude'] != null) {
      location = LocationData(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
        address: json['address'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
      );
    }

    return WatermarkData(
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      location: location,
      cameraType: json['cameraType'] as String?,
    );
  }
}

/// Serviço de marca d'água
class WatermarkService {
  /// Gerar dados de marca d'água para um novo vídeo
  static Future<WatermarkData> generateWatermarkData({
    String? cameraType,
  }) async {
    // Obter localização
    LocationData? location;
    try {
      location = await LocationService.getCurrentLocation();
    } catch (e) {
      print('Erro ao obter localização para marca d'água: $e');
    }

    return WatermarkData(
      recordedAt: DateTime.now(),
      location: location,
      cameraType: cameraType,
    );
  }

  /// Formatar marca d'água para exibição em vídeo
  /// Retorna múltiplas linhas formatadas
  static List<String> formatWatermarkLines(WatermarkData watermark) {
    final lines = <String>[];

    // Data e hora
    lines.add('${watermark.formattedDate}');
    lines.add('${watermark.formattedTime}');

    // Localização
    if (watermark.location != null) {
      lines.add('');
      lines.add(watermark.location!.toDisplayString());
      lines.add(
          '${watermark.location!.latitude.toStringAsFixed(4)}, ${watermark.location!.longitude.toStringAsFixed(4)}');
    }

    // Tipo de câmera
    if (watermark.cameraType != null) {
      lines.add('');
      lines.add('Câmera: ${watermark.cameraType}');
    }

    return lines;
  }

  /// Formatar como string única com quebras de linha
  static String formatWatermarkText(WatermarkData watermark) {
    return formatWatermarkLines(watermark).join('\n');
  }
}
