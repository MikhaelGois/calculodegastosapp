import 'package:flutter/material.dart';

class OverlayService {
  static OverlayEntry? _overlayEntry;
  static bool _isOverlayVisible = false;

  // Método para inicializar o serviço de overlay com o contexto do app
  static void initialize(BuildContext context) {
    // Este método pode ser chamado no início do app para obter o contexto
  }

  // Mostrar overlay com informações de análise de rentabilidade
  static void showTripAnalysisOverlay({
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required IconData icon,
    BuildContext? context,
  }) {
    if (_isOverlayVisible) {
      hideOverlay();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 100.0,
          left: 20.0,
          right: 20.0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        hideOverlay();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Adicionando o overlay à sobreposição raiz
    try {
      Overlay.of(context ?? _getDefaultContext()).insert(_overlayEntry!);
      _isOverlayVisible = true;
    } catch (e) {
      print('Erro ao mostrar overlay: $e');
    }
  }

  // Ocultar o overlay
  static void hideOverlay() {
    if (_isOverlayVisible && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isOverlayVisible = false;
    }
  }

  // Obter contexto padrão para o overlay
  static BuildContext _getDefaultContext() {
    // Em um app Flutter real, você teria acesso ao contexto global
    // Este é um placeholder para demonstração
    throw UnimplementedError(
        "Você precisa fornecer um BuildContext válido ou implementar um mecanismo para obter o contexto global");
  }

  // Verificar se o overlay está visível
  static bool get isOverlayVisible => _isOverlayVisible;
}
