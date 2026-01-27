import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciar o tema do aplicativo
///
/// Suporta três modos:
/// - Light: Tema claro
/// - Dark: Tema escuro
/// - System: Segue o tema do dispositivo
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _customColorKey = 'custom_color';

  ThemeMode _themeMode = ThemeMode.system;
  Color _customColor = const Color(0xFF1F77D2); // Azul padrão

  ThemeMode get themeMode => _themeMode;
  Color get customColor => _customColor;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Carrega o tema salvo do storage
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Carregar modo do tema
      final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex];

      // Carregar cor customizada
      final colorValue = prefs.getInt(_customColorKey);
      if (colorValue != null) {
        _customColor = Color(colorValue);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar tema: $e');
    }
  }

  /// Define o modo do tema
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      debugPrint('Erro ao salvar tema: $e');
    }
  }

  /// Define cor customizada
  Future<void> setCustomColor(Color color) async {
    if (_customColor == color) return;

    _customColor = color;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_customColorKey, color.value);
    } catch (e) {
      debugPrint('Erro ao salvar cor: $e');
    }
  }

  /// Alterna entre light e dark
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Reseta para cor padrão
  Future<void> resetColor() async {
    await setCustomColor(const Color(0xFF1F77D2));
  }

  /// Obtém nome amigável do modo atual
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  /// Obtém ícone do modo atual
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
