# Backend - Sistema Para Professores (Portal PoliEduca)

Backend em Dart com PostgreSQL para o Portal PoliEduca.

## 🏗 Arquitetura

- **Framework:** Dart Shelf 1.4.2 (RESTful API)
- **Banco de Dados:** PostgreSQL 18.0 (dados estruturados)
- **Futuro:** MongoDB (materiais e arquivos)
- **Autenticação:** Em desenvolvimento (JWT planejado)

## 🚀 Setup

### 1. Instalar dependências

```bash
cd server
dart pub get
```

### 2. Configurar PostgreSQL

Primeiro, vamos encontrar sua instalação do PostgreSQL. Geralmente está em:
```
C:\Program Files\PostgreSQL\18\bin\
```

Adicione ao PATH ou use o caminho completo.

### 3. Criar o banco de dados

Abra o terminal como Administrador e execute:

```powershell
# Usando pgAdmin ou psql
# Se estiver no PATH:
psql -U postgres

# Se não estiver no PATH:
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres
```

Dentro do psql, execute:

```sql
CREATE DATABASE sistema_professores;
\c sistema_professores
```

### 4. Criar as tabelas

No mesmo terminal psql:

```sql
\i C:/Users/WinstinV2/Documents/GitHub/SistemaParaProfessores/server/database/schema.sql
```

Ou copie e cole o conteúdo de `database/schema.sql` no pgAdmin.

### 5. Inserir dados de teste (opcional)

```sql
\i C:/Users/WinstinV2/Documents/GitHub/SistemaParaProfessores/server/database/seed.sql
```

### 6. Configurar variáveis de ambiente

Copie o arquivo `.env.example` para `.env`:

```powershell
Copy-Item .env.example .env
```

Edite o arquivo `.env` e configure sua senha do PostgreSQL:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sistema_professores
DB_USER=postgres
DB_PASSWORD=SUA_SENHA_AQUI  # <-- Altere aqui
PORT=8080
JWT_SECRET=seu_secret_key_super_seguro_aqui_12345
ALLOWED_ORIGINS=http://localhost:43895
```

### 7. Rodar o servidor

```bash
dart run bin/server.dart
```

O servidor estará rodando em `http://localhost:8080`

## 📡 API Endpoints

### Autenticação
- `POST /api/auth/login` - Login (email, senha)
- `POST /api/auth/register` - Registro de usuário

### Usuários
- `GET /api/usuarios` - Listar todos usuários
- `GET /api/usuarios/:id` - Buscar por ID
- `GET /api/alunos` - Listar apenas alunos

### Disciplinas
- `GET /api/disciplinas` - Listar todas
- `GET /api/disciplinas/:id` - Buscar por ID
- `GET /api/disciplinas/professor/:id` - Por professor
- `POST /api/disciplinas` - Criar
- `PUT /api/disciplinas/:id` - Atualizar
- `DELETE /api/disciplinas/:id` - Deletar

### Matrícula (Aluno-Disciplina)
- `POST /api/alunos/:alunoId/disciplinas/:disciplinaId` - Matricular
- `DELETE /api/alunos/:alunoId/disciplinas/:disciplinaId` - Desmatricular
- `GET /api/disciplinas/:id/alunos` - Alunos de uma disciplina

### Atividades
- `GET /api/atividades/disciplina/:id` - Por disciplina
- `POST /api/atividades` - Criar
- `PUT /api/atividades/:id` - Atualizar
- `DELETE /api/atividades/:id` - Deletar

### Notas
- `GET /api/notas/aluno/:id` - Por aluno
- `GET /api/notas/atividade/:id` - Por atividade
- `POST /api/notas` - Atribuir/Atualizar nota
- `PUT /api/notas/:id` - Editar nota
- `DELETE /api/notas/:id` - Remover nota

### Estatísticas
- `GET /api/stats/professor/:id` - Dashboard do professor
- `GET /api/stats/aluno/:id` - Dashboard do aluno

## 🧪 Testar a API

### Usando PowerShell:

```powershell
# Login
$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body (@{email="silva@escola.com"; senha="123"} | ConvertTo-Json) -ContentType "application/json"
$response

# Listar disciplinas
Invoke-RestMethod -Uri "http://localhost:8080/api/disciplinas" -Method GET
```

### Usando navegador:
- GET: `http://localhost:8080/api/disciplinas`
- GET: `http://localhost:8080/api/notas/aluno/3`

## 📊 Estrutura do Banco

```
usuarios (professor/aluno)
  ├── disciplinas (professor cria)
  │     ├── atividades
  │     │     ├── notas (aluno recebe)
  │     │     └── entregas (aluno submete)
  │     └── aluno_disciplina (matrícula N:N)
  └── mensagens (entre usuários)
```

**Tabelas:**
- `usuarios` - Professores e alunos
- `disciplinas` - Matérias criadas por professores
- `aluno_disciplina` - Relacionamento N:N (matrícula)
- `atividades` - Atividades e provas
- `notas` - Notas atribuídas aos alunos
- `entregas` - Submissões de atividades
- `mensagens` - Comunicação entre usuários

**Recursos:**
- Triggers para atualização automática de timestamps
- Índices para performance em queries comuns
- Constraints para integridade referencial
- ENUMs para tipos de usuário (professor/aluno)

## 🔧 Troubleshooting

### PostgreSQL não encontrado
```powershell
# Encontrar instalação
Get-ChildItem "C:\Program Files\PostgreSQL\" -Recurse -Filter psql.exe

# Ou verificar serviços
Get-Service -Name "*postgresql*"
```

### Erro de conexão
- Verifique se o PostgreSQL está rodando
- Confirme a senha no arquivo `.env`
- Teste a conexão com pgAdmin

### Porta em uso
Altere a `PORT` no arquivo `.env` para outra (ex: 3000, 5000)

## 📝 Próximos passos

### Sprint 3 (Em Andamento)
- [ ] Implementar sistema completo de notas
- [ ] Cálculo automático de médias ponderadas
- [ ] Interface de visualização para alunos
- [ ] Validação de dados com middleware

### Sprint 4-5 (Planejadas)
- [ ] Implementar JWT para autenticação real
- [ ] Hash de senhas com bcrypt
- [ ] Integração com MongoDB para materiais
- [ ] Upload de arquivos (GridFS)
- [ ] WebSockets para mensagens em tempo real
- [ ] Sistema de notificações

### Sprint 6 (Planejada)
- [ ] Documentação Swagger/OpenAPI
- [ ] Logs de auditoria
- [ ] Rate limiting na API
- [ ] Testes de carga e performance
- [ ] CI/CD com GitHub Actions
- [ ] Deploy em produção

---

## 📚 Documentação

Para documentação completa do projeto, consulte:
- [DOCUMENTACAO_PROJETO.md](../DOCUMENTACAO_PROJETO.md) - Documentação completa
- [Postman Collection](./postman_collection.json) - Coleção de testes da API
- [Schema SQL](./database/schema.sql) - Estrutura do banco de dados
- [Seed SQL](./database/seed.sql) - Dados iniciais para testes

---

## 👥 Equipe

- **Product Owner:** Mariana Boschetti Castellani
- **Scrum Master:** Murilo Rodrigues dos Santos  
- **Desenvolvedores:** Henrique Impastaro, Matheus Garcia Mattoso

---

**Portal PoliEduca** - Desenvolvido com 💙 por alunos do Instituto Mauá de Tecnologia
