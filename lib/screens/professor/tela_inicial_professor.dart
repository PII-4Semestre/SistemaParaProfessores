import 'package:flutter/material.dart';
import 'tela_visao_geral_professor.dart';
import 'tela_disciplinas_professor.dart';
import 'tela_alunos_professor.dart';
import 'tela_mensagens_professor.dart';
import '../autenticacao/tela_login.dart';
import '../../services/api_service.dart';
import '../../widgets/app_bar_user_actions.dart';
import '../../widgets/drawer_user_header.dart';

class TelaInicialProfessor extends StatefulWidget {
  const TelaInicialProfessor({super.key});

  @override
  State<TelaInicialProfessor> createState() => _TelaInicialProfessorState();
}

class _TelaInicialProfessorState extends State<TelaInicialProfessor> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Visão Geral',
    ),
    NavigationDestination(
      icon: Icon(Icons.book_outlined),
      selectedIcon: Icon(Icons.book),
      label: 'Disciplinas',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: 'Alunos',
    ),
    NavigationDestination(
      icon: Icon(Icons.message_outlined),
      selectedIcon: Icon(Icons.message),
      label: 'Mensagens',
    ),
  ];

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return TelaVisaoGeralProfessor(
          onNavigateToTab: (index) {
            setState(() => _selectedIndex = index);
          },
        );
      case 1:
        return const TelaDisciplinasProfessor();
      case 2:
        return const TelaAlunosProfessor();
      case 3:
        return const TelaMensagensProfessor();
      default:
        return const TelaVisaoGeralProfessor();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Portal do Professor',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: isWideScreen
            ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppBarUserActions(
                    name: _apiService.currentUser?['nome'] ?? 'Professor',
                    subtitle: 'Professor',
                    onLogout: () async {
                      final navigator = Navigator.of(context);
                      await _apiService.logout();
                      if (!mounted) return;
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const TelaLogin(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ]
            : null,
      ),
      drawer: !isWideScreen
          ? Drawer(
              child: Column(
                children: [
                  DrawerUserHeader(
                    name: _apiService.currentUser?['nome'] ?? 'Professor',
                    subtitle: 'Professor',
                  ),
                  ...List.generate(
                    _destinations.length,
                    (index) => ListTile(
                      selected: _selectedIndex == index,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      leading: _selectedIndex == index
                          ? _destinations[index].selectedIcon
                          : _destinations[index].icon,
                      title: Text(_destinations[index].label),
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Spacer(),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sair'),
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await _apiService.logout();
                      if (!mounted) return;
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const TelaLogin(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              extended: true,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              backgroundColor: Colors.grey[100],
              selectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
              ),
              selectedLabelTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              destinations: _destinations
                  .map(
                    (dest) => NavigationRailDestination(
                      icon: dest.icon,
                      selectedIcon: dest.selectedIcon,
                      label: Text(dest.label),
                    ),
                  )
                  .toList(),
            ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _getCurrentScreen()),
        ],
      ),
    );
  }
}
