# Testes do Backend - Sistema para Professores

## 📋 Visão Geral

Suite de testes abrangente para o backend do Sistema para Professores, cobrindo:
- ✅ Testes unitários de validadores
- ✅ Testes de integração de rotas
- ✅ Validação de segurança
- ✅ Testes de cascata (deleção)
- ✅ Validação de entrada

## 🏗️ Estrutura de Testes

```
server/test/
├── utils/
│   └── validators_test.dart       # Testes unitários dos validadores
└── routes/
    ├── auth_routes_test.dart      # Testes de autenticação
    ├── disciplinas_routes_test.dart  # Testes CRUD disciplinas
    └── atividades_routes_test.dart   # Testes CRUD atividades
```

## 🚀 Executando os Testes

### Pré-requisitos

1. **Servidor deve estar rodando**:
```powershell
cd server
dart run bin/server.dart
```

2. **Banco de dados PostgreSQL configurado**:
   - Verifique o arquivo `server/.env`
   - Database deve estar acessível

### Executar Todos os Testes

```powershell
cd server
dart test
```

### Executar Testes Específicos

**Apenas testes unitários (validadores):**
```powershell
dart test test/utils/
```

**Apenas testes de autenticação:**
```powershell
dart test test/routes/auth_routes_test.dart
```

**Apenas testes de disciplinas:**
```powershell
dart test test/routes/disciplinas_routes_test.dart
```

**Apenas testes de atividades:**
```powershell
dart test test/routes/atividades_routes_test.dart
```

### Executar com Verbose

```powershell
dart test --reporter=expanded
```

### Executar Teste Específico

```powershell
dart test --name "deve aceitar email válido"
```

## 📊 Cobertura de Testes

### Validators (validators_test.dart)
- ✅ 48 testes unitários
- Cobertura: 100% dos métodos de validação
- Categorias:
  - Email: 8 testes
  - Password: 5 testes
  - Nota: 9 testes
  - NotEmpty: 4 testes
  - Peso: 7 testes
  - Color: 10 testes
  - ID: 6 testes

### Auth Routes (auth_routes_test.dart)
- ✅ 17 testes de integração
- Endpoints testados:
  - POST /auth/register (8 testes)
  - POST /auth/login (6 testes)
  - Token validation (1 teste)
  - Security checks (2 testes)
- Cenários cobertos:
  - ✅ Registro de professor
  - ✅ Registro de aluno
  - ✅ Emails duplicados
  - ✅ Dados incompletos
  - ✅ Tipos inválidos
  - ✅ Login válido
  - ✅ Credenciais inválidas
  - ⚠️ Senha não verificada (problema conhecido)
  - ✅ Segurança (senha não retornada)

### Disciplinas Routes (disciplinas_routes_test.dart)
- ✅ 26 testes de integração
- Endpoints testados:
  - GET /disciplinas (1 teste)
  - GET /disciplinas/professor/:id (2 testes)
  - POST /disciplinas (7 testes)
  - PUT /disciplinas/:id (4 testes)
  - DELETE /disciplinas/:id (4 testes)
  - Validação (2 testes)
- Cenários cobertos:
  - ✅ CRUD completo
  - ✅ Validação de cores
  - ✅ Campos opcionais
  - ✅ IDs inválidos
  - ✅ Deleção em cascata

### Atividades Routes (atividades_routes_test.dart)
- ✅ 29 testes de integração
- Endpoints testados:
  - GET /atividades/disciplina/:id (3 testes)
  - POST /atividades (9 testes)
  - PUT /atividades/:id (6 testes)
  - DELETE /atividades/:id (4 testes)
  - Validação (2 testes)
- Cenários cobertos:
  - ✅ CRUD completo
  - ✅ Pesos decimais
  - ✅ Campos opcionais
  - ✅ Validação de peso
  - ✅ Deleção em cascata (notas)

### Notas Routes (notas_routes_test.dart)
- ✅ 35 testes de integração
- Endpoints testados:
  - GET /notas/aluno/:id (4 testes)
  - POST /notas - Criar (11 testes)
  - POST /notas - UPSERT (2 testes)
  - Validação (3 testes)
  - Business Logic (2 testes)
- Cenários cobertos:
  - ✅ Listagem com JOIN de atividades e disciplinas
  - ✅ Criação de notas (0-10)
  - ✅ Validação de range de notas
  - ✅ UPSERT (criar ou atualizar)
  - ✅ Notas decimais
  - ✅ Múltiplas notas por aluno
  - ✅ Associação com disciplinas

### Alunos Routes (alunos_routes_test.dart)
- ✅ 37 testes de integração
- Endpoints testados:
  - GET /alunos (3 testes)
  - GET /alunos/:id/disciplinas (3 testes)
  - GET /alunos/disciplina/:id (3 testes)
  - GET /alunos/disponiveis/:id (4 testes)
  - POST /alunos/matricular (8 testes)
  - DELETE /alunos/desmatricular (6 testes)
  - Business Logic (2 testes)
