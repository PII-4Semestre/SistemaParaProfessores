import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  final Db db;
  final DbCollection materiais;

  MongoService(String uri)
    : db = Db(uri),
      materiais = Db(uri).collection('materiais');

  Future<void> connect() async {
    await db.open();
  }

  Future<void> close() async {
    await db.close();
  }

}