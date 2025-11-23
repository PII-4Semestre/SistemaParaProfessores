import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
}
