# Backend - Sistema Para Professores

Backend em Dart com PostgreSQL para o Sistema Para Professores.

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
- `POST /api/auth/register` - Registro

### Disciplinas
- `GET /api/disciplinas` - Listar todas
- `GET /api/disciplinas/professor/:id` - Por professor
- `POST /api/disciplinas` - Criar
- `PUT /api/disciplinas/:id` - Atualizar
- `DELETE /api/disciplinas/:id` - Deletar

### Atividades
- `GET /api/atividades/disciplina/:id` - Por disciplina
- `POST /api/atividades` - Criar

### Notas
- `GET /api/notas/aluno/:id` - Por aluno
- `POST /api/notas` - Atribuir/Atualizar nota

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
  │     │     └── notas (aluno recebe)
  │     └── aluno_disciplina (matrícula)
  └── mensagens (entre usuários)
```

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

- [ ] Implementar JWT para autenticação real
- [ ] Hash de senhas com bcrypt
- [ ] Upload de arquivos (materiais)
- [ ] WebSockets para mensagens em tempo real
- [ ] Validação de dados com middleware
