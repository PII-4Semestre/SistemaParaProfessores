import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/database.dart';

class NotasRoutes {
  Router get router {
    final router = Router();
    
    // GET /api/notas/aluno/<id> - Notas de um aluno
    router.get('/aluno/<id>', (Request request, String id) async {
      try {
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          SELECT n.*, a.titulo as atividade_titulo, d.nome as disciplina_nome
          FROM notas n
          JOIN atividades a ON n.atividade_id = a.id
          JOIN disciplinas d ON a.disciplina_id = d.id
          WHERE n.aluno_id = @id
          ORDER BY n.atribuida_em DESC
          ''',
          parameters: {'id': int.parse(id)},
        );
        
        final notas = result.map((row) => row.toColumnMap()).toList();
        
        return Response.ok(
          json.encode(notas),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar notas: $e'}),
        );
      }
    });
    
    // POST /api/notas - Atribuir nota
    router.post('/', (Request request) async {
      try {
        final payload = json.decode(await request.readAsString());
        
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          INSERT INTO notas (atividade_id, aluno_id, nota, comentario)
          VALUES (@atividade_id, @aluno_id, @nota, @comentario)
          ON CONFLICT (atividade_id, aluno_id)
          DO UPDATE SET nota = EXCLUDED.nota, comentario = EXCLUDED.comentario
          RETURNING *
          ''',
          parameters: {
            'atividade_id': payload['atividade_id'],
            'aluno_id': payload['aluno_id'],
            'nota': payload['nota'],
            'comentario': payload['comentario'],
          },
        );
        
        return Response.ok(
          json.encode(result.first.toColumnMap()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao atribuir nota: $e'}),
        );
      }
    });
    
    return router;
  }
}
