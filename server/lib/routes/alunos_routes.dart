import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sistema_professores_server/database/database.dart';

class AlunosRoutes {
  Router get router {
    final router = Router();
    
    // GET /api/alunos - Listar todos os alunos com suas disciplinas
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        
        // Buscar todos os alunos
        final alunosResult = await db.connection.execute(
          '''
          SELECT id, nome, email, ra, criado_em
          FROM usuarios
          WHERE tipo = 'aluno'
          ORDER BY nome
          ''',
        );
        
        final alunos = <Map<String, dynamic>>[];
        
        for (final alunoRow in alunosResult) {
          final alunoId = alunoRow[0] as int;
          
          // Buscar disciplinas do aluno
          final disciplinasResult = await db.connection.execute(
            '''
            SELECT d.id, d.nome, d.cor
            FROM disciplinas d
            INNER JOIN aluno_disciplina ad ON d.id = ad.disciplina_id
            WHERE ad.aluno_id = \$1
            ORDER BY d.nome
            ''',
            parameters: [alunoId],
          );
          
          final disciplinas = disciplinasResult.map((row) => {
            'id': row[0],
            'nome': row[1],
            'cor': row[2],
          }).toList();
          
          alunos.add({
            'id': alunoId,
            'nome': alunoRow[1],
            'email': alunoRow[2],
            'ra': alunoRow[3],
            'criado_em': alunoRow[4]?.toString(),
            'disciplinas': disciplinas,
          });
        }
        
        return Response.ok(
          json.encode(alunos),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar alunos: $e'}),
        );
      }
    });
    
    // GET /api/alunos/disciplina/<id> - Listar alunos matriculados em uma disciplina
    router.get('/disciplina/<id>', (Request request, String id) async {
      try {
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          SELECT u.id, u.nome, u.email, u.ra, ad.matriculado_em
          FROM usuarios u
          INNER JOIN aluno_disciplina ad ON u.id = ad.aluno_id
          WHERE ad.disciplina_id = \$1 AND u.tipo = 'aluno'
          ORDER BY u.nome
          ''',
          parameters: [int.parse(id)],
        );
        
        final alunos = result.map((row) => {
          'id': row[0],
          'nome': row[1],
          'email': row[2],
          'ra': row[3],
          'matriculado_em': row[4]?.toString(),
        }).toList();
        
        return Response.ok(
          json.encode(alunos),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar alunos: $e'}),
        );
      }
    });
    
    // GET /api/alunos/disponiveis/<disciplinaId> - Listar alunos que NÃO estão matriculados na disciplina
    router.get('/disponiveis/<disciplinaId>', (Request request, String disciplinaId) async {
      try {
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          SELECT u.id, u.nome, u.email, u.ra
          FROM usuarios u
          WHERE u.tipo = 'aluno'
          AND u.id NOT IN (
            SELECT aluno_id FROM aluno_disciplina WHERE disciplina_id = \$1
          )
          ORDER BY u.nome
          ''',
          parameters: [int.parse(disciplinaId)],
        );
        
        final alunos = result.map((row) => {
          'id': row[0],
          'nome': row[1],
          'email': row[2],
          'ra': row[3],
        }).toList();
        
        return Response.ok(
          json.encode(alunos),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao buscar alunos disponíveis: $e'}),
        );
      }
    });
    
    // POST /api/alunos/matricular - Matricular aluno em uma disciplina
    router.post('/matricular', (Request request) async {
      try {
        final payload = json.decode(await request.readAsString());
        
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          INSERT INTO aluno_disciplina (aluno_id, disciplina_id)
          VALUES (\$1, \$2)
          ON CONFLICT (aluno_id, disciplina_id) DO NOTHING
          RETURNING aluno_id, disciplina_id, matriculado_em
          ''',
          parameters: [
            payload['aluno_id'],
            payload['disciplina_id'],
          ],
        );
        
        if (result.isEmpty) {
          return Response(409, 
            body: json.encode({'error': 'Aluno já está matriculado nesta disciplina'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        final row = result.first;
        return Response.ok(
          json.encode({
            'aluno_id': row[0],
            'disciplina_id': row[1],
            'matriculado_em': row[2]?.toString(),
            'message': 'Aluno matriculado com sucesso',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao matricular aluno: $e'}),
        );
      }
    });
    
    // DELETE /api/alunos/desmatricular - Remover aluno de uma disciplina
    router.delete('/desmatricular', (Request request) async {
      try {
        final payload = json.decode(await request.readAsString());
        
        final db = await Database.getInstance();
        final result = await db.connection.execute(
          '''
          DELETE FROM aluno_disciplina
          WHERE aluno_id = \$1 AND disciplina_id = \$2
          RETURNING aluno_id, disciplina_id
          ''',
          parameters: [
            payload['aluno_id'],
            payload['disciplina_id'],
          ],
        );
        
        if (result.isEmpty) {
          return Response.notFound(
            json.encode({'error': 'Matrícula não encontrada'}),
          );
        }
        
        return Response.ok(
          json.encode({'message': 'Aluno removido da disciplina com sucesso'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: json.encode({'error': 'Erro ao remover aluno: $e'}),
        );
      }
    });
    
    return router;
  }
}
