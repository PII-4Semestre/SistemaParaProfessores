import 'package:flutter/material.dart';
import 'tela_detalhes_disciplina_professor.dart';
import '../../services/api_service.dart';

class TelaDisciplinasProfessor extends StatefulWidget {
  const TelaDisciplinasProfessor({super.key});

  @override
  State<TelaDisciplinasProfessor> createState() => _TelaDisciplinasProfessorState();
}

class _TelaDisciplinasProfessorState extends State<TelaDisciplinasProfessor> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  Color _selectedColor = Colors.blue;
  final ApiService _apiService = ApiService();
  
  List<dynamic> _disciplinas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDisciplinas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _loadDisciplinas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final professorId = _apiService.currentUser?['id'];
      if (professorId == null) {
        throw Exception('Professor ID não encontrado');
      }

      final disciplinas = await _apiService.getDisciplinasProfessor(professorId);
      
      if (mounted) {
        setState(() {
          _disciplinas = disciplinas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showAddDisciplinaDialog() {
    _nomeController.clear();
    _descricaoController.clear();
    _selectedColor = Colors.blue;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Disciplina'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Disciplina',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Escolha uma cor:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.cyan,
                  Colors.pink,
                  Colors.teal,
                ].map((color) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: _selectedColor == color
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nomeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nome da disciplina é obrigatório'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final professorId = _apiService.currentUser?['id'];
                if (professorId == null) {
                  throw Exception('Professor ID não encontrado');
                }

                await _apiService.createDisciplina(
                  nome: _nomeController.text,
                  descricao: _descricaoController.text,
                  professorId: professorId,
                  cor: '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                );

                if (!context.mounted) return;
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Disciplina criada com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );

                _loadDisciplinas();
              } catch (e) {
                if (!context.mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao criar disciplina: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showEditDisciplinaDialog(Map<String, dynamic> disciplina) {
    _nomeController.text = disciplina['nome'] ?? '';
    _descricaoController.text = disciplina['descricao'] ?? '';
    
    // Parse color from database
    final corString = disciplina['cor'] ?? '#2196F3';
    try {
      _selectedColor = Color(int.parse(corString.replaceFirst('#', '0xFF')));
    } catch (e) {
      _selectedColor = Colors.blue;
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Disciplina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Disciplina',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Escolha uma cor:',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.teal,
                    Colors.pink,
                    Colors.indigo,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nomeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nome da disciplina é obrigatório'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _apiService.updateDisciplina(
                    id: disciplina['id'],
                    nome: _nomeController.text,
                    descricao: _descricaoController.text,
                    cor: '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                  );

                  if (!context.mounted) return;
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Disciplina atualizada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  _loadDisciplinas();
                } catch (e) {
                  if (!context.mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao atualizar disciplina: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDisciplina(Map<String, dynamic> disciplina) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a disciplina "${disciplina['nome']}"?\n\n'
          'Esta ação não pode ser desfeita e todos os dados relacionados serão perdidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.deleteDisciplina(disciplina['id']);

                if (!context.mounted) return;
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Disciplina excluída com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );

                _loadDisciplinas();
              } catch (e) {
                if (!context.mounted) return;
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir disciplina: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
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
            'Disciplinas',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie suas disciplinas e veja os detalhes de cada uma',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar disciplinas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddDisciplinaDialog,
                icon: const Icon(Icons.add),
                label: const Text('Nova Disciplina'),
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
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Erro ao carregar disciplinas', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                            const SizedBox(height: 8),
                            Text(_error!, style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDisciplinas,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : _disciplinas.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text('Nenhuma disciplina cadastrada', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                                const SizedBox(height: 8),
                                Text('Clique em "Nova Disciplina" para começar', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _getCrossAxisCount(context),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: _getCardAspectRatio(context),
                            ),
                            itemCount: _disciplinas.length,
                            itemBuilder: (context, index) {
                              final disciplina = _disciplinas[index];
                              final cor = _parseColor(disciplina['cor'] ?? '#2196F3');
                              
                              return _buildDisciplinaCard(
                                disciplina['nome'] ?? 'Sem nome',
                                disciplina['descricao'] ?? 'Sem descrição',
                                cor,
                                disciplina,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 5;
    if (width > 1100) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  double _getCardAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // More conservative (taller) aspect ratios to prevent overflow
    if (width > 1400) return 1.3;
    if (width > 1100) return 1.25;
    if (width > 800) return 1.2;
    if (width > 600) return 1.15;
    return 1.0; // Mobile - square-ish cards
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  Widget _buildDisciplinaCard(String nome, String descricao, Color cor, Map<String, dynamic> disciplina) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaDetalhesDisciplinaProfessor(
                subjectName: nome,
                subjectColor: cor,
                disciplinaId: disciplina['id'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cor.withValues(alpha: 0.7),
                cor,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20),
                                SizedBox(width: 8),
                                Text('Excluir'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDisciplinaDialog(disciplina);
                          } else if (value == 'delete') {
                            _confirmDeleteDisciplina(disciplina);
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: constraints.maxHeight > 150 ? 8 : 4),
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      descricao,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
