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

-- Push tokens table
CREATE TABLE IF NOT EXISTS public.push_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token text NOT NULL UNIQUE,
  platform text,
  device_info jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;