# API de Materiais Didáticos - MongoDB

Este documento descreve como usar a API de materiais didáticos que utiliza MongoDB e GridFS para armazenamento.

## 📦 Estrutura de Dados

### Material
```json
{
  "_id": "507f1f77bcf86cd799439011",
  "disciplina_id": 1,
  "professor_id": 2,
  "titulo": "Apostila de Matemática - Capítulo 1",
  "descricao": "Introdução às equações do primeiro grau",
  "tipo": "apostila",
  "tags": ["matematica", "equacoes", "algebra"],
  "arquivos": [
    {
      "gridfs_id": "507f1f77bcf86cd799439012",
      "nome_original": "apostila_cap1.pdf",
      "mime_type": "application/pdf",
      "tamanho_bytes": 1024000,
      "upload_em": "2024-01-15T10:30:00Z"
    }
  ],
  "link_externo": null,
  "criado_em": "2024-01-15T10:00:00Z",
  "atualizado_em": "2024-01-15T10:30:00Z",
  "ativo": true
}
```

### Tipos de Material
- `apostila` - Documentos PDF, DOC, etc.
- `slide` - Apresentações PowerPoint, Google Slides
- `video` - Vídeos educacionais
- `link` - Links externos (YouTube, sites, etc.)
- `documento` - Documentos gerais

## 🔌 Endpoints

### 1. Criar Material (sem arquivo)

**POST** `/api/materiais`

```json
{
  "disciplina_id": 1,
  "professor_id": 2,
  "titulo": "Apostila de Matemática",
  "descricao": "Material completo de álgebra",
  "tipo": "apostila",
  "tags": ["matematica", "algebra"],
  "link_externo": null
}
```

**Resposta:**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "message": "Material criado com sucesso"
}
```

### 2. Listar Materiais de uma Disciplina

**GET** `/api/materiais/disciplina/1`

**Resposta:**
```json
[
  {
    "_id": "507f1f77bcf86cd799439011",
    "disciplina_id": 1,
    "professor_id": 2,
    "titulo": "Apostila de Matemática",
    "descricao": "Material completo de álgebra",
    "tipo": "apostila",
    "tags": ["matematica", "algebra"],
    "arquivos": [],
    "criado_em": "2024-01-15T10:00:00Z",
    "ativo": true
  }
]
```

### 3. Upload de Arquivo para Material

**POST** `/api/materiais/{material_id}/arquivo`

**Headers:**
- `Content-Type`: tipo MIME do arquivo (ex: `application/pdf`)
- `X-File-Name`: nome do arquivo (ex: `apostila.pdf`)

**Body:** Binário do arquivo

**Exemplo com PowerShell:**
```powershell
$materialId = "507f1f77bcf86cd799439011"
$filePath = "C:\documentos\apostila.pdf"
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)

$headers = @{
    "Content-Type" = "application/pdf"
    "X-File-Name" = "apostila.pdf"
}

Invoke-RestMethod -Uri "http://localhost:8080/api/materiais/$materialId/arquivo" `
    -Method POST `
    -Body $fileBytes `
    -Headers $headers
```

**Resposta:**
```json
{
  "message": "Arquivo enviado com sucesso",
  "arquivo_id": "507f1f77bcf86cd799439012"
}
```

### 4. Download de Arquivo

**GET** `/api/materiais/arquivo/{arquivo_id}`

**Exemplo com PowerShell:**
```powershell
$arquivoId = "507f1f77bcf86cd799439012"
Invoke-WebRequest -Uri "http://localhost:8080/api/materiais/arquivo/$arquivoId" `
    -OutFile "apostila_baixada.pdf"
