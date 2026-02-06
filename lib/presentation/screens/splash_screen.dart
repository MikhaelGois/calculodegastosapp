import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permissions_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissionsAndNavigate();
  }

  Future<void> _checkPermissionsAndNavigate() async {
    // Aguardar um pouco para mostrar o splash
    await Future.delayed(const Duration(seconds: 2));

    // Verificar permissões
    bool notificationsPermission = await Permission.notification.isGranted;
    bool overlayPermission = await Permission.systemAlertWindow.isGranted;

    if (!notificationsPermission || !overlayPermission) {
      // Se não tiver permissões, ir para a tela de permissões
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PermissionsScreen()),
      );
    } else {
      // Se tiver todas as permissões, ir direto para o dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do app
            Image.asset(
              'assets/images/logo_icon.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'RotaLucro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Analise a rentabilidade das suas corridas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
