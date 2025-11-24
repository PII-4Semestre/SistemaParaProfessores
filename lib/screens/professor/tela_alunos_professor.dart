import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TelaAlunosProfessor extends StatefulWidget {
  const TelaAlunosProfessor({super.key});

  @override
  State<TelaAlunosProfessor> createState() => _TelaAlunosProfessorState();
}

class _TelaAlunosProfessorState extends State<TelaAlunosProfessor> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _raController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<dynamic> _alunos = [];
  List<dynamic> _alunosFiltrados = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlunos();
    _searchController.addListener(_filterAlunos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nomeController.dispose();
    _raController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadAlunos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final alunos = await _apiService.getTodosAlunos();
      setState(() {
        _alunos = alunos;
        _alunosFiltrados = alunos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterAlunos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _alunosFiltrados = _alunos;
      } else {
        _alunosFiltrados = _alunos.where((aluno) {
          final nome = (aluno['nome'] ?? '').toString().toLowerCase();
          final email = (aluno['email'] ?? '').toString().toLowerCase();
          final ra = (aluno['ra'] ?? '').toString().toLowerCase();
          return nome.contains(query) ||
              email.contains(query) ||
              ra.contains(query);
        }).toList();
      }
    });
  }

  void _showAddAlunoDialog() {
    _nomeController.clear();
    _raController.clear();
    _emailController.clear();

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
            onPressed: () async {
              final nome = _nomeController.text.trim();
              final ra = _raController.text.trim();
              final email = _emailController.text.trim();

              if (nome.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nome e e-mail são obrigatórios'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Use RA como senha padrão se fornecido, senão senha padrão temporária
              final senha = ra.isNotEmpty ? ra : 'senha_123';

              try {
                // Chamar API para registrar aluno
                final result = await _apiService.registerUser(
                  nome: nome,
                  email: email,
                  senha: senha,
                  tipo: 'aluno',
                  ra: ra.isNotEmpty ? ra : null,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aluno ${result['nome']} cadastrado com sucesso',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );

                // Recarregar lista
                await _loadAlunos();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao cadastrar aluno: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alunos',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie todos os alunos e suas disciplinas',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, RA ou e-mail...',
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
                icon: const Icon(Icons.person_add),
                label: const Text('Novo Aluno'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Erro ao carregar alunos'),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAlunos,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                : _alunosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Nenhum aluno cadastrado'
                              : 'Nenhum aluno encontrado',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _alunosFiltrados.length,
                    itemBuilder: (context, index) {
                      final aluno = _alunosFiltrados[index];
                      final disciplinas = aluno['disciplinas'] as List? ?? [];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Text(
                              (aluno['nome'] ?? '?')[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(aluno['nome'] ?? 'Sem nome'),
                          subtitle: Text('RA: ${aluno['ra'] ?? 'N/A'}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        aluno['email'] ?? 'N/A',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Disciplinas:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  disciplinas.isEmpty
                                      ? Text(
                                          'Não matriculado em nenhuma disciplina',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: disciplinas.map<Widget>((
                                            disc,
                                          ) {
                                            Color chipColor;
                                            try {
                                              final corString =
                                                  disc['cor'] ?? '#2196F3';
                                              chipColor = Color(
                                                int.parse(
                                                  corString.replaceFirst(
                                                    '#',
                                                    '0xFF',
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              chipColor = Colors.blue;
                                            }

                                            return Chip(
                                              label: Text(
                                                disc['nome'] ?? 'Sem nome',
                                              ),
                                              backgroundColor: chipColor
                                                  .withValues(alpha: 0.2),
                                            );
                                          }).toList(),
                                        ),
                                ],
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
}
