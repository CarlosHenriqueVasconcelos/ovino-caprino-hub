-- Adiciona campo is_read na tabela notes
ALTER TABLE notes ADD COLUMN is_read INTEGER DEFAULT 0;
