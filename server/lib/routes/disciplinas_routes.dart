import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sistema_professores_server/database/database.dart';

class DisciplinasRoutes {
  Router get router {
    final router = Router();

    // GET /api/disciplinas - Listar todas as disciplinas
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          'SELECT id, nome, descricao, professor_id, cor, criado_em, atualizado_em FROM disciplinas ORDER BY nome',
        );

        final disciplinas = result
            .map(
              (row) => {
                'id': row[0],
                'nome': row[1],
                'descricao': row[2],
                'professor_id': row[3],
                'cor': row[4],
                'criado_em': row[5]?.toString(),
                'atualizado_em': row[6]?.toString(),
              },
            )
            .toList();

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
          'SELECT id, nome, descricao, professor_id, cor, criado_em, atualizado_em FROM disciplinas WHERE professor_id = \$1 ORDER BY nome',
          parameters: [int.parse(id)],
        );

        final disciplinas = result
            .map(
              (row) => {
                'id': row[0],
                'nome': row[1],
                'descricao': row[2],
                'professor_id': row[3],
                'cor': row[4],
                'criado_em': row[5]?.toString(),
                'atualizado_em': row[6]?.toString(),
              },
            )
            .toList();

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
          VALUES (\$1, \$2, \$3, \$4)
          RETURNING id, nome, descricao, professor_id, cor, criado_em, atualizado_em
          ''',
          parameters: [
            payload['nome'],
            payload['descricao'],
            payload['professor_id'],
            payload['cor'] ?? '#FF9800',
          ],
        );

        final row = result.first;
        return Response.ok(
          json.encode({
            'id': row[0],
            'nome': row[1],
            'descricao': row[2],
            'professor_id': row[3],
            'cor': row[4],
            'criado_em': row[5]?.toString(),
            'atualizado_em': row[6]?.toString(),
          }),
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
          SET nome = \$1, descricao = \$2, cor = \$3
          WHERE id = \$4
          RETURNING id, nome, descricao, professor_id, cor, criado_em, atualizado_em
          ''',
          parameters: [
            payload['nome'],
            payload['descricao'],
            payload['cor'],
            int.parse(id),
          ],
        );

        if (result.isEmpty) {
          return Response.notFound(
            json.encode({'error': 'Disciplina não encontrada'}),
          );
        }

        final row = result.first;
        return Response.ok(
          json.encode({
            'id': row[0],
            'nome': row[1],
            'descricao': row[2],
            'professor_id': row[3],
            'cor': row[4],
            'criado_em': row[5]?.toString(),
            'atualizado_em': row[6]?.toString(),
          }),
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
          'DELETE FROM disciplinas WHERE id = \$1',
          parameters: [int.parse(id)],
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
