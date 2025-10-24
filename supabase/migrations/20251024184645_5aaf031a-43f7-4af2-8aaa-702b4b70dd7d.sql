-- Adicionar campo weight_120_days para borregos nas tabelas animals, sold_animals e deceased_animals
ALTER TABLE public.animals 
ADD COLUMN IF NOT EXISTS weight_120_days numeric;