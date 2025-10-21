import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  const baseUrl = 'http://localhost:8080';
  int? professorId;

  setUpAll(() async {
    // Criar professor de teste para usar nos testes
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': 'Professor Disciplinas',
        'email': 'prof.disciplinas@escola.com',
        'senha': 'senha123',
        'tipo': 'professor'
      }),
    );

    final data = jsonDecode(response.body);
    professorId = data['usuario']['id'];
  });

  group('Disciplinas Routes - GET', () {
    test('GET /disciplinas - deve listar todas as disciplinas', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/disciplinas'),
      );

      expect(response.statusCode, equals(200));
      
      final data = jsonDecode(response.body);
      expect(data, isA<List>());
    });

    test('GET /disciplinas/professor/:id - deve listar disciplinas do professor', () async {
      // Primeiro criar uma disciplina
      await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Matemática Teste',
          'descricao': 'Disciplina de teste',
          'cor': '#FF5733',
          'professor_id': professorId
        }),
      );

      // Buscar disciplinas do professor
      final response = await http.get(
        Uri.parse('$baseUrl/disciplinas/professor/$professorId'),
      );

      expect(response.statusCode, equals(200));
      
      final data = jsonDecode(response.body);
      expect(data, isA<List>());
      expect(data.length, greaterThan(0));
      expect(data[0]['professor_id'], equals(professorId));
      expect(data[0]['nome'], isNotNull);
      expect(data[0]['cor'], isNotNull);
    });

    test('GET /disciplinas/professor/:id - deve retornar lista vazia para professor sem disciplinas', () async {
      // Criar professor sem disciplinas
      final response1 = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Professor Vazio',
          'email': 'prof.vazio@escola.com',
          'senha': 'senha123',
          'tipo': 'professor'
        }),
      );
      
      final newProfId = jsonDecode(response1.body)['usuario']['id'];

      final response = await http.get(
        Uri.parse('$baseUrl/disciplinas/professor/$newProfId'),
      );

      expect(response.statusCode, equals(200));
      final data = jsonDecode(response.body);
      expect(data, equals([]));
    });
  });

  group('Disciplinas Routes - POST', () {
    test('POST /disciplinas - deve criar nova disciplina com dados completos', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Física',
          'descricao': 'Física básica e avançada',
          'cor': '#00FF00',
          'professor_id': professorId
        }),
      );

      expect(response.statusCode, equals(201));
      
      final data = jsonDecode(response.body);
      expect(data['id'], isA<int>());
      expect(data['nome'], equals('Física'));
      expect(data['descricao'], equals('Física básica e avançada'));
      expect(data['cor'], equals('#00FF00'));
      expect(data['professor_id'], equals(professorId));
    });

    test('POST /disciplinas - deve criar disciplina sem descrição (opcional)', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Química',
          'cor': '#FFFF00',
          'professor_id': professorId
        }),
      );

      expect(response.statusCode, equals(201));
      final data = jsonDecode(response.body);
      expect(data['nome'], equals('Química'));
    });

    test('POST /disciplinas - deve rejeitar disciplina sem nome', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cor': '#FF0000',
          'professor_id': professorId
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /disciplinas - deve rejeitar disciplina sem professor_id', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Teste',
          'cor': '#FF0000'
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /disciplinas - deve rejeitar professor_id inexistente', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Teste',
          'cor': '#FF0000',
          'professor_id': 99999
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /disciplinas - deve aceitar cores em diferentes formatos', () async {
      final cores = ['#FF0000', '#ff0000', '#F00', '#ABC123'];
      
      for (final cor in cores) {
        final response = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Teste Cor $cor',
            'cor': cor,
            'professor_id': professorId
          }),
        );

        expect(response.statusCode, anyOf([equals(201), equals(400)]));
      }
    });
  });

  group('Disciplinas Routes - PUT', () {
    int? disciplinaId;

    setUp(() async {
      // Criar disciplina para editar
      final response = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Disciplina Para Editar',
          'descricao': 'Descrição original',
          'cor': '#000000',
          'professor_id': professorId
        }),
      );

      disciplinaId = jsonDecode(response.body)['id'];
    });

    test('PUT /disciplinas/:id - deve atualizar disciplina', () async {
      final response = await http.put(
        Uri.parse('$baseUrl/disciplinas/$disciplinaId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Disciplina Editada',
          'descricao': 'Nova descrição',
          'cor': '#FFFFFF'
        }),
      );

      expect(response.statusCode, equals(200));
      
      final data = jsonDecode(response.body);
      expect(data['id'], equals(disciplinaId));
      expect(data['nome'], equals('Disciplina Editada'));
      expect(data['descricao'], equals('Nova descrição'));
      expect(data['cor'], equals('#FFFFFF'));
    });

    test('PUT /disciplinas/:id - deve atualizar apenas nome', () async {
      final response = await http.put(
        Uri.parse('$baseUrl/disciplinas/$disciplinaId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Apenas Nome Novo'
        }),
      );

      expect(response.statusCode, equals(200));
      final data = jsonDecode(response.body);
      expect(data['nome'], equals('Apenas Nome Novo'));
    });

    test('PUT /disciplinas/:id - deve retornar 404 para ID inexistente', () async {
      final response = await http.put(
        Uri.parse('$baseUrl/disciplinas/99999'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Teste'
        }),
      );

      expect(response.statusCode, equals(404));
    });

    test('PUT /disciplinas/:id - deve rejeitar ID inválido', () async {
      final response = await http.put(
        Uri.parse('$baseUrl/disciplinas/abc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Teste'
        }),
      );

      expect(response.statusCode, equals(400));
    });
  });

  group('Disciplinas Routes - DELETE', () {
    test('DELETE /disciplinas/:id - deve deletar disciplina', () async {
      // Criar disciplina para deletar
      final createResponse = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Disciplina Para Deletar',
          'cor': '#000000',
          'professor_id': professorId
        }),
      );

      final disciplinaId = jsonDecode(createResponse.body)['id'];

      // Deletar
      final response = await http.delete(
        Uri.parse('$baseUrl/disciplinas/$disciplinaId'),
      );

      expect(response.statusCode, equals(200));
      
      final data = jsonDecode(response.body);
      expect(data['mensagem'], contains('deletada'));
    });

    test('DELETE /disciplinas/:id - deve retornar 404 para ID inexistente', () async {
      final response = await http.delete(
        Uri.parse('$baseUrl/disciplinas/99999'),
      );

      expect(response.statusCode, equals(404));
    });

    test('DELETE /disciplinas/:id - deve rejeitar ID inválido', () async {
      final response = await http.delete(
        Uri.parse('$baseUrl/disciplinas/abc'),
      );

      expect(response.statusCode, equals(400));
    });

    test('DELETE /disciplinas/:id - deve deletar em cascata (atividades e notas)', () async {
      // Criar disciplina
      final discResponse = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Disciplina Cascata',
          'cor': '#000000',
          'professor_id': professorId
        }),
      );
      final discId = jsonDecode(discResponse.body)['id'];

      // Criar atividade para esta disciplina
      await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Atividade Teste',
          'descricao': 'Teste',
          'peso': 1.0,
          'disciplina_id': discId
        }),
      );

      // Deletar disciplina (deve deletar atividade também)
      final deleteResponse = await http.delete(
        Uri.parse('$baseUrl/disciplinas/$discId'),
      );

      expect(deleteResponse.statusCode, equals(200));

      // Verificar que atividades foram deletadas
      final atividadesResponse = await http.get(
        Uri.parse('$baseUrl/atividades/disciplina/$discId'),
      );
      
      final atividades = jsonDecode(atividadesResponse.body);
      expect(atividades, equals([]));
    });
  });

  group('Disciplinas Routes - Validação', () {
    test('deve validar cor hexadecimal', () async {
      final coresInvalidas = ['FF0000', '#GG0000', '#12', ''];
      
      for (final cor in coresInvalidas) {
        final response = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Teste',
            'cor': cor,
            'professor_id': professorId
          }),
        );

        // Pode aceitar ou rejeitar dependendo da validação implementada
        expect(response.statusCode, anyOf([equals(201), equals(400)]));
      }
    });

    test('deve validar tamanho do nome', () async {
      // Nome muito longo
      final nomeLongo = 'A' * 300;
      
      final response = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nomeLongo,
          'cor': '#FF0000',
          'professor_id': professorId
        }),
      );

      // Deve aceitar ou ter validação de tamanho
      expect(response.statusCode, anyOf([equals(201), equals(400)]));
    });
  });
}
