import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:portal_polieduca/models/atividade.dart';

class AtividadesService {
  static const String baseUrl = 'http://localhost:8080/api/atividades';

  // Singleton pattern
  static final AtividadesService _instance = AtividadesService._internal();
  factory AtividadesService() => _instance;
  AtividadesService._internal();

  Map<String, String> _headers() {
    return {'Content-Type': 'application/json'};
  }

  // GET /api/atividades/disciplina/:id - Listar atividades de uma disciplina
  Future<List<Atividade>> getAtividadesDisciplina(String disciplinaId) async {
    try {
      print('[AtividadesService] Buscando atividades da disciplina: $disciplinaId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/disciplina/$disciplinaId'),
        headers: _headers(),
      );

      print('[AtividadesService] Status: ${response.statusCode}');
      print('[AtividadesService] Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body == 'null') {
          print('[AtividadesService] Resposta vazia, retornando lista vazia');
          return [];
        }
        
        final List<dynamic> data = json.decode(response.body);
        print('[AtividadesService] Dados recebidos: ${data.length} atividades');
        
        if (data.isEmpty) {
          return [];
        }
        
        print('[AtividadesService] Primeiro item: ${data[0]}');
        
        final atividades = <Atividade>[];
        for (var i = 0; i < data.length; i++) {
          try {
            print('[AtividadesService] Processando atividade $i: ${data[i]}');
            final atividade = Atividade.fromJson(data[i]);
            atividades.add(atividade);
          } catch (e) {
            print('[AtividadesService] ERRO ao processar atividade $i: $e');
            print('[AtividadesService] JSON problemático: ${data[i]}');
          }
        }
        
        return atividades;
      } else {
        throw Exception('Erro ao buscar atividades: ${response.statusCode}');
      }
    } catch (e) {
      print('[AtividadesService] Erro: $e');
      throw Exception('Erro ao buscar atividades: $e');
    }
  }

  // POST /api/atividades - Criar nova atividade
  Future<Atividade> criarAtividade({
    required String titulo,
    required String descricao,
    required String disciplinaId,
    required double peso,
    required DateTime dataEntrega,
  }) async {
    try {
      print('[AtividadesService] Criando atividade: $titulo');
      print('[AtividadesService] disciplinaId: $disciplinaId (${disciplinaId.runtimeType})');

      final body = json.encode({
        'titulo': titulo,
        'descricao': descricao,
        'disciplina_id': disciplinaId, // Backend espera snake_case
        'peso': peso,
        'data_entrega': dataEntrega.toIso8601String(), // Backend espera snake_case
      });

      print('[AtividadesService] Body enviado: $body');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers(),
        body: body,
      );

      print('[AtividadesService] Status: ${response.statusCode}');
      print('[AtividadesService] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return Atividade.fromJson(data);
      } else {
        throw Exception('Erro ao criar atividade: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[AtividadesService] Erro: $e');
      throw Exception('Erro ao criar atividade: $e');
    }
  }

  // PUT /api/atividades/:id - Atualizar atividade
  Future<Atividade> atualizarAtividade({
    required String id,
    required String titulo,
    required String descricao,
    required double peso,
    required DateTime dataEntrega,
  }) async {
    try {
      print('[AtividadesService] Atualizando atividade: $id');

      final body = json.encode({
        'titulo': titulo,
        'descricao': descricao,
        'peso': peso,
        'dataEntrega': dataEntrega.toIso8601String(),
      });

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: _headers(),
        body: body,
      );

      print('[AtividadesService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Atividade.fromJson(data);
      } else {
        throw Exception('Erro ao atualizar atividade: ${response.statusCode}');
      }
    } catch (e) {
      print('[AtividadesService] Erro: $e');
      throw Exception('Erro ao atualizar atividade: $e');
    }
  }

  // DELETE /api/atividades/:id - Deletar atividade
  Future<void> deletarAtividade(String id) async {
    try {
      print('[AtividadesService] Deletando atividade: $id');

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers(),
      );

      print('[AtividadesService] Status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao deletar atividade: ${response.statusCode}');
      }
    } catch (e) {
      print('[AtividadesService] Erro: $e');
      throw Exception('Erro ao deletar atividade: $e');
    }
  }

  // GET /api/atividades/:id/submissoes - Listar submissões de uma atividade
  Future<List<SubmissaoAtividade>> getSubmissoes(String atividadeId) async {
    try {
      print('[AtividadesService] Buscando submissões da atividade: $atividadeId');

      final response = await http.get(
        Uri.parse('$baseUrl/$atividadeId/submissoes'),
        headers: _headers(),
      );

      print('[AtividadesService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SubmissaoAtividade.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar submissões: ${response.statusCode}');
      }
    } catch (e) {
      print('[AtividadesService] Erro: $e');
      throw Exception('Erro ao buscar submissões: $e');
    }
  }

  // POST /api/atividades/:id/submissoes - Criar/atualizar submissão (aluno)
  Future<SubmissaoAtividade> submeterAtividade({
    required String atividadeId,
    required String alunoId,
    required String alunoNome,
    required List<Uint8List> arquivosBytes,
    required List<String> arquivosNomes,
    String? comentario,
  }) async {
    try {
      print('[AtividadesService] Submetendo atividade: $atividadeId');
      print('[AtividadesService] URL: $baseUrl/$atividadeId/submissoes');
      print('[AtividadesService] Aluno: $alunoId - $alunoNome');
      print('[AtividadesService] Arquivos: ${arquivosNomes.length}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$atividadeId/submissoes'),
      );

      // Adiciona campos
      request.fields['alunoId'] = alunoId;
      request.fields['alunoNome'] = alunoNome;
      if (comentario != null && comentario.isNotEmpty) {
        request.fields['comentario'] = comentario;
      }
      
      print('[AtividadesService] Campos adicionados: ${request.fields}');

      // Adiciona arquivos
      for (int i = 0; i < arquivosBytes.length; i++) {
        print('[AtividadesService] Adicionando arquivo: ${arquivosNomes[i]} (${arquivosBytes[i].length} bytes)');
        request.files.add(
          http.MultipartFile.fromBytes(
            'arquivos',
            arquivosBytes[i],
            filename: arquivosNomes[i],
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('[AtividadesService] Status: ${response.statusCode}');
      print('[AtividadesService] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return SubmissaoAtividade.fromJson(data);
      } else {
        throw Exception('Erro ao submeter atividade: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[AtividadesService] Erro: $e');
      throw Exception('Erro ao submeter atividade: $e');
    }
  }

  // PUT /api/atividades/:id/submissoes/:submissaoId/avaliar - Avaliar submissão (professor)
  Future<SubmissaoAtividade> avaliarSubmissao({
    required String atividadeId,
    required String submissaoId,
    required double nota,
    String? feedback,
  }) async {
    try {
      print('[AtividadesService] Avaliando submissão: $submissaoId');

      final body = json.encode({
        'nota': nota,
        if (feedback != null) 'feedback': feedback,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/submissoes/$submissaoId/avaliar'),
        headers: _headers(),
        body: body,
      );

      print('[AtividadesService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SubmissaoAtividade.fromJson(data);
      } else {
        throw Exception('Erro ao avaliar submissão: ${response.statusCode}');
      }
    } catch (e) {
      print('[AtividadesService] Erro: $e');
      throw Exception('Erro ao avaliar submissão: $e');
    }
  }

  // GET /api/atividades/:id/submissoes/aluno/:alunoId - Buscar submissão de um aluno específico
  Future<SubmissaoAtividade?> getSubmissaoAluno({
    required String atividadeId,
    required String alunoId,
  }) async {
    try {
      print('[AtividadesService] Buscando submissão do aluno $alunoId na atividade $atividadeId');

      final response = await http.get(
        Uri.parse('$baseUrl/$atividadeId/submissoes/$alunoId'),
        headers: _headers(),
      );

      print('[AtividadesService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SubmissaoAtividade.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Aluno ainda não submeteu
      } else {
        throw Exception('Erro ao buscar submissão: ${response.statusCode}');
      }
    } catch (e) {
      print('[AtividadesService] Erro: $e');
      return null; // Se der erro, considera que não foi submetido
    }
  }

  // GET /api/atividades/submissoes/arquivo/:arquivoId - Download de arquivo
  Future<Uint8List> downloadArquivo(String arquivoId) async {
    try {
      print('[AtividadesService] Baixando arquivo: $arquivoId');

      final response = await http.get(
        Uri.parse('$baseUrl/submissoes/arquivo/$arquivoId'),
      );

      print('[AtividadesService] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Erro ao baixar arquivo: ${response.statusCode}');
      }
    } catch (e) {
      print('[AtividadesService] Erro: $e');
      throw Exception('Erro ao baixar arquivo: $e');
    }
  }
}
