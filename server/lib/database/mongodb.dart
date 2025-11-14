import 'package:mongo_dart/mongo_dart.dart';
import 'package:dotenv/dotenv.dart';

class MongoDB {
  static MongoDB? _instance;
  late Db _db;
  bool _isConnected = false;

  MongoDB._();

  static Future<MongoDB> getInstance() async {
    if (_instance == null) {
      _instance = MongoDB._();
      await _instance!._connect();
    }
    return _instance!;
  }

  String _timestamp() {
    final now = DateTime.now();
    return '[${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}]';
  }

  Future<void> _connect() async {
    final env = DotEnv()..load();

    // URI de conexão MongoDB Atlas
    // Formato: mongodb+srv://<username>:<password>@<cluster>.mongodb.net/<database>?retryWrites=true&w=majority
    // Obtenha sua connection string no MongoDB Atlas (https://cloud.mongodb.com)
    final mongoUri = env['MONGO_URI'];
    
    if (mongoUri == null || mongoUri.isEmpty) {
      throw Exception(
        'MONGO_URI não configurado no arquivo .env. '
        'Configure sua connection string do MongoDB Atlas.'
      );
    }

    try {
      _db = await Db.create(mongoUri);
      await _db.open();
      _isConnected = true;
      
      print('${_timestamp()} [mongodb] ✅ Conectado ao MongoDB Atlas');
      
      // Criar índices necessários
      await _createIndexes();
    } catch (e) {
      print('${_timestamp()} [mongodb] ❌ Erro ao conectar ao MongoDB Atlas: $e');
      rethrow;
    }
  }

  Future<void> _createIndexes() async {
    try {
      // Índices para coleção de materiais
      final materiais = _db.collection('materiais');
      await materiais.createIndex(keys: {'disciplina_id': 1});
      await materiais.createIndex(keys: {'professor_id': 1});
      await materiais.createIndex(keys: {'criado_em': -1});
      
      // Índices para coleção de arquivos (GridFS metadata)
      final arquivos = _db.collection('arquivos.files');
      await arquivos.createIndex(keys: {'metadata.material_id': 1});
      
      print('${_timestamp()} [mongodb] ✅ Índices criados no MongoDB');
    } catch (e) {
      print('${_timestamp()} [mongodb] ⚠️ Aviso ao criar índices: $e');
    }
  }

  /// Retorna a instância do banco de dados MongoDB
  Db get db => _db;

  /// Verifica se está conectado
  bool get isConnected => _isConnected;

  /// Retorna uma coleção específica
  DbCollection collection(String name) => _db.collection(name);

  /// Retorna o GridFS para gerenciamento de arquivos
  GridFS getGridFS([String bucketName = 'arquivos']) {
    return GridFS(_db, bucketName);
  }

  /// Fecha a conexão com o MongoDB
  Future<void> close() async {
    if (_isConnected) {
      await _db.close();
      _isConnected = false;
      print('${_timestamp()} [mongodb] ❌ Conexão com MongoDB fechada');
    }
  }

  /// Testa a conexão com o MongoDB
  Future<bool> testConnection() async {
    try {
      await _db.collection('system.version').findOne();
      return true;
    } catch (e) {
      print('${_timestamp()} [mongodb] ❌ Falha no teste de conexão: $e');
      return false;
    }
  }
}
