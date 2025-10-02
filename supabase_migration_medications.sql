-- ============================================================
-- MIGRAÇÃO SUPABASE: Adicionar Medicamentos e Campos Extras
-- ============================================================
-- Execute este SQL no SQL Editor do seu projeto Supabase
-- ============================================================

-- 1. Adicionar colunas faltantes na tabela animals
ALTER TABLE public.animals 
ADD COLUMN IF NOT EXISTS name_color TEXT,
ADD COLUMN IF NOT EXISTS category TEXT,
ADD COLUMN IF NOT EXISTS birth_weight REAL,
ADD COLUMN IF NOT EXISTS weight_30_days REAL,
ADD COLUMN IF NOT EXISTS weight_60_days REAL,
ADD COLUMN IF NOT EXISTS weight_90_days REAL;

-- 2. Criar tabela de medicamentos
CREATE TABLE IF NOT EXISTS public.medications (
  id TEXT PRIMARY KEY,
  animal_id TEXT NOT NULL,
  medication_name TEXT NOT NULL,
  date TEXT NOT NULL,
  next_date TEXT,
  dosage TEXT,
  veterinarian TEXT,
  notes TEXT,
  created_at TEXT NOT NULL,
  CONSTRAINT fk_medications_animal 
    FOREIGN KEY (animal_id) 
    REFERENCES public.animals(id) 
    ON DELETE CASCADE
);

-- 3. Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_medications_animal_id ON public.medications(animal_id);
CREATE INDEX IF NOT EXISTS idx_medications_date ON public.medications(date);
CREATE INDEX IF NOT EXISTS idx_medications_next_date ON public.medications(next_date);

-- 4. Habilitar RLS na tabela medications
ALTER TABLE public.medications ENABLE ROW LEVEL SECURITY;

-- 5. Políticas RLS para medications
-- Permitir todas operações para usuários autenticados
CREATE POLICY "Enable all access for authenticated users" ON public.medications
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- 6. Comentários nas tabelas e colunas (documentação)
COMMENT ON TABLE public.medications IS 'Registros de medicamentos aplicados aos animais';
COMMENT ON COLUMN public.medications.id IS 'ID único do registro de medicamento';
COMMENT ON COLUMN public.medications.animal_id IS 'ID do animal que recebeu o medicamento';
COMMENT ON COLUMN public.medications.medication_name IS 'Nome do medicamento aplicado';
COMMENT ON COLUMN public.medications.date IS 'Data de aplicação do medicamento';
COMMENT ON COLUMN public.medications.next_date IS 'Data prevista para próxima aplicação';
COMMENT ON COLUMN public.medications.dosage IS 'Dosagem aplicada';
COMMENT ON COLUMN public.medications.veterinarian IS 'Veterinário responsável';
COMMENT ON COLUMN public.medications.notes IS 'Observações adicionais';
COMMENT ON COLUMN public.medications.created_at IS 'Data de criação do registro';

COMMENT ON COLUMN public.animals.name_color IS 'Cor identificadora do nome do animal';
COMMENT ON COLUMN public.animals.category IS 'Categoria do animal (ex: Reprodutor, Matriz, Cordeiro, Cria)';
COMMENT ON COLUMN public.animals.birth_weight IS 'Peso ao nascer em kg';
COMMENT ON COLUMN public.animals.weight_30_days IS 'Peso aos 30 dias em kg';
COMMENT ON COLUMN public.animals.weight_60_days IS 'Peso aos 60 dias em kg';
COMMENT ON COLUMN public.animals.weight_90_days IS 'Peso aos 90 dias em kg';

-- ============================================================
-- FIM DA MIGRAÇÃO
-- ============================================================
-- Após executar, você pode verificar se tudo foi criado com:
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'animals';
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'medications';
-- ============================================================
