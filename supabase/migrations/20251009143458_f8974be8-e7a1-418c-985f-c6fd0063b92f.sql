-- Adiciona campo is_read na tabela notes
ALTER TABLE notes 
ADD COLUMN is_read boolean DEFAULT false NOT NULL;

-- Atualiza registros existentes para garantir consistência
UPDATE notes 
SET is_read = false 
WHERE is_read IS NULL;