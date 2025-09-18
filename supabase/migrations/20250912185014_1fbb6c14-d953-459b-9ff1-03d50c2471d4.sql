-- Notes table
CREATE TABLE IF NOT EXISTS public.notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  animal_id uuid REFERENCES public.animals(id) ON DELETE SET NULL,
  title text NOT NULL,
  content text,
  category text NOT NULL,
  priority text NOT NULL DEFAULT 'Média',
  date date NOT NULL DEFAULT now(),
  created_by text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "Notas visíveis para todos"
  ON public.notes FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Permite inserir notas"
  ON public.notes FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "Permite atualizar notas"
  ON public.notes FOR UPDATE USING (true);
CREATE POLICY IF NOT EXISTS "Permite deletar notas"
  ON public.notes FOR DELETE USING (true);

CREATE TRIGGER IF NOT EXISTS update_notes_updated_at
BEFORE UPDATE ON public.notes
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Breeding records table
CREATE TABLE IF NOT EXISTS public.breeding_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  female_animal_id uuid REFERENCES public.animals(id) ON DELETE CASCADE,
  male_animal_id uuid REFERENCES public.animals(id) ON DELETE SET NULL,
  breeding_date date NOT NULL,
  expected_birth date,
  status text NOT NULL DEFAULT 'Cobertura',
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.breeding_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "Registros de reprodução visíveis para todos"
  ON public.breeding_records FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Permite inserir reprodução"
  ON public.breeding_records FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "Permite atualizar reprodução"
  ON public.breeding_records FOR UPDATE USING (true);
CREATE POLICY IF NOT EXISTS "Permite deletar reprodução"
  ON public.breeding_records FOR DELETE USING (true);

CREATE TRIGGER IF NOT EXISTS update_breeding_records_updated_at
BEFORE UPDATE ON public.breeding_records
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Financial records table
CREATE TABLE IF NOT EXISTS public.financial_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL CHECK (type IN ('receita', 'despesa')),
  category text NOT NULL,
  description text,
  amount numeric NOT NULL,
  date date NOT NULL DEFAULT now(),
  animal_id uuid REFERENCES public.animals(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.financial_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "Registros financeiros visíveis para todos"
  ON public.financial_records FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Permite inserir registros financeiros"
  ON public.financial_records FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "Permite atualizar registros financeiros"
  ON public.financial_records FOR UPDATE USING (true);
CREATE POLICY IF NOT EXISTS "Permite deletar registros financeiros"
  ON public.financial_records FOR DELETE USING (true);

CREATE TRIGGER IF NOT EXISTS update_financial_records_updated_at
BEFORE UPDATE ON public.financial_records
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Push tokens table
CREATE TABLE IF NOT EXISTS public.push_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token text NOT NULL UNIQUE,
  platform text,
  device_info jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "Tokens visíveis para todos"
  ON public.push_tokens FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Permite inserir tokens"
  ON public.push_tokens FOR INSERT WITH CHECK (true);
