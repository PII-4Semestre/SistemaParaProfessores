import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../services/api_service.dart';
import 'tela_detalhes_disciplina_professor.dart';

class TelaVisaoGeralProfessor extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const TelaVisaoGeralProfessor({super.key, this.onNavigateToTab});

  @override
  State<TelaVisaoGeralProfessor> createState() =>
      _TelaVisaoGeralProfessorState();
}

class _TelaVisaoGeralProfessorState extends State<TelaVisaoGeralProfessor> {
  final ApiService _apiService = ApiService();

  List<dynamic> _disciplinas = [];
  List<dynamic> _alunos = [];
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
      final professorId = _apiService.currentUser?['id'];
      if (professorId == null) {
        throw Exception('Professor ID não encontrado');
      }

      // Load all data in parallel
      final results = await Future.wait([
        _apiService.getDisciplinasProfessor(professorId),
        _apiService.getTodosAlunos(),
      ]);

      _disciplinas = results[0];
      _alunos = results[1];

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
              'Erro ao carregar dados',
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visão Geral',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bem-vindo ao Portal do Professor',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                            title: 'Disciplinas',
                            value: '${_disciplinas.length}',
                            icon: Icons.book,
                            color: const Color(0xFFED2152),
                            onTap: () => widget.onNavigateToTab?.call(1),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            title: 'Total de Alunos',
                            value: '${_alunos.length}',
                            icon: Icons.people,
                            color: const Color(0xFF1CB3C2),
                            onTap: () => widget.onNavigateToTab?.call(2),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            title: 'Mensagens',
                            value: '0',
                            icon: Icons.mail,
                            color: const Color(0xFFF9A31F),
                            onTap: () => widget.onNavigateToTab?.call(3),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Disciplinas',
                              value: '${_disciplinas.length}',
                              icon: Icons.book,
                              color: const Color(0xFFED2152),
                              onTap: () => widget.onNavigateToTab?.call(1),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total de Alunos',
                              value: '${_alunos.length}',
                              icon: Icons.people,
                              color: const Color(0xFF1CB3C2),
                              onTap: () => widget.onNavigateToTab?.call(2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Mensagens',
                              value: '0',
                              icon: Icons.mail,
                              color: const Color(0xFFF9A31F),
                              onTap: () => widget.onNavigateToTab?.call(3),
                            ),
                          ),
                        ],
                      );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Seção de disciplinas com dados reais
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Minhas Disciplinas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (_disciplinas.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to disciplines tab (index 1)
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
                        Icon(
                          Icons.school_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nenhuma disciplina cadastrada',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Clique em "Disciplinas" para começar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
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
                        cor = Color(
                          int.parse(corString.replaceFirst('#', '0xFF')),
                        );
                      } catch (e) {
                        cor = Colors.blue;
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
                                  builder: (context) =>
                                      TelaDetalhesDisciplinaProfessor(
                                        subjectName:
                                            disciplina['nome'] ?? 'Sem nome',
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
                                  colors: [cor.withValues(alpha: 0.7), cor],
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.assignment,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      FutureBuilder<List<dynamic>>(
                                        future: _apiService
                                            .getAtividadesDisciplina(
                                              disciplina['id'],
                                            ),
                                        builder: (context, snapshot) {
                                          final count = snapshot.hasData
                                              ? snapshot.data!.length
                                              : 0;
                                          return Text(
                                            '$count atividade${count != 1 ? 's' : ''}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          );
                                        },
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
    VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (animValue * 0.2),
          child: Opacity(opacity: animValue, child: child),
        );
      },
      child: Card(
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
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
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
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
      ),
    );
  }
}
