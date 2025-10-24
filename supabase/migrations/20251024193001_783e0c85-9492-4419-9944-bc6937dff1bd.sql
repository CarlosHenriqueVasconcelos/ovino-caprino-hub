-- Adicionar novos campos às tabelas de animais
ALTER TABLE animals
ADD COLUMN year INTEGER,
ADD COLUMN lote TEXT,
ADD COLUMN mother_id TEXT;

ALTER TABLE sold_animals
ADD COLUMN year INTEGER,
ADD COLUMN lote TEXT,
ADD COLUMN mother_id TEXT;

ALTER TABLE deceased_animals
ADD COLUMN year INTEGER,
ADD COLUMN lote TEXT,
ADD COLUMN mother_id TEXT;

-- Criar índice composto para otimizar validação de unicidade
CREATE INDEX idx_animals_name_color_category ON animals(name, name_color, category);

-- Preencher year com o ano da data de nascimento para animais existentes
UPDATE animals SET year = EXTRACT(YEAR FROM birth_date) WHERE year IS NULL;
UPDATE sold_animals SET year = EXTRACT(YEAR FROM birth_date) WHERE year IS NULL;
UPDATE deceased_animals SET year = EXTRACT(YEAR FROM birth_date) WHERE year IS NULL;