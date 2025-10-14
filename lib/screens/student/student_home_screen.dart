import 'package:flutter/material.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildVisaoGeral() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.blue[400],
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Média Geral',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.grade,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '8.5',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: Colors.green[400],
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Atividades Pendentes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.assignment_late,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: Colors.purple[400],
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Novas Mensagens',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.mail,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Atividades Recentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[200],
                      child: const Icon(Icons.assignment, color: Colors.orange),
                    ),
                    title: Text('Atividade ${index + 1}'),
                    subtitle: Text('Entrega: ${DateTime.now().add(Duration(days: index + 1)).toString().substring(0, 10)}'),
                    trailing: Chip(
                      label: Text(
                        'Pendente',
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                      backgroundColor: Colors.orange[50],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriais() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Materiais de Estudo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Acesse os materiais disponibilizados pelo professor',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar materiais...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Card(
                  child: InkWell(
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          index % 2 == 0 ? Icons.picture_as_pdf : Icons.image,
                          size: 48,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Material ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'PDF - 2.5 MB',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensagens() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mensagens',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Visualize as mensagens do professor',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar mensagens...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                final bool isUnread = index < 3;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isUnread ? Colors.orange[50] : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isUnread ? Colors.orange : Colors.grey[300],
                      child: const Icon(Icons.mail, color: Colors.white),
                    ),
                    title: const Text('Professor'),
                    subtitle: Text('Mensagem ${index + 1}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${DateTime.now().hour}:${DateTime.now().minute}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        if (isUnread)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Nova',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotas() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minhas Notas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Acompanhe seu desempenho',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Média Geral',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '8.5',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_upward,
                            color: Colors.green[600],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Notas por Atividade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                final double nota = 7.0 + (index * 0.5);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: nota >= 6 ? Colors.green[100] : Colors.red[100],
                      child: Icon(
                        nota >= 6 ? Icons.check : Icons.close,
                        color: nota >= 6 ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text('Atividade ${index + 1}'),
                    subtitle: Text('Peso: ${1 + index * 0.5}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: nota >= 6 ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        nota.toStringAsFixed(1),
                        style: TextStyle(
                          color: nota >= 6 ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return _buildVisaoGeral();
      case 1:
        return _buildMateriais();
      case 2:
        return _buildMensagens();
      case 3:
        return _buildNotas();
      default:
        return const Center(child: Text('Em construção...'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Portal do Aluno',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'João da Silva',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'RA: 24.00304-2',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
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
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            ListTile(
              selected: _selectedIndex == 0,
              leading: const Icon(Icons.dashboard),
              title: const Text('Visão Geral'),
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            ListTile(
              selected: _selectedIndex == 1,
              leading: const Icon(Icons.book),
              title: const Text('Materiais'),
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            ListTile(
              selected: _selectedIndex == 2,
              leading: const Icon(Icons.message),
              title: const Text('Mensagens'),
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            ListTile(
              selected: _selectedIndex == 3,
              leading: const Icon(Icons.grade),
              title: const Text('Notas'),
              onTap: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),

      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 1100)
            NavigationRail(
              extended: true,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Visão Geral'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.book),
                  label: Text('Materiais'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.message),
                  label: Text('Mensagens'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.grade),
                  label: Text('Notas'),
                ),
              ],
            ),

          Expanded(
            child: _buildCurrentView(),
          ),
        ],
      ),
    );
  }
}
