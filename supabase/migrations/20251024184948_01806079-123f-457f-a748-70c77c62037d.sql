-- Adicionar campo weight_120_days nas tabelas de animais vendidos e falecidos
ALTER TABLE public.sold_animals 
ADD COLUMN IF NOT EXISTS weight_120_days numeric;

ALTER TABLE public.deceased_animals 
ADD COLUMN IF NOT EXISTS weight_120_days numeric;