import 'package:flutter/material.dart';
import 'student_overview_screen.dart';
import 'student_subjects_screen.dart';
import 'student_messages_screen.dart';
import '../auth/login_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

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
      icon: Icon(Icons.message_outlined),
      selectedIcon: Icon(Icons.message),
      label: 'Mensagens',
    ),
    NavigationDestination(
      icon: Icon(Icons.grade_outlined),
      selectedIcon: Icon(Icons.grade),
      label: 'Notas',
    ),
  ];

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const StudentOverviewScreen();
      case 1:
        return const StudentSubjectsScreen();
      case 2:
        return const StudentMessagesScreen();
      case 3:
        return _buildNotasScreen();
      default:
        return const StudentOverviewScreen();
    }
  }

  Widget _buildNotasScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minhas Notas',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Veja suas notas em todas as disciplinas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.blue.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.grade,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Média Geral',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '8.5',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Notas por Disciplina',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
                final media = 7.0 + (index * 0.5);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors[index].withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.book, color: colors[index]),
                    ),
                    title: Text('Disciplina ${index + 1}'),
                    subtitle: Text('Prof. Silva'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors[index].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        media.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors[index],
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Atividade ${i + 1}'),
                                  Row(
                                    children: [
                                      Text(
                                        'Peso: ${i + 1}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors[index].withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          (7.0 + i * 0.3).toStringAsFixed(1),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: colors[index],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Portal do Aluno',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    const Text(
                      'João da Silva',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'RA: 24.00304-2',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.orange),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 35, color: Colors.orange),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'João da Silva',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'RA: 24.00304-2',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(
                    _destinations.length,
                    (index) => ListTile(
                      selected: _selectedIndex == index,
                      selectedTileColor: Colors.orange.withValues(alpha: 0.1),
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
