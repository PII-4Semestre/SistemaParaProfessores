import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'tela_detalhes_disciplina_professor.dart';
import '../../services/api_service.dart';

class TelaDisciplinasProfessor extends StatefulWidget {
  const TelaDisciplinasProfessor({super.key});

  @override
  State<TelaDisciplinasProfessor> createState() =>
      _TelaDisciplinasProfessorState();
}

class _TelaDisciplinasProfessorState extends State<TelaDisciplinasProfessor> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  Color _selectedColor = Colors.blue;
  final ApiService _apiService = ApiService();

  List<dynamic> _disciplinas = [];
  bool _isLoading = true;
  String? _error;

  String _colorToHexRGB(Color c) {
    // Use non-deprecated r/g/b (0..1) components and convert to 0..255 ints
    final r = ((c.r * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final g = ((c.g * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final b = ((c.b * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    return '#${(r + g + b).toUpperCase()}';
  }

  @override
  void initState() {
    super.initState();
    _loadDisciplinas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _loadDisciplinas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final professorId = _apiService.currentUser?['id'];
      if (professorId == null) {
        throw Exception('Professor ID não encontrado');
      }

      final disciplinas = await _apiService.getDisciplinasProfessor(
        professorId,
      );

      if (mounted) {
        setState(() {
          _disciplinas = disciplinas;
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

  void _showAddDisciplinaDialog() {
    _nomeController.clear();
    _descricaoController.clear();
    _selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Disciplina'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Disciplina',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Escolha uma cor:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              // Botão para abrir o seletor de cores avançado
              InkWell(
                onTap: () async {
                  final Color? newColor = await showDialog<Color>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Selecione uma cor'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          color: _selectedColor,
                          onColorChanged: (Color color) {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          width: 44,
                          height: 44,
                          borderRadius: 8,
                          spacing: 5,
                          runSpacing: 5,
                          wheelDiameter: 200,
                          heading: const Text(
                            'Cores Pré-definidas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subheading: const Text(
                            'Cores Recentes',
                            style: TextStyle(fontSize: 14),
                          ),
                          wheelSubheading: const Text(
                            'Roda de Cores',
                            style: TextStyle(fontSize: 14),
                          ),
                          showMaterialName: true,
                          showColorName: true,
                          showColorCode: true,
                          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                            longPressMenu: true,
                          ),
                          materialNameTextStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          colorNameTextStyle: const TextStyle(fontSize: 12),
                          colorCodeTextStyle: const TextStyle(fontSize: 11),
                          pickersEnabled: const <ColorPickerType, bool>{
                            ColorPickerType.both: false,
                            ColorPickerType.primary: true,
                            ColorPickerType.accent: true,
                            ColorPickerType.bw: false,
                            ColorPickerType.custom: true,
                            ColorPickerType.wheel: true,
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  if (newColor != null) {
                    setState(() {
                      _selectedColor = newColor;
                    });
                  }
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.palette, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Clique para escolher cor',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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
              if (_nomeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nome da disciplina é obrigatório'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final professorId = _apiService.currentUser?['id'];
                if (professorId == null) {
                  throw Exception('Professor ID não encontrado');
                }

                await _apiService.createDisciplina(
                  nome: _nomeController.text,
                  descricao: _descricaoController.text,
                  professorId: professorId,
                  cor: _colorToHexRGB(_selectedColor),
                );

                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Disciplina criada com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );

                _loadDisciplinas();
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao criar disciplina: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showEditDisciplinaDialog(Map<String, dynamic> disciplina) {
    _nomeController.text = disciplina['nome'] ?? '';
    _descricaoController.text = disciplina['descricao'] ?? '';

    // Parse color from database
    final corString = disciplina['cor'] ?? '#2196F3';
    try {
      _selectedColor = Color(int.parse(corString.replaceFirst('#', '0xFF')));
    } catch (e) {
      _selectedColor = Colors.blue;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Disciplina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Disciplina',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Escolha uma cor:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                // Botão para abrir o seletor de cores avançado
                InkWell(
                  onTap: () async {
                    final Color? newColor = await showDialog<Color>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Selecione uma cor'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            color: _selectedColor,
                            onColorChanged: (Color color) {
                              setDialogState(() {
                                _selectedColor = color;
                              });
                            },
                            width: 44,
                            height: 44,
                            borderRadius: 8,
                            spacing: 5,
                            runSpacing: 5,
                            wheelDiameter: 200,
                            heading: const Text(
                              'Cores Pré-definidas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subheading: const Text(
                              'Cores Recentes',
                              style: TextStyle(fontSize: 14),
                            ),
                            wheelSubheading: const Text(
                              'Roda de Cores',
                              style: TextStyle(fontSize: 14),
                            ),
                            showMaterialName: true,
                            showColorName: true,
                            showColorCode: true,
                            copyPasteBehavior:
                                const ColorPickerCopyPasteBehavior(
                                  longPressMenu: true,
                                ),
                            materialNameTextStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            colorNameTextStyle: const TextStyle(fontSize: 12),
                            colorCodeTextStyle: const TextStyle(fontSize: 11),
                            pickersEnabled: const <ColorPickerType, bool>{
                              ColorPickerType.both: false,
                              ColorPickerType.primary: true,
                              ColorPickerType.accent: true,
                              ColorPickerType.bw: false,
                              ColorPickerType.custom: true,
                              ColorPickerType.wheel: true,
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    if (newColor != null) {
                      setDialogState(() {
                        _selectedColor = newColor;
                      });
                    }
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.palette, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Clique para escolher cor',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                if (_nomeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nome da disciplina é obrigatório'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _apiService.updateDisciplina(
                    id: disciplina['id'],
                    nome: _nomeController.text,
                    descricao: _descricaoController.text,
                    cor: _colorToHexRGB(_selectedColor),
                  );

                  if (!context.mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Disciplina atualizada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  _loadDisciplinas();
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao atualizar disciplina: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDisciplina(Map<String, dynamic> disciplina) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a disciplina "${disciplina['nome']}"?\n\n'
          'Esta ação não pode ser desfeita e todos os dados relacionados serão perdidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.deleteDisciplina(disciplina['id']);

                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Disciplina excluída com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );

                _loadDisciplinas();
              } catch (e) {
                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir disciplina: $e'),
                    backgroundColor: Colors.red,
                  ),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disciplinas',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie suas disciplinas e veja os detalhes de cada uma',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar disciplinas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddDisciplinaDialog,
                icon: const Icon(Icons.add),
                label: const Text('Nova Disciplina'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar disciplinas',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDisciplinas,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                : _disciplinas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma disciplina cadastrada',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Clique em "Nova Disciplina" para começar',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: _getCardAspectRatio(context),
                    ),
                    itemCount: _disciplinas.length,
                    itemBuilder: (context, index) {
                      final disciplina = _disciplinas[index];
                      final cor = _parseColor(disciplina['cor'] ?? '#2196F3');

                      return _buildDisciplinaCard(
                        disciplina['nome'] ?? 'Sem nome',
                        disciplina['descricao'] ?? 'Sem descrição',
                        cor,
                        disciplina,
                      );
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
    // More conservative (taller) aspect ratios to prevent overflow
    if (width > 1400) return 1.0;
    if (width > 1100) return 0.95;
    if (width > 800) return 0.9;
    if (width > 600) return 0.85;
    // Telas muito estreitas (Galaxy Fold, etc)
    if (width < 350) return 2.5;
    // Mobile normal: cards retangulares horizontais
    return 2.0;
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  Widget _buildDisciplinaCard(
    String nome,
    String descricao,
    Color cor,
    Map<String, dynamic> disciplina,
  ) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaDetalhesDisciplinaProfessor(
                subjectName: nome,
                subjectColor: cor,
                disciplinaId: disciplina['id'],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: isVerySmall ? 20 : 24,
                          ),
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
                                  Icon(Icons.delete, size: 20),
                                  SizedBox(width: 8),
                                  Text('Excluir'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDisciplinaDialog(disciplina);
                            } else if (value == 'delete') {
                              _confirmDeleteDisciplina(disciplina);
                            }
                          },
                        ),
                      ],
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
                    if (!isVerySmall) ...[
                      SizedBox(height: spacing / 2),
                      Expanded(
                        child: Text(
                          descricao,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: subtitleSize,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
