import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

class Database {
  static Database? _instance;
  late Connection _connection;
  
  Database._();
  
  static Future<Database> getInstance() async {
    if (_instance == null) {
      _instance = Database._();
      await _instance!._connect();
    }
    return _instance!;
  }
  
  Future<void> _connect() async {
    final env = DotEnv()..load();
    
    final endpoint = Endpoint(
      host: env['DB_HOST'] ?? 'localhost',
      port: int.parse(env['DB_PORT'] ?? '5432'),
      database: env['DB_NAME'] ?? 'sistema_professores',
      username: env['DB_USER'] ?? 'postgres',
      password: env['DB_PASSWORD'] ?? '',
    );
    
    _connection = await Connection.open(
      endpoint,
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
        encoding: utf8,
      ),
    );
    
    print('✅ Conectado ao PostgreSQL');
  }
  
  Connection get connection => _connection;
  
  Future<void> close() async {
    await _connection.close();
    print('❌ Conexão com PostgreSQL fechada');
  }
}
