-- Dados de exemplo para testes

-- Inserir professores
INSERT INTO usuarios (nome, email, senha_hash, tipo) VALUES
('Prof. Silva', 'silva@escola.com', '$2b$10$abcdefghijklmnopqrstuv', 'professor'),
('Prof. Maria', 'maria@escola.com', '$2b$10$abcdefghijklmnopqrstuv', 'professor');

-- Inserir alunos
INSERT INTO usuarios (nome, email, senha_hash, tipo, ra) VALUES
('Joao Santos', 'joao@aluno.com', '$2b$10$abcdefghijklmnopqrstuv', 'aluno', 'RA001'),
('Ana Costa', 'ana@aluno.com', '$2b$10$abcdefghijklmnopqrstuv', 'aluno', 'RA002'),
('Pedro Lima', 'pedro@aluno.com', '$2b$10$abcdefghijklmnopqrstuv', 'aluno', 'RA003');

-- Inserir disciplinas
INSERT INTO disciplinas (nome, descricao, professor_id, cor) VALUES
('Matematica', 'Calculo e Algebra Linear', 1, '#2196F3'),
('Programacao', 'Desenvolvimento em Flutter e Dart', 1, '#4CAF50'),
('Fisica', 'Mecanica e Termodinamica', 2, '#FF9800');

-- Matricular alunos nas disciplinas
INSERT INTO aluno_disciplina (aluno_id, disciplina_id) VALUES
(3, 1), (3, 2), -- Joao em Matematica e Programacao
(4, 1), (4, 3), -- Ana em Matematica e Fisica
(5, 2), (5, 3); -- Pedro em Programacao e Fisica

-- Inserir atividades
INSERT INTO atividades (disciplina_id, titulo, descricao, peso, data_entrega) VALUES
(1, 'Prova 1', 'Primeira avaliacao de calculo', 3.0, '2025-10-20 23:59:00'),
(1, 'Lista de Exercicios 1', 'Exercicios sobre derivadas', 1.0, '2025-10-15 23:59:00'),
(2, 'Projeto Flutter', 'Desenvolvimento de app mobile', 4.0, '2025-11-01 23:59:00'),
(3, 'Experimento Lab 1', 'Relatorio de laboratorio', 2.0, '2025-10-18 23:59:00');

-- Inserir algumas entregas
INSERT INTO entregas (atividade_id, aluno_id, arquivo_url, observacoes) VALUES
(2, 3, 'https://storage.example.com/joao_lista1.pdf', 'Concluido'),
(4, 4, 'https://storage.example.com/ana_lab1.pdf', 'Experimento realizado');

-- Inserir notas
INSERT INTO notas (atividade_id, aluno_id, nota, comentario) VALUES
(2, 3, 8.5, 'Bom trabalho!'),
(4, 4, 9.0, 'Excelente relatorio');

-- Inserir mensagens
INSERT INTO mensagens (remetente_id, destinatario_id, disciplina_id, conteudo) VALUES
(3, 1, 1, 'Professor, tenho uma duvida sobre a lista de exercicios.'),
(1, 3, 1, 'Claro! Qual e sua duvida?'),
(4, 2, 3, 'Professora, qual e a data da proxima prova?');
