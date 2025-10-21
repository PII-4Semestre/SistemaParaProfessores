import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../services/api_service.dart';
import 'tela_detalhes_disciplina_aluno.dart';

class TelaVisaoGeralAluno extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const TelaVisaoGeralAluno({super.key, this.onNavigateToTab});

  @override
  State<TelaVisaoGeralAluno> createState() => _TelaVisaoGeralAlunoState();
}

class _TelaVisaoGeralAlunoState extends State<TelaVisaoGeralAluno> {
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

      // Load data in parallel
      final results = await Future.wait([
        _apiService.getDisciplinasAluno(alunoId),
        _apiService.getNotasAluno(alunoId),
      ]);

      _disciplinas = results[0];
      _notas = results[1];

      if (mounted) {
        setState(() {
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

  double _calcularMediaGeral() {
    if (_notas.isEmpty) return 0.0;
    double soma = 0.0;
    for (var nota in _notas) {
      soma += (nota['nota'] is String) 
          ? double.tryParse(nota['nota']) ?? 0.0 
          : (nota['nota'] as num).toDouble();
    }
    return soma / _notas.length;
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
            Text('Erro ao carregar dados', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text(
            'Visão Geral',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bem-vindo ao Portal do Aluno',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Cards de estatísticas com dados reais
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              return isNarrow
                ? Column(
                    children: [
                      _buildStatCard(
                        title: 'Média Geral',
                        value: _notas.isEmpty ? '-' : _calcularMediaGeral().toStringAsFixed(1),
                        icon: Icons.grade,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: 'Disciplinas',
                        value: '${_disciplinas.length}',
                        icon: Icons.book,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: 'Mensagens',
                        value: '0',
                        icon: Icons.mail,
                        color: Colors.purple,
                      ),
                    ],
                  )
                : Row(
                    children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Média Geral',
                  value: _notas.isEmpty ? '-' : _calcularMediaGeral().toStringAsFixed(1),
                  icon: Icons.grade,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Disciplinas',
                  value: '${_disciplinas.length}',
                  icon: Icons.book,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Mensagens',
                  value: '0',
                  icon: Icons.mail,
                  color: Colors.purple,
                ),
              ),
            ],
          );
            },
          ),
          const SizedBox(height: 24),
          // Seção de atividades recentes com dados reais
          const Text(
            'Notas Recentes',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_notas.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Nenhuma nota cadastrada', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notas.length > 5 ? 5 : _notas.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final nota = _notas[index];
                  final notaValor = (nota['nota'] is String) 
                      ? double.tryParse(nota['nota']) ?? 0.0 
                      : (nota['nota'] as num).toDouble();
                  
                  Color notaColor = Colors.green;
                  if (notaValor < 6.0) {
                    notaColor = Colors.red;
                  } else if (notaValor < 7.0) {
                    notaColor = Colors.orange;
                  }
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notaColor.withValues(alpha: 0.2),
                      child: Icon(Icons.grade, color: notaColor),
                    ),
                    title: Text(nota['atividade_titulo'] ?? 'Sem título'),
                    subtitle: Text(nota['disciplina_nome'] ?? 'Sem disciplina'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: notaColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notaValor.toStringAsFixed(1),
                        style: TextStyle(
                          color: notaColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 24),

          // Seção de disciplinas com dados reais
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minhas Disciplinas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_disciplinas.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    widget.onNavigateToTab?.call(1);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Ver Todas'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_disciplinas.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Você não está matriculado em nenhuma disciplina', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _disciplinas.length,
                  itemBuilder: (context, index) {
                  final disciplina = _disciplinas[index];
                  final corString = disciplina['cor'] ?? '#2196F3';
                  Color cor;
                  try {
                    cor = Color(int.parse(corString.replaceFirst('#', '0xFF')));
                  } catch (e) {
                    cor = Colors.blue;
                  }

                  final notasDisciplina = _notas.where((n) => n['disciplina_nome'] == disciplina['nome']).toList();
                  double mediaDisciplina = 0.0;
                  if (notasDisciplina.isNotEmpty) {
                    double soma = 0.0;
                    for (var nota in notasDisciplina) {
                      soma += (nota['nota'] is String) 
                          ? double.tryParse(nota['nota']) ?? 0.0 
                          : (nota['nota'] as num).toDouble();
                    }
                    mediaDisciplina = soma / notasDisciplina.length;
                  }

                  return Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 16),
                    child: Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaDetalhesDisciplinaAluno(
                                subjectName: disciplina['nome'] ?? 'Sem nome',
                                subjectColor: cor,
                                professorName: disciplina['professor_nome'] ?? 'Sem professor',
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.book,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                disciplina['nome'] ?? 'Sem nome',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                disciplina['descricao'] ?? 'Sem descrição',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      disciplina['professor_nome'] ?? 'Sem professor',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (notasDisciplina.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Média: ${mediaDisciplina.toStringAsFixed(1)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
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
                  );
                },
              ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double animValue, child) {
        return Transform.scale(
          scale: 0.8 + (animValue * 0.2),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
