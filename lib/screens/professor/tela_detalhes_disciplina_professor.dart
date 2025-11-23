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

class _TelaDetalhesDisciplinaProfessorState
    extends State<TelaDetalhesDisciplinaProfessor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<Atividade> _atividades = [];
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
      final atividades = await _atividadesService.getAtividadesDisciplina(
        widget.disciplinaId.toString(),
      );

      if (mounted) {
        setState(() {
          _atividades = atividades;
          _isLoadingAtividades = false;
        });
      }
    } catch (e) {
      print('[TelaDetalhesDisciplina] Erro ao carregar atividades: $e');
      if (mounted) {
        setState(() {
          _errorAtividades = e.toString();
          _atividades = [];
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
      body: Column(
        children: [
          // Header com gradiente e informações da disciplina
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.subjectColor.withValues(alpha: 0.8),
                  widget.subjectColor,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // AppBar customizada
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.subjectName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_alunos.length} alunos • ${_atividades.length} atividades',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // TabBar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(icon: Icon(Icons.people), text: 'Alunos'),
                      Tab(icon: Icon(Icons.assignment), text: 'Atividades'),
                      Tab(icon: Icon(Icons.book), text: 'Materiais'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Conteúdo das tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlunosTab(),
                _buildAtividadesTab(),
                _buildMateriaisTab(),
              ],
            ),
          ),
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
            Text(
              'Erro ao carregar alunos',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _errorAlunos!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
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
                    const Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum aluno matriculado',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Clique em "Adicionar Aluno" para começar',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
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
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: widget.subjectColor.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: widget.subjectColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nome,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: widget.subjectColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'RA: $ra',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: widget.subjectColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (email.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          email,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
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
            Text(
              'Erro ao carregar atividades',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
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
                onPressed: _showAddAtividadeDialog,
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
                    const Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma atividade cadastrada',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Clique em "Nova Atividade" para começar',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
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
                  final isExpired = atividade.dataEntrega.isBefore(DateTime.now());

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _showSubmissoesDialog(atividade),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: widget.subjectColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.assignment,
                                    color: widget.subjectColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        atividade.titulo,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (atividade.descricao.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          atividade.descricao,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showEditAtividadeDialog(atividade),
                                      tooltip: 'Editar',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDeleteAtividade(atividade),
                                      tooltip: 'Excluir',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isExpired
                                        ? Colors.red.withValues(alpha: 0.1)
                                        : Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isExpired ? Icons.event_busy : Icons.event,
                                        size: 14,
                                        color: isExpired ? Colors.red : Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(atividade.dataEntrega),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isExpired ? Colors.red : Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildMateriaisTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: widget.subjectColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open,
                size: 80,
                color: widget.subjectColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Materiais em Desenvolvimento',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'A funcionalidade de materiais didáticos estará disponível em breve.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Aqui você poderá fazer upload e gerenciar PDFs, slides, apostilas e outros recursos.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.subjectColor.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: widget.subjectColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Integração com MongoDB em progresso',
                    style: TextStyle(
                      color: widget.subjectColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAtividadeDialog() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
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
                ListTile(
                  title: const Text('Data de Entrega'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      locale: const Locale('pt', 'BR'),
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
                  await _atividadesService.criarAtividade(
                    titulo: tituloController.text,
                    descricao: descricaoController.text,
                    disciplinaId: widget.disciplinaId.toString(),
                    peso: 1.0,
                    dataEntrega: selectedDate,
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Atividade criada com sucesso!')),
                  );
                  _loadAtividades();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Erro ao criar atividade: $e')),
                  );
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

  void _showEditAtividadeDialog(Atividade atividade) {
    final tituloController = TextEditingController(text: atividade.titulo);
    final descricaoController = TextEditingController(text: atividade.descricao);
    DateTime selectedDate = atividade.dataEntrega;

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
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Data de Entrega'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      locale: const Locale('pt', 'BR'),
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
                  await _atividadesService.atualizarAtividade(
                    id: atividade.id,
                    titulo: tituloController.text,
                    descricao: descricaoController.text,
                    peso: 1.0,
                    dataEntrega: selectedDate,
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Atividade atualizada com sucesso!')),
                  );
                  _loadAtividades();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Erro ao atualizar atividade: $e')),
                  );
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

  void _confirmDeleteAtividade(Atividade atividade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Atividade'),
        content: Text(
          'Deseja realmente excluir a atividade "${atividade.titulo}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _atividadesService.deletarAtividade(atividade.id);

                if (!context.mounted) return;
                Navigator.pop(context);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Atividade excluída com sucesso!')),
                );
                _loadAtividades();
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Erro ao excluir atividade: $e')),
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

  void _showSubmissoesDialog(Atividade atividade) async {
    try {
      final submissoes = await _atividadesService.getSubmissoes(atividade.id);
      
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: 800,
            height: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment_turned_in, color: widget.subjectColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            atividade.titulo,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Submissões: ${submissoes.length}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 32),
                if (submissoes.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma submissão ainda',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: submissoes.length,
                      itemBuilder: (context, index) {
                        final submissao = submissoes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: submissao.foiAvaliada
                                  ? Colors.green
                                  : Colors.orange,
                              child: Text(
                                submissao.alunoNome.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(submissao.alunoNome),
                            subtitle: Text(
                              'Enviado em: ${DateFormat('dd/MM/yyyy HH:mm').format(submissao.dataSubmissao)}',
                            ),
                            trailing: submissao.foiAvaliada
                                ? Chip(
                                    label: Text('Nota: ${submissao.nota!.toStringAsFixed(1)}'),
                                    backgroundColor: Colors.green[100],
                                  )
                                : const Chip(
                                    label: Text('Pendente'),
                                    backgroundColor: Colors.orange,
                                  ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Arquivos:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    ...submissao.arquivos.map((arquivo) => ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.attach_file),
                                      title: Text(arquivo.nomeOriginal),
                                      subtitle: Text(
                                        '${(arquivo.tamanho / 1024).toStringAsFixed(2)} KB',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: () async {
                                          try {
                                            final bytes = await _atividadesService
                                                .downloadArquivo(arquivo.arquivoId!);
                                            _downloadFile(bytes, arquivo.nomeOriginal);
                                          } catch (e) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Erro ao baixar arquivo: $e'),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    )),
                                    const SizedBox(height: 16),
                                    if (submissao.comentario != null && submissao.comentario!.isNotEmpty) ...[
                                      const Text(
                                        'Comentário do Aluno:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue[200]!),
                                        ),
                                        child: Text(
                                          submissao.comentario!,
                                          style: TextStyle(color: Colors.grey[800]),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    if (submissao.foiAvaliada) ...[
                                      const Text(
                                        'Avaliação:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Nota: ${submissao.nota!.toStringAsFixed(2)}'),
                                      if (submissao.feedback != null) ...[
                                        const SizedBox(height: 4),
                                        Text('Feedback: ${submissao.feedback}'),
                                      ],
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: () => _showAvaliarDialog(submissao, atividade),
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Editar Avaliação'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ] else ...[
                                      ElevatedButton.icon(
                                        onPressed: () => _showAvaliarDialog(submissao, atividade),
                                        icon: const Icon(Icons.grade),
                                        label: const Text('Avaliar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: widget.subjectColor,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
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
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar submissões: $e')),
      );
    }
  }

  void _showAvaliarDialog(SubmissaoAtividade submissao, Atividade atividade) {
    final notaController = TextEditingController(
      text: submissao.nota?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: submissao.feedback ?? '',
    );
    
    final isEdicao = submissao.foiAvaliada;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isEdicao ? 'Editar Avaliação' : 'Avaliar'} - ${submissao.alunoNome}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEdicao)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Avaliado em: ${DateFormat('dd/MM/yyyy HH:mm').format(submissao.dataAvaliacao!)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            TextField(
              controller: notaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nota (0 - 10)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Feedback (opcional)',
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
              final nota = double.tryParse(notaController.text);
              if (nota == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, insira uma nota válida')),
                );
                return;
              }

              if (nota < 0 || nota > 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('A nota deve estar entre 0 e 10'),
                  ),
                );
                return;
              }

              try {
                await _atividadesService.avaliarSubmissao(
                  atividadeId: atividade.id,
                  submissaoId: submissao.id!,
                  nota: nota,
                  feedback: feedbackController.text.isNotEmpty
                      ? feedbackController.text
                      : null,
                );

                if (!context.mounted) return;
                Navigator.pop(context); // Fecha diálogo de avaliar
                Navigator.pop(context); // Fecha diálogo de submissões
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(isEdicao 
                        ? 'Avaliação atualizada com sucesso!' 
                        : 'Avaliação salva com sucesso!'),
                  ),
                );
                _showSubmissoesDialog(atividade); // Reabre para mostrar atualização
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Erro ao avaliar: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.subjectColor,
              foregroundColor: Colors.white,
            ),
            child: Text(isEdicao ? 'Atualizar Avaliação' : 'Salvar Avaliação'),
          ),
        ],
      ),
    );
  }

  void _showAddAlunoDialog() async {
    try {
      final alunosDisponiveis = await _apiService.getAlunosDisponiveis(
        widget.disciplinaId,
      );

      if (!mounted) return;

      if (alunosDisponiveis.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não há alunos disponíveis para adicionar'),
          ),
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
                  leading: const CircleAvatar(child: Icon(Icons.person)),
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

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Aluno adicionado com sucesso!'),
                          ),
                        );
                        _loadAlunos(); // Reload students list
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao adicionar aluno: $e'),
                          ),
                        );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao buscar alunos: $e')));
      }
    }
  }

  void _confirmRemoveAluno(Map<String, dynamic> aluno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Aluno'),
        content: Text(
          'Deseja realmente remover "${aluno['nome']}" desta disciplina?',
        ),
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

                if (!context.mounted) return;
                Navigator.pop(context);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Aluno removido com sucesso!')),
                );
                _loadAlunos(); // Reload students list
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Erro ao remover aluno: $e')),
                );
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
