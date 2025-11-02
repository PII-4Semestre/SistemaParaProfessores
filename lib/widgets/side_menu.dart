import 'package:flutter/material.dart';
import '../services/theme_controller.dart';
import 'drawer_user_header.dart';

class SideMenu extends StatelessWidget {
  final String name;
  final String? subtitle;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  const SideMenu({
    super.key,
    required this.name,
    this.subtitle,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color:
          Theme.of(context).drawerTheme.backgroundColor ??
          Theme.of(context).colorScheme.surface,
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            DrawerUserHeader(name: name, subtitle: subtitle),
            ...List.generate(
              destinations.length,
              (index) => ListTile(
                selected: selectedIndex == index,
                selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
                leading: selectedIndex == index
                    ? destinations[index].selectedIcon
                    : destinations[index].icon,
                title: Text(destinations[index].label),
                onTap: () => onSelect(index),
              ),
            ),
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeController.instance.themeMode,
                builder: (context, mode, _) {
                  final isDark = mode == ThemeMode.dark;
                  return SwitchListTile(
                    dense: true,
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                    ),
                    title: const Text('Tema'),
                    value: isDark,
                    onChanged: (v) => ThemeController.instance.set(
                      v ? ThemeMode.dark : ThemeMode.light,
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
