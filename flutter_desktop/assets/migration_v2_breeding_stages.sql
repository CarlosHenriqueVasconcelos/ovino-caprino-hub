-- Migration v2: Add breeding stages system
-- This migration adds new fields to the breeding_records and medications tables

-- Add new fields to breeding_records if they don't exist
ALTER TABLE breeding_records ADD COLUMN mating_start_date TEXT;
ALTER TABLE breeding_records ADD COLUMN mating_end_date TEXT;
ALTER TABLE breeding_records ADD COLUMN separation_date TEXT;
ALTER TABLE breeding_records ADD COLUMN ultrasound_date TEXT;
ALTER TABLE breeding_records ADD COLUMN ultrasound_result TEXT;
ALTER TABLE breeding_records ADD COLUMN birth_date TEXT;
ALTER TABLE breeding_records ADD COLUMN stage TEXT DEFAULT 'Encabritamento';

-- Add missing fields to medications if they don't exist
ALTER TABLE medications ADD COLUMN applied_date TEXT;
ALTER TABLE medications ADD COLUMN status TEXT NOT NULL DEFAULT 'Agendado';
ALTER TABLE medications ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime('now'));

-- Update existing records to have mating_start_date from breeding_date
UPDATE breeding_records 
SET mating_start_date = breeding_date,
    mating_end_date = date(breeding_date, '+60 days')
WHERE mating_start_date IS NULL;

-- Create new indices for performance
CREATE INDEX IF NOT EXISTS idx_medications_status ON medications(status);
CREATE INDEX IF NOT EXISTS idx_breeding_stage ON breeding_records(stage);
