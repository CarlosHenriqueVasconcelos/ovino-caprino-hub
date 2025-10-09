-- Criar tabela animal_weights
CREATE TABLE IF NOT EXISTS animal_weights (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  animal_id uuid NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
  date date NOT NULL,
  weight numeric NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Índice para otimizar buscas por animal e data
CREATE INDEX idx_animal_weights_animal_date ON animal_weights(animal_id, date);

-- Trigger para atualizar updated_at automaticamente
CREATE TRIGGER animal_weights_updated_at 
  BEFORE UPDATE ON animal_weights 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Habilitar Row Level Security
ALTER TABLE animal_weights ENABLE ROW LEVEL SECURITY;

-- Política: Pesos visíveis para todos
CREATE POLICY "Pesos visíveis para todos"
  ON animal_weights FOR SELECT
  USING (true);

-- Política: Permite inserir pesos
CREATE POLICY "Permite inserir pesos"
  ON animal_weights FOR INSERT
  WITH CHECK (true);

-- Política: Permite atualizar pesos
CREATE POLICY "Permite atualizar pesos"
  ON animal_weights FOR UPDATE
  USING (true);

-- Política: Permite deletar pesos
CREATE POLICY "Permite deletar pesos"
  ON animal_weights FOR DELETE
  USING (true);