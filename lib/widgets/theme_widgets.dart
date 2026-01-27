import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/theme_settings_screen.dart';

/// Botão flutuante para alternar tema rapidamente
///
/// Pode ser adicionado em qualquer tela para acesso rápido
class ThemeToggleButton extends StatelessWidget {
  final bool mini;
  final String? tooltip;

  const ThemeToggleButton({Key? key, this.mini = false, this.tooltip})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FloatingActionButton(
      mini: mini,
      heroTag: 'theme_toggle',
      tooltip: tooltip ?? 'Alternar tema',
      onPressed: () => themeProvider.toggleTheme(),
      child: Icon(themeProvider.themeModeIcon),
    );
  }
}

/// Ícone de tema para AppBar
class ThemeIconButton extends StatelessWidget {
  const ThemeIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return IconButton(
      icon: Icon(themeProvider.themeModeIcon),
      tooltip: 'Tema: ${themeProvider.themeModeDisplayName}',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
        );
      },
    );
  }
}

/// Menu item para configurações de tema
class ThemeSettingsMenuItem extends StatelessWidget {
  const ThemeSettingsMenuItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListTile(
      leading: Icon(
        themeProvider.themeModeIcon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('Tema e Aparência'),
      subtitle: Text('${themeProvider.themeModeDisplayName}'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
        );
      },
    );
  }
}

/// Badge indicador do tema atual
class ThemeBadge extends StatelessWidget {
  const ThemeBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.black12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            themeProvider.themeModeIcon,
            size: 16,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          const SizedBox(width: 6),
          Text(
            themeProvider.themeModeDisplayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog rápido para alternar tema
class QuickThemeDialog extends StatelessWidget {
  const QuickThemeDialog({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const QuickThemeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AlertDialog(
      title: const Text('Escolher Tema'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context,
            ThemeMode.light,
            'Claro',
            Icons.light_mode,
            themeProvider,
          ),
          const SizedBox(height: 8),
          _buildOption(
            context,
            ThemeMode.dark,
            'Escuro',
            Icons.dark_mode,
            themeProvider,
          ),
          const SizedBox(height: 8),
          _buildOption(
            context,
            ThemeMode.system,
            'Sistema',
            Icons.brightness_auto,
            themeProvider,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('FECHAR'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
            );
          },
          child: const Text('PERSONALIZAR'),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    ThemeMode mode,
    String label,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return InkWell(
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
