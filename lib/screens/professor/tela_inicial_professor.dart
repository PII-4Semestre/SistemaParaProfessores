import 'package:flutter/material.dart';
import 'tela_visao_geral_professor.dart';
import 'tela_disciplinas_professor.dart';
import 'tela_alunos_professor.dart';
import 'tela_mensagens_professor.dart';
import '../autenticacao/tela_login.dart';
import '../../services/api_service.dart';

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
        title: const Text('Portal do Professor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_apiService.currentUser?['nome'] ?? 'Professor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Professor', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
                const SizedBox(width: 12),
                const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.orange)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await _apiService.logout();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const TelaLogin()),
                      (route) => false,
                    );
                  },
                  tooltip: 'Sair',
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: !isWideScreen
          ? Drawer(
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.orange),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, size: 35, color: Colors.orange)),
                        const SizedBox(height: 10),
                        Text(_apiService.currentUser?['nome'] ?? 'Professor', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Professor', style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                  ...List.generate(
                    _destinations.length,
                    (index) => ListTile(
                      selected: _selectedIndex == index,
                      selectedTileColor: Colors.orange.withValues(alpha: 0.1),
                      leading: _selectedIndex == index ? _destinations[index].selectedIcon : _destinations[index].icon,
                      title: Text(_destinations[index].label),
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        Navigator.pop(context);
                      },
                    ),
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
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              backgroundColor: Colors.grey[100],
              selectedIconTheme: const IconThemeData(color: Colors.orange),
              selectedLabelTextStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              destinations: _destinations.map((dest) => NavigationRailDestination(icon: dest.icon, selectedIcon: dest.selectedIcon, label: Text(dest.label))).toList(),
            ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _getCurrentScreen()),
        ],
      ),
    );
  }
}