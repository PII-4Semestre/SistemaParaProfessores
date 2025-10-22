import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  // URL base do servidor (ajuste conforme necessário)
  const baseUrl = 'http://localhost:8080';

  group('Auth Routes - Register', () {
    test('POST /auth/register - deve criar novo usuário professor', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Professor Teste',
          'email': 'professor.teste@escola.com',
          'senha': 'senha123',
          'tipo': 'professor',
        }),
      );

      expect(response.statusCode, equals(201));

      final data = jsonDecode(response.body);
      expect(data['usuario'], isNotNull);
      expect(data['usuario']['nome'], equals('Professor Teste'));
      expect(data['usuario']['email'], equals('professor.teste@escola.com'));
      expect(data['usuario']['tipo'], equals('professor'));
      expect(data['usuario']['id'], isA<int>());
      expect(data['token'], isNotNull);
      expect(data['token'], isA<String>());
    });

    test('POST /auth/register - deve criar novo usuário aluno', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Aluno Teste',
          'email': 'aluno.teste@escola.com',
          'senha': 'senha123',
          'tipo': 'aluno',
        }),
      );

      expect(response.statusCode, equals(201));

      final data = jsonDecode(response.body);
      expect(data['usuario']['tipo'], equals('aluno'));
    });

    test('POST /auth/register - deve rejeitar email duplicado', () async {
      final userData = {
        'nome': 'Usuário Duplicado',
        'email': 'duplicado@escola.com',
        'senha': 'senha123',
        'tipo': 'professor',
      };

      // Primeiro registro
      final response1 = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      expect(response1.statusCode, equals(201));

      // Segundo registro com mesmo email
      final response2 = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      expect(response2.statusCode, equals(409)); // Conflict
      final data = jsonDecode(response2.body);
      expect(data['erro'], contains('já existe'));
    });

    test('POST /auth/register - deve rejeitar dados incompletos', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Teste',
          // faltando email, senha, tipo
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /auth/register - deve rejeitar tipo inválido', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Teste',
          'email': 'teste@teste.com',
          'senha': 'senha123',
          'tipo': 'admin', // tipo inválido
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /auth/register - deve rejeitar JSON inválido', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: 'invalid json',
      );

      expect(response.statusCode, equals(400));
    });
  });

  group('Auth Routes - Login', () {
    setUp(() async {
      // Criar usuário de teste antes de cada login test
      await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Login Teste',
          'email': 'login.teste@escola.com',
          'senha': 'senha123',
          'tipo': 'professor',
        }),
      );
    });

    test(
      'POST /auth/login - deve fazer login com credenciais válidas',
      () async {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': 'login.teste@escola.com',
            'senha': 'senha123',
          }),
        );

        expect(response.statusCode, equals(200));

        final data = jsonDecode(response.body);
        expect(data['usuario'], isNotNull);
        expect(data['usuario']['email'], equals('login.teste@escola.com'));
        expect(data['usuario']['nome'], equals('Login Teste'));
        expect(data['token'], isNotNull);
        expect(data['token'], isA<String>());
      },
    );

    test('POST /auth/login - deve rejeitar email inexistente', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'naoexiste@escola.com',
          'senha': 'senha123',
        }),
      );

      expect(response.statusCode, equals(401));
      final data = jsonDecode(response.body);
      expect(data['erro'], contains('Credenciais'));
    });

    test(
      'POST /auth/login - deve aceitar qualquer senha (SECURITY ISSUE)',
      () async {
        // NOTA: Este teste documenta o problema de segurança atual
        // onde qualquer senha é aceita
        final response = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': 'login.teste@escola.com',
            'senha': 'senhaerrada',
          }),
        );

        // ATUALMENTE aceita qualquer senha (PROBLEMA!)
        expect(response.statusCode, equals(200));

        // TODO: Quando bcrypt for implementado, este teste deve ser:
        // expect(response.statusCode, equals(401));
      },
    );

    test('POST /auth/login - deve rejeitar dados incompletos', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'teste@teste.com',
          // faltando senha
        }),
      );

      expect(response.statusCode, equals(400));
    });

    test('POST /auth/login - deve rejeitar JSON inválido', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: 'not a json',
      );

      expect(response.statusCode, equals(400));
    });
  });

  group('Auth Routes - Token', () {
    test('deve retornar token com estrutura válida', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Token Teste',
          'email': 'token.teste@escola.com',
          'senha': 'senha123',
          'tipo': 'professor',
        }),
      );

      final data = jsonDecode(response.body);
      final token = data['token'] as String;

      // Token JWT tem 3 partes separadas por ponto
      expect(token.split('.').length, equals(3));

      // TODO: Quando JWT real for implementado, validar:
      // - Assinatura
      // - Claims (sub, exp, iat)
      // - Tipo de usuário no payload
    });
  });

  group('Auth Routes - Security', () {
    test('não deve retornar senha nas respostas', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': 'Security Teste',
          'email': 'security.teste@escola.com',
          'senha': 'senha123',
          'tipo': 'professor',
        }),
      );

      final data = jsonDecode(response.body);
      expect(data['usuario'], isNotNull);
      expect(data['usuario']['senha'], isNull);
      expect(data['usuario'].containsKey('senha'), isFalse);
    });

    test('não deve retornar hash de senha nas respostas', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'login.teste@escola.com',
          'senha': 'senha123',
        }),
      );

      final data = jsonDecode(response.body);
      expect(data['usuario']['senha_hash'], isNull);
      expect(data['usuario'].containsKey('senha_hash'), isFalse);
    });
  });
}
