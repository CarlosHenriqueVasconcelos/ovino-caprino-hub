-- Migração v6: Adicionar índices para otimizar consultas SQL
-- Esta migração cria índices em colunas frequentemente usadas em WHERE, JOIN e ORDER BY

-- Índices para vaccinations
CREATE INDEX IF NOT EXISTS idx_vaccinations_status ON vaccinations(status);
CREATE INDEX IF NOT EXISTS idx_vaccinations_scheduled_date ON vaccinations(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_id ON vaccinations(animal_id);
CREATE INDEX IF NOT EXISTS idx_vaccinations_applied_date ON vaccinations(applied_date);

-- Índices para medications
CREATE INDEX IF NOT EXISTS idx_medications_status ON medications(status);
CREATE INDEX IF NOT EXISTS idx_medications_date ON medications(date);
CREATE INDEX IF NOT EXISTS idx_medications_animal_id ON medications(animal_id);
CREATE INDEX IF NOT EXISTS idx_medications_applied_date ON medications(applied_date);

-- Índices para animals
CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status);
CREATE INDEX IF NOT EXISTS idx_animals_category ON animals(category);
CREATE INDEX IF NOT EXISTS idx_animals_gender ON animals(gender);
CREATE INDEX IF NOT EXISTS idx_animals_pregnant ON animals(pregnant);
CREATE INDEX IF NOT EXISTS idx_animals_name ON animals(name COLLATE NOCASE);
CREATE INDEX IF NOT EXISTS idx_animals_code ON animals(code);

-- Índices para breeding_records
CREATE INDEX IF NOT EXISTS idx_breeding_stage ON breeding_records(stage);
CREATE INDEX IF NOT EXISTS idx_breeding_status ON breeding_records(status);
CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id);
CREATE INDEX IF NOT EXISTS idx_breeding_male ON breeding_records(male_animal_id);

-- Índices para weight_alerts
CREATE INDEX IF NOT EXISTS idx_weight_alerts_completed ON weight_alerts(completed);
CREATE INDEX IF NOT EXISTS idx_weight_alerts_due_date ON weight_alerts(due_date);
CREATE INDEX IF NOT EXISTS idx_weight_alerts_animal_id ON weight_alerts(animal_id);

-- Índices para animal_weights
CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_id ON animal_weights(animal_id);
CREATE INDEX IF NOT EXISTS idx_animal_weights_date ON animal_weights(date);

-- Índices para financial_accounts
CREATE INDEX IF NOT EXISTS idx_financial_accounts_status ON financial_accounts(status);
CREATE INDEX IF NOT EXISTS idx_financial_accounts_type ON financial_accounts(type);
CREATE INDEX IF NOT EXISTS idx_financial_accounts_due_date ON financial_accounts(due_date);
CREATE INDEX IF NOT EXISTS idx_financial_accounts_animal_id ON financial_accounts(animal_id);

-- Índices para notes
CREATE INDEX IF NOT EXISTS idx_notes_animal_id ON notes(animal_id);
CREATE INDEX IF NOT EXISTS idx_notes_category ON notes(category);
CREATE INDEX IF NOT EXISTS idx_notes_date ON notes(date);
CREATE INDEX IF NOT EXISTS idx_notes_is_read ON notes(is_read);

-- Índices para feeding_schedules
CREATE INDEX IF NOT EXISTS idx_feeding_schedules_pen_id ON feeding_schedules(pen_id);

-- Índices para pharmacy_stock
CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_medication_name ON pharmacy_stock(medication_name);
CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_expiration_date ON pharmacy_stock(expiration_date);

-- Índices para pharmacy_stock_movements
CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_movements_stock_id ON pharmacy_stock_movements(pharmacy_stock_id);
CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_movements_medication_id ON pharmacy_stock_movements(medication_id);
