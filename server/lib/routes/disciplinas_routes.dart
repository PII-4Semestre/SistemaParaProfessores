import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/database.dart';

class DisciplinasRoutes {
  Router get router {
    final router = Router();
    
    // GET /api/disciplinas - Listar todas as disciplinas
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          'SELECT * FROM disciplinas ORDER BY nome',
        );
        
        final disciplinas = result.map((row) => row.toColumnMap()).toList();
        
        return Response.ok(
          json.encode(disciplinas),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar disciplinas: $e'}),
        );
      }
    });
    
    // GET /api/disciplinas/professor/<id> - Disciplinas de um professor
    router.get('/professor/<id>', (Request request, String id) async {
      try {
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          'SELECT * FROM disciplinas WHERE professor_id = @id ORDER BY nome',
          parameters: {'id': int.parse(id)},
        );
        
        final disciplinas = result.map((row) => row.toColumnMap()).toList();
        
        return Response.ok(
          json.encode(disciplinas),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar disciplinas: $e'}),
        );
      }
    });
    
    // POST /api/disciplinas - Criar nova disciplina
    router.post('/', (Request request) async {
      try {
        final payload = json.decode(await request.readAsString());
        
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          INSERT INTO disciplinas (nome, descricao, professor_id, cor)
          VALUES (@nome, @descricao, @professor_id, @cor)
          RETURNING *
          ''',
          parameters: {
            'nome': payload['nome'],
            'descricao': payload['descricao'],
            'professor_id': payload['professor_id'],
            'cor': payload['cor'] ?? '#FF9800',
          },
        );
        
        return Response.ok(
          json.encode(result.first.toColumnMap()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao criar disciplina: $e'}),
        );
      }
    });
    
    // PUT /api/disciplinas/<id> - Atualizar disciplina
    router.put('/<id>', (Request request, String id) async {
      try {
        final payload = json.decode(await request.readAsString());
        
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          UPDATE disciplinas
          SET nome = @nome, descricao = @descricao, cor = @cor
          WHERE id = @id
          RETURNING *
          ''',
          parameters: {
            'id': int.parse(id),
            'nome': payload['nome'],
            'descricao': payload['descricao'],
            'cor': payload['cor'],
          },
        );
        
        if (result.isEmpty) {
          return Response.notFound(json.encode({'error': 'Disciplina não encontrada'}));
        }
        
        return Response.ok(
          json.encode(result.first.toColumnMap()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao atualizar disciplina: $e'}),
        );
      }
    });
    
    // DELETE /api/disciplinas/<id> - Deletar disciplina
    router.delete('/<id>', (Request request, String id) async {
      try {
        final db = await Database.getInstance();
        await db.connection.execute(
          'DELETE FROM disciplinas WHERE id = @id',
          parameters: {'id': int.parse(id)},
        );
        
        return Response.ok(
          json.encode({'message': 'Disciplina deletada com sucesso'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao deletar disciplina: $e'}),
        );
      }
    });
    
    return router;
  }
}
