import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import 'database/database.dart';
import 'routes/auth_routes.dart';
import 'routes/disciplinas_routes.dart';
import 'routes/atividades_routes.dart';
import 'routes/notas_routes.dart';

void main() async {
  // Carregar variáveis de ambiente
  final env = DotEnv()..load();
  
  // Conectar ao banco de dados
  await Database.getInstance();
  
  // Configurar rotas
  final router = Router()
    ..mount('/api/auth', AuthRoutes().router)
    ..mount('/api/disciplinas', DisciplinasRoutes().router)
    ..mount('/api/atividades', AtividadesRoutes().router)
    ..mount('/api/notas', NotasRoutes().router);
  
  // Middleware para CORS
  final handler = Pipeline()
    .addMiddleware(corsHeaders())
    .addMiddleware(logRequests())
    .addHandler(router.call);
  
  // Iniciar servidor
  final port = int.parse(env['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  
  print('🚀 Servidor rodando em http://${server.address.host}:${server.port}');
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
