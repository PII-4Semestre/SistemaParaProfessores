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
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopBackground(height: 220),
        ),
        SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _IntroHeader(
              title: 'Visão Geral',
              subtitle: 'Bem-vindo ao Portal do Professor',
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
            const _AnimatedGradientDivider(),
            const SizedBox(height: 16),

            // Seção de disciplinas com dados reais
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildSectionHeader(
                    context,
                    'Minhas Disciplinas',
                    Icons.book,
                  ),
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
    ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return _AnimatedStatCard(
      title: title,
      value: value,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [cs.primary, cs.secondary],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBackground extends StatelessWidget {
  const _TopBackground({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primary.withValues(alpha: 0.10),
              cs.secondary.withValues(alpha: 0.06),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

class _AnimatedGradientDivider extends StatelessWidget {
  const _AnimatedGradientDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, _) {
        return Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primary.withValues(alpha: 0.25),
                    cs.secondary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IntroHeader extends StatelessWidget {
  const _IntroHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      tween: Tween(begin: 0, end: 1),
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 12),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) => Text(
              subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedStatCard extends StatefulWidget {
  const _AnimatedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color;
    final shadowColor = baseColor.withValues(alpha: 0.3);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.9 + (animValue * 0.1),
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          scale: _hovered ? 1.02 : 1.0,
          child: Card(
            elevation: _hovered ? 6 : 2,
            shadowColor: shadowColor,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      baseColor.withValues(alpha: _hovered ? 0.14 : 0.1),
                      baseColor.withValues(alpha: _hovered ? 0.08 : 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: baseColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: _hovered ? 18 : 10,
                      offset: Offset(0, _hovered ? 10 : 6),
                    ),
                  ],
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
                            widget.title,
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
                            color: baseColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(widget.icon, color: baseColor, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.value,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: baseColor,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
