-- Schema inicial compatível com Supabase
-- BEGO Ovino e Caprino Database

-- Tabela de animais
CREATE TABLE IF NOT EXISTS animals (
  id TEXT PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  name_color TEXT,
  category TEXT,
  species TEXT NOT NULL,
  breed TEXT NOT NULL,
  gender TEXT NOT NULL,
  birth_date TEXT NOT NULL,
  weight REAL NOT NULL,
  status TEXT NOT NULL DEFAULT 'Saudável',
  location TEXT,
  last_vaccination TEXT,
  pregnant INTEGER DEFAULT 0,
  expected_delivery TEXT,
  health_issue TEXT,
  birth_weight REAL,
  weight_30_days REAL,
  weight_60_days REAL,
  weight_90_days REAL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Tabela de vacinações
CREATE TABLE IF NOT EXISTS vaccinations (
  id TEXT PRIMARY KEY,
  animal_id TEXT NOT NULL,
  vaccine_name TEXT NOT NULL,
  vaccine_type TEXT,
  scheduled_date TEXT NOT NULL,
  applied_date TEXT,
  status TEXT NOT NULL DEFAULT 'Agendada',
  veterinarian TEXT,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
);

-- Tabela de medicamentos
CREATE TABLE IF NOT EXISTS medications (
  id TEXT PRIMARY KEY,
  animal_id TEXT NOT NULL,
  medication_name TEXT NOT NULL,
  date TEXT NOT NULL,
  next_date TEXT,
  applied_date TEXT,
  dosage TEXT,
  status TEXT NOT NULL DEFAULT 'Agendado',
  veterinarian TEXT,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
);

-- Tabela de reprodução (Sistema multi-etapas)
CREATE TABLE IF NOT EXISTS breeding_records (
  id TEXT PRIMARY KEY,
  female_animal_id TEXT NOT NULL,
  male_animal_id TEXT,
  breeding_date TEXT NOT NULL,
  mating_start_date TEXT,
  mating_end_date TEXT,
  separation_date TEXT,
  ultrasound_date TEXT,
  ultrasound_result TEXT,
  expected_birth TEXT,
  birth_date TEXT,
  stage TEXT DEFAULT 'Encabritamento',
  status TEXT DEFAULT 'Cobertura',
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (female_animal_id) REFERENCES animals(id) ON DELETE CASCADE,
  FOREIGN KEY (male_animal_id) REFERENCES animals(id) ON DELETE SET NULL
);

-- Tabela de anotações
CREATE TABLE IF NOT EXISTS notes (
  id TEXT PRIMARY KEY,
  animal_id TEXT,
  title TEXT NOT NULL,
  content TEXT,
  category TEXT,
  priority TEXT DEFAULT 'Média',
  date TEXT NOT NULL,
  created_by TEXT,
  is_read INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE SET NULL
);

-- Tabela de registros financeiros
CREATE TABLE IF NOT EXISTS financial_records (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  category TEXT NOT NULL,
  amount REAL NOT NULL,
  description TEXT,
  date TEXT NOT NULL,
  animal_id TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE SET NULL
);

-- Tabela de relatórios
CREATE TABLE IF NOT EXISTS reports (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  report_type TEXT NOT NULL,
  parameters TEXT NOT NULL DEFAULT '{}',
  generated_at TEXT NOT NULL,
  generated_by TEXT
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_animals_code ON animals(code);
CREATE INDEX IF NOT EXISTS idx_animals_species ON animals(species);
CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status);
CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_id ON vaccinations(animal_id);
CREATE INDEX IF NOT EXISTS idx_vaccinations_scheduled_date ON vaccinations(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_medications_animal_id ON medications(animal_id);
CREATE INDEX IF NOT EXISTS idx_medications_status ON medications(status);
CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id);
CREATE INDEX IF NOT EXISTS idx_breeding_male ON breeding_records(male_animal_id);
CREATE INDEX IF NOT EXISTS idx_breeding_stage ON breeding_records(stage);
CREATE INDEX IF NOT EXISTS idx_notes_animal_id ON notes(animal_id);
CREATE INDEX IF NOT EXISTS idx_financial_animal_id ON financial_records(animal_id);
CREATE INDEX IF NOT EXISTS idx_financial_type ON financial_records(type);
