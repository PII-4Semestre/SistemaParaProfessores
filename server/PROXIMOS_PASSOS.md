# 🎯 Próximos Passos - MongoDB Atlas

Você está pronto para começar! Siga estes passos para finalizar a configuração.

## ✅ Checklist de Implementação

### 1. Configure o MongoDB Atlas
📖 **Guia detalhado:** Abra o arquivo `MONGODB_ATLAS_SETUP.md`

Resumo rápido:
1. Crie conta em https://www.mongodb.com/cloud/atlas
2. Crie cluster gratuito M0
3. Configure usuário e senha
4. Adicione IP 0.0.0.0/0 na whitelist (desenvolvimento)
5. Copie a connection string

### 2. Crie o arquivo `.env`

```powershell
# No diretório server, copie o exemplo:
Copy-Item .env.example .env
```

Depois edite o `.env` com suas credenciais:

```env
# PostgreSQL Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sistema_professores
DB_USER=postgres
DB_PASSWORD=sua_senha_postgresql

# MongoDB Atlas (COLE SUA CONNECTION STRING AQUI)
MONGO_URI=mongodb+srv://seu_usuario:sua_senha@cluster0.xxxxx.mongodb.net/sistema_professores?retryWrites=true&w=majority

# Server
PORT=8080
JWT_SECRET=seu_secret_key_super_seguro_aqui_12345

# CORS
ALLOWED_ORIGINS=http://localhost:43895
```

### 3. Teste a Conexão

```powershell
# Rodar o servidor
dart run bin/server.dart
```

**Você deve ver:**
```
✅ Conectado ao PostgreSQL
✅ Conectado ao MongoDB
🚀 Servidor rodando em http://0.0.0.0:8080
```

### 4. Teste a API de Materiais

```powershell
# Criar um material de teste
$material = @{
    disciplina_id = 1
    professor_id = 2
    titulo = "Meu Primeiro Material"
    descricao = "Teste do MongoDB Atlas"
    tipo = "documento"
    tags = @("teste", "mongodb")
} | ConvertTo-Json

$response = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/materiais" `
    -Method POST `
    -Body $material `
    -ContentType "application/json"

Write-Host "Material criado com ID: $($response.id)"

# Listar materiais
$materiais = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/materiais" `
    -Method GET

$materiais | ConvertTo-Json
```

### 5. Visualize os Dados

**Opção 1: MongoDB Atlas Web Interface**
1. Vá para https://cloud.mongodb.com
2. Database → Browse Collections
3. Veja `sistema_professores` → `materiais`

**Opção 2: MongoDB Compass (Recomendado)**
1. Baixe: https://www.mongodb.com/try/download/compass
2. Cole sua connection string
3. Navegue visualmente pelo banco

## 📚 Documentação Disponível

Criamos 3 guias completos para você:

1. **`README.md`** - Documentação geral do servidor
2. **`MONGODB_ATLAS_SETUP.md`** - Guia passo a passo do MongoDB Atlas
3. **`API_MATERIAIS.md`** - Documentação completa da API de materiais

## 🧪 Testando Upload de Arquivos

Depois que tudo estiver funcionando, teste o upload:

```powershell
# Criar material
$material = @{
    disciplina_id = 1
    professor_id = 2
    titulo = "Apostila de Teste"
    tipo = "apostila"
} | ConvertTo-Json

$response = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/materiais" `
    -Method POST `
    -Body $material `
    -ContentType "application/json"

$materialId = $response.id

# Upload de arquivo (substitua o caminho!)
$filePath = "C:\caminho\para\seu\arquivo.pdf"
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)

$headers = @{
    "Content-Type" = "application/pdf"
    "X-File-Name" = "teste.pdf"
}

$uploadResponse = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/materiais/$materialId/arquivo" `
    -Method POST `
    -Body $fileBytes `
    -Headers $headers

Write-Host "Arquivo enviado! ID: $($uploadResponse.arquivo_id)"

# Download do arquivo
$arquivoId = $uploadResponse.arquivo_id
Invoke-WebRequest `
    -Uri "http://localhost:8080/api/materiais/arquivo/$arquivoId" `
    -OutFile "arquivo_baixado.pdf"

Write-Host "Arquivo baixado com sucesso!"
```

## 🎓 Recursos Criados

### Banco de Dados Híbrido
✅ **PostgreSQL** - Dados estruturados (usuários, disciplinas, notas)  
✅ **MongoDB Atlas** - Documentos e arquivos (materiais, GridFS)

### API REST
✅ **8 novos endpoints** para gerenciamento de materiais  
✅ **GridFS** para upload/download de arquivos grandes  
✅ **Soft delete** para não perder dados  
✅ **Tags e categorização** de materiais  

### Models & Database
✅ **MongoDB singleton** com gerenciamento de conexão  
✅ **Models Material e Arquivo** com serialização JSON  
✅ **Índices otimizados** para performance  

## 🚨 Troubleshooting

Se algo der errado:

1. **Erro de autenticação MongoDB:**
   - Verifique usuário e senha no `.env`
   - Senha tem caracteres especiais? Faça URL encoding

2. **Timeout na conexão:**
   - IP está na whitelist? (0.0.0.0/0)
   - Firewall bloqueando porta 27017?

3. **"No database selected":**
   - Tem `/sistema_professores` antes do `?` na connection string?

4. **Servidor não inicia:**
   - PostgreSQL está rodando?
   - Porta 8080 está livre?

📖 **Mais detalhes:** Veja a seção Troubleshooting do `README.md`

## 🎉 Está Funcionando?

Se você viu `✅ Conectado ao MongoDB`, parabéns! 🎊

Agora você tem:
- ✅ Backend com arquitetura híbrida
- ✅ API REST completa
- ✅ Upload/Download de arquivos
- ✅ Banco na nuvem (gratuito!)
- ✅ Pronto para integrar com o front-end

## 📱 Integração com Front-end

A branch atual é `9-integração-mongodb---front-end`, então o próximo passo é:

1. ✅ Criar telas no Flutter para gerenciar materiais
2. ✅ Implementar upload de arquivos no app
3. ✅ Visualizador de materiais por disciplina
4. ✅ Download de arquivos para os alunos

---

**Dúvidas?** Consulte os guias:
- `MONGODB_ATLAS_SETUP.md` - Setup do Atlas
- `API_MATERIAIS.md` - Como usar a API
- `README.md` - Documentação completa

**Portal PoliEduca** - Desenvolvido com 💙 por alunos do Instituto Mauá
