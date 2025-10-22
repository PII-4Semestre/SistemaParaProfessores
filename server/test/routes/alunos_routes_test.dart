import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  const baseUrl = 'http://localhost:8080';
  int? professorId;
  int? disciplinaId;
  List<int> alunoIds = [];

  setUpAll(() async {
    // Criar professor de teste
    final profResponse = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': 'Professor Alunos',
        'email': 'prof.alunos@escola.com',
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
        'nome': 'Matemática Alunos',
        'cor': '#FF0000',
        'professor_id': professorId,
      }),
    );
    disciplinaId = jsonDecode(discResponse.body)['id'];

    // Criar 5 alunos de teste
    for (int i = 1; i <= 5; i++) {
      final alunoResponse = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Aluno Teste $i',
          'email': 'aluno.teste$i@escola.com',
          'senha': 'senha123',
          'tipo': 'aluno',
        }),
      );
      alunoIds.add(jsonDecode(alunoResponse.body)['usuario']['id']);
    }
  });

  group('Alunos Routes - GET /', () {
    test('GET /alunos - deve listar todos os alunos', () async {
      final response = await http.get(Uri.parse('$baseUrl/alunos'));

      expect(response.statusCode, equals(200));

      final data = jsonDecode(response.body);
      expect(data, isA<List>());
      expect(data.length, greaterThan(0));

      // Verificar estrutura do aluno
      final aluno = data[0];
      expect(aluno['id'], isNotNull);
      expect(aluno['nome'], isNotNull);
      expect(aluno['email'], isNotNull);
      expect(aluno['ra'], isNotNull);
      expect(aluno['disciplinas'], isNotNull);
    });

    test('GET /alunos - deve incluir disciplinas matriculadas', () async {
      // Matricular aluno em uma disciplina
      await http.post(
        Uri.parse('$baseUrl/alunos/matricular'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aluno_id': alunoIds[0],
          'disciplina_id': disciplinaId,
        }),
      );

      final response = await http.get(Uri.parse('$baseUrl/alunos'));

      final alunos = jsonDecode(response.body) as List;
      final alunoMatriculado = alunos.firstWhere((a) => a['id'] == alunoIds[0]);

      expect(alunoMatriculado['disciplinas'], isA<List>());
      final disciplinas = alunoMatriculado['disciplinas'] as List;
      expect(
        disciplinas.any((d) => d['disciplina_id'] == disciplinaId),
        isTrue,
      );
    });

    test('GET /alunos - disciplinas devem incluir dados completos', () async {
      final response = await http.get(Uri.parse('$baseUrl/alunos'));

      final alunos = jsonDecode(response.body) as List;

      for (final aluno in alunos) {
        final disciplinas = aluno['disciplinas'] as List;
        for (final disc in disciplinas) {
          expect(disc['disciplina_id'], isNotNull);
          expect(disc['disciplina_nome'], isNotNull);
          expect(disc['disciplina_cor'], isNotNull);
          expect(disc['professor_nome'], isNotNull);
        }
      }
    });
  });

  group('Alunos Routes - GET /:id/disciplinas', () {
    test(
      'GET /alunos/:id/disciplinas - deve listar disciplinas do aluno',
      () async {
        // Matricular aluno em disciplina
        await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[1],
            'disciplina_id': disciplinaId,
          }),
        );

        final response = await http.get(
          Uri.parse('$baseUrl/alunos/${alunoIds[1]}/disciplinas'),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<List>());
        expect(data.length, greaterThan(0));

        // Verificar estrutura da disciplina
        final disc = data[0];
        expect(disc['disciplina_id'], equals(disciplinaId));
        expect(disc['disciplina_nome'], isNotNull);
        expect(disc['disciplina_cor'], isNotNull);
        expect(disc['professor_nome'], isNotNull);
      },
    );

    test(
      'GET /alunos/:id/disciplinas - deve retornar lista vazia para aluno sem disciplinas',
      () async {
        final response = await http.get(
          Uri.parse('$baseUrl/alunos/${alunoIds[4]}/disciplinas'),
        );

        expect(response.statusCode, equals(200));
        final data = jsonDecode(response.body);
        expect(data, equals([]));
      },
    );

    test('GET /alunos/:id/disciplinas - deve rejeitar ID inválido', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/alunos/abc/disciplinas'),
      );

      expect(response.statusCode, equals(400));
    });
  });

  group('Alunos Routes - GET /disciplina/:id', () {
    test(
      'GET /alunos/disciplina/:id - deve listar alunos da disciplina',
      () async {
        // Matricular aluno
        await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[2],
            'disciplina_id': disciplinaId,
          }),
        );

        final response = await http.get(
          Uri.parse('$baseUrl/alunos/disciplina/$disciplinaId'),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<List>());
        expect(data.length, greaterThan(0));

        // Verificar estrutura do aluno
        final aluno = data[0];
        expect(aluno['id'], isNotNull);
        expect(aluno['nome'], isNotNull);
        expect(aluno['email'], isNotNull);
        expect(aluno['ra'], isNotNull);
      },
    );

    test(
      'GET /alunos/disciplina/:id - deve retornar lista vazia para disciplina sem alunos',
      () async {
        // Criar nova disciplina sem alunos
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
          Uri.parse('$baseUrl/alunos/disciplina/$novaDiscId'),
        );

        expect(response.statusCode, equals(200));
        final data = jsonDecode(response.body);
        expect(data, equals([]));
      },
    );

    test('GET /alunos/disciplina/:id - deve rejeitar ID inválido', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/alunos/disciplina/abc'),
      );

      expect(response.statusCode, equals(400));
    });
  });

  group('Alunos Routes - GET /disponiveis/:disciplina_id', () {
    test(
      'GET /alunos/disponiveis/:id - deve listar alunos não matriculados',
      () async {
        // Criar nova disciplina
        final discResponse = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Nova Disciplina',
            'cor': '#00FF00',
            'professor_id': professorId,
          }),
        );
        final novaDiscId = jsonDecode(discResponse.body)['id'];

        final response = await http.get(
          Uri.parse('$baseUrl/alunos/disponiveis/$novaDiscId'),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data, isA<List>());
        // Todos os alunos devem estar disponíveis para nova disciplina
        expect(data.length, greaterThanOrEqualTo(alunoIds.length));
      },
    );

    test(
      'GET /alunos/disponiveis/:id - não deve incluir alunos já matriculados',
      () async {
        // Criar disciplina
        final discResponse = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Disciplina Filtro',
            'cor': '#0000FF',
            'professor_id': professorId,
          }),
        );
        final testDiscId = jsonDecode(discResponse.body)['id'];

        // Matricular um aluno
        await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[0],
            'disciplina_id': testDiscId,
          }),
        );

        // Buscar disponíveis
        final response = await http.get(
          Uri.parse('$baseUrl/alunos/disponiveis/$testDiscId'),
        );

        final disponiveis = jsonDecode(response.body) as List;
        final alunoMatriculado = disponiveis.any((a) => a['id'] == alunoIds[0]);

        expect(alunoMatriculado, isFalse);
      },
    );

    test(
      'GET /alunos/disponiveis/:id - deve retornar todos se ninguém matriculado',
      () async {
        // Criar disciplina nova
        final discResponse = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Totalmente Vazia',
            'cor': '#FFFF00',
            'professor_id': professorId,
          }),
        );
        final vaziaDiscId = jsonDecode(discResponse.body)['id'];

        final response = await http.get(
          Uri.parse('$baseUrl/alunos/disponiveis/$vaziaDiscId'),
        );

        final disponiveis = jsonDecode(response.body) as List;

        // Deve ter pelo menos os alunos criados no setup
        expect(disponiveis.length, greaterThanOrEqualTo(alunoIds.length));
      },
    );

    test('GET /alunos/disponiveis/:id - deve rejeitar ID inválido', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/alunos/disponiveis/abc'),
      );

      expect(response.statusCode, equals(400));
    });
  });

  group('Alunos Routes - POST /matricular', () {
    test(
      'POST /alunos/matricular - deve matricular aluno com sucesso',
      () async {
        // Criar nova disciplina para teste limpo
        final discResponse = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Teste Matrícula',
            'cor': '#FF00FF',
            'professor_id': professorId,
          }),
        );
        final testDiscId = jsonDecode(discResponse.body)['id'];

        final response = await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[3],
            'disciplina_id': testDiscId,
          }),
        );

        expect(response.statusCode, equals(201));

        final data = jsonDecode(response.body);
        expect(data['mensagem'], contains('matriculado'));
      },
    );

    test(
      'POST /alunos/matricular - deve aparecer nas listas após matrícula',
      () async {
        // Criar disciplina
        final discResponse = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Verificação Matrícula',
            'cor': '#00FFFF',
            'professor_id': professorId,
          }),
        );
        final testDiscId = jsonDecode(discResponse.body)['id'];

        // Matricular
        await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[4],
            'disciplina_id': testDiscId,
          }),
        );

        // Verificar em GET /alunos/disciplina/:id
        final alunosResponse = await http.get(
          Uri.parse('$baseUrl/alunos/disciplina/$testDiscId'),
        );
        final alunos = jsonDecode(alunosResponse.body) as List;
        expect(alunos.any((a) => a['id'] == alunoIds[4]), isTrue);

        // Verificar em GET /alunos/:id/disciplinas
        final discsResponse = await http.get(
          Uri.parse('$baseUrl/alunos/${alunoIds[4]}/disciplinas'),
        );
        final disciplinas = jsonDecode(discsResponse.body) as List;
        expect(
          disciplinas.any((d) => d['disciplina_id'] == testDiscId),
          isTrue,
        );
      },
    );

    test(
      'POST /alunos/matricular - deve rejeitar matrícula duplicada',
      () async {
        // Criar disciplina
        final discResponse = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Teste Duplicação',
            'cor': '#AABBCC',
            'professor_id': professorId,
          }),
        );
        final testDiscId = jsonDecode(discResponse.body)['id'];

        // Primeira matrícula
        final response1 = await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[0],
            'disciplina_id': testDiscId,
          }),
        );
        expect(response1.statusCode, equals(201));

        // Segunda matrícula (duplicada)
        final response2 = await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[0],
            'disciplina_id': testDiscId,
          }),
        );

        expect(response2.statusCode, equals(409)); // Conflict
        final data = jsonDecode(response2.body);
        expect(data['erro'], contains('já matriculado'));
      },
    );

    test(
      'POST /alunos/matricular - deve rejeitar aluno_id inexistente',
      () async {
        final response = await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'aluno_id': 99999, 'disciplina_id': disciplinaId}),
        );

        expect(response.statusCode, equals(400));
      },
    );

    test(
      'POST /alunos/matricular - deve rejeitar disciplina_id inexistente',
      () async {
        final response = await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'aluno_id': alunoIds[0], 'disciplina_id': 99999}),
        );

        expect(response.statusCode, equals(400));
      },
    );

    test('POST /alunos/matricular - deve rejeitar sem aluno_id', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/alunos/matricular'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'disciplina_id': disciplinaId}),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /alunos/matricular - deve rejeitar sem disciplina_id', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/alunos/matricular'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'aluno_id': alunoIds[0]}),
      );

      expect(response.statusCode, equals(400));
    });
  });

  group('Alunos Routes - DELETE /desmatricular', () {
    test(
      'DELETE /alunos/desmatricular - deve remover matrícula com sucesso',
      () async {
        // Criar disciplina e matricular
        final discResponse = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Teste Desmatrícula',
            'cor': '#123456',
            'professor_id': professorId,
          }),
        );
        final testDiscId = jsonDecode(discResponse.body)['id'];

        await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[1],
            'disciplina_id': testDiscId,
          }),
        );

        // Desmatricular
        final response = await http.delete(
          Uri.parse('$baseUrl/alunos/desmatricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[1],
            'disciplina_id': testDiscId,
          }),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data['mensagem'], contains('desmatriculado'));
      },
    );

    test(
      'DELETE /alunos/desmatricular - não deve aparecer nas listas após',
      () async {
        // Criar disciplina e matricular
        final discResponse = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Verificação Desmatrícula',
            'cor': '#654321',
            'professor_id': professorId,
          }),
        );
        final testDiscId = jsonDecode(discResponse.body)['id'];

        await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[2],
            'disciplina_id': testDiscId,
          }),
        );

        // Desmatricular
        await http.delete(
          Uri.parse('$baseUrl/alunos/desmatricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'aluno_id': alunoIds[2],
            'disciplina_id': testDiscId,
          }),
        );

        // Verificar que não aparece mais
        final alunosResponse = await http.get(
          Uri.parse('$baseUrl/alunos/disciplina/$testDiscId'),
        );
        final alunos = jsonDecode(alunosResponse.body) as List;
        expect(alunos.any((a) => a['id'] == alunoIds[2]), isFalse);

        // Verificar que voltou para disponíveis
        final disponiveisResponse = await http.get(
          Uri.parse('$baseUrl/alunos/disponiveis/$testDiscId'),
        );
        final disponiveis = jsonDecode(disponiveisResponse.body) as List;
        expect(disponiveis.any((a) => a['id'] == alunoIds[2]), isTrue);
      },
    );

    test(
      'DELETE /alunos/desmatricular - deve retornar 404 para matrícula inexistente',
      () async {
        final response = await http.delete(
          Uri.parse('$baseUrl/alunos/desmatricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'aluno_id': alunoIds[0], 'disciplina_id': 99999}),
        );

        expect(response.statusCode, equals(404));
      },
    );

    test('DELETE /alunos/desmatricular - deve rejeitar sem aluno_id', () async {
      final response = await http.delete(
        Uri.parse('$baseUrl/alunos/desmatricular'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'disciplina_id': disciplinaId}),
      );

      expect(response.statusCode, equals(400));
    });

    test(
      'DELETE /alunos/desmatricular - deve rejeitar sem disciplina_id',
      () async {
        final response = await http.delete(
          Uri.parse('$baseUrl/alunos/desmatricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'aluno_id': alunoIds[0]}),
        );

        expect(response.statusCode, equals(400));
      },
    );
  });

  group('Alunos Routes - Business Logic', () {
    test('múltiplos alunos podem se matricular na mesma disciplina', () async {
      // Criar disciplina
      final discResponse = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Disciplina Popular',
          'cor': '#ABCDEF',
          'professor_id': professorId,
        }),
      );
      final testDiscId = jsonDecode(discResponse.body)['id'];

      // Matricular múltiplos alunos
      for (final alunoId in alunoIds.take(3)) {
        final response = await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'aluno_id': alunoId, 'disciplina_id': testDiscId}),
        );
        expect(response.statusCode, equals(201));
      }

      // Verificar que todos foram matriculados
      final alunosResponse = await http.get(
        Uri.parse('$baseUrl/alunos/disciplina/$testDiscId'),
      );
      final alunos = jsonDecode(alunosResponse.body) as List;
      expect(alunos.length, equals(3));
    });

    test('aluno pode se matricular em múltiplas disciplinas', () async {
      final testAlunoId = alunoIds[0];

      // Criar múltiplas disciplinas e matricular
      for (int i = 1; i <= 3; i++) {
        final discResponse = await http.post(
          Uri.parse('$baseUrl/disciplinas'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nome': 'Disciplina Multi $i',
            'cor': '#FF00${i}0',
            'professor_id': professorId,
          }),
        );
        final discId = jsonDecode(discResponse.body)['id'];

        await http.post(
          Uri.parse('$baseUrl/alunos/matricular'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'aluno_id': testAlunoId, 'disciplina_id': discId}),
        );
      }

      // Verificar disciplinas do aluno
      final response = await http.get(
        Uri.parse('$baseUrl/alunos/$testAlunoId/disciplinas'),
      );

      final disciplinas = jsonDecode(response.body) as List;
      expect(disciplinas.length, greaterThanOrEqualTo(3));
    });
  });
}
