import 'dart:convert';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:sistema_professores_server/database/database.dart';
import 'package:sistema_professores_server/database/mongodb.dart';

class AtividadesRoutes {
  Router get router {
    final router = Router();

    // GET /api/atividades/disciplina/<id> - Atividades de uma disciplina
    router.get('/disciplina/<id>', (Request request, String id) async {
      try {
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          'SELECT id, disciplina_id, titulo, descricao, peso, data_entrega, criado_em, atualizado_em FROM atividades WHERE disciplina_id = \$1 ORDER BY data_entrega',
          parameters: [int.parse(id)],
        );

        final atividades = result
            .map(
              (row) => {
                'id': row[0],
                'disciplina_id': row[1],
                'titulo': row[2],
                'descricao': row[3],
                'peso': row[4],
                'data_entrega': row[5]?.toString(),
                'criado_em': row[6]?.toString(),
                'atualizado_em': row[7]?.toString(),
              },
            )
            .toList();

        return Response.ok(
          json.encode(atividades),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar atividades: $e'}),
        );
      }
    });

    // POST /api/atividades - Criar nova atividade
    router.post('/', (Request request) async {
      try {
        final payload = json.decode(await request.readAsString());

        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          INSERT INTO atividades (disciplina_id, titulo, descricao, peso, data_entrega)
          VALUES (\$1, \$2, \$3, \$4, \$5)
          RETURNING id, disciplina_id, titulo, descricao, peso, data_entrega, criado_em, atualizado_em
          ''',
          parameters: [
            payload['disciplina_id'],
            payload['titulo'],
            payload['descricao'],
            payload['peso'] ?? 1.0,
            payload['data_entrega'],
          ],
        );

        final row = result.first;
        return Response.ok(
          json.encode({
            'id': row[0],
            'disciplina_id': row[1],
            'titulo': row[2],
            'descricao': row[3],
            'peso': row[4],
            'data_entrega': row[5]?.toString(),
            'criado_em': row[6]?.toString(),
            'atualizado_em': row[7]?.toString(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao criar atividade: $e'}),
        );
      }
    });

    // PUT /api/atividades/<id> - Atualizar atividade
    router.put('/<id>', (Request request, String id) async {
      try {
        final payload = json.decode(await request.readAsString());

        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          UPDATE atividades
          SET titulo = \$1, descricao = \$2, peso = \$3, data_entrega = \$4
          WHERE id = \$5
          RETURNING id, disciplina_id, titulo, descricao, peso, data_entrega, criado_em, atualizado_em
          ''',
          parameters: [
            payload['titulo'],
            payload['descricao'],
            payload['peso'] ?? 1.0,
            payload['data_entrega'],
            int.parse(id),
          ],
        );

        if (result.isEmpty) {
          return Response.notFound(
            json.encode({'error': 'Atividade não encontrada'}),
          );
        }

        final row = result.first;
        return Response.ok(
          json.encode({
            'id': row[0],
            'disciplina_id': row[1],
            'titulo': row[2],
            'descricao': row[3],
            'peso': row[4],
            'data_entrega': row[5]?.toString(),
            'criado_em': row[6]?.toString(),
            'atualizado_em': row[7]?.toString(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao atualizar atividade: $e'}),
        );
      }
    });

    // DELETE /api/atividades/<id> - Deletar atividade
    router.delete('/<id>', (Request request, String id) async {
      try {
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          'DELETE FROM atividades WHERE id = \$1 RETURNING id',
          parameters: [int.parse(id)],
        );

        if (result.isEmpty) {
          return Response.notFound(
            json.encode({'error': 'Atividade não encontrada'}),
          );
        }

        return Response.ok(
          json.encode({'message': 'Atividade deletada com sucesso'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao deletar atividade: $e'}),
        );
      }
    });

    // GET /api/atividades/<id>/submissoes - Listar todas as submissões de uma atividade
    router.get('/<id>/submissoes', (Request request, String id) async {
      try {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Buscando submissões da atividade: $id');

        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('submissoes_atividades');

        final submissoes = await collection.find(
          where.eq('atividade_id', int.parse(id)),
        ).toList();

        // Formatar as submissões
        final submissoesFormatadas = submissoes.map((s) {
          final submissao = Map<String, dynamic>.from(s);
          
          if (submissao['_id'] != null) {
            submissao['id'] = (submissao['_id'] as ObjectId).toHexString();
            submissao.remove('_id');
          }
          
          if (submissao['data_submissao'] is DateTime) {
            submissao['data_submissao'] = (submissao['data_submissao'] as DateTime).toIso8601String();
          }
          
          if (submissao['data_avaliacao'] is DateTime) {
            submissao['data_avaliacao'] = (submissao['data_avaliacao'] as DateTime).toIso8601String();
          }
          
          // Formatar arquivos
          if (submissao['arquivos'] is List) {
            submissao['arquivos'] = (submissao['arquivos'] as List).map((a) {
              final arquivo = Map<String, dynamic>.from(a);
              if (arquivo['data_upload'] is DateTime) {
                arquivo['data_upload'] = (arquivo['data_upload'] as DateTime).toIso8601String();
              }
              if (arquivo['grid_fs_id'] is ObjectId) {
                arquivo['grid_fs_id'] = (arquivo['grid_fs_id'] as ObjectId).toHexString();
              }
              return arquivo;
            }).toList();
          }
          
          return submissao;
        }).toList();

        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ✅ ${submissoesFormatadas.length} submissões encontradas');

        return Response.ok(
          json.encode(submissoesFormatadas),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, stack) {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ❌ Erro ao buscar submissões: $e');
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Stack: $stack');
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar submissões: $e'}),
        );
      }
    });

    // POST /api/atividades/<id>/submissoes - Criar/atualizar submissão de atividade
    router.post('/<id>/submissoes', (Request request, String id) async {
      try {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Upload de submissão iniciado para atividade: $id');
        
        // Ler todos os bytes do body
        final bodyBytes = await request.read().expand((chunk) => chunk).toList();
        final body = Uint8List.fromList(bodyBytes);
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Body recebido: ${body.length} bytes');
        
        // Pegar boundary do content-type
        final contentType = request.headers['content-type'] ?? '';
        final boundaryMatch = RegExp(r'boundary=(.+)$').firstMatch(contentType);
        if (boundaryMatch == null) {
          print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ❌ Boundary não encontrado');
          return Response.badRequest(
            body: json.encode({'error': 'Content-Type deve incluir boundary'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        final boundary = '--${boundaryMatch.group(1)}';
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Boundary: $boundary');
        
        // Variáveis para armazenar dados do formulário
        String? alunoId;
        String? alunoNome;
        String? comentario;
        final arquivos = <Map<String, dynamic>>[];
        
        // Parse multipart manualmente
        final boundaryBytes = utf8.encode(boundary);
        final boundaryBytesWithCrLf = utf8.encode('\r\n$boundary');
        final doubleCrLf = utf8.encode('\r\n\r\n');
        
        // Dividir body em partes - procurar por boundary com e sem \r\n
        final parts = <Uint8List>[];
        int start = 0;
        
        // Primeira parte pode começar direto com boundary (sem \r\n)
        bool firstPart = true;
        
        while (start < body.length) {
          int boundaryIndex = -1;
          final searchBytes = firstPart ? boundaryBytes : boundaryBytesWithCrLf;
          
          for (int i = start; i <= body.length - searchBytes.length; i++) {
            bool match = true;
            for (int j = 0; j < searchBytes.length; j++) {
              if (body[i + j] != searchBytes[j]) {
                match = false;
                break;
              }
            }
            if (match) {
              boundaryIndex = i;
              break;
            }
          }
          
          if (boundaryIndex == -1) break;
          
          if (!firstPart) {
            parts.add(Uint8List.fromList(body.sublist(start, boundaryIndex)));
          }
          
          start = boundaryIndex + searchBytes.length;
          firstPart = false;
        }
        
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Partes encontradas: ${parts.length}');
        
        final mongo = await MongoDB.getInstance();
        final gridFS = mongo.getGridFS();
        
        // Processar cada parte
        for (final partBytes in parts) {
          if (partBytes.isEmpty) continue;
          
          // Encontrar o fim dos headers
          int headerEnd = -1;
          for (int i = 0; i <= partBytes.length - doubleCrLf.length; i++) {
            bool match = true;
            for (int j = 0; j < doubleCrLf.length; j++) {
              if (partBytes[i + j] != doubleCrLf[j]) {
                match = false;
                break;
              }
            }
            if (match) {
              headerEnd = i;
              break;
            }
          }
          
          if (headerEnd == -1) continue;
          
          // Extrair headers
          final headerBytes = partBytes.sublist(0, headerEnd);
          final headerString = utf8.decode(headerBytes);
          final headerLines = headerString.split('\r\n');
          
          final headers = <String, String>{};
          for (final line in headerLines) {
            final colonIndex = line.indexOf(':');
            if (colonIndex > 0) {
              final key = line.substring(0, colonIndex).trim().toLowerCase();
              final value = line.substring(colonIndex + 1).trim();
              headers[key] = value;
            }
          }
          
          final contentDisposition = headers['content-disposition'] ?? '';
          print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Content-Disposition: $contentDisposition');
          final nameMatch = RegExp(r'name="([^"]+)"').firstMatch(contentDisposition);
          if (nameMatch == null) continue;
          final fieldName = nameMatch.group(1);
          print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Campo: $fieldName');
          
          // Extrair conteúdo
          final contentStart = headerEnd + doubleCrLf.length;
          final contentBytes = partBytes.sublist(contentStart);
          
          if (fieldName == 'alunoId') {
            alunoId = utf8.decode(contentBytes).trim();
            print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Aluno ID: $alunoId');
          } else if (fieldName == 'alunoNome') {
            alunoNome = utf8.decode(contentBytes).trim();
            print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Aluno Nome: $alunoNome');
          } else if (fieldName == 'comentario') {
            comentario = utf8.decode(contentBytes).trim();
            print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Comentário: $comentario');
          } else if (fieldName == 'arquivos') {
            // Arquivo
            final filenameMatch = RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
            if (filenameMatch != null) {
              final nomeOriginal = filenameMatch.group(1)!;
              final mimeType = headers['content-type'] ?? 'application/octet-stream';
              final fileBytes = contentBytes;
              
              print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Processando arquivo: $nomeOriginal (${fileBytes.length} bytes)');
              
              // Upload para GridFS
              final inputStream = Stream.fromIterable([fileBytes]);
              final gridIn = gridFS.createFile(inputStream, nomeOriginal);
              gridIn.contentType = mimeType;
              await gridIn.save();
              
              arquivos.add({
                'nome_original': nomeOriginal,
                'mime_type': mimeType,
                'tamanho': fileBytes.length,
                'grid_fs_id': gridIn.id,
                'data_upload': DateTime.now(),
              });
              
              print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ✅ Arquivo salvo no GridFS: ${gridIn.id.toHexString()}');
            }
          }
        }
        
        if (alunoId == null || alunoNome == null) {
          print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ❌ Faltando campos: alunoId=$alunoId, alunoNome=$alunoNome');
          print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ❌ Partes processadas: ${parts.length}');
          return Response.badRequest(
            body: json.encode({
              'error': 'alunoId e alunoNome são obrigatórios',
              'received_alunoId': alunoId,
              'received_alunoNome': alunoNome,
              'parts_count': parts.length,
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        if (arquivos.isEmpty) {
          return Response.badRequest(
            body: json.encode({'error': 'Pelo menos um arquivo deve ser enviado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        // Verificar se já existe submissão do aluno para esta atividade
        final collection = mongo.collection('submissoes_atividades');
        final submissaoExistente = await collection.findOne(
          where.eq('atividade_id', int.parse(id)).eq('aluno_id', int.parse(alunoId)),
        );
        
        if (submissaoExistente != null) {
          // Atualizar submissão existente
          await collection.updateOne(
            where.eq('atividade_id', int.parse(id)).eq('aluno_id', int.parse(alunoId)),
            modify
              .set('arquivos', arquivos)
              .set('data_submissao', DateTime.now())
              .set('comentario', comentario),
          );
          
          final submissaoId = (submissaoExistente['_id'] as ObjectId).toHexString();
          print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ✅ Submissão atualizada: $submissaoId');
          
          return Response.ok(
            json.encode({
              'id': submissaoId,
              'atividade_id': int.parse(id),
              'aluno_id': int.parse(alunoId),
              'aluno_nome': alunoNome,
              'arquivos': arquivos.map((a) => {
                'nome_original': a['nome_original'],
                'mime_type': a['mime_type'],
                'tamanho': a['tamanho'],
                'grid_fs_id': (a['grid_fs_id'] as ObjectId).toHexString(),
                'data_upload': (a['data_upload'] as DateTime).toIso8601String(),
              }).toList(),
              'data_submissao': DateTime.now().toIso8601String(),
              'comentario': comentario,
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          // Criar nova submissão
          final submissao = {
            'atividade_id': int.parse(id),
            'aluno_id': int.parse(alunoId),
            'aluno_nome': alunoNome,
            'arquivos': arquivos,
            'data_submissao': DateTime.now(),
            'comentario': comentario,
            'nota': null,
            'feedback': null,
            'data_avaliacao': null,
          };
          
          final result = await collection.insertOne(submissao);
          final submissaoId = result.id.toHexString();
          
          print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ✅ Nova submissão criada: $submissaoId');
          
          return Response(201,
            body: json.encode({
              'id': submissaoId,
              'atividade_id': int.parse(id),
              'aluno_id': int.parse(alunoId),
              'aluno_nome': alunoNome,
              'arquivos': arquivos.map((a) => {
                'nome_original': a['nome_original'],
                'mime_type': a['mime_type'],
                'tamanho': a['tamanho'],
                'grid_fs_id': (a['grid_fs_id'] as ObjectId).toHexString(),
                'data_upload': (a['data_upload'] as DateTime).toIso8601String(),
              }).toList(),
              'data_submissao': DateTime.now().toIso8601String(),
              'comentario': comentario,
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      } catch (e, stack) {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ❌ Erro ao processar submissão: $e');
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Stack: $stack');
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao processar submissão: $e'}),
        );
      }
    });

    // GET /api/atividades/<atividadeId>/submissoes/<alunoId> - Buscar submissão específica de um aluno
    router.get('/<atividadeId>/submissoes/<alunoId>', (Request request, String atividadeId, String alunoId) async {
      try {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Buscando submissão: atividade=$atividadeId, aluno=$alunoId');

        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('submissoes_atividades');

        final submissao = await collection.findOne(
          where.eq('atividade_id', int.parse(atividadeId)).eq('aluno_id', int.parse(alunoId)),
        );

        if (submissao == null) {
          return Response.notFound(
            json.encode({'error': 'Submissão não encontrada'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Formatar submissão
        final submissaoFormatada = Map<String, dynamic>.from(submissao);
        
        if (submissaoFormatada['_id'] != null) {
          submissaoFormatada['id'] = (submissaoFormatada['_id'] as ObjectId).toHexString();
          submissaoFormatada.remove('_id');
        }
        
        if (submissaoFormatada['data_submissao'] is DateTime) {
          submissaoFormatada['data_submissao'] = (submissaoFormatada['data_submissao'] as DateTime).toIso8601String();
        }
        
        if (submissaoFormatada['data_avaliacao'] is DateTime) {
          submissaoFormatada['data_avaliacao'] = (submissaoFormatada['data_avaliacao'] as DateTime).toIso8601String();
        }
        
        if (submissaoFormatada['arquivos'] is List) {
          submissaoFormatada['arquivos'] = (submissaoFormatada['arquivos'] as List).map((a) {
            final arquivo = Map<String, dynamic>.from(a);
            if (arquivo['data_upload'] is DateTime) {
              arquivo['data_upload'] = (arquivo['data_upload'] as DateTime).toIso8601String();
            }
            if (arquivo['grid_fs_id'] is ObjectId) {
              arquivo['grid_fs_id'] = (arquivo['grid_fs_id'] as ObjectId).toHexString();
            }
            return arquivo;
          }).toList();
        }

        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ✅ Submissão encontrada');

        return Response.ok(
          json.encode(submissaoFormatada),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, stack) {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ❌ Erro ao buscar submissão: $e');
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Stack: $stack');
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar submissão: $e'}),
        );
      }
    });

    // PUT /api/atividades/submissoes/<id>/avaliar - Avaliar uma submissão
    router.put('/submissoes/<id>/avaliar', (Request request, String id) async {
      try {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Avaliando submissão: $id');
        
        final payload = json.decode(await request.readAsString());
        
        final nota = payload['nota'];
        final feedback = payload['feedback'];
        
        if (nota == null) {
          return Response.badRequest(
            body: json.encode({'error': 'Nota é obrigatória'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('submissoes_atividades');

        final result = await collection.updateOne(
          where.id(ObjectId.fromHexString(id)),
          modify
            .set('nota', nota is int ? nota.toDouble() : nota)
            .set('feedback', feedback)
            .set('data_avaliacao', DateTime.now()),
        );

        if (result.nModified == 0) {
          return Response.notFound(
            json.encode({'error': 'Submissão não encontrada'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Buscar a submissão atualizada
        final submissao = await collection.findOne(where.id(ObjectId.fromHexString(id)));
        
        if (submissao == null) {
          return Response.notFound(
            json.encode({'error': 'Submissão não encontrada'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Formatar submissão
        final submissaoFormatada = Map<String, dynamic>.from(submissao);
        
        if (submissaoFormatada['_id'] != null) {
          submissaoFormatada['id'] = (submissaoFormatada['_id'] as ObjectId).toHexString();
          submissaoFormatada.remove('_id');
        }
        
        if (submissaoFormatada['data_submissao'] is DateTime) {
          submissaoFormatada['data_submissao'] = (submissaoFormatada['data_submissao'] as DateTime).toIso8601String();
        }
        
        if (submissaoFormatada['data_avaliacao'] is DateTime) {
          submissaoFormatada['data_avaliacao'] = (submissaoFormatada['data_avaliacao'] as DateTime).toIso8601String();
        }
        
        if (submissaoFormatada['arquivos'] is List) {
          submissaoFormatada['arquivos'] = (submissaoFormatada['arquivos'] as List).map((a) {
            final arquivo = Map<String, dynamic>.from(a);
            if (arquivo['data_upload'] is DateTime) {
              arquivo['data_upload'] = (arquivo['data_upload'] as DateTime).toIso8601String();
            }
            if (arquivo['grid_fs_id'] is ObjectId) {
              arquivo['grid_fs_id'] = (arquivo['grid_fs_id'] as ObjectId).toHexString();
            }
            return arquivo;
          }).toList();
        }

        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ✅ Submissão avaliada com sucesso');

        return Response.ok(
          json.encode(submissaoFormatada),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, stack) {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ❌ Erro ao avaliar submissão: $e');
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Stack: $stack');
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao avaliar submissão: $e'}),
        );
      }
    });

    // GET /api/atividades/submissoes/arquivo/<fileId> - Download de arquivo de submissão
    router.get('/submissoes/arquivo/<fileId>', (Request request, String fileId) async {
      try {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Download solicitado para arquivo: $fileId');
        
        final mongo = await MongoDB.getInstance();
        final gridFS = mongo.getGridFS();

        final gridOut = await gridFS.findOne(where.id(ObjectId.fromHexString(fileId)));

        if (gridOut == null) {
          print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ❌ Arquivo não encontrado no GridFS');
          return Response.notFound(
            json.encode({'error': 'Arquivo não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Arquivo encontrado: ${gridOut.filename} (${gridOut.length} bytes)');

        // Ler chunks do arquivo
        final bytesBuffer = <int>[];
        await for (var chunk in mongo.db
            .collection('${gridFS.bucketName}.chunks')
            .find(where.eq('files_id', gridOut.id).sortBy('n'))) {
          final data = chunk['data'] as BsonBinary;
          bytesBuffer.addAll(data.byteList);
        }

        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ✅ Enviando arquivo: ${bytesBuffer.length} bytes');

        return Response.ok(
          Uint8List.fromList(bytesBuffer),
          headers: {
            'Content-Type': gridOut.contentType ?? 'application/octet-stream',
            'Content-Disposition': 'attachment; filename="${gridOut.filename}"',
            'Content-Length': gridOut.length.toString(),
          },
        );
      } catch (e, stack) {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ❌ Erro no download: $e');
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Stack: $stack');
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao baixar arquivo: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}
