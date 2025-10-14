import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sistema_professores_server/database/database.dart';

class NotasRoutes {
  Router get router {
    final router = Router();
    
    // GET /api/notas/aluno/<id> - Notas de um aluno
    router.get('/aluno/<id>', (Request request, String id) async {
      try {
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          SELECT n.id, n.atividade_id, n.aluno_id, n.nota, n.comentario, n.atribuida_em,
                 a.titulo as atividade_titulo, d.nome as disciplina_nome
          FROM notas n
          JOIN atividades a ON n.atividade_id = a.id
          JOIN disciplinas d ON a.disciplina_id = d.id
          WHERE n.aluno_id = \$1
          ORDER BY n.atribuida_em DESC
          ''',
          parameters: [int.parse(id)],
        );
        
        final notas = result.map((row) => {
          'id': row[0],
          'atividade_id': row[1],
          'aluno_id': row[2],
          'nota': row[3],
          'comentario': row[4],
          'atribuida_em': row[5]?.toString(),
          'atividade_titulo': row[6],
          'disciplina_nome': row[7],
        }).toList();
        
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
          VALUES (\$1, \$2, \$3, \$4)
          ON CONFLICT (atividade_id, aluno_id)
          DO UPDATE SET nota = EXCLUDED.nota, comentario = EXCLUDED.comentario
          RETURNING id, atividade_id, aluno_id, nota, comentario, atribuida_em
          ''',
          parameters: [
            payload['atividade_id'],
            payload['aluno_id'],
            payload['nota'],
            payload['comentario'],
          ],
        );
        
        final row = result.first;
        return Response.ok(
          json.encode({
            'id': row[0],
            'atividade_id': row[1],
            'aluno_id': row[2],
            'nota': row[3],
            'comentario': row[4],
            'atribuida_em': row[5]?.toString(),
          }),
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
