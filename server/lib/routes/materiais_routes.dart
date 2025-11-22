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

        return Response.ok(
          json.encode(materiais),
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

        return Response.ok(
          json.encode(materiais),
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

        final material = await collection.findOne(
          where.id(ObjectId.fromHexString(id)),
        );

        if (material == null) {
          return Response.notFound(
            json.encode({'error': 'Material não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
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

        final material = Material(
          disciplinaId: payload['disciplina_id'] as int,
          professorId: payload['professor_id'] as int,
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
    // Nota: Para uma implementação completa com multipart/form-data,
    // considere usar o pacote 'shelf_multipart'
    router.post('/<id>/arquivo', (Request request, String id) async {
      try {
        // Esta é uma implementação básica
        // Para produção, use shelf_multipart para lidar com uploads reais
        final bytes = await request.read().expand((chunk) => chunk).toList();
        final data = Uint8List.fromList(bytes);

        // Obter headers do arquivo
        final contentType = request.headers['content-type'] ?? 'application/octet-stream';
        final fileName = request.headers['x-file-name'] ?? 'arquivo_sem_nome';

        final mongo = await MongoDB.getInstance();
        final gridFS = mongo.getGridFS();

        // Criar stream de dados e fazer upload para GridFS
        final inputStream = Stream.fromIterable([data]);
        final gridIn = gridFS.createFile(inputStream, fileName);
        gridIn.contentType = contentType;
        await gridIn.save();
        
        final gridFsId = gridIn.id;

        // Atualizar documento do material com informações do arquivo
        final arquivo = Arquivo(
          gridFsId: gridFsId,
          nomeOriginal: fileName,
          mimeType: contentType,
          tamanhoBytes: data.length,
        );

        final collection = mongo.collection('materiais');
        await collection.updateOne(
          where.id(ObjectId.fromHexString(id)),
          modify.push('arquivos', arquivo.toJson()),
        );

        return Response.ok(
          json.encode({
            'message': 'Arquivo enviado com sucesso',
            'arquivo_id': gridFsId.toHexString(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao fazer upload do arquivo: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // GET /api/materiais/arquivo/<fileId> - Download de arquivo
    router.get('/arquivo/<fileId>', (Request request, String fileId) async {
      try {
        final mongo = await MongoDB.getInstance();
        final gridFS = mongo.getGridFS();

        final gridOut = await gridFS.findOne(where.id(ObjectId.fromHexString(fileId)));

        if (gridOut == null) {
          return Response.notFound(
            json.encode({'error': 'Arquivo não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Usar chunks para ler os dados do arquivo
        final bytesBuffer = <int>[];
        await for (var chunk in mongo.db
            .collection('${gridFS.bucketName}.chunks')
            .find(where.eq('files_id', gridOut.id).sortBy('n'))) {
          final data = chunk['data'] as BsonBinary;
          bytesBuffer.addAll(data.byteList);
        }

        return Response.ok(
          Uint8List.fromList(bytesBuffer),
          headers: {
            'Content-Type': gridOut.contentType ?? 'application/octet-stream',
            'Content-Disposition': 'attachment; filename="${gridOut.filename}"',
            'Content-Length': gridOut.length.toString(),
          },
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao baixar arquivo: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}
