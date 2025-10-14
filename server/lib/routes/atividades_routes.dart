import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/database.dart';

class AtividadesRoutes {
  Router get router {
    final router = Router();
    
    // GET /api/atividades/disciplina/<id> - Atividades de uma disciplina
    router.get('/disciplina/<id>', (Request request, String id) async {
      try {
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          'SELECT * FROM atividades WHERE disciplina_id = @id ORDER BY data_entrega',
          parameters: {'id': int.parse(id)},
        );
        
        final atividades = result.map((row) => row.toColumnMap()).toList();
        
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
          VALUES (@disciplina_id, @titulo, @descricao, @peso, @data_entrega)
          RETURNING *
          ''',
          parameters: {
            'disciplina_id': payload['disciplina_id'],
            'titulo': payload['titulo'],
            'descricao': payload['descricao'],
            'peso': payload['peso'] ?? 1.0,
            'data_entrega': payload['data_entrega'],
          },
        );
        
        return Response.ok(
          json.encode(result.first.toColumnMap()),
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
