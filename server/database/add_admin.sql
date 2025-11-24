-- Adiciona o tipo 'admin' ao enum tipo_usuario, se necessário, e insere um usuário admin
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_type t
        JOIN pg_enum e ON t.oid = e.enumtypid
        WHERE t.typname = 'tipo_usuario' AND e.enumlabel = 'admin'
    ) THEN
        ALTER TYPE tipo_usuario ADD VALUE 'admin';
    END IF;
END
$$;

INSERT INTO usuarios (nome, email, senha_hash, tipo)
VALUES ('Administrador', 'admin@poliedro.com', '$2b$10$abcdefghijklmnopqrstuv', 'admin')
ON CONFLICT (email) DO NOTHING;
