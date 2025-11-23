import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mensagem.dart';

class MensagensService {
  static const String baseUrl = 'http://localhost:8080/api/mensagens';

  // Singleton pattern
  static final MensagensService _instance = MensagensService._internal();
  factory MensagensService() => _instance;
  MensagensService._internal();

  Map<String, String> _headers() {
    return {'Content-Type': 'application/json'};
  }

  // Listar conversas de um usuário
  Future<List<dynamic>> getConversas(String usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversas/$usuarioId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Erro ao carregar conversas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar conversas: $e');
    }
  }

  // Listar mensagens entre dois usuários
  Future<List<Mensagem>> getMensagens(String usuarioId, String outroUsuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$usuarioId/$outroUsuarioId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Mensagem.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar mensagens: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar mensagens: $e');
    }
  }

  // Enviar mensagem
  Future<Mensagem> enviarMensagem({
    required String remetenteId,
    required String destinatarioId,
    required String conteudo,
    String? replyToId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers(),
        body: json.encode({
          'remetenteId': remetenteId,
          'destinatarioId': destinatarioId,
          'conteudo': conteudo,
          if (replyToId != null) 'replyToId': replyToId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Mensagem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erro ao enviar mensagem: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }

  // Editar mensagem
  Future<Mensagem> editarMensagem(String mensagemId, String novoConteudo) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$mensagemId'),
        headers: _headers(),
        body: json.encode({'conteudo': novoConteudo}),
      );

      if (response.statusCode == 200) {
        return Mensagem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erro ao editar mensagem: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao editar mensagem: $e');
    }
  }

  // Deletar mensagem
  Future<void> deletarMensagem(String mensagemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$mensagemId'),
        headers: _headers(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao deletar mensagem: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar mensagem: $e');
    }
  }

  // Adicionar reação
  Future<void> adicionarReacao(String mensagemId, String emoji) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$mensagemId/reacoes'),
        headers: _headers(),
        body: json.encode({'emoji': emoji}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erro ao adicionar reação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao adicionar reação: $e');
    }
  }

  // Remover reação
  Future<void> removerReacao(String mensagemId, String emoji) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$mensagemId/reacoes/$emoji'),
        headers: _headers(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao remover reação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao remover reação: $e');
    }
  }

  // Marcar mensagem como lida
  Future<void> marcarComoLida(String mensagemId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$mensagemId/lida'),
        headers: _headers(),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao marcar como lida: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao marcar como lida: $e');
    }
  }

  // Marcar mensagem como não lida
  Future<void> marcarComoNaoLida(String mensagemId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$mensagemId/nao-lida'),
        headers: _headers(),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao marcar como não lida: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao marcar como não lida: $e');
    }
  }
}
