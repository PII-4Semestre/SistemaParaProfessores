import 'dart:io';
import 'dart:developer' as developer;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import 'package:sistema_professores_server/database/database.dart';
import 'package:sistema_professores_server/database/mongodb.dart';
import 'package:sistema_professores_server/routes/auth_routes.dart';
import 'package:sistema_professores_server/routes/disciplinas_routes.dart';
import 'package:sistema_professores_server/routes/atividades_routes.dart';
import 'package:sistema_professores_server/routes/notas_routes.dart';
import 'package:sistema_professores_server/routes/alunos_routes.dart';
import 'package:sistema_professores_server/routes/materiais_routes.dart';
import 'package:sistema_professores_server/routes/mensagens_routes.dart';
import 'package:sistema_professores_server/routes/usuarios_routes.dart';

/// Helper para formatar timestamp nos logs
String _timestamp() {
  final now = DateTime.now();
  return '[${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}:'
      '${now.second.toString().padLeft(2, '0')}]';
}

void main() async {
  // Carregar variáveis de ambiente
  final env = DotEnv()..load();

  print('${_timestamp()} Iniciando servidor...');

  // Conectar ao PostgreSQL
  await Database.getInstance();

  // Conectar ao MongoDB
  try {
    await MongoDB.getInstance();
  } catch (e) {
    print('${_timestamp()} [server] ⚠️ MongoDB não disponível. Recursos de materiais estarão desabilitados: $e');
  }

  // Configurar rotas
  final router = Router()
    ..mount('/api/auth', AuthRoutes().router.call)
    ..mount('/api/disciplinas', DisciplinasRoutes().router.call)
    ..mount('/api/atividades', AtividadesRoutes().router.call)
    ..mount('/api/notas', NotasRoutes().router.call)
    ..mount('/api/alunos', AlunosRoutes().router.call)
    ..mount('/api/materiais', MateriaisRoutes().router.call)
    ..mount('/api/mensagens', MensagensRoutes().router.call)
    ..mount('/api/usuarios', UsuariosRoutes().router.call);

  // Middleware para CORS
  Middleware requestLogger() {
    return (Handler handler) {
      return (Request request) async {
        try {
          print('${_timestamp()} [server] ⤴️ ${request.method} ${request.requestedUri}');
        } catch (_) {}
        return await handler(request);
      };
    };
  }

  final handler = Pipeline()
      .addMiddleware(requestLogger())
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addMiddleware(handleErrors())
      .addHandler(router.call);

  // Iniciar servidor
  final port = int.parse(env['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print(
    '${_timestamp()} [server] 🚀 Servidor rodando em http://${server.address.host}:${server.port}',
  );
}

Middleware corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders());
      }

      final response = await handler(request);
      return response.change(headers: _corsHeaders());
    };
  };
}

Map<String, String> _corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };
}

Middleware handleErrors() {
  return (Handler handler) {
    return (Request request) async {
      try {
        return await handler(request);
      } catch (error, stackTrace) {
        developer.log(
          '❌ Error handling request: $error',
          name: 'server',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
        return Response.internalServerError(
          body: '{"error": "Internal server error: $error"}',
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  };
}
