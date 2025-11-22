import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'tela_detalhes_disciplina_aluno.dart';

class TelaDisciplinasAluno extends StatefulWidget {
  const TelaDisciplinasAluno({super.key});

  @override
  State<TelaDisciplinasAluno> createState() => _TelaDisciplinasAlunoState();
}

class _TelaDisciplinasAlunoState extends State<TelaDisciplinasAluno> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<dynamic> _disciplinas = [];
  List<dynamic> _notas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final alunoId = _apiService.currentUser?['id'];
      if (alunoId == null) {
        throw Exception('Aluno ID não encontrado');
      }

      // Carregar disciplinas e notas
      final results = await Future.wait([
        _apiService.getDisciplinasAluno(alunoId),
        _apiService.getNotasAluno(alunoId),
      ]);

      if (mounted) {
        setState(() {
          _disciplinas = results[0];
          _notas = results[1];
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar disciplinas',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // Filtrar disciplinas pela busca
    final disciplinasFiltradas = _disciplinas.where((disciplina) {
      final nome = disciplina['nome']?.toString().toLowerCase() ?? '';
      final professor =
          disciplina['professor_nome']?.toString().toLowerCase() ?? '';
      final busca = _searchController.text.toLowerCase();
      return nome.contains(busca) || professor.contains(busca);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Minhas Disciplinas',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você está matriculado em ${_disciplinas.length} disciplina(s)',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Atualizar',
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar disciplinas...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 24),
          if (disciplinasFiltradas.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? 'Você não está matriculado em nenhuma disciplina'
                          : 'Nenhuma disciplina encontrada',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: _getCardAspectRatio(context),
                ),
                itemCount: disciplinasFiltradas.length,
                itemBuilder: (context, index) {
                  final disciplina = disciplinasFiltradas[index];
                  return _buildDisciplinaCard(disciplina);
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
    if (width > 1400) return 1.0;
    if (width > 1100) return 0.95;
    if (width > 800) return 0.9;
    if (width > 600) return 0.85;
    // Telas muito estreitas (Galaxy Fold, etc)
    if (width < 350) return 2.5;
    // Mobile normal: cards retangulares horizontais
    return 2.0;
  }

  Widget _buildDisciplinaCard(Map<String, dynamic> disciplina) {
    // Parse da cor
    final corString = disciplina['cor'] ?? '#2196F3';
    Color cor;
    try {
      cor = Color(int.parse(corString.replaceFirst('#', '0xFF')));
    } catch (e) {
      cor = Colors.blue;
    }

    final nome = disciplina['nome'] ?? 'Sem nome';
    final professor = disciplina['professor_nome'] ?? 'Sem professor';
    final descricao = disciplina['descricao'] ?? '';
    final disciplinaId = disciplina['id'] as int;

    // Calcular média da disciplina
    final notasDisciplina = _notas
        .where((n) => n['disciplina_nome'] == nome)
        .toList();
    double? mediaDisciplina;
    if (notasDisciplina.isNotEmpty) {
      double soma = 0.0;
      for (var nota in notasDisciplina) {
        soma += (nota['nota'] is String)
            ? double.tryParse(nota['nota']) ?? 0.0
            : (nota['nota'] as num).toDouble();
      }
      mediaDisciplina = soma / notasDisciplina.length;
    }

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaDetalhesDisciplinaAluno(
                subjectName: nome,
                subjectColor: cor,
                professorName: professor,
                disciplinaId: disciplinaId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cor.withValues(alpha: 0.8), cor],
            ),
            boxShadow: [
              BoxShadow(
                color: cor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Detectar se é tela muito pequena
                final isVerySmall = constraints.maxHeight < 120;
                final iconSize = isVerySmall ? 20.0 : 24.0;
                final titleSize = isVerySmall ? 14.0 : 16.0;
                final subtitleSize = isVerySmall ? 10.0 : 12.0;
                final spacing = isVerySmall ? 4.0 : 8.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isVerySmall ? 6 : 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.book,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(height: spacing),
                    Text(
                      nome,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (descricao.isNotEmpty && !isVerySmall) ...[
                      const SizedBox(height: 4),
                      Text(
                        descricao,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: subtitleSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: spacing / 2),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: isVerySmall ? 12 : 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            professor,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: subtitleSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (mediaDisciplina != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.grade,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Média: ${mediaDisciplina.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.assignment,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${notasDisciplina.length} notas',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
