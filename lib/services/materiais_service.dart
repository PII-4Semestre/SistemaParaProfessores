import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:portal_polieduca/models/material.dart';

class MateriaisService {
  static const String baseUrl = 'http://localhost:8080/api/materiais';

  // Singleton pattern
  static final MateriaisService _instance = MateriaisService._internal();
  factory MateriaisService() => _instance;
  MateriaisService._internal();

  // Headers básicos
  Map<String, String> _headers() {
    return {'Content-Type': 'application/json'};
  }

  // GET /api/materiais - Listar todos os materiais
  Future<List<Material>> getMateriais() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Material.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar materiais: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar materiais: $e');
    }
  }

  // GET /api/materiais/disciplina/:id - Materiais por disciplina
  Future<List<Material>> getMateriaisPorDisciplina(String disciplinaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/disciplina/$disciplinaId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Material.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erro ao buscar materiais da disciplina: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar materiais da disciplina: $e');
    }
  }

  // GET /api/materiais/:id - Buscar material específico
  Future<Material> getMaterial(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Material.fromJson(data);
      } else {
        throw Exception('Erro ao buscar material: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar material: $e');
    }
  }

  // POST /api/materiais - Criar novo material
  Future<Material> criarMaterial({
    required String disciplinaId,
    required String professorId,
    required String titulo,
    String? descricao,
    String tipo = 'documento',
    List<String>? tags,
    String? linkExterno,
  }) async {
    try {
      final body = {
        'disciplina_id': disciplinaId,
        'professor_id': professorId,
        'titulo': titulo,
        if (descricao != null) 'descricao': descricao,
        'tipo': tipo,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        if (linkExterno != null) 'link_externo': linkExterno,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers(),
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Material.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erro ao criar material');
      }
    } catch (e) {
      throw Exception('Erro ao criar material: $e');
    }
  }

  // PUT /api/materiais/:id - Atualizar material
  Future<Material> atualizarMaterial({
    required String id,
    String? titulo,
    String? descricao,
    String? tipo,
    List<String>? tags,
    String? linkExterno,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (titulo != null) body['titulo'] = titulo;
      if (descricao != null) body['descricao'] = descricao;
      if (tipo != null) body['tipo'] = tipo;
      if (tags != null) body['tags'] = tags;
      if (linkExterno != null) body['link_externo'] = linkExterno;

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: _headers(),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Material.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erro ao atualizar material');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar material: $e');
    }
  }

  // DELETE /api/materiais/:id - Deletar material (soft delete)
  Future<void> deletarMaterial(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: _headers(),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erro ao deletar material');
      }
    } catch (e) {
      throw Exception('Erro ao deletar material: $e');
    }
  }

  // POST /api/materiais/:id/arquivo - Upload de arquivo
  Future<Map<String, dynamic>> uploadArquivo({
    required String materialId,
    required File arquivo,
    required String nomeOriginal,
    required String mimeType,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$materialId/arquivo'),
      );

      // Adiciona o arquivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'arquivo',
          arquivo.path,
          filename: nomeOriginal,
        ),
      );

      // Adiciona campos adicionais
      request.fields['nome_original'] = nomeOriginal;
      request.fields['mime_type'] = mimeType;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erro ao fazer upload do arquivo');
      }
    } catch (e) {
      throw Exception('Erro ao fazer upload do arquivo: $e');
    }
  }

  // GET /api/materiais/arquivo/:fileId - Download de arquivo
  Future<Uint8List> downloadArquivo(String fileId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arquivo/$fileId'),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Erro ao baixar arquivo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao baixar arquivo: $e');
    }
  }

  // Método auxiliar para obter informações do arquivo sem baixá-lo
  Future<Map<String, String>> getInfoArquivo(String fileId) async {
    try {
      final response = await http.head(
        Uri.parse('$baseUrl/arquivo/$fileId'),
      );

      if (response.statusCode == 200) {
        return {
          'content-type': response.headers['content-type'] ?? 'application/octet-stream',
          'content-length': response.headers['content-length'] ?? '0',
          'content-disposition': response.headers['content-disposition'] ?? '',
        };
      } else {
        throw Exception('Erro ao obter informações do arquivo');
      }
    } catch (e) {
      throw Exception('Erro ao obter informações do arquivo: $e');
    }
  }
}
