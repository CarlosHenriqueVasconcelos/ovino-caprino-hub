-- Tabela para animais vendidos
CREATE TABLE public.sold_animals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  original_animal_id UUID NOT NULL,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  species TEXT NOT NULL,
  breed TEXT NOT NULL,
  gender TEXT NOT NULL,
  birth_date DATE NOT NULL,
  weight NUMERIC NOT NULL,
  location TEXT NOT NULL,
  name_color TEXT,
  category TEXT,
  birth_weight NUMERIC,
  weight_30_days NUMERIC,
  weight_60_days NUMERIC,
  weight_90_days NUMERIC,
  -- Dados da venda
  sale_date DATE NOT NULL,
  sale_price NUMERIC,
  buyer TEXT,
  sale_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Tabela para animais falecidos
CREATE TABLE public.deceased_animals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  original_animal_id UUID NOT NULL,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  species TEXT NOT NULL,
  breed TEXT NOT NULL,
  gender TEXT NOT NULL,
  birth_date DATE NOT NULL,
  weight NUMERIC NOT NULL,
  location TEXT NOT NULL,
  name_color TEXT,
  category TEXT,
  birth_weight NUMERIC,
  weight_30_days NUMERIC,
  weight_60_days NUMERIC,
  weight_90_days NUMERIC,
  -- Dados do óbito
  death_date DATE NOT NULL,
  cause_of_death TEXT,
  death_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.sold_animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deceased_animals ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para sold_animals
CREATE POLICY "Animais vendidos visíveis para todos" 
ON public.sold_animals 
FOR SELECT 
USING (true);

CREATE POLICY "Permite inserir animais vendidos" 
ON public.sold_animals 
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Permite atualizar animais vendidos" 
ON public.sold_animals 
FOR UPDATE 
USING (true);

CREATE POLICY "Permite deletar animais vendidos" 
ON public.sold_animals 
FOR DELETE 
USING (true);

-- Políticas RLS para deceased_animals
CREATE POLICY "Animais falecidos visíveis para todos" 
ON public.deceased_animals 
FOR SELECT 
USING (true);

CREATE POLICY "Permite inserir animais falecidos" 
ON public.deceased_animals 
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Permite atualizar animais falecidos" 
ON public.deceased_animals 
FOR UPDATE 
USING (true);

CREATE POLICY "Permite deletar animais falecidos" 
ON public.deceased_animals 
FOR DELETE 
USING (true);

-- Triggers para atualizar updated_at
CREATE TRIGGER update_sold_animals_updated_at
BEFORE UPDATE ON public.sold_animals
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_deceased_animals_updated_at
BEFORE UPDATE ON public.deceased_animals
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Índices para performance
CREATE INDEX idx_sold_animals_code ON public.sold_animals(code);
CREATE INDEX idx_sold_animals_name_color ON public.sold_animals(name, name_color);
CREATE INDEX idx_deceased_animals_code ON public.deceased_animals(code);
CREATE INDEX idx_deceased_animals_name_color ON public.deceased_animals(name, name_color);