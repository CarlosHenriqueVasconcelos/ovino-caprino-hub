-- Adicionar campo status na tabela medications
ALTER TABLE public.medications 
ADD COLUMN status TEXT NOT NULL DEFAULT 'Agendado';

-- Atualizar registros existentes para terem status 'Agendado'
UPDATE public.medications 
SET status = 'Agendado' 
WHERE status IS NULL;

-- Adicionar campo applied_date para medications (útil para relatórios futuros)
ALTER TABLE public.medications 
ADD COLUMN applied_date DATE;

-- Adicionar comentários para documentação
COMMENT ON COLUMN public.medications.status IS 'Status do medicamento: Agendado, Aplicado, Cancelado';
COMMENT ON COLUMN public.medications.applied_date IS 'Data em que o medicamento foi aplicado';