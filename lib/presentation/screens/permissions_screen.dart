import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dashboard_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _notificationsPermission = false;
  bool _overlayPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentPermissions();
  }

  Future<void> _checkCurrentPermissions() async {
    setState(() {
      _isLoading = true;
    });

    _notificationsPermission = await Permission.notification.isGranted;
    _overlayPermission = await Permission.systemAlertWindow.isGranted;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestNotificationsPermission() async {
    var status = await Permission.notification.request();
    setState(() {
      _notificationsPermission = status == PermissionStatus.granted;
    });
  }

  Future<void> _requestOverlayPermission() async {
    var status = await Permission.systemAlertWindow.request();
    setState(() {
      _overlayPermission = status.isGranted;
    });
  }

  Future<void> _requestAllPermissions() async {
    await _requestNotificationsPermission();
    await _requestOverlayPermission();

    // Após solicitar todas as permissões, verificar se ambas foram concedidas
    if (_notificationsPermission && _overlayPermission) {
      // Navegar para o dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissões Necessárias'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.privacy_tip,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'O RotaLucro precisa de algumas permissões para funcionar corretamente:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _notificationsPermission,
                          onChanged: (_) => _requestNotificationsPermission(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Acesso às notificações',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Para ler notificações dos apps de corrida (Uber, 99, Indriver)',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            _showPermissionInfoDialog(
                              'Acesso às notificações',
                              'Esta permissão permite que o app leia notificações dos apps de corrida para analisar automaticamente as corridas sugeridas.',
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Checkbox(
                          value: _overlayPermission,
                          onChanged: (_) => _requestOverlayPermission(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sobreposição de apps',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Para exibir cálculos instantaneamente sobre outros apps',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            _showPermissionInfoDialog(
                              'Sobreposição de apps',
                              'Esta permissão permite que o app exiba uma janela sobreposta quando uma notificação de corrida é recebida, mostrando a análise de rentabilidade imediatamente.',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _requestAllPermissions,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Solicitar Permissões',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: _notificationsPermission && _overlayPermission,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const DashboardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continuar sem permissões',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
