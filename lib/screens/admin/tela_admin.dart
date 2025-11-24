
import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../services/api_service.dart';
import '../autenticacao/tela_login.dart';


class TelaAdmin extends StatefulWidget {
  const TelaAdmin({super.key});

  @override
  State<TelaAdmin> createState() => _TelaAdminState();
}

class _TelaAdminState extends State<TelaAdmin> {
    void _showCreateUserDialog(TipoUsuario tipo) {
      final nomeController = TextEditingController();
      final emailController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          bool isCreating = false;
          return StatefulBuilder(builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Criar ${tipo == TipoUsuario.aluno ? 'Aluno' : 'Professor'}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                ],
              ),
              actions: isCreating
                  ? [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    ]
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final nome = nomeController.text.trim();
                          final email = emailController.text.trim();
                          if (nome.isEmpty || email.isEmpty) return;
                          try {
                            setStateDialog(() => isCreating = true);
                            final api = ApiService();
                            await api.createUsuario(
                              nome: nome,
                              email: email,
                              tipo: tipo.name,
                            );
                            if (mounted) {
                              setState(() {
                                _usuariosFuture = _fetchUsuarios();
                              });
                            }
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Usuário criado com sucesso')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao criar usuário: $e')),
                            );
                          } finally {
                            if (mounted) setStateDialog(() => isCreating = false);
                          }
                        },
                        child: const Text('Criar'),
                      ),
                    ],
            );
          });
        },
      );
    }
  // ...existing code...
  late Future<List<Usuario>> _usuariosFuture;
  List<Usuario>? _cachedUsuarios;
  final Set<String> _deletingIds = {};

  void _showUndoSnackBar(Usuario deleted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deleted.nome} removido'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () async {
            try {
              final api = ApiService();
              final created = await api.createUsuario(
                nome: deleted.nome,
                email: deleted.email,
                tipo: deleted.tipo.name,
              );
              final restored = Usuario.fromJson(created);
              if (_cachedUsuarios != null) {
                setState(() {
                  _cachedUsuarios!.insert(0, restored);
                });
              } else {
                if (mounted) setState(() => _usuariosFuture = _fetchUsuarios());
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remoção desfeita')));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao desfazer: $e')));
            }
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _usuariosFuture = _fetchUsuarios();
  }

  Future<List<Usuario>> _fetchUsuarios() async {
    final api = ApiService();
    final data = await api.getUsuarios();
    final list = data.map<Usuario>((u) => Usuario.fromJson(u)).toList();
    _cachedUsuarios = list;
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0820),
      appBar: AppBar(
        backgroundColor: const Color(0xFF170C2F),
        title: const Text('Administração de Usuários', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              final api = ApiService();
              await api.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TelaLogin()));
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final usuarios = _cachedUsuarios ?? (snapshot.data ?? []);
          final alunos = usuarios.where((u) => u.tipo == TipoUsuario.aluno).toList();
          final professores = usuarios.where((u) => u.tipo == TipoUsuario.professor).toList();

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Alunos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BCD4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Adicionar Aluno'),
                        onPressed: () => _showCreateUserDialog(TipoUsuario.aluno),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: alunos.length,
                        itemBuilder: (context, index) {
                          final aluno = alunos[index];
                          return ListTile(
                            leading: const Icon(Icons.school, color: Colors.white),
                            title: Text(aluno.nome, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(aluno.email, style: const TextStyle(color: Colors.white70)),
                            trailing: _deletingIds.contains(aluno.id)
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                : IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    tooltip: 'Remover Aluno',
                                    onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar remoção'),
                                    content: Text('Remover ${aluno.nome}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                                      ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Remover')),
                                    ],
                                  ),
                                );
                                if (confirm != true) return;
                                setState(() => _deletingIds.add(aluno.id));
                                try {
                                  final api = ApiService();
                                  await api.deleteUsuario(aluno.id);
                                  if (_cachedUsuarios != null) {
                                    final deleted = aluno;
                                    setState(() {
                                      _cachedUsuarios!.removeWhere((u) => u.id == aluno.id);
                                    });
                                    _showUndoSnackBar(deleted);
                                  } else {
                                    if (mounted) setState(() => _usuariosFuture = _fetchUsuarios());
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao remover aluno: $e')));
                                } finally {
                                  setState(() => _deletingIds.remove(aluno.id));
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Professores', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BCD4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Adicionar Professor'),
                        onPressed: () => _showCreateUserDialog(TipoUsuario.professor),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: professores.length,
                        itemBuilder: (context, index) {
                          final prof = professores[index];
                          return ListTile(
                            leading: const Icon(Icons.person, color: Colors.white),
                            title: Text(prof.nome, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(prof.email, style: const TextStyle(color: Colors.white70)),
                            trailing: _deletingIds.contains(prof.id)
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                : IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    tooltip: 'Remover Professor',
                                    onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar remoção'),
                                    content: Text('Remover ${prof.nome}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                                      ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Remover')),
                                    ],
                                  ),
                                );
                                if (confirm != true) return;
                                setState(() => _deletingIds.add(prof.id));
                                try {
                                  final api = ApiService();
                                  await api.deleteUsuario(prof.id);
                                  if (_cachedUsuarios != null) {
                                    final deleted = prof;
                                    setState(() {
                                      _cachedUsuarios!.removeWhere((u) => u.id == prof.id);
                                    });
                                    _showUndoSnackBar(deleted);
                                  } else {
                                    if (mounted) setState(() => _usuariosFuture = _fetchUsuarios());
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao remover professor: $e')));
                                } finally {
                                  setState(() => _deletingIds.remove(prof.id));
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
