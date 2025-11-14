# Guia Rápido: MongoDB Atlas Setup

Este guia te ajudará a configurar o MongoDB Atlas em poucos minutos.

## 📋 Checklist Rápido

- [ ] Criar conta no MongoDB Atlas
- [ ] Criar cluster gratuito (M0)
- [ ] Criar usuário de banco de dados
- [ ] Configurar acesso de rede (IP Whitelist)
- [ ] Obter connection string
- [ ] Atualizar arquivo `.env`
- [ ] Testar conexão

## 🚀 Passo a Passo Detalhado

### 1️⃣ Criar Conta e Cluster

1. Acesse: https://www.mongodb.com/cloud/atlas/register
2. Cadastre-se com email ou conta Google/GitHub
3. Na página inicial, clique em **"Build a Database"**
4. Escolha **"M0 FREE"** (512MB gratuitos para sempre)
5. Configurações:
   - **Provider:** AWS (recomendado)
   - **Region:** São Paulo (sa-east-1) - mais próximo do Brasil
   - **Name:** `Cluster0` (pode deixar o padrão)
6. Clique em **"Create"** (leva ~3-5 minutos)

### 2️⃣ Configurar Usuário

Assim que o cluster estiver criando, você verá a tela de configuração:

1. **Database Access** (Acesso ao Banco):
   ```
   Username: admin_poliEduca
   Password: [Gere uma senha forte]
   ```
   - ⚠️ **IMPORTANTE:** Guarde a senha! Você vai precisar dela no `.env`
   - Não use caracteres especiais se possível (evita problemas de encoding)
   - Clique em **"Create User"**

2. **Privilégios:**
   - Deixe selecionado **"Built-in Role: Read and write to any database"**

### 3️⃣ Configurar Acesso de Rede

1. Clique em **"Network Access"** no menu lateral
2. Clique em **"Add IP Address"**
3. Para desenvolvimento:
   - Clique em **"Allow Access from Anywhere"**
   - Confirme o IP `0.0.0.0/0`
   - ⚠️ Para produção, use IPs específicos!
4. Clique em **"Confirm"**

### 4️⃣ Obter Connection String

1. Volte para **"Database"** no menu lateral
2. Clique no botão **"Connect"** do seu cluster
3. Escolha **"Drivers"**
4. Selecione:
   - **Driver:** Dart
   - **Version:** (qualquer versão)
5. Copie a connection string:

```
mongodb+srv://admin_poliEduca:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
```

### 5️⃣ Configurar no Projeto

1. Abra o arquivo `.env` no seu projeto
2. Edite a linha `MONGO_URI`:

```env
MONGO_URI=mongodb+srv://admin_poliEduca:SUA_SENHA_AQUI@cluster0.xxxxx.mongodb.net/sistema_professores?retryWrites=true&w=majority
```

**Substituições necessárias:**
- `admin_poliEduca` → seu username
- `<password>` ou `SUA_SENHA_AQUI` → sua senha real
- `xxxxx` → código do seu cluster (algo como `ab12cd.mongodb.net`)
- **IMPORTANTE:** Adicione `/sistema_professores` antes do `?` para especificar o database

**Exemplo real:**
```env
MONGO_URI=mongodb+srv://admin_poliEduca:MinhaSenh@123@cluster0.ab12cd.mongodb.net/sistema_professores?retryWrites=true&w=majority
```

### 6️⃣ Testar a Conexão

```powershell
cd c:\Users\WinstinV2\Documents\GitHub\SistemaParaProfessores\server
dart run bin/server.dart
```

**Você deve ver:**
```
✅ Conectado ao PostgreSQL
✅ Conectado ao MongoDB
🚀 Servidor rodando em http://0.0.0.0:8080
```

## 🎉 Pronto!

Seu MongoDB Atlas está configurado! Agora você pode:

1. **Ver seus dados no Atlas:**
   - Vá para "Database" → "Browse Collections"
   - Você verá as collections: `materiais`, `arquivos.files`, `arquivos.chunks`

2. **Usar MongoDB Compass (Desktop):**
   - Baixe: https://www.mongodb.com/try/download/compass
   - Cole a mesma connection string
   - Navegue visualmente pelo banco

3. **Testar a API de materiais:**
   ```powershell
   # Criar um material
   $material = @{
       disciplina_id = 1
       professor_id = 2
       titulo = "Teste MongoDB Atlas"
       tipo = "documento"
   } | ConvertTo-Json
   
   Invoke-RestMethod -Uri "http://localhost:8080/api/materiais" `
       -Method POST `
       -Body $material `
       -ContentType "application/json"
   ```

## 🔍 Visualizando seus Dados

### No Atlas (Web):
1. Vá para "Database" → "Browse Collections"
2. Selecione database `sistema_professores`
3. Clique em uma collection (ex: `materiais`)
4. Veja os documentos JSON

### No Compass (Desktop):
1. Conecte com a connection string
2. Expanda `sistema_professores`
3. Navegue pelas collections
4. Execute queries, agregações, etc.

## ❓ Problemas Comuns

### "Authentication failed"
- ✅ Verifique se a senha está correta no `.env`
- ✅ Senha tem caracteres especiais? Faça URL encoding
- ✅ Username correto?

### "Connection timeout"
- ✅ IP na whitelist? (0.0.0.0/0 para desenvolvimento)
- ✅ Firewall/antivírus bloqueando porta 27017?
- ✅ Internet funcionando?

### "No database selected"
- ✅ Certifique-se de ter `/sistema_professores` na connection string
- ✅ Deve estar ANTES do `?retryWrites`

### Senha com caracteres especiais
Se sua senha tem `@`, `#`, `$`, etc., faça URL encoding:
```
@ → %40
# → %23  
$ → %24
& → %26
```

**Exemplo:**
```
Senha real: Abc@123#
Na .env: mongodb+srv://user:Abc%40123%23@cluster...
```

## 🎓 Recursos Úteis

- [MongoDB Atlas Docs](https://www.mongodb.com/docs/atlas/)
- [MongoDB Dart Driver](https://pub.dev/packages/mongo_dart)
- [GridFS Documentation](https://www.mongodb.com/docs/manual/core/gridfs/)
- [Connection String Guide](https://www.mongodb.com/docs/manual/reference/connection-string/)

---

**Dúvidas?** Verifique o README principal ou a documentação do MongoDB Atlas.

**Portal PoliEduca** - Desenvolvido com 💙
