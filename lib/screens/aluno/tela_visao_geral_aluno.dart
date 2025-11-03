import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import 'tela_detalhes_disciplina_aluno.dart';

class TelaVisaoGeralAluno extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const TelaVisaoGeralAluno({
    Key? key,
    this.onNavigateToTab,
  }) : super(key: key);

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
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final alunoId = _apiService.currentUser?['id'];
      if (alunoId == null) {
        throw Exception('Aluno ID não encontrado');
      }

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

  double _calcularMedia() {
    if (_notas.isEmpty) return 0.0;
    double soma = 0;
    int count = 0;
    for (var nota in _notas) {
      if (nota['nota'] != null) {
        final notaValue = nota['nota'];
        final notaDouble = notaValue is String 
            ? double.tryParse(notaValue) ?? 0.0 
            : (notaValue as num).toDouble();
        soma += notaDouble;
        count++;
      }
    }
    return count > 0 ? soma / count : 0.0;
  }

  int _contarAtividadesPendentes() {
    return 0; // TODO: Implement when atividades API is ready
  }

  Map<String, dynamic> _calcularTendencia() {
    if (_notas.length < 4) {
      return {'trend': 'stable', 'percentage': 0.0};
    }

    // Dividir notas em duas metades
    int metade = _notas.length ~/ 2;
    List<double> notasAntigas = _notas
        .skip(metade)
        .map((n) => _converterNota(n['nota']))
        .where((n) => n != null)
        .cast<double>()
        .toList();
    
    List<double> notasRecentes = _notas
        .take(metade)
        .map((n) => _converterNota(n['nota']))
        .where((n) => n != null)
        .cast<double>()
        .toList();

    if (notasAntigas.isEmpty || notasRecentes.isEmpty) {
      return {'trend': 'stable', 'percentage': 0.0};
    }

    double mediaAntiga = notasAntigas.reduce((a, b) => a + b) / notasAntigas.length;
    double mediaRecente = notasRecentes.reduce((a, b) => a + b) / notasRecentes.length;
    
    double diferenca = mediaRecente - mediaAntiga;
    double percentual = mediaAntiga > 0 ? (diferenca / mediaAntiga * 100) : 0.0;

    String trend;
    if (diferenca.abs() < 0.3) {
      trend = 'stable';
    } else if (diferenca > 0) {
      trend = 'up';
    } else {
      trend = 'down';
    }

    return {'trend': trend, 'percentage': percentual.abs()};
  }

  Widget _buildPerformanceBadge(double media) {
    String label;
    Color color;
    IconData icon;
    
    if (media >= 9.0) {
      label = 'EXCELENTE';
      color = Color(0xFF1CB3C2); // Cyan - mesma cor da tela professor
      icon = Iconsax.medal_star;
    } else if (media >= 7.0) {
      label = 'BOM';
      color = Color(0xFF1CB3C2); // Cyan - mesma cor da tela professor
      icon = Iconsax.award;
    } else if (media >= 5.0) {
      label = 'REGULAR';
      color = Color(0xFFF9A31F); // Orange - mesma cor da tela professor
      icon = Iconsax.warning_2;
    } else {
      label = 'ATENÇÃO';
      color = Color(0xFFED2152); // Pink - mesma cor da tela professor
      icon = Iconsax.danger;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                media.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatarNota(dynamic nota) {
    if (nota == null) return '-';
    if (nota is String) {
      final notaDouble = double.tryParse(nota);
      return notaDouble?.toStringAsFixed(1) ?? '-';
    }
    return (nota as num).toDouble().toStringAsFixed(1);
  }

  double? _converterNota(dynamic nota) {
    if (nota == null) return null;
    if (nota is String) return double.tryParse(nota);
    return (nota as num).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Header skeleton
            Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 36,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Achievements skeleton
                  Row(
                    children: List.generate(3, (index) => Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Container(
                        width: 100,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )),
                  ),
                  SizedBox(height: 32),
                  // Quick actions skeleton
                  Row(
                    children: List.generate(4, (index) => Expanded(
                      child: Container(
                        height: 70,
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )),
                  ),
                  SizedBox(height: 32),
                  // Stats skeleton
                  Row(
                    children: List.generate(3, (index) => Expanded(
                      child: Container(
                        height: 140,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )),
                  ),
                  SizedBox(height: 32),
                  // Chart skeleton
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Cards skeleton
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
              Icon(Iconsax.danger, size: 64, color: Color(0xFFED2152)), // Pink
              SizedBox(height: 16),
              Text(
                'Erro ao carregar dados',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _error ?? 'Erro desconhecido',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
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
                    color: Colors.white,
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
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _carregarDados,
        backgroundColor: Color(0xFF24243E),
        color: Color(0xFF1CB3C2), // Cyan - mesma cor da tela professor
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
                  SizedBox(height: 24),
                  _buildAchievements(),
                  SizedBox(height: 32),
                  _buildQuickActions(isDesktop, isTablet),
                  SizedBox(height: 32),
                  _buildStatsSection(isDesktop, isTablet),
                  SizedBox(height: 32),
                  if (_notas.isNotEmpty) ...[
                    _buildPerformanceChart(),
                    SizedBox(height: 32),
                  ],
                  _buildNotasSection(),
                  SizedBox(height: 32),
                  _buildDisciplinasSection(isDesktop, isTablet),
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
    final nomeAluno = _apiService.currentUser?['nome'] ?? 'Aluno';
    final media = _calcularMedia();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.3, end: 0),
                  SizedBox(height: 4),
                  Text(
                    nomeAluno,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3, end: 0),
                ],
              ),
            ),
            if (_notas.isNotEmpty)
              _buildPerformanceBadge(media)
                  .animate()
                  .fadeIn(delay: 250.ms)
                  .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1CB3C2), Color(0xFFED2152), Color(0xFFF9A31F)], // Cores da tela professor
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.5, end: 0),
      ],
    );
  }

  Widget _buildAchievements() {
    final media = _calcularMedia();
    final tendencia = _calcularTendencia();
    
    // Definir conquistas baseadas em condições
    List<Map<String, dynamic>> achievements = [];
    
    // Conquista: Média alta
    if (media >= 9.0) {
      achievements.add({
        'icon': Iconsax.crown5,
        'title': 'Destaque',
        'subtitle': 'Média ≥ 9.0',
        'color': Color(0xFFFFD700), // Dourado
      });
    }
    
    // Conquista: Evolução positiva
    if (tendencia['trend'] == 'up' && tendencia['percentage'] > 10) {
      achievements.add({
        'icon': Iconsax.trend_up5,
        'title': 'Em Ascensão',
        'subtitle': 'Melhorando ${tendencia['percentage'].toStringAsFixed(0)}%',
        'color': Color(0xFF4CAF50), // Verde
      });
    }
    
    // Conquista: Muitas disciplinas
    if (_disciplinas.length >= 5) {
      achievements.add({
        'icon': Iconsax.book5,
        'title': 'Dedicado',
        'subtitle': '${_disciplinas.length} disciplinas',
        'color': Color(0xFF1CB3C2), // Cyan - mesma cor da tela professor
      });
    }
    
    // Conquista: Participação
    if (_notas.length >= 10) {
      achievements.add({
        'icon': Iconsax.task_square5,
        'title': 'Participativo',
        'subtitle': '${_notas.length} avaliações',
        'color': Color(0xFFED2152), // Pink - mesma cor da tela professor
      });
    }
    
    if (achievements.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.medal_star5, size: 20, color: Color(0xFFF9A31F)), // Orange - mesma cor da tela professor
            SizedBox(width: 8),
            Text(
              'Conquistas',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFF9A31F).withOpacity(0.2), // Orange
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${achievements.length}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF9A31F), // Orange
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: achievements.asMap().entries.map((entry) {
              final index = entry.key;
              final achievement = entry.value;
              
              return Padding(
                padding: EdgeInsets.only(right: 12),
                child: _AchievementBadge(
                  icon: achievement['icon'],
                  title: achievement['title'],
                  subtitle: achievement['subtitle'],
                  color: achievement['color'],
                  index: index,
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildQuickActions(bool isDesktop, bool isTablet) {
    final actions = [
      _QuickActionData(
        icon: Iconsax.document_text5,
        title: 'Materiais',
        subtitle: 'Acessar conteúdo',
        color: Color(0xFF1CB3C2), // Cyan - mesma cor da tela professor
        notificationCount: 3, // TODO: Get from API
        onTap: () {
          // TODO: Navigate to materials
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Materiais em desenvolvimento'),
              backgroundColor: Color(0xFF1CB3C2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      _QuickActionData(
        icon: Iconsax.message_text5,
        title: 'Mensagens',
        subtitle: 'Conversar',
        color: Color(0xFFED2152), // Pink - mesma cor da tela professor
        notificationCount: 5, // TODO: Get from API
        onTap: () {
          // TODO: Navigate to messages
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mensagens em desenvolvimento'),
              backgroundColor: Color(0xFFED2152),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      _QuickActionData(
        icon: Iconsax.calendar5,
        title: 'Calendário',
        subtitle: 'Ver agenda',
        color: Color(0xFFF9A31F), // Orange - mesma cor da tela professor
        onTap: () {
          // TODO: Navigate to calendar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Calendário em desenvolvimento'),
              backgroundColor: Color(0xFFF9A31F),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      _QuickActionData(
        icon: Iconsax.chart_215,
        title: 'Relatórios',
        subtitle: 'Desempenho',
        color: Color(0xFF9C27B0),
        onTap: () {
          // TODO: Navigate to reports
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Relatórios em desenvolvimento'),
              backgroundColor: Color(0xFF9C27B0),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    ];

    if (isDesktop) {
      return Row(
        children: actions.asMap().entries.map((entry) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: _QuickActionCard(
                data: entry.value,
                index: entry.key,
              ),
            ),
          );
        }).toList(),
      ).animate().fadeIn(delay: 250.ms).slideY(begin: -0.2, end: 0);
    } else if (isTablet) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: actions.asMap().entries.map((entry) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 64) / 2,
            child: _QuickActionCard(
              data: entry.value,
              index: entry.key,
            ),
          );
        }).toList(),
      ).animate().fadeIn(delay: 250.ms).slideY(begin: -0.2, end: 0);
    } else {
      return Column(
        children: actions.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: entry.key < actions.length - 1 ? 12 : 0),
            child: _QuickActionCard(
              data: entry.value,
              index: entry.key,
            ),
          );
        }).toList(),
      ).animate().fadeIn(delay: 250.ms).slideY(begin: -0.2, end: 0);
    }
  }

  Widget _buildStatsSection(bool isDesktop, bool isTablet) {
    final media = _calcularMedia();
    final pendentes = _contarAtividadesPendentes();
    final tendencia = _calcularTendencia();
    
    final stats = [
      StatCardData(
        icon: Iconsax.book_1,
        title: 'Disciplinas',
        value: _disciplinas.length.toString(),
        color: Color(0xFF1CB3C2), // Cyan - mesma cor da tela professor
        subtitle: 'Matriculado',
      ),
      StatCardData(
        icon: Iconsax.medal_star,
        title: 'Média Geral',
        value: media.toStringAsFixed(1),
        color: Color(0xFFED2152), // Pink - mesma cor da tela professor
        subtitle: 'Desempenho',
        trend: tendencia['trend'],
        trendPercentage: tendencia['percentage'],
      ),
      StatCardData(
        icon: Iconsax.task_square,
        title: 'Atividades',
        value: pendentes.toString(),
        color: Color(0xFFF9A31F), // Orange - mesma cor da tela professor
        subtitle: 'Pendentes',
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

  Widget _buildPerformanceChart() {
    // Agrupar notas por disciplina e calcular evolução
    Map<String, List<double>> notasPorDisciplina = {};
    
    for (var nota in _notas) {
      String disciplina = nota['disciplina'] ?? 'Outras';
      double? valor = _converterNota(nota['nota']);
      if (valor == null) continue;
      
      if (!notasPorDisciplina.containsKey(disciplina)) {
        notasPorDisciplina[disciplina] = [];
      }
      notasPorDisciplina[disciplina]!.add(valor);
    }
    
    // Pegar últimas 6 notas para mostrar evolução
    List<double> ultimasNotas = _notas
        .take(6)
        .map((n) => _converterNota(n['nota']))
        .where((n) => n != null)
        .cast<double>()
        .toList()
        .reversed
        .toList();
    
    if (ultimasNotas.isEmpty) return SizedBox.shrink();
    
    // Calcular média móvel
    double mediaAtual = ultimasNotas.reduce((a, b) => a + b) / ultimasNotas.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Evolução de Performance',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: mediaAtual >= 7.0 
                    ? Color(0xFF1CB3C2).withOpacity(0.2) // Cyan
                    : Color(0xFFF9A31F).withOpacity(0.2), // Orange
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: mediaAtual >= 7.0
                      ? Color(0xFF1CB3C2).withOpacity(0.3)
                      : Color(0xFFF9A31F).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.chart_215,
                    size: 14,
                    color: mediaAtual >= 7.0 ? Color(0xFF1CB3C2) : Color(0xFFF9A31F),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Média: ${mediaAtual.toStringAsFixed(1)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: mediaAtual >= 7.0 ? Color(0xFF1CB3C2) : Color(0xFFF9A31F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(delay: 350.ms),
        SizedBox(height: 16),
        GlassContainer(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2.5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 1.0,
                            getTitlesWidget: (value, meta) {
                              // Mostrar todos os valores inteiros de 0 a 10
                              if (value % 1 != 0 || value > 10) return SizedBox();
                              return Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Text(
                                  value.toInt().toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                          axisNameWidget: Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Nota',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          axisNameSize: 20,
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                          axisNameWidget: Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Avaliações',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          axisNameSize: 25,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                          bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                        ),
                      ),
                      minX: 0,
                      maxX: (ultimasNotas.length - 1).toDouble(),
                      minY: 0,
                      maxY: 10.0, // Escala de notas 0-10
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            ultimasNotas.length,
                            (index) => FlSpot(index.toDouble(), ultimasNotas[index]),
                          ),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1CB3C2), // Cyan
                              Color(0xFFED2152), // Pink
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: Color(0xFF1CB3C2), // Cyan
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1CB3C2).withOpacity(0.3), // Cyan
                                Color(0xFFED2152).withOpacity(0.1), // Pink
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (spot) => Color(0xFF24243E),
                          tooltipRoundedRadius: 8,
                          tooltipPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                'Nota: ${spot.y.toStringAsFixed(1)}',
                                GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.info_circle, size: 16, color: Color(0xFF1CB3C2)), // Cyan
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gráfico mostra suas últimas ${ultimasNotas.length} avaliações mais recentes',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildNotasSection() {
    final notasRecentes = _notas.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notas Recentes',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (_notas.length > 5)
              TextButton(
                onPressed: () => widget.onNavigateToTab?.call(1),
                child: Text(
                  'Ver todas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFF1CB3C2), // Cyan
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ).animate().fadeIn(delay: 400.ms),
        SizedBox(height: 16),
        if (notasRecentes.isEmpty)
          GlassContainer(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF1CB3C2).withOpacity(0.2), // Cyan
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.clipboard_text5,
                        size: 48,
                        color: Color(0xFF1CB3C2), // Cyan
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Nenhuma nota ainda',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Suas notas aparecerão aqui assim que\nseu professor lançar as avaliações',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white60,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1CB3C2).withOpacity(0.3), // Cyan
                            Color(0xFF1CB3C2).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF1CB3C2).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.info_circle, size: 16, color: Color(0xFF1CB3C2)), // Cyan
                          SizedBox(width: 8),
                          Text(
                            'Continue acompanhando suas disciplinas',
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
          ).animate().fadeIn(delay: 500.ms)
        else
          GlassContainer(
            child: Column(
              children: notasRecentes.asMap().entries.map((entry) {
                final index = entry.key;
                final nota = entry.value;
                final isLast = index == notasRecentes.length - 1;
                
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getNotaColor(nota['nota']),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                _formatarNota(nota['nota']),
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
                                  nota['disciplina_nome'] ?? 'Sem nome',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  nota['atividade_nome'] ?? 'Atividade',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white60,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Iconsax.arrow_right_3,
                            color: Colors.white38,
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
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  List<Color> _getNotaColor(dynamic notaValue) {
    final nota = _converterNota(notaValue);
    if (nota == null) return [Colors.grey.shade700, Colors.grey.shade800];
    if (nota >= 7.0) return [Color(0xFF1CB3C2), Color(0xFF0E8A96)]; // Cyan
    if (nota >= 5.0) return [Color(0xFFF9A31F), Color(0xFFD88A15)]; // Orange
    return [Color(0xFFED2152), Color(0xFFB81840)]; // Pink
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
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () => widget.onNavigateToTab?.call(2),
              child: Text(
                'Ver todas',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color(0xFF1CB3C2), // Cyan
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 600.ms),
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
                        color: Color(0xFFF9A31F).withOpacity(0.2), // Orange
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.book_15,
                        size: 48,
                        color: Color(0xFFF9A31F), // Orange
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Nenhuma disciplina matriculada',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Entre em contato com a secretaria para\nverificar sua matrícula nas disciplinas',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white60,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFF9A31F).withOpacity(0.3), // Orange
                            Color(0xFFF9A31F).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFF9A31F).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.warning_2, size: 16, color: Color(0xFFF9A31F)), // Orange
                          SizedBox(width: 8),
                          Text(
                            'Disciplinas são necessárias para acessar o conteúdo',
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
}

// ============ COMPONENT CLASSES ============

class _AchievementBadge extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int index;

  const _AchievementBadge({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.index,
  }) : super(key: key);

  @override
  State<_AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<_AchievementBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.1 : 1.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withOpacity(0.3),
                widget.color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withOpacity(_isHovered ? 0.6 : 0.4),
              width: 2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 24,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 100 * widget.index))
            .fadeIn(duration: 400.ms)
            .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
      ),
    );
  }
}

