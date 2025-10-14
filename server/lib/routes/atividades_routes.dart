import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sistema_professores_server/database/database.dart';

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
        
        final atividades = result.map((row) => {
          'id': row[0],
          'disciplina_id': row[1],
          'titulo': row[2],
          'descricao': row[3],
          'peso': row[4],
          'data_entrega': row[5]?.toString(),
          'criado_em': row[6]?.toString(),
          'atualizado_em': row[7]?.toString(),
        }).toList();
        
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
    
    return router;
  }
}
