import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html show Blob, Url, AnchorElement;
import 'package:file_picker/file_picker.dart';
import '../../services/materiais_service.dart';
import '../../services/atividades_service.dart';
import '../../services/api_service.dart';
import '../../models/material.dart' as models;
import '../../models/atividade.dart';

class TelaDetalhesDisciplinaAluno extends StatefulWidget {
  final String subjectName;
  final Color subjectColor;
  final String professorName;
  final int disciplinaId;

  const TelaDetalhesDisciplinaAluno({
    super.key,
    required this.subjectName,
    required this.subjectColor,
    required this.professorName,
    required this.disciplinaId,
  });

  @override
  State<TelaDetalhesDisciplinaAluno> createState() =>
      _TelaDetalhesDisciplinaAlunoState();
}

class _TelaDetalhesDisciplinaAlunoState
    extends State<TelaDetalhesDisciplinaAluno>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MateriaisService _materiaisService = MateriaisService();
  final AtividadesService _atividadesService = AtividadesService();
  final ApiService _apiService = ApiService();
  List<models.Material> _materiais = [];
  bool _isLoadingMateriais = true;
  List<Atividade> _atividades = [];
  Map<String, SubmissaoAtividade?> _submissoes = {};
  bool _isLoadingAtividades = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMateriais();
    _loadAtividades();
  }

  Future<void> _loadMateriais() async {
    try {
      setState(() => _isLoadingMateriais = true);
      final materiais = await _materiaisService.getMateriaisPorDisciplina(
        widget.disciplinaId.toString(),
      );
      setState(() {
        _materiais = materiais;
        _isLoadingMateriais = false;
      });
    } catch (e) {
      setState(() => _isLoadingMateriais = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar materiais: $e')),
        );
      }
    }
  }

  Future<void> _loadAtividades() async {
    try {
      setState(() => _isLoadingAtividades = true);
      final atividades = await _atividadesService.getAtividadesDisciplina(
        widget.disciplinaId.toString(),
      );
      
      // Carregar submissões do aluno para cada atividade
      final submissoes = <String, SubmissaoAtividade?>{};
      final alunoId = _apiService.currentUser?['id']?.toString();
      
      if (alunoId != null) {
        for (final atividade in atividades) {
          try {
            final submissao = await _atividadesService.getSubmissaoAluno(
              atividadeId: atividade.id,
              alunoId: alunoId,
            );
            submissoes[atividade.id] = submissao;
          } catch (e) {
            submissoes[atividade.id] = null;
          }
        }
      }

      setState(() {
        _atividades = atividades;
        _submissoes = submissoes;
        _isLoadingAtividades = false;
      });
    } catch (e) {
      setState(() => _isLoadingAtividades = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar atividades: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom gradient header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.subjectColor.withValues(alpha: 0.7),
                  widget.subjectColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header with back button and title
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.professorName,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.book), text: 'Materiais'),
                      Tab(icon: Icon(Icons.assignment), text: 'Atividades'),
                      Tab(icon: Icon(Icons.grade), text: 'Notas'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMateriaisTab(),
                _buildAtividadesTab(),
                _buildNotasTab(),
              ],
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

    if (_materiais.isEmpty) {
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
                'Nenhum material disponível',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'O professor ainda não disponibilizou materiais para esta disciplina.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMateriais,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _materiais.length,
        itemBuilder: (context, index) {
          final material = _materiais[index];
          return _buildMaterialCard(material);
        },
      ),
    );
  }

  Widget _buildMaterialCard(models.Material material) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                            fontSize: 18,
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
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              if (material.descricao != null && material.descricao!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  material.descricao!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (material.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: material.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
              if (material.temArquivos) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${material.arquivos.length} arquivo(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
                          title: Text(arquivo.nomeOriginal.isEmpty ? 'arquivo_sem_nome' : arquivo.nomeOriginal),
                          subtitle: Text(
                            '${arquivo.tamanhoFormatado}${arquivo.extensao.isNotEmpty ? ' • ${arquivo.extensao}' : ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => _downloadArquivo(arquivo),
                            tooltip: 'Baixar arquivo',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Publicado em ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(material.criadoEm)}',
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final bytes = await _materiaisService.downloadArquivo(arquivo.gridFsId);

      if (mounted) {
        Navigator.pop(context);

        if (kIsWeb) {
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao baixar arquivo: $e')),
        );
      }
    }
  }

  Widget _buildAtividadesTab() {
    if (_isLoadingAtividades) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_atividades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma atividade disponível',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView.builder(
        itemCount: _atividades.length,
        itemBuilder: (context, index) {
          final atividade = _atividades[index];
          final submissao = _submissoes[atividade.id];
          final isExpired = atividade.dataEntrega.isBefore(DateTime.now());
          final hasSubmission = submissao != null;
          final isGraded = submissao?.foiAvaliada ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: InkWell(
              onTap: () => _showAtividadeDetailsDialog(atividade, submissao),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isGraded
                                ? Colors.blue.withValues(alpha: 0.1)
                                : hasSubmission
                                    ? Colors.orange.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isGraded
                                    ? Icons.grade
                                    : hasSubmission
                                        ? Icons.check_circle
                                        : Icons.hourglass_empty,
                                size: 14,
                                color: isGraded
                                    ? Colors.blue
                                    : hasSubmission
                                        ? Colors.orange
                                        : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isGraded
                                    ? 'Nota: ${submissao!.nota!.toStringAsFixed(1)}'
                                    : hasSubmission
                                        ? 'Aguardando correção'
                                        : 'Não entregue',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isGraded
                                      ? Colors.blue
                                      : hasSubmission
                                          ? Colors.orange
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildNotasTab() {
    // Calcular média real das atividades avaliadas
    final atividadesAvaliadas = _atividades.where((a) {
      final s = _submissoes[a.id];
      return s != null && s.foiAvaliada && s.nota != null;
    }).toList();
    double media = 0.0;
    if (atividadesAvaliadas.isNotEmpty) {
      media = atividadesAvaliadas
          .map((a) => _submissoes[a.id]!.nota!)
          .reduce((a, b) => a + b) /
          atividadesAvaliadas.length;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: widget.subjectColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grade, size: 48, color: widget.subjectColor),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sua Média',
                        style: TextStyle(fontSize: 16, color: widget.subjectColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        atividadesAvaliadas.isNotEmpty ? media.toStringAsFixed(2) : '-',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.subjectColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: atividadesAvaliadas.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma nota disponível ainda.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: atividadesAvaliadas.length,
                    itemBuilder: (context, index) {
                      final atividade = atividadesAvaliadas[index];
                      final submissao = _submissoes[atividade.id]!;
                      final nota = submissao.nota!;
                      Color notaColor;
                      if (nota >= 7.0) {
                        notaColor = Colors.green;
                      } else if (nota >= 5.0) {
                        notaColor = Colors.orange;
                      } else {
                        notaColor = Colors.red;
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notaColor.withOpacity(0.2),
                            child: Icon(Icons.assignment_turned_in, color: notaColor),
                          ),
                          title: Text(atividade.titulo),
                          // subtitle removido: Peso não será exibido
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: notaColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              nota.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: notaColor,
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

  void _showAtividadeDetailsDialog(Atividade atividade, SubmissaoAtividade? submissao) {
    final isExpired = atividade.dataEntrega.isBefore(DateTime.now());
    final hasSubmission = submissao != null;
    final isGraded = submissao?.foiAvaliada ?? false;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 700,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment, color: widget.subjectColor, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          atividade.titulo,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Entrega: ${DateFormat('dd/MM/yyyy HH:mm').format(atividade.dataEntrega)}',
                          style: TextStyle(
                            color: isExpired ? Colors.red : Colors.grey[600],
                            fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
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
              const Divider(height: 24),
              if (atividade.descricao.isNotEmpty) ...[
                const Text(
                  'Descrição:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  atividade.descricao,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  if (isGraded)
                    Chip(
                      avatar: const Icon(Icons.grade, size: 18),
                      label: Text('Nota: ${submissao!.nota!.toStringAsFixed(2)}'),
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    ),
                ],
              ),
              const Divider(height: 24),
              if (isGraded) ...[
                const Text(
                  'Avaliação:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.blue.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.grade, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Nota: ${submissao!.nota!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        if (submissao.feedback != null) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Feedback do Professor:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(submissao.feedback!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (hasSubmission) ...[
                const Text(
                  'Arquivos Enviados:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: submissao.arquivos.length,
                    itemBuilder: (context, index) {
                      final arquivo = submissao.arquivos[index];
                      return ListTile(
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (submissao.comentario != null && submissao.comentario!.isNotEmpty) ...[
                  const Text(
                    'Seu Comentário:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
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
                if (!isGraded) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSubmitDialog(atividade, isEdit: true);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Submissão'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ] else ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isExpired
                              ? 'Prazo de entrega expirado'
                              : 'Nenhum arquivo enviado ainda',
                          style: TextStyle(
                            fontSize: 16,
                            color: isExpired ? Colors.red : Colors.grey[600],
                            fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (!isExpired) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showSubmitDialog(atividade),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Enviar Arquivos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.subjectColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmitDialog(Atividade atividade, {bool isEdit = false}) async {
    List<PlatformFile> selectedFiles = [];
    final comentarioController = TextEditingController();

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result == null) return;

    selectedFiles = result.files;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Enviar Atividade'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Arquivos selecionados: ${selectedFiles.length}'),
                  const SizedBox(height: 16),
                  if (selectedFiles.isNotEmpty)
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: selectedFiles.length,
                        itemBuilder: (context, index) {
                          final file = selectedFiles[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.attach_file),
                            title: Text(file.name),
                            subtitle: Text(
                              '${(file.size / 1024).toStringAsFixed(2)} KB',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  selectedFiles.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final newResult = await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        type: FileType.any,
                      );
                      if (newResult != null) {
                        setState(() {
                          selectedFiles.addAll(newResult.files);
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar mais arquivos'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Comentário (opcional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: comentarioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Adicione um comentário sobre sua entrega...',
                      border: OutlineInputBorder(),
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
              onPressed: selectedFiles.isEmpty
                  ? null
                  : () async {
                      try {
                        final usuario = _apiService.currentUser;
                        if (usuario == null) {
                          throw Exception('Usuário não autenticado');
                        }

                        final arquivosBytes = selectedFiles
                            .map((f) => f.bytes!)
                            .toList();
                        final arquivosNomes = selectedFiles
                            .map((f) => f.name)
                            .toList();

                        await _atividadesService.submeterAtividade(
                          atividadeId: atividade.id,
                          alunoId: usuario['id'].toString(),
                          alunoNome: usuario['nome'],
                          arquivosBytes: arquivosBytes,
                          arquivosNomes: arquivosNomes,
                          comentario: comentarioController.text.isNotEmpty 
                              ? comentarioController.text 
                              : null,
                        );

                        if (!mounted) return;
                        Navigator.pop(context); // Fecha dialog de submit
                        if (!isEdit) {
                          Navigator.pop(context); // Fecha dialog de detalhes (apenas se não for edição)
                        }
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Atividade enviada com sucesso!'),
                          ),
                        );
                        _loadAtividades(); // Recarrega para mostrar submissão
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao enviar atividade: $e'),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.subjectColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(List<int> bytes, String nomeArquivo) async {
    try {
      if (kIsWeb) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', nomeArquivo)
          ..click();
        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arquivo baixado com sucesso!')),
          );
        }
      } else {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Salvar arquivo',
          fileName: nomeArquivo,
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar arquivo: $e')),
        );
      }
    }
  }
}
