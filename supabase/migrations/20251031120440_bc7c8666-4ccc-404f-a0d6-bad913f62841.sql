-- Add father_id field to animals, sold_animals, and deceased_animals tables
-- This migration synchronizes the Supabase schema with the local database schema

-- Add father_id to animals table
ALTER TABLE animals ADD COLUMN father_id TEXT;

-- Add father_id to sold_animals table
ALTER TABLE sold_animals ADD COLUMN father_id TEXT;

-- Add father_id to deceased_animals table
ALTER TABLE deceased_animals ADD COLUMN father_id TEXT;

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_animals_father_id ON animals(father_id);
CREATE INDEX IF NOT EXISTS idx_sold_animals_father_id ON sold_animals(father_id);
CREATE INDEX IF NOT EXISTS idx_deceased_animals_father_id ON deceased_animals(father_id);