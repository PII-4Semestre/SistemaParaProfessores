import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sistema_professores_server/database/database.dart';

class UsuariosRoutes {
  Router get router {
    final router = Router();

    // GET /api/usuarios - Listar todos os usuários
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        
        final result = await db.connection.execute(
          'SELECT id, nome, email, tipo::text, ra FROM usuarios ORDER BY nome',
        );

        final usuarios = result.map((row) => {
          'id': row[0],
          'nome': row[1],
          'email': row[2],
          'tipo': row[3],
          'ra': row[4],
        }).toList();

        return Response.ok(
          json.encode(usuarios),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar lista de usuários: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // GET /api/usuarios/:id - Buscar dados básicos de um usuário
    router.get('/<id>', (Request request, String id) async {
      try {
        final db = await Database.getInstance();
        
        // Tentar converter para int, se falhar retornar erro
        final userId = int.tryParse(id);
        if (userId == null) {
          return Response.badRequest(
            body: json.encode({'error': 'ID de usuário inválido'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        final result = await db.connection.execute(
          'SELECT id, nome, email, tipo::text, ra FROM usuarios WHERE id = \$1',
          parameters: [userId],
        );

        if (result.isEmpty) {
          return Response.notFound(
            json.encode({'error': 'Usuário não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final row = result.first;
        final usuario = {
          'id': row[0],
          'nome': row[1],
          'email': row[2],
          'tipo': row[3],
          'ra': row[4],
        };

        return Response.ok(
          json.encode(usuario),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar usuário: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}

