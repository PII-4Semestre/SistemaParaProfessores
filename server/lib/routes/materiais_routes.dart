import 'dart:convert';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:sistema_professores_server/database/mongodb.dart';
import 'package:sistema_professores_server/models/material.dart';

class MateriaisRoutes {
  Router get router {
    final router = Router();

    // GET /api/materiais - Listar todos os materiais
    router.get('/', (Request request) async {
      try {
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('materiais');

        final materiais = await collection.find().toList();

        // Converter DateTime para String em cada material
        final materiaisFormatados = materiais.map((m) {
          final material = Map<String, dynamic>.from(m);
          
          if (material['_id'] != null) {
            material['_id'] = (material['_id'] as ObjectId).toHexString();
          }
          
          if (material['criado_em'] is DateTime) {
            material['criado_em'] = (material['criado_em'] as DateTime).toIso8601String();
          }
          if (material['atualizado_em'] is DateTime) {
            material['atualizado_em'] = (material['atualizado_em'] as DateTime).toIso8601String();
          }
          
          if (material['arquivos'] is List) {
            material['arquivos'] = (material['arquivos'] as List).map((a) {
              final arquivo = Map<String, dynamic>.from(a);
              if (arquivo['upload_em'] is DateTime) {
                arquivo['upload_em'] = (arquivo['upload_em'] as DateTime).toIso8601String();
              }
              if (arquivo['grid_fs_id'] is ObjectId) {
                arquivo['grid_fs_id'] = (arquivo['grid_fs_id'] as ObjectId).toHexString();
              }
              return arquivo;
            }).toList();
          }
          
          return material;
        }).toList();

        return Response.ok(
          json.encode(materiaisFormatados),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar materiais: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // GET /api/materiais/disciplina/<id> - Materiais de uma disciplina
    router.get('/disciplina/<id>', (Request request, String id) async {
      try {
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('materiais');

        final materiais = await collection.find(
          where.eq('disciplina_id', int.parse(id)).eq('ativo', true),
        ).toList();

        // Converter DateTime para String em cada material
        final materiaisFormatados = materiais.map((m) {
          final material = Map<String, dynamic>.from(m);
          
          // Converter _id ObjectId para string
          if (material['_id'] != null) {
            material['_id'] = (material['_id'] as ObjectId).toHexString();
          }
          
          // Converter DateTime para String ISO 8601
          if (material['criado_em'] is DateTime) {
            material['criado_em'] = (material['criado_em'] as DateTime).toIso8601String();
          }
          if (material['atualizado_em'] is DateTime) {
            material['atualizado_em'] = (material['atualizado_em'] as DateTime).toIso8601String();
          }
          
          // Converter DateTime nos arquivos
          if (material['arquivos'] is List) {
            material['arquivos'] = (material['arquivos'] as List).map((a) {
              final arquivo = Map<String, dynamic>.from(a);
              if (arquivo['upload_em'] is DateTime) {
                arquivo['upload_em'] = (arquivo['upload_em'] as DateTime).toIso8601String();
              }
              if (arquivo['grid_fs_id'] is ObjectId) {
                arquivo['grid_fs_id'] = (arquivo['grid_fs_id'] as ObjectId).toHexString();
              }
              return arquivo;
            }).toList();
          }
          
          return material;
        }).toList();

        return Response.ok(
          json.encode(materiaisFormatados),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar materiais: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // GET /api/materiais/<id> - Buscar material por ID
    router.get('/<id>', (Request request, String id) async {
      try {
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('materiais');

        final materialDoc = await collection.findOne(
          where.id(ObjectId.fromHexString(id)),
        );

        if (materialDoc == null) {
          return Response.notFound(
            json.encode({'error': 'Material não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Converter DateTime para String
        final material = Map<String, dynamic>.from(materialDoc);
        
        if (material['_id'] != null) {
          material['_id'] = (material['_id'] as ObjectId).toHexString();
        }
        
        if (material['criado_em'] is DateTime) {
          material['criado_em'] = (material['criado_em'] as DateTime).toIso8601String();
        }
        if (material['atualizado_em'] is DateTime) {
          material['atualizado_em'] = (material['atualizado_em'] as DateTime).toIso8601String();
        }
        
        if (material['arquivos'] is List) {
          material['arquivos'] = (material['arquivos'] as List).map((a) {
            final arquivo = Map<String, dynamic>.from(a);
            if (arquivo['upload_em'] is DateTime) {
              arquivo['upload_em'] = (arquivo['upload_em'] as DateTime).toIso8601String();
            }
            if (arquivo['grid_fs_id'] is ObjectId) {
              arquivo['grid_fs_id'] = (arquivo['grid_fs_id'] as ObjectId).toHexString();
            }
            return arquivo;
          }).toList();
        }

        return Response.ok(
          json.encode(material),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar material: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // POST /api/materiais - Criar novo material
    router.post('/', (Request request) async {
      try {
        final payload = json.decode(await request.readAsString());

        // Converter IDs para inteiros (suporta tanto String quanto int)
        final disciplinaId = payload['disciplina_id'] is String
            ? int.parse(payload['disciplina_id'])
            : payload['disciplina_id'] as int;
        
        final professorId = payload['professor_id'] is String
            ? int.parse(payload['professor_id'])
            : payload['professor_id'] as int;

        final material = Material(
          disciplinaId: disciplinaId,
          professorId: professorId,
          titulo: payload['titulo'] as String,
          descricao: payload['descricao'] as String?,
          tipo: payload['tipo'] as String,
          tags: (payload['tags'] as List<dynamic>?)?.cast<String>() ?? [],
          linkExterno: payload['link_externo'] as String?,
        );

        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('materiais');

        final result = await collection.insertOne(material.toJson());

        return Response.ok(
          json.encode({
            'id': result.id.toHexString(),
            'message': 'Material criado com sucesso',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao criar material: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // PUT /api/materiais/<id> - Atualizar material
    router.put('/<id>', (Request request, String id) async {
      try {
        final payload = json.decode(await request.readAsString());

        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('materiais');

        final updateData = <String, dynamic>{
          'atualizado_em': DateTime.now(),
        };

        if (payload.containsKey('titulo')) {
          updateData['titulo'] = payload['titulo'];
        }
        if (payload.containsKey('descricao')) {
          updateData['descricao'] = payload['descricao'];
        }
        if (payload.containsKey('tipo')) {
          updateData['tipo'] = payload['tipo'];
        }
        if (payload.containsKey('tags')) {
          updateData['tags'] = payload['tags'];
        }
        if (payload.containsKey('link_externo')) {
          updateData['link_externo'] = payload['link_externo'];
        }

        final result = await collection.updateOne(
          where.id(ObjectId.fromHexString(id)),
          modify.set('atualizado_em', DateTime.now()).set(
                'titulo',
                payload['titulo'],
              )..set('descricao', payload['descricao'])..set(
                  'tipo',
                  payload['tipo'],
                )..set('tags', payload['tags']),
        );

        if (result.nModified == 0) {
          return Response.notFound(
            json.encode({'error': 'Material não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.ok(
          json.encode({'message': 'Material atualizado com sucesso'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao atualizar material: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // DELETE /api/materiais/<id> - Deletar material (soft delete)
    router.delete('/<id>', (Request request, String id) async {
      try {
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('materiais');

        // Soft delete - apenas marca como inativo
        final result = await collection.updateOne(
          where.id(ObjectId.fromHexString(id)),
          modify.set('ativo', false).set('atualizado_em', DateTime.now()),
        );

        if (result.nModified == 0) {
          return Response.notFound(
            json.encode({'error': 'Material não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.ok(
          json.encode({'message': 'Material deletado com sucesso'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao deletar material: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // POST /api/materiais/<id>/arquivo - Upload de arquivo para material
    router.post('/<id>/arquivo', (Request request, String id) async {
      try {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Upload de arquivo iniciado para material: $id');
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Content-Type: ${request.headers['content-type']}');
        
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
        
        // Parsear as partes do multipart
        String? nomeOriginal;
        String? mimeType;
        Uint8List? fileBytes;
        
        // Parse multipart manualmente trabalhando com bytes
        final boundaryBytes = utf8.encode('\r\n$boundary');
        final doubleCrLf = utf8.encode('\r\n\r\n');
        
        // Dividir body em partes usando o boundary
        final parts = <Uint8List>[];
        int start = 0;
        
        while (start < body.length) {
          // Procurar próximo boundary
          int boundaryIndex = -1;
          for (int i = start; i <= body.length - boundaryBytes.length; i++) {
            bool match = true;
            for (int j = 0; j < boundaryBytes.length; j++) {
              if (body[i + j] != boundaryBytes[j]) {
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
          
          if (start > 0) {
            parts.add(Uint8List.fromList(body.sublist(start, boundaryIndex)));
          }
          
          start = boundaryIndex + boundaryBytes.length;
        }
        
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Partes encontradas: ${parts.length}');
        
        // Processar cada parte
        for (final partBytes in parts) {
          if (partBytes.isEmpty) continue;
          
          // Encontrar o fim dos headers (\r\n\r\n)
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
          
          // Extrair headers como string
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
          
          // Extrair o name do campo
          final nameMatch = RegExp(r'name="([^"]+)"').firstMatch(contentDisposition);
          if (nameMatch == null) continue;
          final fieldName = nameMatch.group(1);
          print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Campo encontrado: $fieldName');
          
          // Extrair conteúdo (bytes após \r\n\r\n)
          final contentStart = headerEnd + doubleCrLf.length;
          final contentBytes = partBytes.sublist(contentStart);
          
          if (fieldName == 'arquivo') {
            // Extrair nome do arquivo
            final filenameMatch = RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
            if (filenameMatch != null) {
              nomeOriginal = filenameMatch.group(1);
              print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Nome do arquivo: $nomeOriginal');
            }
            
            // Pegar content-type do arquivo
            mimeType = headers['content-type'];
            
            // Bytes do arquivo (já são binários, não precisamos converter)
            fileBytes = contentBytes;
            print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Arquivo recebido: ${fileBytes.length} bytes');
            
          } else if (fieldName == 'nome_original') {
            final content = utf8.decode(contentBytes).trim();
            nomeOriginal = content;
          } else if (fieldName == 'mime_type') {
            final content = utf8.decode(contentBytes).trim();
            mimeType = content;
          }
        }

        if (fileBytes == null || fileBytes.isEmpty) {
          return Response.badRequest(
            body: json.encode({'error': 'Nenhum arquivo fornecido'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        nomeOriginal ??= 'arquivo_sem_nome';
        mimeType ??= 'application/octet-stream';

        final mongo = await MongoDB.getInstance();
        final gridFS = mongo.getGridFS();

        // Criar stream de dados e fazer upload para GridFS
        final inputStream = Stream.fromIterable([fileBytes]);
        final gridIn = gridFS.createFile(inputStream, nomeOriginal);
        gridIn.contentType = mimeType;
        await gridIn.save();
        
        final gridFsId = gridIn.id;

        // Atualizar documento do material com informações do arquivo
        final arquivo = Arquivo(
          gridFsId: gridFsId,
          nomeOriginal: nomeOriginal,
          mimeType: mimeType,
          tamanhoBytes: fileBytes.length,
        );

        // Converter para JSON e depois converter DateTime para o formato do MongoDB
        final arquivoJson = arquivo.toJson();
        // MongoDB aceita DateTime nativamente, não precisa converter

        final collection = mongo.collection('materiais');
        await collection.updateOne(
          where.id(ObjectId.fromHexString(id)),
          modify.push('arquivos', arquivoJson),
        );
        
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ✅ Arquivo salvo com sucesso: $nomeOriginal');

        return Response.ok(
          json.encode({
            'message': 'Arquivo enviado com sucesso',
            'arquivo_id': gridFsId.toHexString(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, stack) {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Erro no upload: $e');
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Stack: $stack');
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao fazer upload do arquivo: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // GET /api/materiais/arquivo/<fileId> - Download de arquivo
    router.get('/arquivo/<fileId>', (Request request, String fileId) async {
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

        // Usar chunks para ler os dados do arquivo
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
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Erro no download: $e');
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Stack: $stack');
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao baixar arquivo: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // DELETE /api/materiais/<materialId>/arquivo/<fileId> - Remover arquivo específico
    router.delete('/<materialId>/arquivo/<fileId>', (Request request, String materialId, String fileId) async {
      try {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Removendo arquivo $fileId do material $materialId');
        
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('materiais');
        final gridFS = mongo.getGridFS();

        // Buscar o material para pegar as informações do arquivo
        final material = await collection.findOne(where.id(ObjectId.fromHexString(materialId)));
        
        if (material == null) {
          return Response.notFound(
            json.encode({'error': 'Material não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Encontrar o arquivo na lista
        final arquivos = material['arquivos'] as List?;
        if (arquivos == null || arquivos.isEmpty) {
          return Response.notFound(
            json.encode({'error': 'Material não possui arquivos'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Buscar o arquivo com o grid_fs_id correspondente
        final arquivoIndex = arquivos.indexWhere((a) {
          final gridFsId = a['grid_fs_id'];
          if (gridFsId is ObjectId) {
            return gridFsId.toHexString() == fileId;
          } else if (gridFsId is String) {
            return gridFsId == fileId;
          }
          return false;
        });

        if (arquivoIndex == -1) {
          return Response.notFound(
            json.encode({'error': 'Arquivo não encontrado no material'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Remover arquivo do GridFS
        final filesCollection = mongo.db.collection('${gridFS.bucketName}.files');
        final chunksCollection = mongo.db.collection('${gridFS.bucketName}.chunks');
        
        final fileObjectId = ObjectId.fromHexString(fileId);
        
        // Deletar chunks
        await chunksCollection.deleteMany(where.eq('files_id', fileObjectId));
        
        // Deletar arquivo
        await filesCollection.deleteOne(where.id(fileObjectId));

        // Remover arquivo da lista do material
        await collection.updateOne(
          where.id(ObjectId.fromHexString(materialId)),
          modify.pull('arquivos', {'grid_fs_id': fileObjectId}),
        );

        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] ✅ Arquivo removido com sucesso');

        return Response.ok(
          json.encode({'message': 'Arquivo removido com sucesso'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, stack) {
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Erro ao remover arquivo: $e');
        print('[${DateTime.now().toString().split('.')[0].substring(11, 19)}] Stack: $stack');
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao remover arquivo: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}
