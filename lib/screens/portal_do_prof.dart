import 'package:flutter/material.dart';

class PortalProfessor extends StatefulWidget {
  const PortalProfessor({super.key});

  @override
  State<PortalProfessor> createState() => _PortalProfessorState();
}

class _PortalProfessorState extends State<PortalProfessor> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _raController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tituloAtividadeController = TextEditingController();
  final TextEditingController _descricaoAtividadeController = TextEditingController();
  final TextEditingController _pesoAtividadeController = TextEditingController();
  final TextEditingController _tituloMaterialController = TextEditingController();
  final TextEditingController _descricaoMaterialController = TextEditingController();
  final TextEditingController _mensagemController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _nomeController.dispose();
    _raController.dispose();
    _emailController.dispose();
    _tituloAtividadeController.dispose();
    _descricaoAtividadeController.dispose();
    _pesoAtividadeController.dispose();
    _tituloMaterialController.dispose();
    _descricaoMaterialController.dispose();
    _mensagemController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  void _showAddAlunoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastrar Novo Aluno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _raController,
              decoration: const InputDecoration(
                labelText: 'RA',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar lógica de adicionar aluno
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
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
                  color: Colors.red[400],
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total de Alunos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '24',
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
                  color: Colors.cyan[400],
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Atividades',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.assignment,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '12',
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
                  color: Colors.orange[400],
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Materiais',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.book,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '8',
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
        ],
      ),
    );
  }

  Widget _buildAtividades() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gerenciar Atividades',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Cadastre e gerencie as atividades da turma',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar atividades...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar diálogo de nova atividade
                },
                icon: const Icon(Icons.add),
                label: const Text('Nova Atividade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.assignment, color: Colors.white),
                    ),
                    title: Text('Atividade ${index + 1}'),
                    subtitle: Text('Peso: ${index + 1}.0'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Data: ${DateTime.now().day}/${DateTime.now().month}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {},
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

  Widget _buildMateriais() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Materiais Didáticos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Compartilhe materiais com seus alunos',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar materiais...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar upload de material
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Novo Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
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
            'Envie mensagens individuais para os alunos',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar mensagens...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar envio de mensagem
                },
                icon: const Icon(Icons.send),
                label: const Text('Nova Mensagem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text('Aluno ${index + 1}'),
                    subtitle: const Text('Última mensagem: Bom trabalho!'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${DateTime.now().hour}:${DateTime.now().minute}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '1',
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
            'Gerenciar Notas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Registre e calcule as notas dos alunos',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Média da Turma: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('7.5'),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar exportação
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Exportar Notas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text('Aluno ${index + 1}'),
                    subtitle: Row(
                      children: [
                        const Text('Média: '),
                        Text(
                          '${7.0 + (index * 0.5)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            // TODO: Implementar adição de nota
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // TODO: Implementar edição de notas
                          },
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

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return _buildVisaoGeral();
      case 1:
        return _buildGerenciarAlunos();
      case 2:
        return _buildAtividades();
      case 3:
        return _buildMateriais();
      case 4:
        return _buildMensagens();
      case 5:
        return _buildNotas();
      default:
        return const Center(child: Text('Em construção...'));
    }
  }

  Widget _buildGerenciarAlunos() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gerenciar Alunos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Adicione e gerencie os alunos da turma',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Busque por nome, RA ou e-mail...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddAlunoDialog,
                icon: const Icon(Icons.add),
                label: const Text('Novo Aluno'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 4, // Exemplo com 4 alunos
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: const Text('Matheus Mattoso'),
                    subtitle: Text('RA: 24.00304-2'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'matheus.mattoso@poliedro.br',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // TODO: Implementar edição
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // TODO: Implementar exclusão
                          },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com título e botão de desconexão
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Portal do Professor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Nome do professor e cargo
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Matheus Mattoso',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Professor',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Botão de desconexão
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implementar lógica de logout
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      // Painel lateral (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.orange),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Matheus Mattoso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Professor',
                    style: TextStyle(color: Colors.white70),
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
              leading: const Icon(Icons.people),
              title: const Text('Alunos'),
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            ListTile(
              selected: _selectedIndex == 2,
              leading: const Icon(Icons.assignment),
              title: const Text('Atividades'),
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            ListTile(
              selected: _selectedIndex == 3,
              leading: const Icon(Icons.book),
              title: const Text('Materiais'),
              onTap: () => setState(() => _selectedIndex = 3),
            ),
            ListTile(
              selected: _selectedIndex == 4,
              leading: const Icon(Icons.message),
              title: const Text('Mensagens'),
              onTap: () => setState(() => _selectedIndex = 4),
            ),
            ListTile(
              selected: _selectedIndex == 5,
              leading: const Icon(Icons.grade),
              title: const Text('Notas'),
              onTap: () => setState(() => _selectedIndex = 5),
            ),
          ],
        ),
      ),

      // Conteúdo principal
      body: Row(
        children: [
          // Painel lateral fixo (alternativa ao Drawer para telas grandes)
          if (MediaQuery.of(context).size.width > 1100)
            NavigationRail(
              extended: true,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Visão Geral'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Alunos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment),
                  label: Text('Atividades'),
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

          // Área de conteúdo principal
          Expanded(
            child: _buildCurrentView(),
          ),
        ],
      ),
    );
  }
}
