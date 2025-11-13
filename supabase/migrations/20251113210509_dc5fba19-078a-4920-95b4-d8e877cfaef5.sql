-- Adicionar campo father_id na tabela animals
-- Este campo já existe no banco local e precisa ser sincronizado no Supabase

ALTER TABLE public.animals 
ADD COLUMN IF NOT EXISTS father_id TEXT;

-- Adicionar comentário explicativo
COMMENT ON COLUMN public.animals.father_id IS 'ID do pai do animal (macho reprodutor)';