-- ============================================================
-- MIGRAÇÃO: Sistema de Farmácia
-- ============================================================

-- 1. Criar tabela de estoque da farmácia
CREATE TABLE IF NOT EXISTS public.pharmacy_stock (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  medication_name TEXT NOT NULL,
  medication_type TEXT NOT NULL,
  unit_of_measure TEXT NOT NULL,
  quantity_per_unit NUMERIC,
  total_quantity NUMERIC NOT NULL DEFAULT 0,
  min_stock_alert NUMERIC,
  expiration_date DATE,
  manufacturer TEXT,
  batch_number TEXT,
  purchase_price NUMERIC,
  is_opened BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Criar tabela de movimentações do estoque
CREATE TABLE IF NOT EXISTS public.pharmacy_stock_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pharmacy_stock_id UUID NOT NULL REFERENCES public.pharmacy_stock(id) ON DELETE CASCADE,
  medication_id UUID REFERENCES public.medications(id),
  movement_type TEXT NOT NULL,
  quantity NUMERIC NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Adicionar coluna pharmacy_stock_id na tabela medications
ALTER TABLE public.medications 
ADD COLUMN IF NOT EXISTS pharmacy_stock_id UUID REFERENCES public.pharmacy_stock(id);

ALTER TABLE public.medications
ADD COLUMN IF NOT EXISTS quantity_used NUMERIC;

-- 4. Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_name ON public.pharmacy_stock(medication_name);
CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_expiration ON public.pharmacy_stock(expiration_date);
CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_type ON public.pharmacy_stock(medication_type);
CREATE INDEX IF NOT EXISTS idx_movements_stock_id ON public.pharmacy_stock_movements(pharmacy_stock_id);
CREATE INDEX IF NOT EXISTS idx_movements_medication_id ON public.pharmacy_stock_movements(medication_id);
CREATE INDEX IF NOT EXISTS idx_medications_pharmacy_stock ON public.medications(pharmacy_stock_id);

-- 5. Habilitar RLS
ALTER TABLE public.pharmacy_stock ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pharmacy_stock_movements ENABLE ROW LEVEL SECURITY;

-- 6. Políticas RLS para pharmacy_stock
CREATE POLICY "Estoque visível para todos" 
ON public.pharmacy_stock FOR SELECT 
USING (true);

CREATE POLICY "Permite inserir no estoque" 
ON public.pharmacy_stock FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Permite atualizar estoque" 
ON public.pharmacy_stock FOR UPDATE 
USING (true);

CREATE POLICY "Permite deletar do estoque" 
ON public.pharmacy_stock FOR DELETE 
USING (true);

-- 7. Políticas RLS para pharmacy_stock_movements
CREATE POLICY "Movimentações visíveis para todos" 
ON public.pharmacy_stock_movements FOR SELECT 
USING (true);

CREATE POLICY "Permite inserir movimentações" 
ON public.pharmacy_stock_movements FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Permite atualizar movimentações" 
ON public.pharmacy_stock_movements FOR UPDATE 
USING (true);

CREATE POLICY "Permite deletar movimentações" 
ON public.pharmacy_stock_movements FOR DELETE 
USING (true);

-- 8. Trigger para atualizar updated_at
CREATE TRIGGER update_pharmacy_stock_updated_at
BEFORE UPDATE ON public.pharmacy_stock
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- 9. Comentários nas tabelas
COMMENT ON TABLE public.pharmacy_stock IS 'Estoque de medicamentos da farmácia';
COMMENT ON TABLE public.pharmacy_stock_movements IS 'Histórico de movimentações do estoque';
COMMENT ON COLUMN public.pharmacy_stock.medication_name IS 'Nome do medicamento';
COMMENT ON COLUMN public.pharmacy_stock.medication_type IS 'Tipo: Ampola, Comprimido, Frasco, etc';
COMMENT ON COLUMN public.pharmacy_stock.unit_of_measure IS 'Unidade: ml, mg, comprimido, unidade';
COMMENT ON COLUMN public.pharmacy_stock.quantity_per_unit IS 'Quantidade por unidade (ex: 10ml por ampola)';
COMMENT ON COLUMN public.pharmacy_stock.total_quantity IS 'Quantidade total disponível';
COMMENT ON COLUMN public.pharmacy_stock.is_opened IS 'Indica se é ampola aberta/parcialmente usada';
COMMENT ON COLUMN public.medications.pharmacy_stock_id IS 'Referência ao medicamento da farmácia';
COMMENT ON COLUMN public.medications.quantity_used IS 'Quantidade usada na aplicação';