- Cenários cobertos:
  - ✅ Listagem completa com disciplinas aninhadas
  - ✅ Disciplinas de um aluno
  - ✅ Alunos de uma disciplina
  - ✅ Filtro de alunos disponíveis
  - ✅ Matrícula com validação de duplicação
  - ✅ Desmatrícula com verificação
  - ✅ Múltiplos alunos por disciplina
  - ✅ Múltiplas disciplinas por aluno

## ⚠️ Problemas Conhecidos Documentados

Os testes documentam problemas de segurança existentes:

### 1. Autenticação Mock
```dart
test('deve aceitar qualquer senha (SECURITY ISSUE)', () async {
  // NOTA: Este teste documenta o problema de segurança atual
  // onde qualquer senha é aceita
  
  // ATUALMENTE aceita qualquer senha (PROBLEMA!)
  expect(response.statusCode, equals(200));
  
  // TODO: Quando bcrypt for implementado, este teste deve ser:
  // expect(response.statusCode, equals(401));
});
```

### 2. Validação Limitada
- Alguns testes usam `anyOf([201, 400])` indicando que validação pode ou não estar implementada
- Tamanhos de string não são validados
- Cores em formatos variados podem ser aceitas

## 🔧 Configuração

### Ajustar URL do Servidor

Se o servidor estiver rodando em porta diferente, edite:
```dart
const baseUrl = 'http://localhost:8080';  // Altere aqui
```

### Limpar Banco de Dados

Entre testes, pode ser necessário limpar o banco:
```sql
TRUNCATE usuarios, disciplinas, atividades, notas, aluno_disciplina CASCADE;
```

## 📝 Adicionando Novos Testes

### Template de Teste Unitário

```dart
import 'package:test/test.dart';
import 'package:sistema_professores_server/utils/validators.dart';

void main() {
  group('Nome do Grupo', () {
    test('deve fazer algo específico', () {
      // Arrange
      final input = 'valor';
      
      // Act
      final result = Validators.validateSomething(input);
      
      // Assert
      expect(result.isValid, isTrue);
      expect(result.error, isNull);
    });
  });
}
```

### Template de Teste de Integração

```dart
import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  const baseUrl = 'http://localhost:8080';
  
  group('Endpoint Routes', () {
    test('GET /endpoint - deve fazer algo', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/endpoint'),
      );

      expect(response.statusCode, equals(200));
      
      final data = jsonDecode(response.body);
      expect(data, isNotNull);
    });
  });
}
```

## 🎯 Próximos Passos

### Testes Criados ✅

1. ✅ **Validators** (49 testes) - Todos passando
2. ✅ **Auth Routes** (17 testes) - Pronto para execução
3. ✅ **Disciplinas Routes** (26 testes) - Pronto para execução
4. ✅ **Atividades Routes** (29 testes) - Pronto para execução
5. ✅ **Notas Routes** (35 testes) - Pronto para execução
6. ✅ **Alunos Routes** (37 testes) - Pronto para execução

### Testes Pendentes (Futuros)

1. **Testes de Performance**
   - Múltiplas requisições simultâneas
   - Grandes volumes de dados

4. **Testes de Segurança**
   - SQL Injection (já protegido por prepared statements)
   - XSS
   - Rate limiting

### Melhorias Recomendadas

1. **Setup/Teardown Global**
   - Criar banco de dados de teste separado
   - Limpar dados entre testes

2. **Mocks para Banco de Dados**
   - Usar mocktail para testar sem banco real
   - Acelerar execução de testes

3. **CI/CD Integration**
   - Configurar testes no GitHub Actions
   - Automatizar execução em PRs

4. **Coverage Report**
   ```powershell
   dart test --coverage=coverage
   dart pub global activate coverage
   format_coverage --lcov --in=coverage --out=coverage.lcov --report-on=lib
   ```

## 📚 Referências

- [Dart Test Package](https://pub.dev/packages/test)
- [HTTP Package](https://pub.dev/packages/http)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Testing Best Practices](https://dart.dev/guides/testing)

## 🐛 Reportando Problemas

Se encontrar falhas nos testes:
1. Verifique se o servidor está rodando
2. Confirme se o banco de dados está acessível
3. Limpe dados de testes anteriores
4. Execute teste individual para isolar problema

## ✅ Checklist de Testes

- [x] Validators unitários (49 testes)
- [x] Auth routes (17 testes)
- [x] Disciplinas routes (26 testes)
- [x] Atividades routes (29 testes)
- [x] Notas routes (35 testes)
- [x] Alunos routes (37 testes)
- [ ] Testes de performance (pendente)
- [ ] Testes de segurança avançados (pendente)

**Total Atual: 193 testes implementados** ✅
