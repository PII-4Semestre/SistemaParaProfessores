import 'package:test/test.dart';
import 'package:sistema_professores_server/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('deve aceitar email válido', () {
      final result = Validators.validateEmail('teste@exemplo.com');
      expect(result.isValid, isTrue);
      expect(result.error, isNull);
    });

    test('deve aceitar email com números', () {
      final result = Validators.validateEmail('user123@test.com.br');
      expect(result.isValid, isTrue);
    });

    test('deve aceitar email com hífen e underline', () {
      final result = Validators.validateEmail('user-name_test@example.co.uk');
      expect(result.isValid, isTrue);
    });

    test('deve rejeitar email sem @', () {
      final result = Validators.validateEmail('emailinvalido.com');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Email inválido'));
    });

    test('deve rejeitar email sem domínio', () {
      final result = Validators.validateEmail('user@');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Email inválido'));
    });

    test('deve rejeitar email vazio', () {
      final result = Validators.validateEmail('');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Email é obrigatório'));
    });

    test('deve rejeitar email null', () {
      final result = Validators.validateEmail(null);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Email é obrigatório'));
    });

    test('deve rejeitar email com espaços', () {
      final result = Validators.validateEmail('user @example.com');
      expect(result.isValid, isFalse);
    });
  });

  group('Validators - Password', () {
    test('deve aceitar senha válida com 6+ caracteres', () {
      final result = Validators.validatePassword('senha123');
      expect(result.isValid, isTrue);
    });

    test('deve aceitar senha com caracteres especiais', () {
      final result = Validators.validatePassword('S3nh@F0rt3!');
      expect(result.isValid, isTrue);
    });

    test('deve rejeitar senha com menos de 6 caracteres', () {
      final result = Validators.validatePassword('12345');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Senha deve ter no mínimo 6 caracteres'));
    });

    test('deve rejeitar senha vazia', () {
      final result = Validators.validatePassword('');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Senha é obrigatória'));
    });

    test('deve rejeitar senha null', () {
      final result = Validators.validatePassword(null);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Senha é obrigatória'));
    });
  });

  group('Validators - Nota', () {
    test('deve aceitar nota válida (0)', () {
      final result = Validators.validateNota(0);
      expect(result.isValid, isTrue);
    });

    test('deve aceitar nota válida (5)', () {
      final result = Validators.validateNota(5);
      expect(result.isValid, isTrue);
    });

    test('deve aceitar nota válida (10)', () {
      final result = Validators.validateNota(10);
      expect(result.isValid, isTrue);
    });

    test('deve aceitar nota decimal válida', () {
      final result = Validators.validateNota(7.5);
      expect(result.isValid, isTrue);
    });

    test('deve aceitar nota como string numérica', () {
      final result = Validators.validateNota('8.5');
      expect(result.isValid, isTrue);
    });

    test('deve rejeitar nota negativa', () {
      final result = Validators.validateNota(-1);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Nota deve estar entre 0 e 10'));
    });

    test('deve rejeitar nota maior que 10', () {
      final result = Validators.validateNota(11);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Nota deve estar entre 0 e 10'));
    });

    test('deve rejeitar nota null', () {
      final result = Validators.validateNota(null);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Nota é obrigatória'));
    });

    test('deve rejeitar nota não numérica', () {
      final result = Validators.validateNota('abc');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Nota deve ser um número'));
    });
  });

  group('Validators - NotEmpty', () {
    test('deve aceitar string válida', () {
      final result = Validators.validateNotEmpty('Teste', 'Campo');
      expect(result.isValid, isTrue);
    });

    test('deve rejeitar string vazia', () {
      final result = Validators.validateNotEmpty('', 'Nome');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Nome é obrigatório'));
    });

    test('deve rejeitar string apenas com espaços', () {
      final result = Validators.validateNotEmpty('   ', 'Descrição');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Descrição é obrigatório'));
    });

    test('deve rejeitar null', () {
      final result = Validators.validateNotEmpty(null, 'Título');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Título é obrigatório'));
    });
  });

  group('Validators - Peso', () {
    test('deve aceitar peso válido', () {
      final result = Validators.validatePeso(1.0);
      expect(result.isValid, isTrue);
    });

    test('deve aceitar peso inteiro', () {
      final result = Validators.validatePeso(2);
      expect(result.isValid, isTrue);
    });

    test('deve aceitar peso como string', () {
      final result = Validators.validatePeso('1.5');
      expect(result.isValid, isTrue);
    });

    test('deve rejeitar peso zero', () {
      final result = Validators.validatePeso(0);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Peso deve ser maior que zero'));
    });

    test('deve rejeitar peso negativo', () {
      final result = Validators.validatePeso(-1);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Peso deve ser maior que zero'));
    });

    test('deve rejeitar peso null', () {
      final result = Validators.validatePeso(null);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Peso é obrigatório'));
    });

    test('deve rejeitar peso não numérico', () {
      final result = Validators.validatePeso('abc');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Peso deve ser um número'));
    });
  });

  group('Validators - Color', () {
    test('deve aceitar cor hexadecimal válida', () {
      final result = Validators.validateColor('#FF5733');
      expect(result.isValid, isTrue);
    });

    test('deve aceitar cor com letras minúsculas', () {
      final result = Validators.validateColor('#ff5733');
      expect(result.isValid, isTrue);
    });

    test('deve aceitar cor branca', () {
      final result = Validators.validateColor('#FFFFFF');
      expect(result.isValid, isTrue);
    });

    test('deve aceitar cor preta', () {
      final result = Validators.validateColor('#000000');
      expect(result.isValid, isTrue);
    });

    test('deve aceitar null (cor opcional)', () {
      final result = Validators.validateColor(null);
      expect(result.isValid, isTrue);
    });

    test('deve aceitar string vazia (cor opcional)', () {
      final result = Validators.validateColor('');
      expect(result.isValid, isTrue);
    });

    test('deve rejeitar cor sem #', () {
      final result = Validators.validateColor('FF5733');
      expect(result.isValid, isFalse);
      expect(result.error, equals('Cor deve estar no formato #RRGGBB'));
    });

    test('deve rejeitar cor com 5 dígitos', () {
      final result = Validators.validateColor('#FF573');
      expect(result.isValid, isFalse);
    });

    test('deve rejeitar cor com 7 dígitos', () {
      final result = Validators.validateColor('#FF57333');
      expect(result.isValid, isFalse);
    });

    test('deve rejeitar cor com caracteres inválidos', () {
      final result = Validators.validateColor('#GGGGGG');
      expect(result.isValid, isFalse);
    });
  });

  group('Validators - ID', () {
    test('deve aceitar ID válido', () {
      final result = Validators.validateId(1);
      expect(result.isValid, isTrue);
    });

    test('deve aceitar ID como string', () {
      final result = Validators.validateId('42');
      expect(result.isValid, isTrue);
    });

    test('deve rejeitar ID zero', () {
      final result = Validators.validateId(0);
      expect(result.isValid, isFalse);
      expect(result.error, equals('ID inválido'));
    });

    test('deve rejeitar ID negativo', () {
      final result = Validators.validateId(-1);
      expect(result.isValid, isFalse);
      expect(result.error, equals('ID inválido'));
    });

    test('deve rejeitar ID null', () {
      final result = Validators.validateId(null);
      expect(result.isValid, isFalse);
      expect(result.error, equals('ID é obrigatório'));
    });

    test('deve rejeitar ID não numérico', () {
      final result = Validators.validateId('abc');
      expect(result.isValid, isFalse);
      expect(result.error, equals('ID inválido'));
    });
  });
}
