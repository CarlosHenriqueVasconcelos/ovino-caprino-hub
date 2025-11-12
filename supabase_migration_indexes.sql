-- ============================================================
-- MIGRAÇÃO SUPABASE: Adicionar Índices para Otimização
-- ============================================================
-- Execute este SQL no SQL Editor do seu projeto Supabase
-- Esta migração adiciona índices em colunas frequentemente 
-- consultadas para melhorar a performance das queries
-- ============================================================

-- Índices para animals
CREATE INDEX IF NOT EXISTS idx_animals_category ON public.animals(category);
CREATE INDEX IF NOT EXISTS idx_animals_gender ON public.animals(gender);
CREATE INDEX IF NOT EXISTS idx_animals_pregnant ON public.animals(pregnant);
CREATE INDEX IF NOT EXISTS idx_animals_name ON public.animals(name);

-- Índices para animal_weights
CREATE INDEX IF NOT EXISTS idx_animal_weights_date ON public.animal_weights(date);

-- Índices para breeding_records
CREATE INDEX IF NOT EXISTS idx_breeding_stage ON public.breeding_records(stage);
CREATE INDEX IF NOT EXISTS idx_breeding_status ON public.breeding_records(status);

-- Índices para vaccinations
CREATE INDEX IF NOT EXISTS idx_vaccinations_status ON public.vaccinations(status);
CREATE INDEX IF NOT EXISTS idx_vaccinations_scheduled_date ON public.vaccinations(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_vaccinations_applied_date ON public.vaccinations(applied_date);

-- Índices para medications
CREATE INDEX IF NOT EXISTS idx_medications_status ON public.medications(status);
CREATE INDEX IF NOT EXISTS idx_medications_date ON public.medications(date);
CREATE INDEX IF NOT EXISTS idx_medications_applied_date ON public.medications(applied_date);

-- Índices para notes
CREATE INDEX IF NOT EXISTS idx_notes_category ON public.notes(category);
CREATE INDEX IF NOT EXISTS idx_notes_date ON public.notes(date);
CREATE INDEX IF NOT EXISTS idx_notes_is_read ON public.notes(is_read);

-- Índices para weight_alerts
CREATE INDEX IF NOT EXISTS idx_weight_alerts_completed ON public.weight_alerts(completed);

-- ============================================================
-- FIM DA MIGRAÇÃO
-- ============================================================
-- Após executar, você pode verificar os índices com:
-- SELECT schemaname, tablename, indexname 
-- FROM pg_indexes 
-- WHERE schemaname = 'public' 
-- ORDER BY tablename, indexname;
-- ============================================================
