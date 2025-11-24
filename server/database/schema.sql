-- Database: sistema_professores
-- Criação das tabelas para o Sistema Para Professores

CREATE TYPE tipo_usuario AS ENUM ('professor', 'aluno', 'admin');

-- Tabela de Usuários
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    tipo tipo_usuario NOT NULL,
    ra VARCHAR(20), -- Apenas para alunos
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Disciplinas
CREATE TABLE disciplinas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    professor_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    cor VARCHAR(7) DEFAULT '#FF9800', -- Hex color
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de relacionamento Aluno-Disciplina (Many-to-Many)
CREATE TABLE aluno_disciplina (
    aluno_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    disciplina_id INTEGER NOT NULL REFERENCES disciplinas(id) ON DELETE CASCADE,
    matriculado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (aluno_id, disciplina_id)
);

-- Tabela de Atividades
CREATE TABLE atividades (
    id SERIAL PRIMARY KEY,
    disciplina_id INTEGER NOT NULL REFERENCES disciplinas(id) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    descricao TEXT,
    peso DECIMAL(5,2) DEFAULT 1.0,
    data_entrega TIMESTAMP,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Entregas (Submissions)
CREATE TABLE entregas (
    id SERIAL PRIMARY KEY,
    atividade_id INTEGER NOT NULL REFERENCES atividades(id) ON DELETE CASCADE,
    aluno_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    arquivo_url TEXT,
    observacoes TEXT,
    entregue_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(atividade_id, aluno_id)
);

-- Tabela de Notas
CREATE TABLE notas (
    id SERIAL PRIMARY KEY,
    atividade_id INTEGER NOT NULL REFERENCES atividades(id) ON DELETE CASCADE,
    aluno_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nota DECIMAL(5,2) NOT NULL,
    comentario TEXT,
    atribuida_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizada_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(atividade_id, aluno_id)
);

-- Tabela de Mensagens
CREATE TABLE mensagens (
    id SERIAL PRIMARY KEY,
    remetente_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    destinatario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    disciplina_id INTEGER REFERENCES disciplinas(id) ON DELETE SET NULL,
    conteudo TEXT NOT NULL,
    lida BOOLEAN DEFAULT FALSE,
    enviada_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para melhor performance
CREATE INDEX idx_disciplinas_professor ON disciplinas(professor_id);
CREATE INDEX idx_atividades_disciplina ON atividades(disciplina_id);
CREATE INDEX idx_notas_aluno ON notas(aluno_id);
CREATE INDEX idx_notas_atividade ON notas(atividade_id);
CREATE INDEX idx_mensagens_destinatario ON mensagens(destinatario_id);
CREATE INDEX idx_mensagens_remetente ON mensagens(remetente_id);

-- Função para atualizar timestamp
CREATE OR REPLACE FUNCTION atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para atualizar timestamp automaticamente
CREATE TRIGGER trigger_usuarios_timestamp
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_timestamp();

CREATE TRIGGER trigger_disciplinas_timestamp
    BEFORE UPDATE ON disciplinas
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_timestamp();

CREATE TRIGGER trigger_atividades_timestamp
    BEFORE UPDATE ON atividades
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_timestamp();

CREATE TRIGGER trigger_notas_timestamp
    BEFORE UPDATE ON notas
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_timestamp();
