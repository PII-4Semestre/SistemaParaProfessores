#!/bin/bash

# Script de Setup do Banco de Dados PostgreSQL
# Sistema Para Professores - Portal PoliEduca

echo "==============================================="
echo "   Setup do Banco de Dados PostgreSQL"
echo "   Portal PoliEduca"
echo "==============================================="
echo ""

# Verificar se o PostgreSQL está instalado
echo "Verificando instalação do PostgreSQL..."
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL não encontrado!"
    echo "Por favor, instale o PostgreSQL 18 ou superior:"
    echo "  Ubuntu/Debian: sudo apt-get install postgresql"
    echo "  macOS: brew install postgresql"
    exit 1
fi

echo "✅ PostgreSQL encontrado: $(which psql)"
echo ""

# Solicitar credenciais
echo "Digite as credenciais do PostgreSQL:"
read -p "Usuário (padrão: postgres): " username
username=${username:-postgres}

read -sp "Senha: " password
echo ""
echo ""

# Nome do banco de dados
dbName="sistema_professores"

# Verificar se o banco já existe
echo "Verificando se o banco '$dbName' já existe..."
export PGPASSWORD=$password
if psql -U $username -lqt | cut -d \| -f 1 | grep -qw $dbName; then
    echo "⚠️  O banco '$dbName' já existe!"
    read -p "Deseja recriar o banco? (s/N) [ATENÇÃO: Todos os dados serão perdidos]: " response
    
    if [[ "$response" =~ ^[Ss]$ ]]; then
        echo "Deletando banco existente..."
        psql -U $username -c "DROP DATABASE $dbName;"
        
        if [ $? -ne 0 ]; then
            echo "❌ Erro ao deletar banco!"
            exit 1
        fi
        echo "✅ Banco deletado com sucesso!"
    else
        echo "❌ Setup cancelado pelo usuário."
        exit 0
    fi
fi

# Criar o banco de dados
echo ""
echo "Criando banco de dados '$dbName'..."
psql -U $username -c "CREATE DATABASE $dbName;"

if [ $? -ne 0 ]; then
    echo "❌ Erro ao criar banco!"
    exit 1
fi
echo "✅ Banco criado com sucesso!"

# Executar schema.sql
echo ""
echo "Criando tabelas (schema.sql)..."
psql -U $username -d $dbName -f database/schema.sql

if [ $? -ne 0 ]; then
    echo "❌ Erro ao criar schema!"
    exit 1
fi
echo "✅ Schema criado com sucesso!"

# Executar seed.sql
echo ""
echo "Populando banco com dados de exemplo (seed.sql)..."
psql -U $username -d $dbName -f database/seed.sql

if [ $? -ne 0 ]; then
    echo "❌ Erro ao popular banco!"
    exit 1
fi
echo "✅ Dados de exemplo inseridos com sucesso!"

# Limpar senha
unset PGPASSWORD

# Resumo
echo ""
echo "==============================================="
echo "   ✅ Setup concluído com sucesso!"
echo "==============================================="
echo ""
echo "📋 Informações do Banco:"
echo "   • Nome: $dbName"
echo "   • Usuário: $username"
echo "   • Host: localhost"
echo "   • Porta: 5432"
echo ""
echo "👤 Usuários de teste disponíveis:"
echo "   Professores:"
echo "   • professor@poliedro.com (qualquer senha)"
echo "   • silva@escola.com (qualquer senha)"
echo "   • maria@escola.com (qualquer senha)"
echo ""
echo "   Alunos:"
echo "   • aluno@poliedro.com (qualquer senha)"
echo "   • joao@aluno.com (qualquer senha)"
echo "   • ana@aluno.com (qualquer senha)"
echo "   • pedro@aluno.com (qualquer senha)"
echo ""
echo "⚙️  Próximos passos:"
echo "   1. Configure o arquivo .env com suas credenciais"
echo "   2. Execute: dart run bin/server.dart"
echo "   3. O servidor estará rodando em http://localhost:8080"
echo ""
