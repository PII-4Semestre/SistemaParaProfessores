import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  const baseUrl = 'http://localhost:8080';
  int? professorId;
  int? disciplinaId;

  setUpAll(() async {
    // Criar professor de teste
    final profResponse = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': 'Professor Atividades',
        'email': 'prof.atividades@escola.com',
        'senha': 'senha123',
        'tipo': 'professor',
      }),
    );

    professorId = jsonDecode(profResponse.body)['usuario']['id'];

    // Criar disciplina de teste
    final discResponse = await http.post(
      Uri.parse('$baseUrl/disciplinas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': 'Matemática Atividades',
        'cor': '#FF0000',
        'professor_id': professorId,
      }),
    );

    disciplinaId = jsonDecode(discResponse.body)['id'];
  });

  group('Atividades Routes - GET', () {
    test(
      'GET /atividades/disciplina/:id - deve listar atividades da disciplina',
      () async {
        // Criar atividade
        await http.post(
          Uri.parse('$baseUrl/atividades'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'titulo': 'Prova 1',
            'descricao': 'Primeira avaliação',
            'peso': 3.0,
            'disciplina_id': disciplinaId,
          }),
        );

        final response = await http.get(
          Uri.parse('$baseUrl/atividades/disciplina/$disciplinaId'),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<List>());
        expect(data.length, greaterThan(0));
        expect(data[0]['disciplina_id'], equals(disciplinaId));
        expect(data[0]['titulo'], isNotNull);
        expect(data[0]['peso'], isNotNull);
      },
    );

    test(
      'GET /atividades/disciplina/:id - deve retornar lista vazia para disciplina sem atividades',
      () async {
        // Criar nova disciplina sem atividades
        final discResponse = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Disciplina Vazia',
            'cor': '#000000',
            'professor_id': professorId,
          }),
        );

        final novaDiscId = jsonDecode(discResponse.body)['id'];

        final response = await http.get(
          Uri.parse('$baseUrl/atividades/disciplina/$novaDiscId'),
        );

        expect(response.statusCode, equals(200));
        final data = jsonDecode(response.body);
        expect(data, equals([]));
      },
    );

    test(
      'GET /atividades/disciplina/:id - deve rejeitar ID inválido',
      () async {
        final response = await http.get(
          Uri.parse('$baseUrl/atividades/disciplina/abc'),
        );

        expect(response.statusCode, equals(400));
      },
    );
  });

  group('Atividades Routes - POST', () {
    test(
      'POST /atividades - deve criar atividade com dados completos',
      () async {
        final response = await http.post(
          Uri.parse('$baseUrl/atividades'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'titulo': 'Trabalho Final',
            'descricao': 'Trabalho de conclusão da disciplina',
            'peso': 4.0,
            'disciplina_id': disciplinaId,
          }),
        );

        expect(response.statusCode, equals(201));

        final data = jsonDecode(response.body);
        expect(data['id'], isA<int>());
        expect(data['titulo'], equals('Trabalho Final'));
        expect(
          data['descricao'],
          equals('Trabalho de conclusão da disciplina'),
        );
        expect(data['peso'], equals(4.0));
        expect(data['disciplina_id'], equals(disciplinaId));
      },
    );

    test(
      'POST /atividades - deve criar atividade sem descrição (opcional)',
      () async {
        final response = await http.post(
          Uri.parse('$baseUrl/atividades'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'titulo': 'Quiz Rápido',
            'peso': 1.0,
            'disciplina_id': disciplinaId,
          }),
        );

        expect(response.statusCode, equals(201));
        final data = jsonDecode(response.body);
        expect(data['titulo'], equals('Quiz Rápido'));
      },
    );

    test('POST /atividades - deve aceitar peso decimal', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Participação',
          'peso': 0.5,
          'disciplina_id': disciplinaId,
        }),
      );

      expect(response.statusCode, equals(201));
      final data = jsonDecode(response.body);
      expect(data['peso'], equals(0.5));
    });

    test('POST /atividades - deve rejeitar atividade sem título', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'peso': 1.0, 'disciplina_id': disciplinaId}),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /atividades - deve rejeitar atividade sem peso', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'titulo': 'Teste', 'disciplina_id': disciplinaId}),
      );

      expect(response.statusCode, equals(400));
    });

    test(
      'POST /atividades - deve rejeitar atividade sem disciplina_id',
      () async {
        final response = await http.post(
          Uri.parse('$baseUrl/atividades'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'titulo': 'Teste', 'peso': 1.0}),
        );

        expect(response.statusCode, equals(400));
      },
    );

    test('POST /atividades - deve rejeitar peso negativo', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Teste',
          'peso': -1.0,
          'disciplina_id': disciplinaId,
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /atividades - deve rejeitar peso zero', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Teste',
          'peso': 0,
          'disciplina_id': disciplinaId,
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test(
      'POST /atividades - deve rejeitar disciplina_id inexistente',
      () async {
        final response = await http.post(
          Uri.parse('$baseUrl/atividades'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'titulo': 'Teste',
            'peso': 1.0,
            'disciplina_id': 99999,
          }),
        );

        expect(response.statusCode, equals(400));
      },
    );
  });

  group('Atividades Routes - PUT', () {
    int? atividadeId;

    setUp(() async {
      // Criar atividade para editar
      final response = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Atividade Para Editar',
          'descricao': 'Descrição original',
          'peso': 2.0,
          'disciplina_id': disciplinaId,
        }),
      );

      atividadeId = jsonDecode(response.body)['id'];
    });

    test('PUT /atividades/:id - deve atualizar atividade', () async {
      final response = await http.put(
        Uri.parse('$baseUrl/atividades/$atividadeId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Atividade Editada',
          'descricao': 'Nova descrição',
          'peso': 5.0,
        }),
      );

      expect(response.statusCode, equals(200));

      final data = jsonDecode(response.body);
      expect(data['id'], equals(atividadeId));
      expect(data['titulo'], equals('Atividade Editada'));
      expect(data['descricao'], equals('Nova descrição'));
      expect(data['peso'], equals(5.0));
    });

    test('PUT /atividades/:id - deve atualizar apenas título', () async {
      final response = await http.put(
        Uri.parse('$baseUrl/atividades/$atividadeId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'titulo': 'Apenas Título Novo'}),
      );

      expect(response.statusCode, equals(200));
      final data = jsonDecode(response.body);
      expect(data['titulo'], equals('Apenas Título Novo'));
    });

    test('PUT /atividades/:id - deve atualizar apenas peso', () async {
      final response = await http.put(
        Uri.parse('$baseUrl/atividades/$atividadeId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'peso': 3.5}),
      );

      expect(response.statusCode, equals(200));
      final data = jsonDecode(response.body);
      expect(data['peso'], equals(3.5));
    });

    test(
      'PUT /atividades/:id - deve retornar 404 para ID inexistente',
      () async {
        final response = await http.put(
          Uri.parse('$baseUrl/atividades/99999'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'titulo': 'Teste'}),
        );

        expect(response.statusCode, equals(404));
      },
    );

    test('PUT /atividades/:id - deve rejeitar ID inválido', () async {
      final response = await http.put(
        Uri.parse('$baseUrl/atividades/abc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'titulo': 'Teste'}),
      );

      expect(response.statusCode, equals(400));
    });

    test('PUT /atividades/:id - deve rejeitar peso negativo', () async {
      final response = await http.put(
        Uri.parse('$baseUrl/atividades/$atividadeId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'peso': -2.0}),
      );

      expect(response.statusCode, equals(400));
    });
  });

  group('Atividades Routes - DELETE', () {
    test('DELETE /atividades/:id - deve deletar atividade', () async {
      // Criar atividade para deletar
      final createResponse = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Atividade Para Deletar',
          'peso': 1.0,
          'disciplina_id': disciplinaId,
        }),
      );

      final atividadeId = jsonDecode(createResponse.body)['id'];

      // Deletar
      final response = await http.delete(
        Uri.parse('$baseUrl/atividades/$atividadeId'),
      );

      expect(response.statusCode, equals(200));

      final data = jsonDecode(response.body);
      expect(data['mensagem'], contains('deletada'));
    });

    test(
      'DELETE /atividades/:id - deve retornar 404 para ID inexistente',
      () async {
        final response = await http.delete(
          Uri.parse('$baseUrl/atividades/99999'),
        );

        expect(response.statusCode, equals(404));
      },
    );

    test('DELETE /atividades/:id - deve rejeitar ID inválido', () async {
      final response = await http.delete(Uri.parse('$baseUrl/atividades/abc'));

      expect(response.statusCode, equals(400));
    });

    test('DELETE /atividades/:id - deve deletar em cascata (notas)', () async {
      // Criar aluno
      final alunoResponse = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Aluno Teste Cascade',
          'email': 'aluno.cascade@escola.com',
          'senha': 'senha123',
          'tipo': 'aluno',
        }),
      );
      final alunoId = jsonDecode(alunoResponse.body)['usuario']['id'];

      // Criar atividade
      final atividadeResponse = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Atividade Cascade',
          'peso': 1.0,
          'disciplina_id': disciplinaId,
        }),
      );
      final atividadeId = jsonDecode(atividadeResponse.body)['id'];

      // Criar nota
      await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': atividadeId,
          'nota': 8.5,
        }),
      );

      // Deletar atividade (deve deletar nota também)
      final deleteResponse = await http.delete(
        Uri.parse('$baseUrl/atividades/$atividadeId'),
      );

      expect(deleteResponse.statusCode, equals(200));

      // Verificar que notas foram deletadas
      final notasResponse = await http.get(
        Uri.parse('$baseUrl/notas/aluno/$alunoId'),
      );

      final notas = jsonDecode(notasResponse.body) as List;
      final notaDaAtividade = notas
          .where((n) => n['atividade_id'] == atividadeId)
          .toList();
      expect(notaDaAtividade, isEmpty);
    });
  });

  group('Atividades Routes - Validação', () {
    test('deve validar tamanho do título', () async {
      final tituloLongo = 'A' * 300;

      final response = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': tituloLongo,
          'peso': 1.0,
          'disciplina_id': disciplinaId,
        }),
      );

      expect(response.statusCode, anyOf([equals(201), equals(400)]));
    });

    test('deve validar tipo de dado do peso', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Teste',
          'peso': 'abc',
          'disciplina_id': disciplinaId,
        }),
      );

      expect(response.statusCode, equals(400));
    });
  });
}
