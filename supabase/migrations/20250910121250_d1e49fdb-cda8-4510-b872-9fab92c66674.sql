-- Criar tabela de animais
CREATE TABLE public.animals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  species TEXT NOT NULL CHECK (species IN ('Ovino', 'Caprino')),
  breed TEXT NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('Macho', 'Fêmea')),
  birth_date DATE NOT NULL,
  weight DECIMAL(5,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'Saudável',
  location TEXT NOT NULL,
  last_vaccination DATE,
  pregnant BOOLEAN DEFAULT false,
  expected_delivery DATE,
  health_issue TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Criar tabela de vacinações
CREATE TABLE public.vaccinations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  animal_id UUID NOT NULL REFERENCES public.animals(id) ON DELETE CASCADE,
  vaccine_name TEXT NOT NULL,
  vaccine_type TEXT NOT NULL,
  scheduled_date DATE NOT NULL,
  applied_date DATE,
  veterinarian TEXT,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'Agendada' CHECK (status IN ('Agendada', 'Aplicada', 'Cancelada')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Criar tabela de relatórios
CREATE TABLE public.reports (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  report_type TEXT NOT NULL CHECK (report_type IN ('Animais', 'Vacinações', 'Reprodução', 'Saúde', 'Financeiro')),
  parameters JSONB NOT NULL DEFAULT '{}',
  generated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  generated_by TEXT
);

-- Habilitar RLS nas tabelas
ALTER TABLE public.animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vaccinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Políticas para acesso público (dados da fazenda)
CREATE POLICY "Animais são visíveis para todos"
ON public.animals
FOR SELECT
USING (true);

CREATE POLICY "Permite inserir novos animais"
ON public.animals
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Permite atualizar animais"
ON public.animals
FOR UPDATE
USING (true);

CREATE POLICY "Permite deletar animais"
ON public.animals
FOR DELETE
USING (true);

-- Políticas para vacinações
CREATE POLICY "Vacinações são visíveis para todos"
ON public.vaccinations
FOR SELECT
USING (true);

CREATE POLICY "Permite inserir vacinações"
ON public.vaccinations
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Permite atualizar vacinações"
ON public.vaccinations
FOR UPDATE
USING (true);

CREATE POLICY "Permite deletar vacinações"
ON public.vaccinations
FOR DELETE
USING (true);

-- Políticas para relatórios
CREATE POLICY "Relatórios são visíveis para todos"
ON public.reports
FOR SELECT
USING (true);

CREATE POLICY "Permite inserir relatórios"
ON public.reports
FOR INSERT
WITH CHECK (true);

-- Função para atualizar timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Triggers para atualizar timestamps
CREATE TRIGGER update_animals_updated_at
  BEFORE UPDATE ON public.animals
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_vaccinations_updated_at
  BEFORE UPDATE ON public.vaccinations
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Inserir dados iniciais
INSERT INTO public.animals (code, name, species, breed, gender, birth_date, weight, status, location, last_vaccination, pregnant, expected_delivery) VALUES
('OV001', 'Benedita', 'Ovino', 'Santa Inês', 'Fêmea', '2022-03-15', 45.50, 'Saudável', 'Pasto A1', '2024-08-15', true, '2024-12-20'),
('CP002', 'Joaquim', 'Caprino', 'Boer', 'Macho', '2021-07-22', 65.20, 'Reprodutor', 'Pasto B2', '2024-09-01', false, null),
('OV003', 'Esperança', 'Ovino', 'Morada Nova', 'Fêmea', '2023-01-10', 38.00, 'Em tratamento', 'Enfermaria', '2024-07-20', false, null);

-- Inserir vacinações iniciais
INSERT INTO public.vaccinations (animal_id, vaccine_name, vaccine_type, scheduled_date, status) VALUES
((SELECT id FROM public.animals WHERE code = 'OV001'), 'Clostridiose', 'Preventiva', '2025-02-15', 'Agendada'),
((SELECT id FROM public.animals WHERE code = 'CP002'), 'Raiva', 'Preventiva', '2025-01-20', 'Agendada'),
((SELECT id FROM public.animals WHERE code = 'OV003'), 'Verminose', 'Terapêutica', '2025-01-10', 'Agendada');