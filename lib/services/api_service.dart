import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// imports cleaned: moved model imports to callers to avoid circular/unused imports
class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  String? _token;
  Map<String, dynamic>? _currentUser;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Getters
  String? get token => _token;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null && _currentUser != null;

  // Initialize - load saved token/user
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _currentUser = json.decode(userJson);
    }
  }

  // Save login data
  Future<void> _saveLoginData(String token, Map<String, dynamic> user) async {
    _token = token;
    _currentUser = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', json.encode(user));
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Headers
  Map<String, String> _headers({bool needsAuth = false}) {
    final headers = {'Content-Type': 'application/json'};

    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // AUTH ENDPOINTS

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: json.encode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveLoginData(data['token'], data['user']);
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erro ao fazer login');
    }
  }

  // DISCIPLINAS ENDPOINTS

  Future<List<dynamic>> getDisciplinas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/disciplinas'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar disciplinas');
    }
  }

  Future<List<dynamic>> getDisciplinasProfessor(int professorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/disciplinas/professor/$professorId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar disciplinas do professor');
    }
  }

  Future<Map<String, dynamic>> createDisciplina({
    required String nome,
    required String descricao,
    required int professorId,
    String cor = '#FF9800',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/disciplinas'),
      headers: _headers(needsAuth: true),
      body: json.encode({
        'nome': nome,
        'descricao': descricao,
        'professor_id': professorId,
        'cor': cor,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao criar disciplina');
    }
  }

  Future<Map<String, dynamic>> updateDisciplina({
    required int id,
    required String nome,
    required String descricao,
    required String cor,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/disciplinas/$id'),
      headers: _headers(needsAuth: true),
      body: json.encode({'nome': nome, 'descricao': descricao, 'cor': cor}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao atualizar disciplina');
    }
  }

  Future<void> deleteDisciplina(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/disciplinas/$id'),
      headers: _headers(needsAuth: true),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar disciplina');
    }
  }

  // ATIVIDADES ENDPOINTS
  Future<List<dynamic>> getAtividadesDisciplina(int disciplinaId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/atividades/disciplina/$disciplinaId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar atividades');
    }
  }

  Future<Map<String, dynamic>> createAtividade({
    required int disciplinaId,
    required String titulo,
    required String descricao,
    required double peso,
    required String dataEntrega,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/atividades'),
      headers: _headers(needsAuth: true),
      body: json.encode({
        'disciplina_id': disciplinaId,
        'titulo': titulo,
        'descricao': descricao,
        'peso': peso,
        'data_entrega': dataEntrega,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao criar atividade');
    }
  }

  Future<Map<String, dynamic>> updateAtividade({
    required int id,
    required String titulo,
    required String descricao,
    required double peso,
    required String dataEntrega,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/atividades/$id'),
      headers: _headers(needsAuth: true),
      body: json.encode({
        'titulo': titulo,
        'descricao': descricao,
        'peso': peso,
        'data_entrega': dataEntrega,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao atualizar atividade');
    }
  }

  Future<void> deleteAtividade(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/atividades/$id'),
      headers: _headers(needsAuth: true),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar atividade');
    }
  }

  // NOTAS ENDPOINTS

  Future<List<dynamic>> getNotasAluno(int alunoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notas/aluno/$alunoId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar notas');
    }
  }

  Future<Map<String, dynamic>> atribuirNota({
    required int atividadeId,
    required int alunoId,
    required double nota,
    String? comentario,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notas'),
      headers: _headers(needsAuth: true),
      body: json.encode({
        'atividade_id': atividadeId,
        'aluno_id': alunoId,
        'nota': nota,
        'comentario': comentario,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao atribuir nota');
    }
  }

  // ALUNOS ENDPOINTS

  Future<List<dynamic>> getTodosAlunos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/alunos'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar alunos');
    }
  }

  Future<List<dynamic>> getDisciplinasAluno(int alunoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alunos/$alunoId/disciplinas'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar disciplinas do aluno');
    }
  }

  Future<List<dynamic>> getAlunosDisciplina(int disciplinaId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alunos/disciplina/$disciplinaId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar alunos da disciplina');
    }
  }

  Future<List<dynamic>> getAlunosDisponiveis(int disciplinaId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alunos/disponiveis/$disciplinaId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar alunos disponíveis');
    }
  }

  Future<Map<String, dynamic>> matricularAluno({
    required int alunoId,
    required int disciplinaId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alunos/matricular'),
      headers: _headers(needsAuth: true),
      body: json.encode({'aluno_id': alunoId, 'disciplina_id': disciplinaId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao matricular aluno');
    }
  }

  Future<void> desmatricularAluno({
    required int alunoId,
    required int disciplinaId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/alunos/desmatricular'),
      headers: _headers(needsAuth: true),
      body: json.encode({'aluno_id': alunoId, 'disciplina_id': disciplinaId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover aluno da disciplina');
    }
  }

  // USUÁRIOS ENDPOINTS

  Future<Map<String, dynamic>> getUsuario(String usuarioId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/$usuarioId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar dados do usuário');
    }
  }

  Future<List<dynamic>> getUsuarios() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar lista de usuários');
    }
  }

  // Criar usuário (admin usa endpoint protegido)
  Future<Map<String, dynamic>> createUsuario({
    required String nome,
    required String email,
    String? senha,
    required String tipo, // 'aluno' or 'professor'
  }) async {
    final body = <String, dynamic>{
      'nome': nome,
      'email': email,
      'tipo': tipo,
    };
    if (senha != null && senha.isNotEmpty) {
      body['senha'] = senha;
    }

    final uri = Uri.parse('$baseUrl/usuarios');
    final requestBody = json.encode(body);
    try {
      print('CLIENT: POST $uri');
      print('CLIENT: Headers: ${_headers(needsAuth: true)}');
      print('CLIENT: Body: $requestBody');
    } catch (_) {}

    final response = await http.post(
      uri,
      headers: _headers(needsAuth: true),
      body: requestBody,
    );

    try {
      print('CLIENT: Response status=${response.statusCode} body=${response.body}');
    } catch (_) {}

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }

    // If the admin-protected endpoint is not available (404), fall back to the public
    // register endpoint so the front can create users while admin route is missing.
    if (response.statusCode == 404) {
      try {
        final registerUri = Uri.parse('$baseUrl/auth/register');
        print('CLIENT: Falling back to $registerUri');
        // Ensure senha is present for the public register endpoint (schema requires senha_hash NOT NULL)
        final regBodyMap = json.decode(requestBody) as Map<String, dynamic>;
        if (regBodyMap['senha'] == null) regBodyMap['senha'] = '';
        final regRequestBody = json.encode(regBodyMap);
        final regResp = await http.post(
          registerUri,
          headers: {'Content-Type': 'application/json'},
          body: regRequestBody,
        );
        print('CLIENT: Fallback response status=${regResp.statusCode} body=${regResp.body}');
        if (regResp.statusCode == 200 || regResp.statusCode == 201) {
          return json.decode(regResp.body);
        }
        try {
          final err = json.decode(regResp.body);
          throw Exception(err['error'] ?? 'Erro ao criar usuário (register)');
        } catch (_) {
          throw Exception('Erro ao criar usuário (register): ${regResp.statusCode} - ${regResp.body}');
        }
      } catch (e) {
        throw Exception('Erro ao criar usuário (fallback): $e');
      }
    }

    // Try to decode error safely; some endpoints may return plain text
    try {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erro ao criar usuário');
    } catch (_) {
      throw Exception('Erro ao criar usuário: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteUsuario(String usuarioId) async {
    final uri = Uri.parse('$baseUrl/usuarios/$usuarioId');
    try {
      print('CLIENT: DELETE $uri');
    } catch (_) {}

    final response = await http.delete(
      uri,
      headers: _headers(needsAuth: true),
    );

    try {
      print('CLIENT: DELETE response status=${response.statusCode} body=${response.body}');
    } catch (_) {}

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    try {
      final err = json.decode(response.body);
      throw Exception(err['error'] ?? 'Erro ao deletar usuário');
    } catch (_) {
      throw Exception('Erro ao deletar usuário: ${response.statusCode} - ${response.body}');
    }
  }

  // MENSAGENS ENDPOINTS

  Future<List<dynamic>> getConversas(int usuarioId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mensagens/conversas/$usuarioId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar conversas');
    }
  }

  Future<List<dynamic>> getMensagens({
    required int usuarioId,
    required int outroUsuarioId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mensagens/$usuarioId/$outroUsuarioId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar mensagens');
    }
  }

  Future<Map<String, dynamic>> enviarMensagem({
    required int remetenteId,
    required int destinatarioId,
    required String conteudo,
    int? disciplinaId,
    String? respostaParaId,
    dynamic attachment,
  }) async {
    final Map<String, dynamic> body = {
      'remetenteId': remetenteId.toString(),
      'destinatarioId': destinatarioId.toString(),
      'conteudo': conteudo,
    };
    if (disciplinaId != null) body['disciplinaId'] = disciplinaId.toString();
    if (respostaParaId != null) body['respostaParaId'] = respostaParaId;
    if (attachment != null) {
      // support both AttachedFile objects and plain maps
      final anexo = (attachment is Map)
          ? attachment
          : {
              'name': attachment.name,
              'type': attachment.type,
              'size': attachment.size,
              'url': attachment.url,
            };
      body['anexo'] = anexo;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/mensagens'),
      headers: _headers(needsAuth: true),
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao enviar mensagem');
    }
  }

  Future<void> marcarMensagemComoLida(String mensagemId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/mensagens/$mensagemId/lida'),
      headers: _headers(needsAuth: true),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao marcar mensagem como lida');
    }
  }

  // Marcar todas as mensagens de uma conversa como lidas
  Future<void> marcarConversaComoLida({
    required int usuarioId,
    required int outroUsuarioId,
  }) async {
    // MongoDB: marcar cada mensagem individualmente (a ser implementado se necessário)
    // Por enquanto, não faz nada pois o endpoint não existe
    return;
  }

  Future<void> deletarMensagem(String mensagemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/mensagens/$mensagemId'),
      headers: _headers(needsAuth: true),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar mensagem');
    }
  }

  Future<Map<String, dynamic>> editarMensagem({
    required String mensagemId,
    required String novoConteudo,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/mensagens/$mensagemId'),
      headers: _headers(needsAuth: true),
      body: json.encode({'conteudo': novoConteudo}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao editar mensagem');
    }
  }

  Future<int> contarMensagensNaoLidas(int usuarioId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mensagens/nao-lidas/$usuarioId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['count'] ?? 0;
    } else {
      throw Exception('Erro ao contar mensagens não lidas');
    }
  }

  Future<void> adicionarReacao({
    required String mensagemId,
    required String emoji,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mensagens/$mensagemId/reacoes'),
      headers: _headers(needsAuth: true),
      body: json.encode({'emoji': emoji}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao adicionar reação');
    }
  }

  Future<void> removerReacao({
    required String mensagemId,
    required String emoji,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/mensagens/$mensagemId/reacoes/$emoji'),
      headers: _headers(needsAuth: true),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover reação');
    }
  }
}
