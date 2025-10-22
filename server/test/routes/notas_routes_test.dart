import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  const baseUrl = 'http://localhost:8080';
  int? professorId;
  int? alunoId;
  int? disciplinaId;
  int? atividadeId;

  setUpAll(() async {
    // Criar professor de teste
    final profResponse = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': 'Professor Notas',
        'email': 'prof.notas@escola.com',
        'senha': 'senha123',
        'tipo': 'professor',
      }),
    );
    professorId = jsonDecode(profResponse.body)['usuario']['id'];

    // Criar aluno de teste
    final alunoResponse = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': 'Aluno Notas',
        'email': 'aluno.notas@escola.com',
        'senha': 'senha123',
        'tipo': 'aluno',
      }),
    );
    alunoId = jsonDecode(alunoResponse.body)['usuario']['id'];

    // Criar disciplina de teste
    final discResponse = await http.post(
      Uri.parse('$baseUrl/disciplinas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': 'Matemática Notas',
        'cor': '#FF0000',
        'professor_id': professorId,
      }),
    );
    disciplinaId = jsonDecode(discResponse.body)['id'];

    // Criar atividade de teste
    final atividadeResponse = await http.post(
      Uri.parse('$baseUrl/atividades'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'titulo': 'Prova 1',
        'peso': 3.0,
        'disciplina_id': disciplinaId,
      }),
    );
    atividadeId = jsonDecode(atividadeResponse.body)['id'];
  });

  group('Notas Routes - GET', () {
    test('GET /notas/aluno/:id - deve listar notas do aluno', () async {
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

      final response = await http.get(
        Uri.parse('$baseUrl/notas/aluno/$alunoId'),
      );

      expect(response.statusCode, equals(200));

      final data = jsonDecode(response.body);
      expect(data, isA<List>());
      expect(data.length, greaterThan(0));

      // Verificar estrutura da nota
      final nota = data[0];
      expect(nota['aluno_id'], equals(alunoId));
      expect(nota['nota'], isNotNull);
      expect(nota['atividade_titulo'], isNotNull);
      expect(nota['disciplina_nome'], isNotNull);
      expect(nota['peso'], isNotNull);
    });

    test(
      'GET /notas/aluno/:id - deve retornar lista vazia para aluno sem notas',
      () async {
        // Criar novo aluno sem notas
        final novoAlunoResponse = await http.post(
          Uri.parse('$baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Aluno Sem Notas',
            'email': 'aluno.semnotas@escola.com',
            'senha': 'senha123',
            'tipo': 'aluno',
          }),
        );

        final novoAlunoId = jsonDecode(novoAlunoResponse.body)['usuario']['id'];

        final response = await http.get(
          Uri.parse('$baseUrl/notas/aluno/$novoAlunoId'),
        );

        expect(response.statusCode, equals(200));
        final data = jsonDecode(response.body);
        expect(data, equals([]));
      },
    );

    test(
      'GET /notas/aluno/:id - deve retornar notas com JOIN correto',
      () async {
        final response = await http.get(
          Uri.parse('$baseUrl/notas/aluno/$alunoId'),
        );

        final data = jsonDecode(response.body) as List;
        if (data.isNotEmpty) {
          final nota = data[0];

          // Verificar campos do JOIN
          expect(nota.containsKey('atividade_titulo'), isTrue);
          expect(nota.containsKey('disciplina_nome'), isTrue);
          expect(nota.containsKey('peso'), isTrue);
          expect(nota.containsKey('disciplina_cor'), isTrue);
        }
      },
    );

    test('GET /notas/aluno/:id - deve rejeitar ID inválido', () async {
      final response = await http.get(Uri.parse('$baseUrl/notas/aluno/abc'));

      expect(response.statusCode, equals(400));
    });
  });

  group('Notas Routes - POST (Criar)', () {
    test('POST /notas - deve criar nota válida', () async {
      // Criar nova atividade para teste
      final atividadeResponse = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Trabalho 1',
          'peso': 2.0,
          'disciplina_id': disciplinaId,
        }),
      );
      final novaAtividadeId = jsonDecode(atividadeResponse.body)['id'];

      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': novaAtividadeId,
          'nota': 9.5,
        }),
      );

      expect(response.statusCode, equals(201));

      final data = jsonDecode(response.body);
      expect(data['mensagem'], contains('atribuída'));
      expect(data['nota']['aluno_id'], equals(alunoId));
      expect(data['nota']['atividade_id'], equals(novaAtividadeId));
      expect(data['nota']['nota'], equals(9.5));
    });

    test('POST /notas - deve aceitar nota 0', () async {
      final atividadeResponse = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Quiz Nota Zero',
          'peso': 1.0,
          'disciplina_id': disciplinaId,
        }),
      );
      final novaAtividadeId = jsonDecode(atividadeResponse.body)['id'];

      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': novaAtividadeId,
          'nota': 0,
        }),
      );

      expect(response.statusCode, equals(201));
      final data = jsonDecode(response.body);
      expect(data['nota']['nota'], equals(0));
    });

    test('POST /notas - deve aceitar nota 10', () async {
      final atividadeResponse = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Nota Máxima',
          'peso': 1.0,
          'disciplina_id': disciplinaId,
        }),
      );
      final novaAtividadeId = jsonDecode(atividadeResponse.body)['id'];

      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': novaAtividadeId,
          'nota': 10,
        }),
      );

      expect(response.statusCode, equals(201));
      final data = jsonDecode(response.body);
      expect(data['nota']['nota'], equals(10));
    });

    test('POST /notas - deve aceitar nota decimal', () async {
      final atividadeResponse = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Nota Decimal',
          'peso': 1.0,
          'disciplina_id': disciplinaId,
        }),
      );
      final novaAtividadeId = jsonDecode(atividadeResponse.body)['id'];

      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': novaAtividadeId,
          'nota': 7.75,
        }),
      );

      expect(response.statusCode, equals(201));
      final data = jsonDecode(response.body);
      expect(data['nota']['nota'], equals(7.75));
    });

    test('POST /notas - deve rejeitar nota negativa', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': atividadeId,
          'nota': -1,
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /notas - deve rejeitar nota maior que 10', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': atividadeId,
          'nota': 11,
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /notas - deve rejeitar sem aluno_id', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'atividade_id': atividadeId, 'nota': 8.0}),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /notas - deve rejeitar sem atividade_id', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'aluno_id': alunoId, 'nota': 8.0}),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /notas - deve rejeitar sem nota', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'aluno_id': alunoId, 'atividade_id': atividadeId}),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /notas - deve rejeitar aluno_id inexistente', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': 99999,
          'atividade_id': atividadeId,
          'nota': 8.0,
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /notas - deve rejeitar atividade_id inexistente', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': 99999,
          'nota': 8.0,
        }),
      );

      expect(response.statusCode, equals(400));
    });
  });

  group('Notas Routes - POST (UPSERT)', () {
    test('POST /notas - deve atualizar nota existente (UPSERT)', () async {
      // Criar atividade
      final atividadeResponse = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'UPSERT Test',
          'peso': 1.0,
          'disciplina_id': disciplinaId,
        }),
      );
      final testAtividadeId = jsonDecode(atividadeResponse.body)['id'];

      // Primeira nota
      final response1 = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': testAtividadeId,
          'nota': 6.0,
        }),
      );
      expect(response1.statusCode, equals(201));
      expect(jsonDecode(response1.body)['nota']['nota'], equals(6.0));

      // Atualizar nota (mesma combinação aluno/atividade)
      final response2 = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': testAtividadeId,
          'nota': 9.0,
        }),
      );
      expect(response2.statusCode, equals(200));

      final data2 = jsonDecode(response2.body);
      expect(data2['mensagem'], contains('atualizada'));
      expect(data2['nota']['nota'], equals(9.0));

      // Verificar que ainda é uma única nota
      final getResponse = await http.get(
        Uri.parse('$baseUrl/notas/aluno/$alunoId'),
      );
      final notas = jsonDecode(getResponse.body) as List;
      final notasAtividade = notas
          .where((n) => n['atividade_id'] == testAtividadeId)
          .toList();
      expect(notasAtividade.length, equals(1));
      expect(notasAtividade[0]['nota'], equals(9.0));
    });

    test('POST /notas - mensagem diferente para criar vs atualizar', () async {
      // Criar atividade
      final atividadeResponse = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Mensagem Test',
          'peso': 1.0,
          'disciplina_id': disciplinaId,
        }),
      );
      final testAtividadeId = jsonDecode(atividadeResponse.body)['id'];

      // Criar nota
      final response1 = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': testAtividadeId,
          'nota': 7.0,
        }),
      );

      final data1 = jsonDecode(response1.body);
      expect(data1['mensagem'], contains('atribuída'));

      // Atualizar nota
      final response2 = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': testAtividadeId,
          'nota': 8.5,
        }),
      );

      final data2 = jsonDecode(response2.body);
      expect(data2['mensagem'], contains('atualizada'));
    });
  });

  group('Notas Routes - Validação', () {
    test('deve validar tipo de dado da nota', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': atividadeId,
          'nota': 'abc',
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('deve validar tipo de dado do aluno_id', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': 'abc',
          'atividade_id': atividadeId,
          'nota': 8.0,
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('deve validar tipo de dado do atividade_id', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': 'abc',
          'nota': 8.0,
        }),
      );

      expect(response.statusCode, equals(400));
    });
  });

  group('Notas Routes - Business Logic', () {
    test('nota deve ser associada à disciplina da atividade', () async {
      // Criar nova disciplina
      final discResponse = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Física',
          'cor': '#00FF00',
          'professor_id': professorId,
        }),
      );
      final novaDiscId = jsonDecode(discResponse.body)['id'];

      // Criar atividade nesta disciplina
      final atividadeResponse = await http.post(
        Uri.parse('$baseUrl/atividades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': 'Prova Física',
          'peso': 3.0,
          'disciplina_id': novaDiscId,
        }),
      );
      final novaAtividadeId = jsonDecode(atividadeResponse.body)['id'];

      // Criar nota
      await http.post(
        Uri.parse('$baseUrl/notas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoId,
          'atividade_id': novaAtividadeId,
          'nota': 8.0,
        }),
      );

      // Buscar notas do aluno
      final notasResponse = await http.get(
        Uri.parse('$baseUrl/notas/aluno/$alunoId'),
      );

      final notas = jsonDecode(notasResponse.body) as List;
      final notaFisica = notas.firstWhere(
        (n) => n['atividade_id'] == novaAtividadeId,
      );

      expect(notaFisica['disciplina_nome'], equals('Física'));
      expect(notaFisica['disciplina_cor'], equals('#00FF00'));
    });

    test('múltiplas notas para mesmo aluno em diferentes atividades', () async {
      // Criar múltiplas atividades
      final atividades = <int>[];
      for (int i = 1; i <= 3; i++) {
        final response = await http.post(
          Uri.parse('$baseUrl/atividades'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'titulo': 'Atividade $i',
            'peso': 1.0,
            'disciplina_id': disciplinaId,
          }),
        );
        atividades.add(jsonDecode(response.body)['id']);
      }

      // Criar notas para cada atividade
      for (int i = 0; i < atividades.length; i++) {
        await http.post(
          Uri.parse('$baseUrl/notas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoId,
            'atividade_id': atividades[i],
            'nota': 5.0 + i,
          }),
        );
      }

      // Buscar todas as notas
      final response = await http.get(
        Uri.parse('$baseUrl/notas/aluno/$alunoId'),
      );

      final notas = jsonDecode(response.body) as List;
      expect(notas.length, greaterThanOrEqualTo(3));
    });
  });
}
