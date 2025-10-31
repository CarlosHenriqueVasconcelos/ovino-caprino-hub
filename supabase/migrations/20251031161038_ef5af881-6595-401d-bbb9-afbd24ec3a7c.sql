-- Migração: adicionar coluna para controlar frasco/ampola aberto
BEGIN;

-- Adiciona opened_quantity (ml restante do frasco/ampola aberto)
ALTER TABLE public.pharmacy_stock
ADD COLUMN IF NOT EXISTS opened_quantity NUMERIC DEFAULT 0;

-- Garante valores não nulos
UPDATE public.pharmacy_stock
SET opened_quantity = 0
WHERE opened_quantity IS NULL;

-- Documentação
COMMENT ON COLUMN public.pharmacy_stock.opened_quantity IS 'Quantidade (ml) restante no frasco/ampola aberto';

COMMIT;