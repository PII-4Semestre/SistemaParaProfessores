import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';

Future<Response> onRequest(RequestContext context) async {
  final body = await context.request.body();
  final data = jsonDecode(body);

  final db = Db('mongodb://localhost:27017/PII4Semestre');
  await db.open();
  final materiais = db.collection('materiais');

  await materiais.insertOne ({
    'nome': data['nome'],
    'descricao': data['descricao'],
    'url_pdf': data['url_pdf'],
    'data_upload': DateTime.now().toIso8601String(),
  });

  await db.close();

  return Response.json(body: {'message': 'Material cadastrado com sucesso!'});
}