class _QuickActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int? notificationCount;

  _QuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.notificationCount,
  });
}

class _QuickActionCard extends StatefulWidget {
  final _QuickActionData data;
  final int index;

  const _QuickActionCard({
    Key? key,
    required this.data,
    required this.index,
  }) : super(key: key);

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.data.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -4.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.data.color.withOpacity(_isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 24 : 16,
                spreadRadius: 0,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.data.color.withOpacity(_isHovered ? 0.25 : 0.15),
                      widget.data.color.withOpacity(_isHovered ? 0.15 : 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.data.color.withOpacity(_isHovered ? 0.5 : 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.data.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.data.icon,
                        color: widget.data.color,
                        size: 20,
                      ),
                    ),
                    if (widget.data.notificationCount != null && widget.data.notificationCount! > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFED2152), // Pink
                                Color(0xFFF9A31F), // Orange
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF24243E),
                              width: 2,
                            ),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              widget.data.notificationCount! > 9 
                                  ? '9+' 
                                  : widget.data.notificationCount.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ).animate(
                          onPlay: (controller) => controller.repeat(),
                        ).scale(
                          duration: 1000.ms,
                          begin: Offset(1, 1),
                          end: Offset(1.1, 1.1),
                        ).then().scale(
                          duration: 1000.ms,
                          begin: Offset(1.1, 1.1),
                          end: Offset(1, 1),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.data.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.data.subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: Colors.white.withOpacity(0.7),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    )))
        .animate(delay: Duration(milliseconds: 50 * widget.index))
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.2, end: 0);
  }
}

