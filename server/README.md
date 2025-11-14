# Backend - Sistema Para Professores (Portal PoliEduca)

Backend em Dart com PostgreSQL para o Portal PoliEduca.

## 🏗 Arquitetura

- **Framework:** Dart Shelf 1.4.2 (RESTful API)
- **Banco de Dados Relacional:** PostgreSQL 18.0 (usuários, disciplinas, atividades, notas)
- **Banco de Dados NoSQL:** MongoDB (materiais didáticos e arquivos - GridFS)
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

Edite o arquivo `.env` e configure suas credenciais:

```env
# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sistema_professores
DB_USER=postgres
DB_PASSWORD=SUA_SENHA_AQUI  # <-- Altere aqui

# MongoDB Atlas (configure na seção 7 abaixo)
MONGO_URI=mongodb+srv://usuario:senha@cluster0.xxxxx.mongodb.net/sistema_professores?retryWrites=true&w=majority

# Server
PORT=8080
JWT_SECRET=seu_secret_key_super_seguro_aqui_12345
ALLOWED_ORIGINS=http://localhost:43895
```

### 7. Configurar MongoDB Atlas (para recursos de materiais)

O projeto usa **MongoDB Atlas** (cloud gratuito) para gerenciar materiais didáticos e arquivos.

#### Passo a passo para configurar MongoDB Atlas:

**1. Criar conta e cluster:**
   - Acesse: https://www.mongodb.com/cloud/atlas/register
   - Crie uma conta gratuita
   - Clique em "Build a Database"
   - Escolha o plano **M0 FREE** (512MB)
   - Escolha a região mais próxima (ex: São Paulo - AWS)
   - Nomeie o cluster (ex: `Cluster0`)
   - Clique em "Create"

**2. Configurar acesso ao banco:**
   - Na tela "Security Quickstart":
     - **Username:** Crie um usuário (ex: `admin_poliEduca`)
     - **Password:** Gere uma senha forte (guarde ela!)
     - Clique em "Create User"

**3. Configurar acesso de rede:**
   - Em "Network Access" → "Add IP Address":
     - Para desenvolvimento: Clique em "Allow Access from Anywhere" (0.0.0.0/0)
     - Para produção: Adicione apenas os IPs específicos
   - Clique em "Confirm"

**4. Obter a connection string:**
   - Volte para "Database" → Clique em "Connect" no seu cluster
   - Escolha "Drivers"
   - Copie a connection string (similar a):
     ```
     mongodb+srv://admin_poliEduca:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
     ```

**5. Configurar no projeto:**
   - Edite o arquivo `.env` e atualize o `MONGO_URI`:
   ```env
   MONGO_URI=mongodb+srv://admin_poliEduca:SUA_SENHA_AQUI@cluster0.xxxxx.mongodb.net/sistema_professores?retryWrites=true&w=majority
   ```
   - ⚠️ Substitua `<password>` pela senha que você criou
   - ⚠️ Substitua `xxxxx` pelo código do seu cluster
   - Note que adicionamos `/sistema_professores` antes do `?` para especificar o database

**6. Verificar conexão:**
   ```powershell
   dart run bin/server.dart
   ```
   - Você deve ver: `✅ Conectado ao MongoDB`

**Dica:** Use o MongoDB Compass ou a interface web do Atlas para visualizar seus dados!

### 8. Rodar o servidor

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

### Materiais (MongoDB + GridFS)
- `GET /api/materiais` - Listar todos materiais
- `GET /api/materiais/disciplina/:id` - Materiais de uma disciplina
- `GET /api/materiais/:id` - Buscar material por ID
- `POST /api/materiais` - Criar novo material
- `PUT /api/materiais/:id` - Atualizar material
- `DELETE /api/materiais/:id` - Deletar material (soft delete)
- `POST /api/materiais/:id/arquivo` - Upload de arquivo
- `GET /api/materiais/arquivo/:fileId` - Download de arquivo

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

### PostgreSQL (Dados Estruturados)

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

### MongoDB (Documentos e Arquivos)

**Coleções:**
- `materiais` - Metadados de materiais didáticos
  - `_id`: ObjectId
  - `disciplina_id`: int (referência ao PostgreSQL)
  - `professor_id`: int (referência ao PostgreSQL)
  - `titulo`: string
  - `descricao`: string
  - `tipo`: enum ('apostila', 'slide', 'video', 'link', 'documento')
  - `tags`: array de strings
  - `arquivos`: array de objetos Arquivo
  - `link_externo`: string (opcional)
  - `criado_em`: DateTime
  - `atualizado_em`: DateTime
  - `ativo`: boolean

- `arquivos.files` e `arquivos.chunks` - GridFS para armazenamento de arquivos grandes
  - Suporta arquivos de qualquer tamanho
  - Metadados personalizados por arquivo
  - Streaming de upload/download

**Índices:**
- `materiais.disciplina_id` - Para buscar materiais por disciplina
- `materiais.professor_id` - Para buscar materiais por professor
- `materiais.criado_em` - Para ordenação temporal
- `arquivos.files.metadata.material_id` - Para relacionar arquivos com materiais

## 🔧 Troubleshooting

### PostgreSQL não encontrado
```powershell
# Encontrar instalação
Get-ChildItem "C:\Program Files\PostgreSQL\" -Recurse -Filter psql.exe

# Ou verificar serviços
Get-Service -Name "*postgresql*"
```

### Erro de conexão PostgreSQL
- Verifique se o PostgreSQL está rodando
- Confirme a senha no arquivo `.env`
- Teste a conexão com pgAdmin

### Erro de conexão MongoDB Atlas
**Erro: "connection refused" ou "authentication failed"**
- ✅ Verifique se a senha no `.env` está correta (sem caracteres especiais escapados)
- ✅ Confirme que seu IP está na whitelist (Network Access no Atlas)
- ✅ Verifique se o nome do usuário está correto
- ✅ Teste a connection string no MongoDB Compass

**Erro: "network timeout"**
- ✅ Verifique sua conexão com a internet
- ✅ Alguns firewalls/antivírus bloqueiam conexão MongoDB (porta 27017)
- ✅ Tente usar VPN se estiver em rede corporativa

**Senha com caracteres especiais:**
Se sua senha tem caracteres especiais (@, #, $, etc.), você precisa fazer URL encoding:
```
@ → %40
# → %23
$ → %24
% → %25
```
Exemplo: senha `Abc@123#` → `Abc%40123%23`

**Testar conexão manualmente:**
```powershell
# Instalar MongoDB Shell (mongosh)
# Baixe em: https://www.mongodb.com/try/download/shell

# Testar conexão
mongosh "mongodb+srv://usuario:senha@cluster0.xxxxx.mongodb.net/sistema_professores"
```

### Porta do servidor em uso
Altere a `PORT` no arquivo `.env` para outra (ex: 3000, 5000)

## 📝 Próximos passos

### Sprint 3 (Em Andamento)
- [x] Implementar integração com MongoDB
- [x] Sistema de upload de arquivos com GridFS
- [x] API para gerenciamento de materiais didáticos
- [ ] Implementar sistema completo de notas
- [ ] Cálculo automático de médias ponderadas
- [ ] Interface de visualização para alunos
- [ ] Validação de dados com middleware

### Sprint 4-5 (Planejadas)
- [ ] Implementar JWT para autenticação real
- [ ] Hash de senhas com bcrypt
- [ ] Melhorias no upload de arquivos (multipart/form-data)
- [ ] WebSockets para mensagens em tempo real
- [ ] Sistema de notificações
- [ ] Compressão e otimização de arquivos

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
