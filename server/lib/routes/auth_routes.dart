import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sistema_professores_server/database/database.dart';

class AuthRoutes {
  Router get router {
    final router = Router();

    // POST /api/auth/login
    router.post('/login', (Request request) async {
      try {
        final payload = json.decode(await request.readAsString());
        final email = payload['email'];
        final senha = payload['senha'];

        if (email == null || senha == null) {
          return Response(
            400,
            body: json.encode({'error': 'Email e senha são obrigatórios'}),
          );
        }

        final db = await Database.getInstance();
        final result = await db.connection.execute(
          'SELECT id, nome, email, tipo::text, ra FROM usuarios WHERE email = \$1',
          parameters: [email],
        );

        if (result.isEmpty) {
          return Response(
            401,
            body: json.encode({'error': 'Credenciais inválidas'}),
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

        // TODO: Verificar senha com bcrypt
        // Por enquanto, aceita qualquer senha para desenvolvimento

        return Response.ok(
          json.encode({
            'user': usuario,
            'token': 'mock_jwt_token_${usuario['id']}', // TODO: Gerar JWT real
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao fazer login: $e'}),
        );
      }
    });

    // POST /api/auth/register
    router.post('/register', (Request request) async {
      try {
        final payload = json.decode(await request.readAsString());

        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          INSERT INTO usuarios (nome, email, senha_hash, tipo, ra)
          VALUES (\$1, \$2, \$3, \$4::tipo_usuario, \$5)
          RETURNING id, nome, email, tipo::text, ra
          ''',
          parameters: [
            payload['nome'],
            payload['email'],
            payload['senha'], // TODO: Hash com bcrypt
            payload['tipo'],
            payload['ra'],
          ],
        );

        final row = result.first;
        return Response.ok(
          json.encode({
            'id': row[0],
            'nome': row[1],
            'email': row[2],
            'tipo': row[3],
            'ra': row[4],
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao registrar usuário: $e'}),
        );
      }
    });

    return router;
  }
}
