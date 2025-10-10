-- Limpar dados de teste do Supabase
-- Ordem respeitando foreign keys

-- Deletar registros que referenciam animals
DELETE FROM vaccinations;
DELETE FROM medications;
DELETE FROM notes;
DELETE FROM breeding_records;
DELETE FROM financial_records;
DELETE FROM animal_weights;

-- Deletar contas financeiras (podem referenciar animals e cost_centers)
DELETE FROM financial_accounts;

-- Deletar animais
DELETE FROM animals;

-- Deletar outras tabelas
DELETE FROM cost_centers;
DELETE FROM budgets;
DELETE FROM reports;
DELETE FROM push_tokens;