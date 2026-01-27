import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';

/// Tela de configurações de tema
///
/// Permite ao usuário:
/// - Escolher entre modo claro, escuro ou sistema
/// - Personalizar a cor primária do app
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tema e Aparência')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Seção: Modo de Tema
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Modo de Tema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          _buildThemeModeSection(context),

          const Divider(height: 32),

          // Seção: Cor Primária
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Cor Primária',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          _buildColorSection(context),

          const SizedBox(height: 16),

          // Botão de Reset
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () => _resetToDefault(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Restaurar Padrão'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildThemeModeSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        _buildThemeModeOption(
          context,
          ThemeMode.light,
          'Claro',
          'Sempre usar tema claro',
          Icons.light_mode,
        ),
        _buildThemeModeOption(
          context,
          ThemeMode.dark,
          'Escuro',
          'Sempre usar tema escuro',
          Icons.dark_mode,
        ),
        _buildThemeModeOption(
          context,
          ThemeMode.system,
          'Sistema',
          'Seguir tema do dispositivo',
          Icons.brightness_auto,
        ),
      ],
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = themeProvider.themeMode == mode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      selected: isSelected,
      onTap: () => themeProvider.setThemeMode(mode),
    );
  }

  Widget _buildColorSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: AppThemes.availableColors.map((color) {
          final isSelected = themeProvider.customColor.value == color.value;

          return GestureDetector(
            onTap: () => themeProvider.setCustomColor(color),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 32)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _resetToDefault(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Padrão'),
        content: const Text(
          'Deseja restaurar o tema para as configurações padrão?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              themeProvider.setThemeMode(ThemeMode.system);
              themeProvider.resetColor();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tema restaurado para padrão'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('RESTAURAR'),
          ),
        ],
      ),
    );
  }
}
