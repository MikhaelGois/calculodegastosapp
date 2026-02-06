import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rotalucro/data/models/trip_model.dart';
import 'package:rotalucro/data/services/calculation_service.dart';
import 'package:rotalucro/data/storage/local_storage_service.dart';
import 'package:rotalucro/utils/overlay_service.dart';
import 'package:uuid/uuid.dart';

class NotificationListenerService {
  static const MethodChannel _channel = MethodChannel('notification_listener');

  // Apps de corrida suportados
  static const List<String> rideSharingApps = [
    'com.ubercab',
    'br.com.ninjado taxi',
    'com.taxis99',
    'com.inDriver',
    'com.u90101963.m',
    'com.app.taxi',
    'com.tz.call.driver.brasil'
  ];

  // Inicializar o serviço de escuta de notificações
  static Future<void> initialize() async {
    // Configurar o método para receber notificações do Android
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  // Manipular chamadas de método do lado nativo
  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onRideNotificationReceived':
        final arguments = call.arguments as Map<dynamic, dynamic>;
        final packageName = arguments['packageName'] as String?;
        final title = arguments['title'] as String?;
        final text = arguments['text'] as String?;

        if (packageName != null) {
          await _processRideNotification(packageName, title, text);
        }
        break;
      default:
        throw MissingPluginException('Método não implementado: ${call.method}');
    }
  }

  // Processar notificação de corrida recebida
  static Future<void> _processRideNotification(
    String packageName,
    String? title,
    String? text,
  ) async {
    print('Processando notificação de corrida: $packageName');

    // Tentar extrair informações da notificação
    final tripData = _extractTripDataFromNotification(title, text);

    // Carregar configuração de custos
    final config = await LocalStorageService.loadCostConfig();
    if (config == null) {
      // Se não houver configuração, mostrar aviso
      OverlayService.showTripAnalysisOverlay(
        title: 'Configure seus custos',
        subtitle:
            'Para análise automática, configure seus custos na aba de configurações',
        backgroundColor: Colors.orange,
        icon: Icons.warning,
      );
      return;
    }

    // Criar objeto de corrida com dados extraídos
    final trip = Trip(
      id: const Uuid().v4(),
      distance: tripData['distance'] ?? 0.0,
      value: tripData['value'] ?? 0.0,
      date: DateTime.now(),
      app: _getAppNameFromPackage(packageName),
    );

    // Calcular recomendação
    final recommendation =
        CalculationService.getTripRecommendation(trip, config);

    // Mostrar overlay com resultados
    _showTripAnalysisOverlay(recommendation);
  }

  // Extrair dados de corrida da notificação
  static Map<String, double> _extractTripDataFromNotification(
    String? title,
    String? text,
  ) {
    // Esta é uma implementação simplificada
    // Em um app real, você usaria técnicas de processamento de linguagem natural
    // ou regras específicas para cada app de corrida

    double distance = 0.0;
    double value = 0.0;

    // Exemplo de extração de dados (simulado)
    if (text != null) {
      // Procurar por padrões de distância e valor
      final distanceRegex = RegExp(r'(\d+\.?\d*)\s*(km|kilometro|quilometro)',
          caseSensitive: false);
      final valueRegex = RegExp(
          r'R\$\s*(\d+\.?\d*)|(\d+\.?\d*)\s*R\$|valor.*?(\d+\.?\d*)',
          caseSensitive: false);

      final distanceMatch = distanceRegex.firstMatch(text);
      final valueMatch = valueRegex.firstMatch(text);

      if (distanceMatch != null) {
        distance = double.tryParse(distanceMatch.group(1) ?? '0') ?? 0.0;
      }

      if (valueMatch != null) {
        // Pode haver múltiplas capturas, pegamos a primeira que for válida
        for (int i = 1; i <= valueMatch.groupCount; i++) {
          final match = valueMatch.group(i);
          if (match != null) {
            final parsedValue = double.tryParse(match);
            if (parsedValue != null) {
              value = parsedValue;
              break;
            }
          }
        }
      }
    }

    return {'distance': distance, 'value': value};
  }

  // Obter nome do app a partir do pacote
  static String _getAppNameFromPackage(String packageName) {
    switch (packageName) {
      case 'com.ubercab':
        return 'Uber';
      case 'br.com.ninjado taxi':
      case 'com.taxis99':
        return '99';
      case 'com.inDriver':
        return 'InDriver';
      default:
        return 'App de Corrida';
    }
  }

  // Mostrar overlay com análise da corrida
  static void _showTripAnalysisOverlay(TripRecommendation recommendation) {
    String title;
    String subtitle;
    Color backgroundColor;
    IconData icon;

    if (recommendation.isRecommended) {
      title = 'BOA CORRIDA!';
      backgroundColor = Colors.green;
      icon = Icons.thumb_up_alt;
      subtitle =
          'Lucro estimado: R\$ ${recommendation.profit.toStringAsFixed(2)} '
          '(Margem: ${recommendation.profitMargin.toStringAsFixed(1)}%)';
    } else {
      title = 'NÃO RECOMENDADA';
      backgroundColor = Colors.red;
      icon = Icons.thumb_down_alt;
      subtitle =
          'Prejuízo estimado: R\$ ${recommendation.profit.abs().toStringAsFixed(2)} '
          '(Margem: ${recommendation.profitMargin.toStringAsFixed(1)}%)';
    }

    subtitle +=
        '\nCusto por km: R\$ ${recommendation.costPerKm.toStringAsFixed(2)} '
        '• Receita por km: R\$ ${recommendation.revenuePerKm.toStringAsFixed(2)}';

    // Mostrar overlay (esta é uma chamada simulada)
    // Na implementação real, você precisaria garantir que o contexto esteja disponível
    print('Análise da corrida:');
    print('  Título: $title');
    print('  Subtítulo: $subtitle');
    print('  Recomendada: ${recommendation.isRecommended}');
    print('  Lucro: R\$ ${recommendation.profit.toStringAsFixed(2)}');
    print('  Margem: ${recommendation.profitMargin.toStringAsFixed(1)}%');
    print('  Custo por km: R\$ ${recommendation.costPerKm.toStringAsFixed(2)}');
    print(
        '  Receita por km: R\$ ${recommendation.revenuePerKm.toStringAsFixed(2)}');
  }
}
