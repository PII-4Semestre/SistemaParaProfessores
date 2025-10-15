import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TelaDetalhesDisciplinaProfessor extends StatefulWidget {
  final String subjectName;
  final Color subjectColor;
  final int disciplinaId;

  const TelaDetalhesDisciplinaProfessor({
    super.key,
    required this.subjectName,
    required this.subjectColor,
    required this.disciplinaId,
  });

  @override
  State<TelaDetalhesDisciplinaProfessor> createState() =>
      _TelaDetalhesDisciplinaProfessorState();
}

class _TelaDetalhesDisciplinaProfessorState extends State<TelaDetalhesDisciplinaProfessor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  List<dynamic> _atividades = [];
  bool _isLoadingAtividades = false;
  String? _errorAtividades;

  List<dynamic> _alunos = [];
  bool _isLoadingAlunos = false;
  String? _errorAlunos;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAtividades();
    _loadAlunos();
  }

  Future<void> _loadAlunos() async {
    setState(() {
      _isLoadingAlunos = true;
      _errorAlunos = null;
    });

    try {
      final alunos = await _apiService.getAlunosDisciplina(widget.disciplinaId);
      
      if (mounted) {
        setState(() {
          _alunos = alunos;
          _isLoadingAlunos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorAlunos = e.toString();
          _isLoadingAlunos = false;
        });
      }
    }
  }

  Future<void> _loadAtividades() async {
    setState(() {
      _isLoadingAtividades = true;
      _errorAtividades = null;
    });

    try {
      final atividades = await _apiService.getAtividadesDisciplina(widget.disciplinaId);
      
      if (mounted) {
        setState(() {
          _atividades = atividades;
          _isLoadingAtividades = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorAtividades = e.toString();
          _isLoadingAtividades = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
        backgroundColor: widget.subjectColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Alunos'),
            Tab(icon: Icon(Icons.assignment), text: 'Atividades'),
            Tab(icon: Icon(Icons.book), text: 'Materiais'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlunosTab(),
          _buildAtividadesTab(),
          _buildMateriaisTab(),
        ],
      ),
    );
  }

  Widget _buildAlunosTab() {
    if (_isLoadingAlunos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorAlunos != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro ao carregar alunos', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text(_errorAlunos!, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAlunos,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar alunos...',
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
                  _showAddAlunoDialog();
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Adicionar Aluno'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.subjectColor,
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
          if (_alunos.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Nenhum aluno matriculado', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text('Clique em "Adicionar Aluno" para começar', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _alunos.length,
                itemBuilder: (context, index) {
                  final aluno = _alunos[index];
                  final nome = aluno['nome'] ?? 'Sem nome';
                  final ra = aluno['ra'] ?? 'Sem RA';
                  final email = aluno['email'] ?? '';
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: widget.subjectColor.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.person,
                          color: widget.subjectColor,
                        ),
                      ),
                      title: Text(nome),
                      subtitle: Text('RA: $ra${email.isNotEmpty ? ' - $email' : ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              _confirmRemoveAluno(aluno);
                            },
                            tooltip: 'Remover da disciplina',
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

  Widget _buildAtividadesTab() {
    if (_isLoadingAtividades) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorAtividades != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro ao carregar atividades', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text(_errorAtividades!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAtividades,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  _showAddAtividadeDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Nova Atividade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.subjectColor,
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
          if (_atividades.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Nenhuma atividade cadastrada', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text('Clique em "Nova Atividade" para começar', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _atividades.length,
                itemBuilder: (context, index) {
                  final atividade = _atividades[index];
                  final titulo = atividade['titulo'] ?? 'Sem título';
                  final peso = atividade['peso'];
                  final dataEntrega = atividade['data_entrega'] != null 
                      ? DateTime.parse(atividade['data_entrega'])
                      : null;
                  
                  // Convert peso to double safely
                  double? pesoDouble;
                  if (peso != null) {
                    if (peso is num) {
                      pesoDouble = peso.toDouble();
                    } else if (peso is String) {
                      pesoDouble = double.tryParse(peso);
                    }
                  }
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: widget.subjectColor.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.assignment,
                          color: widget.subjectColor,
                        ),
                      ),
                      title: Text(titulo),
                      subtitle: Text(
                        'Peso: ${pesoDouble?.toStringAsFixed(1) ?? '1.0'}${dataEntrega != null ? ' - Entrega: ${dataEntrega.day.toString().padLeft(2, '0')}/${dataEntrega.month.toString().padLeft(2, '0')}/${dataEntrega.year}' : ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditAtividadeDialog(atividade);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _confirmDeleteAtividade(atividade);
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

  Widget _buildMateriaisTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  // TODO: Upload de material
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Novo Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.subjectColor,
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
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // TODO: Abrir material
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          index % 2 == 0 ? Icons.picture_as_pdf : Icons.image,
                          size: 48,
                          color: widget.subjectColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Material ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          index % 2 == 0 ? 'PDF - 2.5 MB' : 'IMG - 1.2 MB',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () {
                            // TODO: Excluir material
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

  void _showAddAtividadeDialog() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final pesoController = TextEditingController(text: '1.0');
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nova Atividade'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pesoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Peso',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Data de Entrega'),
                  subtitle: Text('${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
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
                if (tituloController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, preencha o título')),
                  );
                  return;
                }

                try {
                  await _apiService.createAtividade(
                    disciplinaId: widget.disciplinaId,
                    titulo: tituloController.text,
                    descricao: descricaoController.text,
                    peso: double.tryParse(pesoController.text) ?? 1.0,
                    dataEntrega: selectedDate.toIso8601String(),
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Atividade criada com sucesso!')),
                    );
                    _loadAtividades(); // Reload activities list
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao criar atividade: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.subjectColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAtividadeDialog(Map<String, dynamic> atividade) {
    final tituloController = TextEditingController(text: atividade['titulo'] ?? '');
    final descricaoController = TextEditingController(text: atividade['descricao'] ?? '');
    final peso = atividade['peso'];
    double? pesoValue;
    if (peso is num) {
      pesoValue = peso.toDouble();
    } else if (peso is String) {
      pesoValue = double.tryParse(peso);
    }
    final pesoController = TextEditingController(text: pesoValue?.toString() ?? '1.0');
    
    DateTime selectedDate = atividade['data_entrega'] != null
        ? DateTime.parse(atividade['data_entrega'])
        : DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Atividade'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pesoController,
                  decoration: const InputDecoration(
                    labelText: 'Peso',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Data de Entrega'),
                  subtitle: Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
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
                if (tituloController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, preencha o título')),
                  );
                  return;
                }

                try {
                  await _apiService.updateAtividade(
                    id: atividade['id'],
                    titulo: tituloController.text,
                    descricao: descricaoController.text,
                    peso: double.tryParse(pesoController.text) ?? 1.0,
                    dataEntrega: selectedDate.toIso8601String(),
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Atividade atualizada com sucesso!')),
                    );
                    _loadAtividades(); // Reload activities list
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar atividade: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.subjectColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAtividade(Map<String, dynamic> atividade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Atividade'),
        content: Text('Deseja realmente excluir a atividade "${atividade['titulo']}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.deleteAtividade(atividade['id']);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Atividade excluída com sucesso!')),
                  );
                  _loadAtividades(); // Reload activities list
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir atividade: $e')),
                  );
                }
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

  void _showAddAlunoDialog() async {
    try {
      final alunosDisponiveis = await _apiService.getAlunosDisponiveis(widget.disciplinaId);
      
      if (!mounted) return;

      if (alunosDisponiveis.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não há alunos disponíveis para adicionar')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Adicionar Aluno à Disciplina'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: alunosDisponiveis.length,
              itemBuilder: (context, index) {
                final aluno = alunosDisponiveis[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(aluno['nome'] ?? 'Sem nome'),
                  subtitle: Text('RA: ${aluno['ra'] ?? 'Sem RA'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: widget.subjectColor,
                    onPressed: () async {
                      try {
                        await _apiService.matricularAluno(
                          alunoId: aluno['id'],
                          disciplinaId: widget.disciplinaId,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Aluno adicionado com sucesso!')),
                          );
                          _loadAlunos(); // Reload students list
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao adicionar aluno: $e')),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar alunos: $e')),
        );
      }
    }
  }

  void _confirmRemoveAluno(Map<String, dynamic> aluno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Aluno'),
        content: Text('Deseja realmente remover "${aluno['nome']}" desta disciplina?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.desmatricularAluno(
                  alunoId: aluno['id'],
                  disciplinaId: widget.disciplinaId,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Aluno removido com sucesso!')),
                  );
                  _loadAlunos(); // Reload students list
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao remover aluno: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
