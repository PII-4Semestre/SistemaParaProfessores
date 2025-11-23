# Script de Setup do Banco de Dados PostgreSQL
# Sistema Para Professores - Portal PoliEduca

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   Setup do Banco de Dados PostgreSQL" -ForegroundColor Cyan
Write-Host "   Portal PoliEduca" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se o PostgreSQL está instalado
Write-Host "Verificando instalação do PostgreSQL..." -ForegroundColor Yellow
$psqlPath = Get-ChildItem "C:\Program Files\PostgreSQL" -Recurse -Filter psql.exe -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $psqlPath) {
    Write-Host "❌ PostgreSQL não encontrado!" -ForegroundColor Red
    Write-Host "Por favor, instale o PostgreSQL 18 ou superior:" -ForegroundColor Yellow
    Write-Host "https://www.postgresql.org/download/windows/" -ForegroundColor Cyan
    exit 1
}

$psql = $psqlPath.FullName
Write-Host "✅ PostgreSQL encontrado: $psql" -ForegroundColor Green
Write-Host ""

# Solicitar credenciais
Write-Host "Digite as credenciais do PostgreSQL:" -ForegroundColor Yellow
$username = Read-Host "Usuário (padrão: postgres)"
if ([string]::IsNullOrWhiteSpace($username)) {
    $username = "postgres"
}

$securePassword = Read-Host "Senha" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host ""

# Nome do banco de dados
$dbName = "sistema_professores"

# Verificar se o banco já existe
Write-Host "Verificando se o banco '$dbName' já existe..." -ForegroundColor Yellow
$env:PGPASSWORD = $password
$checkDb = & $psql -U $username -lqt | Select-String -Pattern $dbName

if ($checkDb) {
    Write-Host "⚠️  O banco '$dbName' já existe!" -ForegroundColor Yellow
    $response = Read-Host "Deseja recriar o banco? (S/N) [ATENÇÃO: Todos os dados serão perdidos]"
    
    if ($response -eq "S" -or $response -eq "s") {
        Write-Host "Deletando banco existente..." -ForegroundColor Yellow
        & $psql -U $username -c "DROP DATABASE $dbName;"
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Erro ao deletar banco!" -ForegroundColor Red
            exit 1
        }
        Write-Host "✅ Banco deletado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "❌ Setup cancelado pelo usuário." -ForegroundColor Red
        exit 0
    }
}

# Criar o banco de dados
Write-Host ""
Write-Host "Criando banco de dados '$dbName'..." -ForegroundColor Yellow
& $psql -U $username -c "CREATE DATABASE $dbName;"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao criar banco!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Banco criado com sucesso!" -ForegroundColor Green

# Executar schema.sql
Write-Host ""
Write-Host "Criando tabelas (schema.sql)..." -ForegroundColor Yellow
& $psql -U $username -d $dbName -f "database\schema.sql"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao criar schema!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Schema criado com sucesso!" -ForegroundColor Green

# Executar seed.sql
Write-Host ""
Write-Host "Populando banco com dados de exemplo (seed.sql)..." -ForegroundColor Yellow
& $psql -U $username -d $dbName -f "database\seed.sql"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao popular banco!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Dados de exemplo inseridos com sucesso!" -ForegroundColor Green

# Limpar senha da variável de ambiente
$env:PGPASSWORD = $null

# Resumo
Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "   ✅ Setup concluído com sucesso!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Informações do Banco:" -ForegroundColor Cyan
Write-Host "   • Nome: $dbName" -ForegroundColor White
Write-Host "   • Usuário: $username" -ForegroundColor White
Write-Host "   • Host: localhost" -ForegroundColor White
Write-Host "   • Porta: 5432" -ForegroundColor White
Write-Host ""
Write-Host "👤 Usuários de teste disponíveis:" -ForegroundColor Cyan
Write-Host "   Professores:" -ForegroundColor Yellow
Write-Host "   • professor@poliedro.com (qualquer senha)" -ForegroundColor White
Write-Host "   • silva@escola.com (qualquer senha)" -ForegroundColor White
Write-Host "   • maria@escola.com (qualquer senha)" -ForegroundColor White
Write-Host ""
Write-Host "   Alunos:" -ForegroundColor Yellow
Write-Host "   • aluno@poliedro.com (qualquer senha)" -ForegroundColor White
Write-Host "   • joao@aluno.com (qualquer senha)" -ForegroundColor White
Write-Host "   • ana@aluno.com (qualquer senha)" -ForegroundColor White
Write-Host "   • pedro@aluno.com (qualquer senha)" -ForegroundColor White
Write-Host ""
Write-Host "⚙️  Próximos passos:" -ForegroundColor Cyan
Write-Host "   1. Configure o arquivo .env com suas credenciais" -ForegroundColor White
Write-Host "   2. Execute: dart run bin/server.dart" -ForegroundColor White
Write-Host "   3. O servidor estará rodando em http://localhost:8080" -ForegroundColor White
Write-Host ""
