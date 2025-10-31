-- Migration v4: Advanced Breeding Management
-- Adds fields for detailed reproduction tracking

-- Add fields for lamb birth details
ALTER TABLE breeding_records ADD COLUMN lambs_count INTEGER;
ALTER TABLE breeding_records ADD COLUMN lambs_alive INTEGER;
ALTER TABLE breeding_records ADD COLUMN lambs_dead INTEGER;

-- Add fields for heat cycle tracking
ALTER TABLE breeding_records ADD COLUMN heat_detected_date TEXT;
ALTER TABLE breeding_records ADD COLUMN natural_heat INTEGER DEFAULT 1;
ALTER TABLE breeding_records ADD COLUMN heat_notes TEXT;
