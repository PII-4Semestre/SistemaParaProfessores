import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/api_service.dart';
import 'tela_detalhes_disciplina_professor.dart';

class TelaVisaoGeralProfessor extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const TelaVisaoGeralProfessor({
    Key? key,
    this.onNavigateToTab,
  }) : super(key: key);

  @override
  State<TelaVisaoGeralProfessor> createState() => _TelaVisaoGeralProfessorState();
}

class _TelaVisaoGeralProfessorState extends State<TelaVisaoGeralProfessor> {
  final ApiService _apiService = ApiService();
  List<dynamic> _disciplinas = [];
  List<dynamic> _alunos = [];
  bool _isLoading = true;
  String? _error;

  // Helper para cores adaptáveis ao tema
  Color _getPrimaryColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Color(0xFF1CB3C2) // Cyan
        : Color(0xFFFF9B71); // Coral
  }

  Color _getSecondaryColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Color(0xFFED2152) // Pink
        : Color(0xFFFFB88C); // Peach
  }

  Color _getAccentColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Color(0xFFF9A31F) // Orange
        : Color(0xFFFF8A65); // Light orange
  }

  Color _getCardColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Color(0xFF24243E)
        : Color(0xFFF6E2CD); // Salmão claro
  }

  List<Color> _getGradientColors() {
    return Theme.of(context).brightness == Brightness.dark
        ? [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)]
        : [Color(0xFFFFF5EB), Color(0xFFFFE4D6), Color(0xFFF6E2CD)];
  }

  Color _getTextColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Color(0xFF5D4037); // Marrom escuro
  }

  Color _getTextSecondaryColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Color(0xFF8D6E63); // Marrom médio
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final professorId = _apiService.currentUser?['id'];
      if (professorId == null) {
        throw Exception('Professor ID não encontrado');
      }

      final results = await Future.wait([
        _apiService.getDisciplinasProfessor(professorId),
        _apiService.getTodosAlunos(),
      ]);

      if (mounted) {
        setState(() {
          _disciplinas = results[0];
          _alunos = results[1];
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

  int _contarAlunosTotal() {
    // Conta alunos únicos em todas as disciplinas
    Set<String> alunosUnicos = {};
    for (var disciplina in _disciplinas) {
      if (disciplina['alunoIds'] != null) {
        alunosUnicos.addAll(List<String>.from(disciplina['alunoIds']));
      }
    }
    return alunosUnicos.length;
  }

  int _contarMensagensPendentes() {
    return 0; // TODO: Implement when mensagens API is ready
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
        ),
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
                ? _buildErrorState()
                : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase = isDark ? Colors.white.withOpacity(0.1) : Color(0xFFFFB88C).withOpacity(0.2);
    final shimmerHighlight = isDark ? Colors.white.withOpacity(0.2) : Color(0xFFFF9B71).withOpacity(0.3);
    final shimmerColor = isDark ? Colors.white : Color(0xFFF6E2CD);
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 20),
            Shimmer.fromColors(
              baseColor: shimmerBase,
              highlightColor: shimmerHighlight,
              child: Column(
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: List.generate(3, (index) => Expanded(
                      child: Container(
                        height: 120,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )),
                  ),
                  SizedBox(height: 24),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(20),
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

  Widget _buildErrorState() {
    return Center(
      child: GlassContainer(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.danger, size: 64, color: _getSecondaryColor()),
              SizedBox(height: 16),
              Text(
                'Erro ao carregar dados',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
              SizedBox(height: 8),
              Text(
                _error ?? 'Erro desconhecido',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _getTextSecondaryColor(),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              GlassButton(
                onPressed: _carregarDados,
                child: Text(
                  'Tentar Novamente',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _carregarDados,
        backgroundColor: isDark ? Color(0xFF24243E) : _getCardColor(),
        color: _getPrimaryColor(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1200;
            final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 1200;
            
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isDesktop ? 32 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 32),
                  _buildStatsSection(isDesktop, isTablet),
                  SizedBox(height: 32),
                  _buildDisciplinasSection(isDesktop, isTablet),
                  SizedBox(height: 32),
                  _buildAlunosSection(isDesktop, isTablet),
                  SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';
    final nomeProfessor = _apiService.currentUser?['nome'] ?? 'Professor';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: _getTextSecondaryColor(),
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.3, end: 0),
        SizedBox(height: 4),
        Text(
          nomeProfessor,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: _getTextColor(),
            height: 1.2,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3, end: 0),
        SizedBox(height: 8),
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_getPrimaryColor(), _getSecondaryColor(), _getAccentColor()],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.5, end: 0),
      ],
    );
  }

  Widget _buildStatsSection(bool isDesktop, bool isTablet) {
    final alunosTotal = _contarAlunosTotal();
    final mensagensPendentes = _contarMensagensPendentes();
    
    final stats = [
      StatCardData(
        icon: Iconsax.book_1,
        title: 'Disciplinas',
        value: _disciplinas.length.toString(),
        color: _getSecondaryColor(),
        subtitle: 'Ativas',
        onTap: () => widget.onNavigateToTab?.call(1),
      ),
      StatCardData(
        icon: Iconsax.people,
        title: 'Alunos',
        value: alunosTotal.toString(),
        color: _getPrimaryColor(),
        subtitle: 'Total',
        onTap: () => widget.onNavigateToTab?.call(2),
      ),
      StatCardData(
        icon: Iconsax.message,
        title: 'Mensagens',
        value: mensagensPendentes.toString(),
        color: _getAccentColor(),
        subtitle: 'Pendentes',
        onTap: () => widget.onNavigateToTab?.call(3),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: stats.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: StatCard(data: entry.value, index: entry.key),
            ),
          );
        }).toList(),
      );
    } else if (isTablet) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: stats.asMap().entries.map((entry) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 72) / 2,
            child: StatCard(data: entry.value, index: entry.key),
          );
        }).toList(),
      );
    } else {
      return Column(
        children: stats.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: entry.key < stats.length - 1 ? 16 : 0),
            child: StatCard(data: entry.value, index: entry.key),
          );
        }).toList(),
      );
    }
  }

  Widget _buildDisciplinasSection(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minhas Disciplinas',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            if (_disciplinas.length > 6)
              TextButton(
                onPressed: () => widget.onNavigateToTab?.call(1),
                child: Text(
                  'Ver todas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _getPrimaryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ).animate().fadeIn(delay: 400.ms),
        SizedBox(height: 16),
        if (_disciplinas.isEmpty)
          GlassContainer(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _getPrimaryColor().withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.book_15,
                        size: 48,
                        color: _getPrimaryColor(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Nenhuma disciplina cadastrada',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Você ainda não possui disciplinas atribuídas.\nEntre em contato com a coordenação',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _getTextSecondaryColor(),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getPrimaryColor().withOpacity(0.3),
                            _getPrimaryColor().withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getPrimaryColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.info_circle, size: 16, color: _getPrimaryColor()),
                          SizedBox(width: 8),
                          Text(
                            'Disciplinas são atribuídas pela administração',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _getTextSecondaryColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms)
        else
          _buildDisciplinasGrid(isDesktop, isTablet),
      ],
    );
  }

  Widget _buildDisciplinasGrid(bool isDesktop, bool isTablet) {
    final disciplinasLimitadas = _disciplinas.take(6).toList();
    
    if (isDesktop) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: disciplinasLimitadas.asMap().entries.map((entry) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 128) / 3,
            child: DisciplinaCard(
              disciplina: entry.value,
              index: entry.key,
            ),
          );
        }).toList(),
      );
    } else if (isTablet) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: disciplinasLimitadas.asMap().entries.map((entry) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 72) / 2,
            child: DisciplinaCard(
              disciplina: entry.value,
              index: entry.key,
            ),
          );
        }).toList(),
      );
    } else {
      return Column(
        children: disciplinasLimitadas.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: entry.key < disciplinasLimitadas.length - 1 ? 16 : 0),
            child: DisciplinaCard(
              disciplina: entry.value,
              index: entry.key,
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildAlunosSection(bool isDesktop, bool isTablet) {
    final alunosLimitados = _alunos.take(isDesktop ? 8 : 6).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alunos Recentes',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _getTextColor(),
              ),
            ),
            if (_alunos.length > (isDesktop ? 8 : 6))
              TextButton(
                onPressed: () => widget.onNavigateToTab?.call(2),
                child: Text(
                  'Ver todos',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _getPrimaryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ).animate().fadeIn(delay: 600.ms),
        SizedBox(height: 16),
        if (alunosLimitados.isEmpty)
          GlassContainer(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _getSecondaryColor().withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.people5,
                        size: 48,
                        color: _getSecondaryColor(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Nenhum aluno matriculado',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ainda não há alunos matriculados\nnas suas disciplinas',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _getTextSecondaryColor(),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getSecondaryColor().withOpacity(0.3),
                            _getSecondaryColor().withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getSecondaryColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.user_add, size: 16, color: _getSecondaryColor()),
                          SizedBox(width: 8),
                          Text(
                            'Alunos aparecerão aqui após matrícula',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 700.ms)
        else
          GlassContainer(
            child: Column(
              children: alunosLimitados.asMap().entries.map((entry) {
                final index = entry.key;
                final aluno = entry.value;
                final isLast = index == alunosLimitados.length - 1;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final textColor = isDark ? Colors.white : Color(0xFF5D4037);
                final secondaryTextColor = isDark ? Colors.white60 : Color(0xFF8D6E63);
                final primaryColor = isDark ? Color(0xFF1CB3C2) : Color(0xFFFF9B71);
                
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.7),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (aluno['nome'] ?? 'A')[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  aluno['nome'] ?? 'Sem nome',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  aluno['ra'] ?? 'RA não informado',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Iconsax.arrow_right_3,
                            color: secondaryTextColor.withOpacity(0.6),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        color: Colors.white.withOpacity(0.1),
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

// ============ COMPONENT CLASSES ============

class StatCardData {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String subtitle;
  final VoidCallback? onTap;

  StatCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.subtitle,
    this.onTap,
  });
}

class StatCard extends StatefulWidget {
  final StatCardData data;
  final int index;

  const StatCard({
    Key? key,
    required this.data,
    required this.index,
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Color(0xFF5D4037);
    final secondaryTextColor = isDark ? Colors.white70 : Color(0xFF8D6E63);
    final tertiaryTextColor = isDark ? Colors.white60 : Color(0xFFA1887F);
    
    return MouseRegion(
      cursor: widget.data.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.data.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: GlassContainer(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.data.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: widget.data.color,
                      size: 24,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.data.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.data.value,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.data.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: tertiaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 400 + (widget.index * 100)))
        .slideY(begin: 0.2, end: 0);
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const GlassContainer({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ]
                  : [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Color(0xFFFFB88C).withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Color(0xFFFF9B71).withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const GlassButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: GlassContainer(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: child,
        ),
      ),
    );
  }
}

class DisciplinaCard extends StatefulWidget {
  final dynamic disciplina;
  final int index;

  const DisciplinaCard({
    Key? key,
    required this.disciplina,
    required this.index,
  }) : super(key: key);

  @override
  State<DisciplinaCard> createState() => _DisciplinaCardState();
}

class _DisciplinaCardState extends State<DisciplinaCard> {
  bool _isHovered = false;

  Color _getDisciplinaColor(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkColors = [
      Color(0xFFED2152),
      Color(0xFF1CB3C2),
      Color(0xFFF9A31F),
      Color(0xFF9B59B6),
      Color(0xFF3498DB),
      Color(0xFFE74C3C),
    ];
    final lightColors = [
      Color(0xFFFFB88C),
      Color(0xFFFF9B71),
      Color(0xFFFF8A65),
      Color(0xFFBA68C8),
      Color(0xFF64B5F6),
      Color(0xFFEF5350),
    ];
    return isDark 
        ? darkColors[index % darkColors.length]
        : lightColors[index % lightColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Color(0xFF5D4037);
    final secondaryTextColor = isDark ? Colors.white60 : Color(0xFF8D6E63);
    
    final color = _getDisciplinaColor(widget.index);
    final nome = widget.disciplina['nome'] ?? 'Sem nome';
    final disciplinaId = widget.disciplina['id'] is String 
        ? int.tryParse(widget.disciplina['id']) ?? 0 
        : widget.disciplina['id'] as int;
    final alunosCount = widget.disciplina['alunoIds'] != null 
        ? (widget.disciplina['alunoIds'] as List).length 
        : 0;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaDetalhesDisciplinaProfessor(
                subjectName: nome,
                subjectColor: color,
                disciplinaId: disciplinaId,
              ),
            ),
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: GlassContainer(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Iconsax.book_1,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Iconsax.people, size: 14, color: secondaryTextColor),
                          SizedBox(width: 4),
                          Text(
                            '$alunosCount alunos',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ver detalhes',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
      ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 500 + (widget.index * 100)))
        .slideY(begin: 0.2, end: 0);
  }
}
