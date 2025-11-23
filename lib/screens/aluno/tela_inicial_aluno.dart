import 'package:flutter/material.dart';
import 'tela_visao_geral_aluno.dart';
import 'tela_disciplinas_aluno.dart';
import 'tela_mensagens_aluno.dart';
import '../autenticacao/tela_login.dart';
import '../../services/api_service.dart';
import '../../services/atividades_service.dart';
import '../../models/atividade.dart';
import '../../widgets/side_menu.dart';

class TelaInicialAluno extends StatefulWidget {
  const TelaInicialAluno({super.key});

  @override
  State<TelaInicialAluno> createState() => _TelaInicialAlunoState();
}

class _TelaInicialAlunoState extends State<TelaInicialAluno> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  final AtividadesService _atividadesService = AtividadesService();

  List<SubmissaoAtividade> _submissoesAvaliadas = [];
  Map<String, String> _disciplinasNomes = {};
  Map<String, Atividade> _atividadesPorId = {};
  bool _isLoadingNotas = false;
  String? _errorNotas;

  @override
  void initState() {
    super.initState();
    _loadNotas();
  }

  Future<void> _loadNotas() async {
    setState(() {
      _isLoadingNotas = true;
      _errorNotas = null;
    });

    try {
      final alunoId = _apiService.currentUser?['id'];
      if (alunoId == null) {
        throw Exception('Aluno ID não encontrado');
      }

      // Buscar todas as disciplinas do aluno
      final disciplinas = await _apiService.getDisciplinasAluno(alunoId);
      
      // Armazenar nomes das disciplinas
      _disciplinasNomes = {};
      for (var disciplina in disciplinas) {
        _disciplinasNomes[disciplina['id'].toString()] = disciplina['nome'];
      }

      // Buscar submissões avaliadas de todas as disciplinas
      List<SubmissaoAtividade> todasSubmissoes = [];
      for (var disciplina in disciplinas) {
        try {
          final atividades = await _atividadesService.getAtividadesDisciplina(
            disciplina['id'].toString(),
          );
          
          for (var atividade in atividades) {
            try {
              final submissao = await _atividadesService.getSubmissaoAluno(
                atividadeId: atividade.id,
                alunoId: alunoId.toString(),
              );
              
              if (submissao != null && submissao.foiAvaliada) {
                todasSubmissoes.add(submissao);
                _atividadesPorId[atividade.id] = atividade;
              }
            } catch (e) {
              // Submissão não encontrada para esta atividade, continua
            }
          }
        } catch (e) {
          // Erro ao buscar atividades desta disciplina, continua
        }
      }

      if (mounted) {
        setState(() {
          _submissoesAvaliadas = todasSubmissoes;
          _isLoadingNotas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorNotas = e.toString();
          _isLoadingNotas = false;
        });
      }
    }
  }

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Visão Geral',
    ),
    NavigationDestination(
      icon: Icon(Icons.book_outlined),
      selectedIcon: Icon(Icons.book),
      label: 'Disciplinas',
    ),
    NavigationDestination(
      icon: Icon(Icons.message_outlined),
      selectedIcon: Icon(Icons.message),
      label: 'Mensagens',
    ),
    NavigationDestination(
      icon: Icon(Icons.grade_outlined),
      selectedIcon: Icon(Icons.grade),
      label: 'Notas',
    ),
  ];

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return TelaVisaoGeralAluno(
          onNavigateToTab: (index) {
            setState(() => _selectedIndex = index);
          },
        );
      case 1:
        return const TelaDisciplinasAluno();
      case 2:
        return const TelaMensagensAluno();
      case 3:
        return _buildNotasScreen();
      default:
        return const TelaVisaoGeralAluno();
    }
  }

  Widget _buildNotasScreen() {
    if (_isLoadingNotas) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorNotas != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar notas',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(_errorNotas!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotas,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // Calcular média geral
    double mediaGeral = 0.0;
    if (_submissoesAvaliadas.isNotEmpty) {
      double soma = 0.0;
      for (var submissao in _submissoesAvaliadas) {
        soma += submissao.nota ?? 0.0;
      }
      mediaGeral = soma / _submissoesAvaliadas.length;
    }

    // Agrupar submissões por disciplina (usando IDs das atividades)
    // Nota: Como não temos disciplinaId nas submissões, vamos mostrar todas juntas
    // ou precisaríamos buscar as atividades para pegar seus disciplinaIds

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minhas Notas',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Veja suas notas em todas as atividades',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.blue.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Icon(Icons.grade, size: 48, color: Colors.blue),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Média Geral',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _submissoesAvaliadas.isEmpty
                            ? '-'
                            : mediaGeral.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Todas as Notas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_submissoesAvaliadas.isEmpty)
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
                      'Nenhuma atividade avaliada ainda',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _submissoesAvaliadas.length,
                itemBuilder: (context, index) {
                  final submissao = _submissoesAvaliadas[index];
                  final nota = submissao.nota ?? 0.0;
                  final atividade = _atividadesPorId[submissao.atividadeId.toString()];
                  
                  // Cor baseada na nota (0-10)
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
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: notaColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.assignment, color: notaColor),
                      ),
                      title: Text(
                        atividade?.titulo ?? 'Atividade',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (submissao.feedback != null &&
                              submissao.feedback!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Feedback: ${submissao.feedback}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: notaColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          nota.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 20,
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

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: !isWideScreen
          ? Drawer(
              child: SideMenu(
                name: _apiService.currentUser?['nome'] ?? 'Aluno',
                subtitle: 'RA: ${_apiService.currentUser?['ra'] ?? ''}',
                destinations: _destinations,
                selectedIndex: _selectedIndex,
                onSelect: (index) {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
                onLogout: () async {
                  final navigator = Navigator.of(context);
                  await _apiService.logout();
                  if (!mounted) return;
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const TelaLogin()),
                    (route) => false,
                  );
                },
              ),
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    Color(0xFF0F0C29),
                    Color(0xFF302B63),
                    Color(0xFF24243E),
                  ]
                : [
                    Color(0xFFFFF5EB),
                    Color(0xFFFFE4D6),
                    Color(0xFFF6E2CD),
                  ],
          ),
        ),
        child: Row(
          children: [
            if (isWideScreen)
              SizedBox(
                width: 300,
                child: SideMenu(
                  name: _apiService.currentUser?['nome'] ?? 'Aluno',
                  subtitle: 'RA: ${_apiService.currentUser?['ra'] ?? ''}',
                  destinations: _destinations,
                  selectedIndex: _selectedIndex,
                  onSelect: (index) => setState(() => _selectedIndex = index),
                  onLogout: () async {
                    final navigator = Navigator.of(context);
                    await _apiService.logout();
                    if (!mounted) return;
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const TelaLogin()),
                      (route) => false,
                    );
                  },
                ),
              ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _getCurrentScreen()),
          ],
        ),
      ),
      floatingActionButton: !isWideScreen
          ? Builder(
              builder: (context) => FloatingActionButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.menu, color: Colors.white),
              ),
            )
          : null,
    );
  }
}