class StatCardData {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String subtitle;
  final VoidCallback? onTap;
  final String? trend; // 'up', 'down', 'stable'
  final double? trendPercentage;

  StatCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.subtitle,
    this.onTap,
    this.trend,
    this.trendPercentage,
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
    return MouseRegion(
      cursor: widget.data.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.data.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.data.color.withOpacity(_isHovered ? 0.4 : 0.2),
                  blurRadius: _isHovered ? 30 : 20,
                  spreadRadius: 0,
                  offset: Offset(0, _isHovered ? 15 : 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.data.color.withOpacity(_isHovered ? 0.25 : 0.15),
                        Colors.white.withOpacity(_isHovered ? 0.12 : 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      width: 1.5,
                      color: widget.data.color.withOpacity(_isHovered ? 0.4 : 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.data.color.withOpacity(0.3),
                                  widget.data.color.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.data.color.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.data.icon,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          if (widget.data.trend != null && widget.data.trend != 'stable')
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: widget.data.trend == 'up'
                                      ? [Color(0xFF4CAF50), Color(0xFF66BB6A)]
                                      : [Color(0xFFEF5350), Color(0xFFE57373)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (widget.data.trend == 'up'
                                            ? Color(0xFF4CAF50)
                                            : Color(0xFFEF5350))
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.data.trend == 'up'
                                        ? Iconsax.arrow_up_2
                                        : Iconsax.arrow_down_1,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${widget.data.trendPercentage!.toStringAsFixed(1)}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        widget.data.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.data.value,
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: widget.data.color.withOpacity(0.5),
                              offset: Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.data.subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 0,
            spreadRadius: 0,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                stops: [0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                width: 1.5,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: child,
          ),
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
    final colors = [
      Color(0xFF1CB3C2), // Cyan - mesma cor da tela professor
      Color(0xFFED2152), // Pink
      Color(0xFFF9A31F), // Orange
      Color(0xFF9B59B6), // Purple
      Color(0xFF3498DB), // Blue
      Color(0xFFE74C3C), // Red
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDisciplinaColor(widget.index);
    final nome = widget.disciplina['nome'] ?? 'Sem nome';
    final professorNome = widget.disciplina['professorNome'] ?? 'Professor';
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaDetalhesDisciplinaAluno(
                subjectName: nome,
                subjectColor: color,
                professorName: professorNome,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -6.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(_isHovered ? 0.5 : 0.3),
                blurRadius: _isHovered ? 30 : 20,
                spreadRadius: 0,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(_isHovered ? 0.25 : 0.15),
                      Colors.white.withOpacity(_isHovered ? 0.12 : 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    width: 1.5,
                    color: color.withOpacity(_isHovered ? 0.4 : 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [color, color.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Iconsax.book_15,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nome,
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.teacher,
                                    size: 14,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      professorNome,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.3),
                                color.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.arrow_right_34,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Ver detalhes',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 700 + (widget.index * 100)))
        .slideY(begin: 0.2, end: 0);
  }
}
