import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../database/mongodb.dart';

class MensagensRoutes {
  Router get router {
    final router = Router();

    // GET /api/mensagens/conversas/<usuarioId> - Listar conversas de um usuário
    router.get('/conversas/<usuarioId>', (Request request, String usuarioId) async {
      try {
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('mensagens');

        // Buscar todas as mensagens onde o usuário é remetente ou destinatário
        final mensagens = await collection.find(
          where.eq('remetenteId', usuarioId).or(where.eq('destinatarioId', usuarioId))
        ).toList();

        // Agrupar por conversas (outros usuários)
        final Map<String, dynamic> conversas = {};
        
        for (var msg in mensagens) {
          final outroUsuarioId = msg['remetenteId'] == usuarioId 
              ? msg['destinatarioId'] 
              : msg['remetenteId'];
          
          if (!conversas.containsKey(outroUsuarioId)) {
            conversas[outroUsuarioId] = {
              'participantId': outroUsuarioId,
              'ultimaMensagem': msg['conteudo'],
              'dataUltimaMensagem': (msg['dataEnvio'] as DateTime).toIso8601String(),
              'naoLidas': 0,
            };
          } else {
            // Atualizar se for mais recente
            final dataAtual = msg['dataEnvio'] as DateTime;
            final dataArmazenada = DateTime.parse(conversas[outroUsuarioId]['dataUltimaMensagem']);
            
            if (dataAtual.isAfter(dataArmazenada)) {
              conversas[outroUsuarioId]['ultimaMensagem'] = msg['conteudo'];
              conversas[outroUsuarioId]['dataUltimaMensagem'] = dataAtual.toIso8601String();
            }
          }
          
          // Contar não lidas
          if (msg['destinatarioId'] == usuarioId && msg['lida'] == false) {
            conversas[outroUsuarioId]['naoLidas']++;
          }
        }

        return Response.ok(
          json.encode(conversas.values.toList()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('Erro ao buscar conversas: $e');
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar conversas: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // GET /api/mensagens/<usuarioId>/<outroUsuarioId> - Listar mensagens entre dois usuários
    router.get('/<usuarioId>/<outroUsuarioId>', (Request request, String usuarioId, String outroUsuarioId) async {
      try {
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('mensagens');

        // Buscar mensagens entre os dois usuários
        final query = {
          r'$or': [
            {
              'remetenteId': usuarioId,
              'destinatarioId': outroUsuarioId,
            },
            {
              'remetenteId': outroUsuarioId,
              'destinatarioId': usuarioId,
            },
          ]
        };

        final mensagens = await collection
            .find(query)
            .toList();
        
        // Ordenar por data
        mensagens.sort((a, b) {
          final dateA = a['dataEnvio'] as DateTime;
          final dateB = b['dataEnvio'] as DateTime;
          return dateA.compareTo(dateB);
        });

        // Formatar mensagens
        final mensagensFormatadas = mensagens.map((m) {
          final mensagem = Map<String, dynamic>.from(m);
          
          if (mensagem['_id'] != null) {
            mensagem['id'] = (mensagem['_id'] as ObjectId).toHexString();
            mensagem.remove('_id');
          }
          
          if (mensagem['dataEnvio'] is DateTime) {
            mensagem['dataEnvio'] = (mensagem['dataEnvio'] as DateTime).toIso8601String();
          }
          
          if (mensagem['dataEdicao'] is DateTime) {
            mensagem['dataEdicao'] = (mensagem['dataEdicao'] as DateTime).toIso8601String();
          }
          
          // Garantir que arrays existam
          mensagem['reacoes'] ??= [];
          
          return mensagem;
        }).toList();

        return Response.ok(
          json.encode(mensagensFormatadas),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar mensagens: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // POST /api/mensagens - Enviar nova mensagem
    router.post('/', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = json.decode(body) as Map<String, dynamic>;
        
        print('📩 Dados recebidos: $data');

        // Validar campos obrigatórios
        if (data['remetenteId'] == null || 
            data['destinatarioId'] == null || 
            data['conteudo'] == null) {
          return Response.badRequest(
            body: json.encode({'error': 'Campos obrigatórios: remetenteId, destinatarioId, conteudo'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('mensagens');

        final mensagem = {
          'remetenteId': data['remetenteId'],
          'destinatarioId': data['destinatarioId'],
          'conteudo': data['conteudo'],
          'dataEnvio': DateTime.now(),
          'lida': false,
          'reacoes': [],
          'editada': false,
        };

        // Campos opcionais
        if (data['respostaParaId'] != null) {
          print('✅ Resposta detectada: ${data['respostaParaId']}');
          mensagem['respostaParaId'] = data['respostaParaId'];
          
          // Buscar o conteúdo da mensagem original
          try {
            final mensagemOriginal = await collection.findOne(
              where.eq('_id', ObjectId.parse(data['respostaParaId']))
            );
            if (mensagemOriginal != null) {
              mensagem['respostaParaConteudo'] = mensagemOriginal['conteudo'];
              print('✅ Conteúdo original encontrado: ${mensagemOriginal['conteudo']}');
            } else {
              print('⚠️ Mensagem original não encontrada');
            }
          } catch (e) {
            print('❌ Erro ao buscar mensagem original: $e');
          }
        } else {
          print('ℹ️ Sem resposta (respostaParaId não fornecido)');
        }

        final result = await collection.insertOne(mensagem);
        
        if (result.isSuccess) {
          mensagem['id'] = result.id!.toHexString();
          mensagem.remove('_id');
          mensagem['dataEnvio'] = (mensagem['dataEnvio'] as DateTime).toIso8601String();
          
          return Response.ok(
            json.encode(mensagem),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          return Response.internalServerError(
            body: json.encode({'error': 'Erro ao enviar mensagem'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao enviar mensagem: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // PUT /api/mensagens/<id> - Editar mensagem
    router.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final data = json.decode(body) as Map<String, dynamic>;

        if (data['conteudo'] == null) {
          return Response.badRequest(
            body: json.encode({'error': 'Campo conteudo é obrigatório'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('mensagens');

        final result = await collection.updateOne(
          where.eq('_id', ObjectId.parse(id)),
          modify
            .set('conteudo', data['conteudo'])
            .set('editada', true)
            .set('dataEdicao', DateTime.now()),
        );

        if (result.isSuccess && result.nMatched > 0) {
          // Buscar mensagem atualizada
          final mensagem = await collection.findOne(where.eq('_id', ObjectId.parse(id)));
          
          if (mensagem != null) {
            mensagem['id'] = (mensagem['_id'] as ObjectId).toHexString();
            mensagem.remove('_id');
            
            if (mensagem['dataEnvio'] is DateTime) {
              mensagem['dataEnvio'] = (mensagem['dataEnvio'] as DateTime).toIso8601String();
            }
            if (mensagem['dataEdicao'] is DateTime) {
              mensagem['dataEdicao'] = (mensagem['dataEdicao'] as DateTime).toIso8601String();
            }
            
            return Response.ok(
              json.encode(mensagem),
              headers: {'Content-Type': 'application/json'},
            );
          }
        }

        return Response.notFound(
          json.encode({'error': 'Mensagem não encontrada'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao editar mensagem: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // DELETE /api/mensagens/<id> - Deletar mensagem
    router.delete('/<id>', (Request request, String id) async {
      try {
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('mensagens');

        final result = await collection.deleteOne(where.eq('_id', ObjectId.parse(id)));

        if (result.isSuccess && result.nRemoved > 0) {
          return Response.ok(
            json.encode({'message': 'Mensagem deletada com sucesso'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.notFound(
          json.encode({'error': 'Mensagem não encontrada'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao deletar mensagem: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // POST /api/mensagens/<id>/reacoes - Adicionar reação
    router.post('/<id>/reacoes', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final data = json.decode(body) as Map<String, dynamic>;

        if (data['emoji'] == null) {
          return Response.badRequest(
            body: json.encode({'error': 'Campo emoji é obrigatório'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('mensagens');

        final result = await collection.updateOne(
          where.eq('_id', ObjectId.parse(id)),
          modify.addToSet('reacoes', data['emoji']),
        );

        if (result.isSuccess && result.nMatched > 0) {
          return Response.ok(
            json.encode({'message': 'Reação adicionada com sucesso'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.notFound(
          json.encode({'error': 'Mensagem não encontrada'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao adicionar reação: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // DELETE /api/mensagens/<id>/reacoes/<emoji> - Remover reação
    router.delete('/<id>/reacoes/<emoji>', (Request request, String id, String emoji) async {
      try {
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('mensagens');

        final result = await collection.updateOne(
          where.eq('_id', ObjectId.parse(id)),
          modify.pull('reacoes', emoji),
        );

        if (result.isSuccess && result.nMatched > 0) {
          return Response.ok(
            json.encode({'message': 'Reação removida com sucesso'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.notFound(
          json.encode({'error': 'Mensagem não encontrada'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao remover reação: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // PUT /api/mensagens/<id>/lida - Marcar como lida
    router.put('/<id>/lida', (Request request, String id) async {
      try {
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('mensagens');

        final result = await collection.updateOne(
          where.eq('_id', ObjectId.parse(id)),
          modify.set('lida', true),
        );

        if (result.isSuccess && result.nMatched > 0) {
          return Response.ok(
            json.encode({'message': 'Mensagem marcada como lida'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.notFound(
          json.encode({'error': 'Mensagem não encontrada'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao marcar mensagem como lida: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // PUT /api/mensagens/<id>/nao-lida - Marcar como não lida
    router.put('/<id>/nao-lida', (Request request, String id) async {
      try {
        final mongo = await MongoDB.getInstance();
        final collection = mongo.collection('mensagens');

        final result = await collection.updateOne(
          where.eq('_id', ObjectId.parse(id)),
          modify.set('lida', false),
        );

        if (result.isSuccess && result.nMatched > 0) {
          return Response.ok(
            json.encode({'message': 'Mensagem marcada como não lida'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.notFound(
          json.encode({'error': 'Mensagem não encontrada'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao marcar mensagem como não lida: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}
