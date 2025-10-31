-- Adicionar campo opened_quantity na tabela pharmacy_stock
-- Execute este SQL no Supabase para manter sincronização com o banco local

ALTER TABLE public.pharmacy_stock 
ADD COLUMN IF NOT EXISTS opened_quantity NUMERIC DEFAULT 0;

COMMENT ON COLUMN public.pharmacy_stock.opened_quantity IS 'Quantidade (ml) restante no frasco/ampola aberto';
