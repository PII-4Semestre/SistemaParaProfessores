import 'package:flutter/material.dart';
import 'tela_visao_geral_professor.dart';
import 'tela_disciplinas_professor.dart';
import 'tela_alunos_professor.dart';
import 'tela_mensagens_professor.dart';
import '../autenticacao/tela_login.dart';
import '../../services/api_service.dart';
import '../../widgets/side_menu.dart';

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
      drawer: !isWideScreen
          ? Drawer(
              child: SideMenu(
                name: _apiService.currentUser?['nome'] ?? 'Professor',
                subtitle: 'Professor',
                destinations: _destinations,
                selectedIndex: _selectedIndex,
                onSelect: (index) {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
                onLogout: () async {
                  final navigator = Navigator.of(context);
                  await _apiService.logout();
                  if (!mounted) return;
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const TelaLogin()),
                    (route) => false,
                  );
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (isWideScreen)
            SizedBox(
              width: 300,
              child: SideMenu(
                name: _apiService.currentUser?['nome'] ?? 'Professor',
                subtitle: 'Professor',
                destinations: _destinations,
                selectedIndex: _selectedIndex,
                onSelect: (index) => setState(() => _selectedIndex = index),
                onLogout: () async {
                  final navigator = Navigator.of(context);
                  await _apiService.logout();
                  if (!mounted) return;
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const TelaLogin()),
                    (route) => false,
                  );
                },
              ),
            ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _getCurrentScreen()),
        ],
      ),
      floatingActionButton: !isWideScreen
          ? Builder(
              builder: (context) => FloatingActionButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                backgroundColor: Color(0xFF1CB3C2),
                child: Icon(Icons.menu, color: Colors.white),
              ),
            )
          : null,
    );
  }
}
