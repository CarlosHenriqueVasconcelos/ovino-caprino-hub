-- Migração v5: Adicionar campo father_id para controle completo de parentesco

-- Adicionar coluna father_id na tabela animals
ALTER TABLE animals ADD COLUMN father_id TEXT;

-- Adicionar coluna father_id na tabela sold_animals
ALTER TABLE sold_animals ADD COLUMN father_id TEXT;

-- Adicionar coluna father_id na tabela deceased_animals
ALTER TABLE deceased_animals ADD COLUMN father_id TEXT;