```

**Exemplo com navegador:**
```
http://localhost:8080/api/materiais/arquivo/507f1f77bcf86cd799439012
```

### 5. Atualizar Material

**PUT** `/api/materiais/{id}`

```json
{
  "titulo": "Apostila de Matemática - Revisada",
  "descricao": "Material completo de álgebra (2ª edição)",
  "tags": ["matematica", "algebra", "revisado"]
}
```

### 6. Deletar Material (Soft Delete)

**DELETE** `/api/materiais/{id}`

**Resposta:**
```json
{
  "message": "Material deletado com sucesso"
}
```

## 🧪 Testando a API

### Teste Completo com PowerShell

```powershell
# 1. Criar um material
$material = @{
    disciplina_id = 1
    professor_id = 2
    titulo = "Apostila de Cálculo I"
    descricao = "Limites e Derivadas"
    tipo = "apostila"
    tags = @("calculo", "derivadas", "limites")
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/materiais" `
    -Method POST `
    -Body $material `
    -ContentType "application/json"

$materialId = $response.id
Write-Host "Material criado: $materialId"

# 2. Upload de arquivo
$filePath = "C:\documentos\apostila_calculo.pdf"
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)
$headers = @{
    "Content-Type" = "application/pdf"
    "X-File-Name" = "apostila_calculo.pdf"
}

$uploadResponse = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/materiais/$materialId/arquivo" `
    -Method POST `
    -Body $fileBytes `
    -Headers $headers

Write-Host "Arquivo enviado: $($uploadResponse.arquivo_id)"

# 3. Listar materiais da disciplina
$materiais = Invoke-RestMethod `
    -Uri "http://localhost:8080/api/materiais/disciplina/1" `
    -Method GET

$materiais | ConvertTo-Json -Depth 10

# 4. Download do arquivo
$arquivoId = $uploadResponse.arquivo_id
Invoke-WebRequest `
    -Uri "http://localhost:8080/api/materiais/arquivo/$arquivoId" `
    -OutFile "apostila_baixada.pdf"

Write-Host "Arquivo baixado com sucesso!"
```

## 💡 Casos de Uso

### 1. Professor compartilha apostila
```json
POST /api/materiais
{
  "disciplina_id": 5,
  "professor_id": 10,
  "titulo": "Introdução à Programação - Aula 01",
  "descricao": "Conceitos básicos de lógica de programação",
  "tipo": "apostila",
  "tags": ["programacao", "logica", "introducao"]
}
```

### 2. Professor adiciona link do YouTube
```json
POST /api/materiais
{
  "disciplina_id": 5,
  "professor_id": 10,
  "titulo": "Vídeo-aula: Estruturas de Repetição",
  "descricao": "Explicação sobre loops for e while",
  "tipo": "video",
  "tags": ["programacao", "loops", "videoaula"],
  "link_externo": "https://youtube.com/watch?v=..."
}
```

### 3. Aluno acessa materiais da disciplina
```
GET /api/materiais/disciplina/5
```

### 4. Aluno baixa apostila
```
GET /api/materiais/arquivo/{arquivo_id}
```

## 🔒 Observações de Segurança

⚠️ **IMPORTANTE:** A implementação atual é básica e não inclui:

1. **Autenticação:** Qualquer pessoa pode fazer upload/download
2. **Autorização:** Não verifica se o usuário tem permissão para acessar o material
3. **Validação de arquivo:** Não valida tipo ou tamanho do arquivo
4. **Rate limiting:** Sem proteção contra abuso

### Melhorias Recomendadas para Produção:

```dart
// Adicionar middleware de autenticação
router.post('/', authMiddleware, (Request request) async {
  final userId = request.context['userId'];
  // Verificar se userId é professor...
});

// Validar tamanho do arquivo
const maxFileSize = 10 * 1024 * 1024; // 10MB
if (data.length > maxFileSize) {
  return Response(413, body: 'Arquivo muito grande');
}

// Validar tipo de arquivo
const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png'];
if (!allowedTypes.contains(contentType)) {
  return Response(415, body: 'Tipo de arquivo não permitido');
}

// Usar shelf_multipart para uploads reais
import 'package:shelf_multipart/shelf_multipart.dart';
```

## 📚 GridFS

GridFS é usado para armazenar arquivos grandes no MongoDB:

- **Vantagens:**
  - Suporta arquivos > 16MB
  - Streaming eficiente
  - Metadados personalizados
  - Integração nativa com MongoDB

- **Estrutura:**
  - `arquivos.files` - Metadados dos arquivos
  - `arquivos.chunks` - Chunks de 255KB do arquivo

- **Índices Automáticos:**
  - `files_id` + `n` nos chunks para recuperação eficiente

---

**Desenvolvido para o Portal PoliEduca** 🎓
