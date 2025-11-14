import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'dart:html' as html show Blob, Url, AnchorElement;
import '../../services/api_service.dart';
import '../../services/materiais_service.dart';
import '../../models/material.dart' as models;

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
  final MateriaisService _materiaisService = MateriaisService();

  List<dynamic> _atividades = [];
  bool _isLoadingAtividades = false;
  String? _errorAtividades;

  List<dynamic> _alunos = [];
  bool _isLoadingAlunos = false;
  String? _errorAlunos;

  List<models.Material> _materiais = [];
  bool _isLoadingMateriais = false;
  String? _errorMateriais;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAtividades();
    _loadAlunos();
    _loadMateriais();
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
      final atividades = await _apiService.getAtividadesDisciplina(
        widget.disciplinaId,
      );

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

  Future<void> _loadMateriais() async {
    setState(() {
      _isLoadingMateriais = true;
      _errorMateriais = null;
    });

    try {
      print('[DEBUG] Carregando materiais da disciplina ID: ${widget.disciplinaId}');
      final materiais = await _materiaisService.getMateriaisPorDisciplina(
        widget.disciplinaId.toString(),
      );
      print('[DEBUG] Materiais carregados: ${materiais.length} encontrado(s)');

      if (mounted) {
        setState(() {
          _materiais = materiais;
          _isLoadingMateriais = false;
        });
      }
    } catch (e) {
      print('[DEBUG] Erro ao carregar materiais: $e');
      if (mounted) {
        setState(() {
          _errorMateriais = e.toString();
          _isLoadingMateriais = false;
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
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'ID: ${widget.disciplinaId}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.subjectName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
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
                  final titulo = atividade['titulo'] ?? 'Sem título';
                  final descricao = atividade['descricao'] ?? '';
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

                  // Check if activity is expired
                  final isExpired =
                      dataEntrega != null &&
                      dataEntrega.isBefore(DateTime.now());

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
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
                                  color: widget.subjectColor.withValues(
                                    alpha: 0.1,
                                  ),
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
                                      titulo,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (descricao.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        descricao,
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
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      _showEditAtividadeDialog(atividade);
                                    },
                                    tooltip: 'Editar',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _confirmDeleteAtividade(atividade);
                                    },
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
                                  color: widget.subjectColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.fitness_center,
                                      size: 14,
                                      color: widget.subjectColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Peso: ${pesoDouble?.toStringAsFixed(1) ?? '1.0'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.subjectColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (dataEntrega != null)
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
                                        isExpired
                                            ? Icons.event_busy
                                            : Icons.event,
                                        size: 14,
                                        color: isExpired
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${dataEntrega.day.toString().padLeft(2, '0')}/${dataEntrega.month.toString().padLeft(2, '0')}/${dataEntrega.year}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isExpired
                                              ? Colors.red
                                              : Colors.green,
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
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMateriaisTab() {
    if (_isLoadingMateriais) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMateriais != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar materiais',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMateriais!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadMateriais,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header com botão de adicionar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_materiais.length} ${_materiais.length == 1 ? 'material' : 'materiais'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddMaterialDialog,
                icon: const Icon(Icons.add),
                label: const Text('Novo Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.subjectColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Lista de materiais
        Expanded(
          child: _materiais.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum material adicionado',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Clique em "Novo Material" para começar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _materiais.length,
                  itemBuilder: (context, index) {
                    final material = _materiais[index];
                    return _buildMaterialCard(material);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMaterialCard(models.Material material) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showMaterialDetails(material),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícone do tipo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.subjectColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      material.icone,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Título e tipo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          material.tipo.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.subjectColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu de ações
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
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
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditMaterialDialog(material);
                      } else if (value == 'delete') {
                        _confirmDeleteMaterial(material);
                      }
                    },
                  ),
                ],
              ),

              // Descrição
              if (material.descricao != null && material.descricao!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    material.descricao!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Tags
              if (material.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: material.tags.map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(fontSize: 12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ),

              // Informações dos arquivos
              if (material.temArquivos)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${material.arquivos.length} ${material.arquivos.length == 1 ? 'arquivo' : 'arquivos'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Link externo
              if (material.isLinkExterno)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            material.linkExterno!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Data de criação
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Criado em ${dateFormat.format(material.criadoEm)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMaterialDialog() {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final linkExternoController = TextEditingController();
    String tipoSelecionado = 'documento';
    List<String> tags = [];
    final tagController = TextEditingController();
    List<PlatformFile> arquivosSelecionados = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo Material'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  TextField(
                    controller: descricaoController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tipo de material
                  DropdownButtonFormField<String>(
                    value: tipoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'documento', child: Text('📄 Documento')),
                      DropdownMenuItem(value: 'video', child: Text('🎥 Vídeo')),
                      DropdownMenuItem(value: 'apresentacao', child: Text('📊 Apresentação')),
                      DropdownMenuItem(value: 'imagem', child: Text('🖼️ Imagem')),
                      DropdownMenuItem(value: 'link', child: Text('🔗 Link')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => tipoSelecionado = value!);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Link externo
                  TextField(
                    controller: linkExternoController,
                    decoration: const InputDecoration(
                      labelText: 'Link Externo (opcional)',
                      border: OutlineInputBorder(),
                      hintText: 'https://...',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  const Text(
                    'Tags',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tagController,
                          decoration: const InputDecoration(
                            hintText: 'Digite uma tag',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              setDialogState(() {
                                tags.add(value);
                                tagController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (tagController.text.isNotEmpty) {
                            setDialogState(() {
                              tags.add(tagController.text);
                              tagController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            onDeleted: () {
                              setDialogState(() => tags.remove(tag));
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Seleção de arquivos
                  const Text(
                    'Arquivos',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        type: FileType.any,
                      );

                      if (result != null) {
                        setDialogState(() {
                          arquivosSelecionados.addAll(result.files);
                        });
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Selecionar Arquivos'),
                  ),
                  if (arquivosSelecionados.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: arquivosSelecionados.map((file) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.insert_drive_file, size: 20),
                            title: Text(
                              file.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              _formatBytes(file.size),
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setDialogState(() {
                                  arquivosSelecionados.remove(file);
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
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
                    const SnackBar(content: Text('O título é obrigatório')),
                  );
                  return;
                }

                Navigator.pop(context);
                await _createMaterial(
                  titulo: tituloController.text,
                  descricao: descricaoController.text.isEmpty ? null : descricaoController.text,
                  tipo: tipoSelecionado,
                  tags: tags,
                  linkExterno: linkExternoController.text.isEmpty ? null : linkExternoController.text,
                  arquivos: arquivosSelecionados,
                );
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  Future<void> _createMaterial({
    required String titulo,
    String? descricao,
    required String tipo,
    required List<String> tags,
    String? linkExterno,
    required List<PlatformFile> arquivos,
  }) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Pegar ID do professor do usuário logado
      final currentUser = _apiService.currentUser;
      final professorId = currentUser?['id']?.toString() ?? '1';

      print('[DEBUG] Criando material:');
      print('  - disciplinaId: ${widget.disciplinaId} (tipo: ${widget.disciplinaId.runtimeType})');
      print('  - professorId: $professorId');
      print('  - titulo: $titulo');
      print('  - tipo: $tipo');

      // Criar material
      final material = await _materiaisService.criarMaterial(
        disciplinaId: widget.disciplinaId.toString(),
        professorId: professorId,
        titulo: titulo,
        descricao: descricao,
        tipo: tipo,
        tags: tags,
        linkExterno: linkExterno,
      );

      // Upload dos arquivos se houver
      if (arquivos.isNotEmpty && material.id != null) {
        for (final arquivo in arquivos) {
          // Detectar tipo MIME correto pelo nome do arquivo
          String mimeType = lookupMimeType(arquivo.name) ?? 'application/octet-stream';

          // Upload usando bytes (funciona na web)
          if (arquivo.bytes != null) {
            await _materiaisService.uploadArquivoBytes(
              materialId: material.id!,
              bytes: arquivo.bytes!,
              nomeOriginal: arquivo.name,
              mimeType: mimeType,
            );
          } else if (arquivo.path != null) {
            // Fallback para mobile/desktop usando path
            await _materiaisService.uploadArquivo(
              materialId: material.id!,
              arquivo: File(arquivo.path!),
              nomeOriginal: arquivo.name,
              mimeType: mimeType,
            );
          }
        }
      }

      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material criado com sucesso!')),
        );
        _loadMateriais(); // Recarregar lista
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar material: $e')),
        );
      }
    }
  }

  void _showEditMaterialDialog(models.Material material) {
    final tituloController = TextEditingController(text: material.titulo);
    final descricaoController = TextEditingController(text: material.descricao ?? '');
    final linkExternoController = TextEditingController(text: material.linkExterno ?? '');
    String tipoSelecionado = material.tipo;
    List<String> tags = List.from(material.tags);
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Material'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  TextField(
                    controller: descricaoController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tipo de material
                  DropdownButtonFormField<String>(
                    value: tipoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'documento', child: Text('📄 Documento')),
                      DropdownMenuItem(value: 'video', child: Text('🎥 Vídeo')),
                      DropdownMenuItem(value: 'apresentacao', child: Text('📊 Apresentação')),
                      DropdownMenuItem(value: 'imagem', child: Text('🖼️ Imagem')),
                      DropdownMenuItem(value: 'link', child: Text('🔗 Link')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => tipoSelecionado = value!);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Link externo
                  TextField(
                    controller: linkExternoController,
                    decoration: const InputDecoration(
                      labelText: 'Link Externo (opcional)',
                      border: OutlineInputBorder(),
                      hintText: 'https://...',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  const Text(
                    'Tags',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tagController,
                          decoration: const InputDecoration(
                            hintText: 'Digite uma tag',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              setDialogState(() {
                                tags.add(value);
                                tagController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (tagController.text.isNotEmpty) {
                            setDialogState(() {
                              tags.add(tagController.text);
                              tagController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            onDeleted: () {
                              setDialogState(() => tags.remove(tag));
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Arquivos existentes
                  if (material.arquivos.isNotEmpty) ...[
                    const Text(
                      'Arquivos anexados',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...material.arquivos.map((arquivo) {
                      return ListTile(
                        dense: true,
                        leading: Text(arquivo.icone, style: const TextStyle(fontSize: 20)),
                        title: Text(
                          arquivo.nomeOriginal,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          arquivo.tamanhoFormatado,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }),
                  ],
                ],
              ),
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
                    const SnackBar(content: Text('O título é obrigatório')),
                  );
                  return;
                }

                Navigator.pop(context);
                await _updateMaterial(
                  material: material,
                  titulo: tituloController.text,
                  descricao: descricaoController.text.isEmpty ? null : descricaoController.text,
                  tipo: tipoSelecionado,
                  tags: tags,
                  linkExterno: linkExternoController.text.isEmpty ? null : linkExternoController.text,
                );
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

  Future<void> _updateMaterial({
    required models.Material material,
    required String titulo,
    String? descricao,
    required String tipo,
    required List<String> tags,
    String? linkExterno,
  }) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Atualizar material
      await _materiaisService.atualizarMaterial(
        id: material.id!,
        titulo: titulo,
        descricao: descricao,
        tipo: tipo,
        tags: tags,
        linkExterno: linkExterno,
      );

      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material atualizado com sucesso!')),
        );
        _loadMateriais(); // Recarregar lista
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar material: $e')),
        );
      }
    }
  }

  void _showMaterialDetails(models.Material material) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.subjectColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      material.icone,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.titulo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          material.tipo.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.subjectColor,
                            fontWeight: FontWeight.w500,
                          ),
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

              // Descrição
              if (material.descricao != null && material.descricao!.isNotEmpty) ...[
                const Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  material.descricao!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tags
              if (material.tags.isNotEmpty) ...[
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: material.tags.map((tag) {
                    return Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Link externo
              if (material.isLinkExterno) ...[
                const Text(
                  'Link Externo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    // TODO: Abrir link no navegador
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Abrir: ${material.linkExterno}')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            material.linkExterno!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Arquivos
              if (material.temArquivos) ...[
                const Text(
                  'Arquivos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: material.arquivos.length,
                    itemBuilder: (context, index) {
                      final arquivo = material.arquivos[index];
                      return Card(
                        child: ListTile(
                          leading: Text(
                            arquivo.icone,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(arquivo.nomeOriginal),
                          subtitle: Text(
                            '${arquivo.tamanhoFormatado} • ${arquivo.extensao}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () => _downloadArquivo(arquivo),
                                tooltip: 'Baixar arquivo',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmRemoverArquivo(material, arquivo),
                                tooltip: 'Remover arquivo',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Data de criação
              Text(
                'Criado em ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(material.criadoEm)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadArquivo(models.Arquivo arquivo) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Download do arquivo
      final bytes = await _materiaisService.downloadArquivo(arquivo.gridFsId);

      if (mounted) {
        Navigator.pop(context); // Fechar loading

        // Verificar se é web
        if (kIsWeb) {
          // No web, usar download via blob
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute('download', arquivo.nomeOriginal)
            ..click();
          html.Url.revokeObjectUrl(url);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Arquivo baixado com sucesso!')),
            );
          }
        } else {
          // No mobile/desktop, usar FilePicker
          final result = await FilePicker.platform.saveFile(
            dialogTitle: 'Salvar arquivo',
            fileName: arquivo.nomeOriginal,
          );

          if (result != null) {
            final file = File(result);
            await file.writeAsBytes(bytes);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Arquivo salvo com sucesso!')),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao baixar arquivo: $e')),
        );
      }
    }
  }

  void _confirmRemoverArquivo(models.Material material, models.Arquivo arquivo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover arquivo'),
        content: Text('Deseja realmente remover o arquivo "${arquivo.nomeOriginal}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removerArquivo(material, arquivo);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  Future<void> _removerArquivo(models.Material material, models.Arquivo arquivo) async {
    try {
      if (arquivo.gridFsId.isEmpty) {
        throw Exception('ID do arquivo está vazio');
      }

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Remover arquivo
      await _materiaisService.removerArquivo(material.id!, arquivo.gridFsId);

      if (mounted) {
        Navigator.pop(context); // Fechar loading
        Navigator.pop(context); // Fechar dialog de detalhes
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arquivo removido com sucesso!')),
        );

        // Recarregar materiais
        await _loadMateriais();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover arquivo: $e')),
        );
      }
    }
  }

  void _confirmDeleteMaterial(models.Material material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "${material.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMaterial(material);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMaterial(models.Material material) async {
    try {
      await _materiaisService.deletarMaterial(material.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material excluído com sucesso')),
        );
        _loadMateriais(); // Recarrega a lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir material: $e')),
        );
      }
    }
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
                    const SnackBar(
                      content: Text('Por favor, preencha o título'),
                    ),
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

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Atividade criada com sucesso!'),
                    ),
                  );
                  _loadAtividades(); // Reload activities list
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

  void _showEditAtividadeDialog(Map<String, dynamic> atividade) {
    final tituloController = TextEditingController(
      text: atividade['titulo'] ?? '',
    );
    final descricaoController = TextEditingController(
      text: atividade['descricao'] ?? '',
    );
    final peso = atividade['peso'];
    double? pesoValue;
    if (peso is num) {
      pesoValue = peso.toDouble();
    } else if (peso is String) {
      pesoValue = double.tryParse(peso);
    }
    final pesoController = TextEditingController(
      text: pesoValue?.toString() ?? '1.0',
    );

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
                    const SnackBar(
                      content: Text('Por favor, preencha o título'),
                    ),
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

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Atividade atualizada com sucesso!'),
                    ),
                  );
                  _loadAtividades(); // Reload activities list
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

  void _confirmDeleteAtividade(Map<String, dynamic> atividade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Atividade'),
        content: Text(
          'Deseja realmente excluir a atividade "${atividade['titulo']}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.deleteAtividade(atividade['id']);

                if (!context.mounted) return;
                Navigator.pop(context);
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Atividade excluída com sucesso!'),
                  ),
                );
                _loadAtividades(); // Reload activities list
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
