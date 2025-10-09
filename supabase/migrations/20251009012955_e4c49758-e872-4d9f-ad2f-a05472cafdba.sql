-- Add new fields to breeding_records table for multi-stage breeding management
ALTER TABLE breeding_records
ADD COLUMN IF NOT EXISTS mating_start_date DATE,
ADD COLUMN IF NOT EXISTS mating_end_date DATE,
ADD COLUMN IF NOT EXISTS separation_date DATE,
ADD COLUMN IF NOT EXISTS ultrasound_date DATE,
ADD COLUMN IF NOT EXISTS ultrasound_result TEXT,
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS stage TEXT DEFAULT 'Encabritamento';

-- Update existing records to have mating_start_date from breeding_date
UPDATE breeding_records 
SET mating_start_date = breeding_date,
    mating_end_date = breeding_date + INTERVAL '60 days'
WHERE mating_start_date IS NULL;

-- Add comment explaining the stage column
COMMENT ON COLUMN breeding_records.stage IS 'Breeding stage: Encabritamento, Separacao, Aguardando_Ultrassom, Gestacao_Confirmada, Parto_Realizado, Falhou';