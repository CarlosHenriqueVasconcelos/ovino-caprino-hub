-- Remove tabelas não utilizadas: cost_centers e budgets
DROP TABLE IF EXISTS budgets CASCADE;
DROP TABLE IF EXISTS cost_centers CASCADE;

-- Remove coluna cost_center_id da tabela financial_accounts (se existir)
ALTER TABLE financial_accounts DROP COLUMN IF EXISTS cost_center_id;

-- Garante que a tabela animal_weights existe com o schema correto
CREATE TABLE IF NOT EXISTS animal_weights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  animal_id UUID NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  weight NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Índices para animal_weights
CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_date ON animal_weights(animal_id, date);
CREATE INDEX IF NOT EXISTS idx_animal_weights_date ON animal_weights(date);

-- Trigger para atualizar updated_at em animal_weights
DROP TRIGGER IF EXISTS update_animal_weights_updated_at ON animal_weights;
CREATE TRIGGER update_animal_weights_updated_at
  BEFORE UPDATE ON animal_weights
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Garante RLS habilitado em animal_weights
ALTER TABLE animal_weights ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para animal_weights (acesso público como outras tabelas)
DROP POLICY IF EXISTS "Pesos visíveis para todos" ON animal_weights;
CREATE POLICY "Pesos visíveis para todos" 
  ON animal_weights FOR SELECT 
  USING (true);

DROP POLICY IF EXISTS "Permite inserir pesos" ON animal_weights;
CREATE POLICY "Permite inserir pesos" 
  ON animal_weights FOR INSERT 
  WITH CHECK (true);

DROP POLICY IF EXISTS "Permite atualizar pesos" ON animal_weights;
CREATE POLICY "Permite atualizar pesos" 
  ON animal_weights FOR UPDATE 
  USING (true);

DROP POLICY IF EXISTS "Permite deletar pesos" ON animal_weights;
CREATE POLICY "Permite deletar pesos" 
  ON animal_weights FOR DELETE 
  USING (true);

-- Adiciona coluna stage à breeding_records se não existir (para compatibilidade)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'breeding_records' AND column_name = 'stage'
  ) THEN
    ALTER TABLE breeding_records ADD COLUMN stage TEXT DEFAULT 'encabritamento';
  END IF;
END $$;