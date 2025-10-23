-- Tabela de Baias
CREATE TABLE public.feeding_pens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  number TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Tabela de Tratos/Alimentação
CREATE TABLE public.feeding_schedules (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  pen_id UUID NOT NULL REFERENCES public.feeding_pens(id) ON DELETE CASCADE,
  feed_type TEXT NOT NULL,
  quantity NUMERIC NOT NULL,
  times_per_day INTEGER NOT NULL DEFAULT 1,
  feeding_times TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.feeding_pens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feeding_schedules ENABLE ROW LEVEL SECURITY;

-- Políticas para feeding_pens
CREATE POLICY "Baias visíveis para todos" 
ON public.feeding_pens 
FOR SELECT 
USING (true);

CREATE POLICY "Permite inserir baias" 
ON public.feeding_pens 
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Permite atualizar baias" 
ON public.feeding_pens 
FOR UPDATE 
USING (true);

CREATE POLICY "Permite deletar baias" 
ON public.feeding_pens 
FOR DELETE 
USING (true);

-- Políticas para feeding_schedules
CREATE POLICY "Tratos visíveis para todos" 
ON public.feeding_schedules 
FOR SELECT 
USING (true);

CREATE POLICY "Permite inserir tratos" 
ON public.feeding_schedules 
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Permite atualizar tratos" 
ON public.feeding_schedules 
FOR UPDATE 
USING (true);

CREATE POLICY "Permite deletar tratos" 
ON public.feeding_schedules 
FOR DELETE 
USING (true);

-- Triggers para updated_at
CREATE TRIGGER update_feeding_pens_updated_at
BEFORE UPDATE ON public.feeding_pens
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_feeding_schedules_updated_at
BEFORE UPDATE ON public.feeding_schedules
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Índices
CREATE INDEX idx_feeding_schedules_pen_id ON public.feeding_schedules(pen_id);
CREATE INDEX idx_feeding_pens_name ON public.feeding_pens(name);