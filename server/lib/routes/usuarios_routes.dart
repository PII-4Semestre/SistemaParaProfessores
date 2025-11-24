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

    // POST /api/usuarios - Criar novo usuário (usado pelo admin)
    router.post('/', (Request request) async {
      try {
        final bodyText = await request.readAsString();
        print('SERVER: Received POST ${request.requestedUri}');
        print('SERVER: Request method=${request.method} headers=${request.headers}');
        print('SERVER: Body text: $bodyText');
        final payload = json.decode(bodyText);

        final nome = payload['nome'];
        final email = payload['email'];
        final tipo = payload['tipo'];
        var senha = payload['senha'];
        final ra = payload['ra'];

        // senha_hash is NOT NULL in the schema; if senha is omitted, use empty string
        if (senha == null) senha = '';

        if (nome == null || email == null || tipo == null) {
          return Response(
            400,
            body: json.encode({'error': 'Campos obrigatórios: nome, email, tipo'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final db = await Database.getInstance();

        // Inserir usuário. Se senha não for fornecida, inserir NULL em senha_hash.
        final result = await db.connection.execute(
          '''
          INSERT INTO usuarios (nome, email, senha_hash, tipo, ra)
          VALUES (
            \$1, \$2, \$3, \$4::tipo_usuario, \$5
          )
          RETURNING id, nome, email, tipo::text, ra
          ''',
          parameters: [
            nome,
            email,
            senha, // TODO: hash com bcrypt em produção
            tipo,
            ra,
          ],
        );

        final row = result.first;
        final usuario = {
          'id': row[0],
          'nome': row[1],
          'email': row[2],
          'tipo': row[3],
          'ra': row[4],
        };

        return Response(201, body: json.encode(usuario), headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        // Log detalhado para debugging
        print('SERVER ERROR: Erro ao criar usuário: $e');
        print('SERVER ERROR: StackTrace: $st');

        // Detectar conflito de email quando possível
        final message = e.toString();
        if (message.contains('duplicate key') || message.contains('unique')) {
          return Response(
            409,
            body: json.encode({'error': 'Email já cadastrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao criar usuário: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // DELETE /api/usuarios/:id - Remover usuário
    router.delete('/<id>', (Request request, String id) async {
      try {
        print('SERVER: Entering DELETE /api/usuarios/$id');
        final userId = int.tryParse(id);
        if (userId == null) {
          return Response.badRequest(
            body: json.encode({'error': 'ID de usuário inválido'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final db = await Database.getInstance();
        final result = await db.connection.execute(
          'DELETE FROM usuarios WHERE id = \$1 RETURNING id',
          parameters: [userId],
        );

        if (result.isEmpty) {
          return Response.notFound(
            json.encode({'error': 'Usuário não encontrado'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.ok(json.encode({'message': 'Usuário removido'}), headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao remover usuário: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}

