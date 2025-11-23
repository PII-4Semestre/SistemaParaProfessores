# 🗄️ Setup do Banco de Dados PostgreSQL

Este guia explica como configurar o banco de dados PostgreSQL para o Portal PoliEduca.

## 📋 Pré-requisitos

- PostgreSQL 18 ou superior instalado
- Acesso ao usuário `postgres` (ou outro usuário com permissões de superusuário)

### Instalação do PostgreSQL

#### Windows
1. Baixe o instalador: https://www.postgresql.org/download/windows/
2. Execute o instalador e siga as instruções
3. Anote a senha do usuário `postgres`

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
```

#### macOS
```bash
brew install postgresql
brew services start postgresql
```

---

## 🚀 Setup Automático (Recomendado)

### Windows (PowerShell)
```powershell
cd server
.\setup-database.ps1
```

### Linux/macOS (Bash)
```bash
cd server
chmod +x setup-database.sh
./setup-database.sh
```

O script irá:
1. ✅ Verificar se o PostgreSQL está instalado
2. ✅ Criar o banco de dados `sistema_professores`
3. ✅ Criar todas as tabelas (schema)
4. ✅ Popular com dados de exemplo (seed)

---

## 🔧 Setup Manual

Se preferir executar os comandos manualmente:

### 1. Criar o banco de dados
```bash
psql -U postgres -c "CREATE DATABASE sistema_professores;"
```

### 2. Executar o schema (criar tabelas)
```bash
psql -U postgres -d sistema_professores -f database/schema.sql
```

### 3. Popular com dados de exemplo
```bash
psql -U postgres -d sistema_professores -f database/seed.sql
```

---

## 📝 Configuração do .env

Após criar o banco, configure o arquivo `.env` na pasta `server/`:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sistema_professores
DB_USER=postgres
DB_PASSWORD=sua_senha_aqui

# MongoDB Atlas (para materiais)
MONGODB_URI=sua_connection_string_aqui

# Server
PORT=8080
```

**Importante:** Nunca commite o arquivo `.env` no Git! Use o `.env.example` como referência.

---

## 👤 Usuários de Teste

Após o setup, os seguintes usuários estarão disponíveis:

### Professores
- **Email:** `professor@poliedro.com` | **Senha:** qualquer senha
- **Email:** `silva@escola.com` | **Senha:** qualquer senha
- **Email:** `maria@escola.com` | **Senha:** qualquer senha

### Alunos
- **Email:** `joao@aluno.com` | **Senha:** qualquer senha
- **Email:** `ana@aluno.com` | **Senha:** qualquer senha
- **Email:** `pedro@aluno.com` | **Senha:** qualquer senha

> ⚠️ **Nota:** O sistema aceita qualquer senha durante o desenvolvimento. A validação real de senha será implementada futuramente com bcrypt.

---

## 🔍 Verificação

Para verificar se o banco foi criado corretamente:

```bash
psql -U postgres -d sistema_professores -c "\dt"
```

Você deverá ver as seguintes tabelas:
- `usuarios`
- `disciplinas`
- `aluno_disciplina`
- `atividades`
- `entregas`
- `notas`
- `mensagens`

---

## 🔄 Resetar o Banco de Dados

Se precisar resetar o banco completamente:

```bash
# Deletar e recriar
psql -U postgres -c "DROP DATABASE sistema_professores;"
psql -U postgres -c "CREATE DATABASE sistema_professores;"

# Reexecutar schema e seed
psql -U postgres -d sistema_professores -f database/schema.sql
psql -U postgres -d sistema_professores -f database/seed.sql
```

Ou simplesmente execute o script de setup novamente e escolha "S" quando perguntado sobre recriar o banco.

---

## 🐛 Troubleshooting

### Erro: "psql: command not found"
O PostgreSQL não está instalado ou não está no PATH. Instale o PostgreSQL ou adicione-o ao PATH do sistema.

### Erro: "FATAL: password authentication failed"
A senha do usuário `postgres` está incorreta. Tente resetar a senha:
```bash
sudo -u postgres psql
ALTER USER postgres PASSWORD 'nova_senha';
```

### Erro: "database already exists"
Execute o script de setup e escolha recriar o banco, ou delete manualmente:
```bash
psql -U postgres -c "DROP DATABASE sistema_professores;"
```

### Erro: "permission denied"
Você precisa de permissões de superusuário. Use `sudo` (Linux/macOS) ou execute como Administrador (Windows).

---

## 📚 Estrutura do Banco

O banco de dados possui a seguinte estrutura:

```
sistema_professores
├── usuarios (professores e alunos)
├── disciplinas
├── aluno_disciplina (relacionamento N:N)
├── atividades
├── entregas
├── notas
└── mensagens
```

Para mais detalhes sobre a estrutura, consulte o arquivo `database/schema.sql`.

---

## 🎯 Próximos Passos

1. ✅ Configure o arquivo `.env`
2. ✅ Inicie o servidor: `dart run bin/server.dart`
3. ✅ Acesse http://localhost:8080/api/auth/login
4. ✅ Teste o login com os usuários de exemplo

---

**Documentação completa:** [README.md](../README.md)
