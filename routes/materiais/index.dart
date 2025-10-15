import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = Db('mongodb://localhost:27017/PII4Semestre');
  await db.open();
  final materiais = db.collection('materiais');
  final lista = await materiais.find().toList();
  await db.close();

  return Response.json(body: lista);
}