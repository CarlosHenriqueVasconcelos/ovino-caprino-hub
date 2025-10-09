// Local offline-first database using localStorage, aligned with src/lib/types.ts
// Source of truth is local; cloud is backup via manual sync

import type { Animal, Vaccination, Medication, Note, BreedingRecord, FinancialRecord, Report, AnimalStats } from "./types";

const KEYS = {
  animals: 'bego_offline_animals',
  vaccinations: 'bego_offline_vaccinations',
  medications: 'bego_offline_medications',
  notes: 'bego_offline_notes',
  breeding: 'bego_offline_breeding',
  financial: 'bego_offline_financial',
  reports: 'bego_offline_reports',
  weights: 'bego_offline_weights',
  lastSync: 'bego_last_sync',
  dbVersion: 'bego_db_version'
} as const;

function loadArray<T>(key: string): T[] {
  try {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) as T[] : [];
  } catch {
    return [];
  }
}

function saveArray<T>(key: string, arr: T[]) {
  localStorage.setItem(key, JSON.stringify(arr));
}

export function genId(prefix = 'id'): string {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
}

// Animals
export const localAnimals = {
  all(): Animal[] {
    const data = loadArray<Animal>(KEYS.animals);
    // sort desc by created_at
    return data.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
  },
  get(id: string): Animal | undefined {
    return this.all().find(a => a.id === id);
  },
  create(input: Omit<Animal, 'id' | 'created_at' | 'updated_at'>): Animal {
    const now = new Date().toISOString();
    const record: Animal = { id: genId('animal'), created_at: now, updated_at: now, ...input };
    const all = loadArray<Animal>(KEYS.animals);
    all.push(record);
    saveArray(KEYS.animals, all);
    return record;
  },
  update(id: string, updates: Partial<Animal>): Animal {
    const all = loadArray<Animal>(KEYS.animals);
    const idx = all.findIndex(a => a.id === id);
    if (idx === -1) throw new Error('Animal não encontrado');
    const updated: Animal = { ...all[idx], ...updates, updated_at: new Date().toISOString() };
    all[idx] = updated;
    saveArray(KEYS.animals, all);
    return updated;
  },
  delete(id: string) {
    const all = loadArray<Animal>(KEYS.animals);
    saveArray(KEYS.animals, all.filter(a => a.id !== id));
  }
};

// Vaccinations
export const localVaccinations = {
  all(): Vaccination[] {
    const data = loadArray<Vaccination>(KEYS.vaccinations);
    return data.sort((a, b) => new Date(a.scheduled_date).getTime() - new Date(b.scheduled_date).getTime());
  },
  forAnimal(animal_id?: string): Vaccination[] {
    const all = this.all();
    return animal_id ? all.filter(v => v.animal_id === animal_id) : all;
  },
  create(input: Omit<Vaccination, 'id' | 'created_at' | 'updated_at'>): Vaccination {
    const now = new Date().toISOString();
    const record: Vaccination = { id: genId('vacc'), created_at: now, updated_at: now, ...input };
    const all = loadArray<Vaccination>(KEYS.vaccinations);
    all.push(record);
    saveArray(KEYS.vaccinations, all);
    return record;
  },
  update(id: string, updates: Partial<Vaccination>): Vaccination {
    const all = loadArray<Vaccination>(KEYS.vaccinations);
    const idx = all.findIndex(v => v.id === id);
    if (idx === -1) throw new Error('Vacinação não encontrada');
    const updated: Vaccination = { ...all[idx], ...updates, updated_at: new Date().toISOString() };
    all[idx] = updated;
    saveArray(KEYS.vaccinations, all);
    return updated;
  }
};

// Medications
export const localMedications = {
  all(): Medication[] {
    const data = loadArray<Medication>(KEYS.medications);
    return data.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
  },
  forAnimal(animal_id?: string): Medication[] {
    const all = this.all();
    return animal_id ? all.filter(m => m.animal_id === animal_id) : all;
  },
  create(input: Omit<Medication, 'id' | 'created_at' | 'updated_at'>): Medication {
    const now = new Date().toISOString();
    const record: Medication = { id: genId('med'), created_at: now, updated_at: now, ...input };
    const all = loadArray<Medication>(KEYS.medications);
    all.push(record);
    saveArray(KEYS.medications, all);
    return record;
  },
  update(id: string, updates: Partial<Medication>): Medication {
    const all = loadArray<Medication>(KEYS.medications);
    const idx = all.findIndex(m => m.id === id);
    if (idx === -1) throw new Error('Medicamento não encontrado');
    const updated: Medication = { ...all[idx], ...updates, updated_at: new Date().toISOString() };
    all[idx] = updated;
    saveArray(KEYS.medications, all);
    return updated;
  },
  delete(id: string) {
    const all = loadArray<Medication>(KEYS.medications);
    saveArray(KEYS.medications, all.filter(m => m.id !== id));
  }
};

// Notes
export const localNotes = {
  all(): Note[] { return loadArray<Note>(KEYS.notes).sort((a,b)=> new Date(b.created_at).getTime()-new Date(a.created_at).getTime()); },
  forAnimal(animal_id?: string): Note[] { const all = this.all(); return animal_id ? all.filter(n=>n.animal_id===animal_id) : all; },
  create(input: Omit<Note, 'id' | 'created_at' | 'updated_at'>): Note {
    const now = new Date().toISOString();
    const record: Note = { id: genId('note'), created_at: now, updated_at: now, ...input };
    const all = loadArray<Note>(KEYS.notes); all.push(record); saveArray(KEYS.notes, all); return record;
  },
  update(id: string, updates: Partial<Note>): Note {
    const all = loadArray<Note>(KEYS.notes); const idx = all.findIndex(n=>n.id===id); if(idx===-1) throw new Error('Nota não encontrada');
    const updated: Note = { ...all[idx], ...updates, updated_at: new Date().toISOString() }; all[idx]=updated; saveArray(KEYS.notes, all); return updated;
  },
  delete(id: string) { const all = loadArray<Note>(KEYS.notes); saveArray(KEYS.notes, all.filter(n=>n.id!==id)); }
};

// Breeding
export const localBreeding = {
  all(): BreedingRecord[] { return loadArray<BreedingRecord>(KEYS.breeding).sort((a,b)=> new Date(b.breeding_date).getTime()-new Date(a.breeding_date).getTime()); },
  create(input: Omit<BreedingRecord, 'id' | 'created_at' | 'updated_at'>): BreedingRecord {
    const now = new Date().toISOString();
    const record: BreedingRecord = { id: genId('breed'), created_at: now, updated_at: now, ...input };
    const all = loadArray<BreedingRecord>(KEYS.breeding); all.push(record); saveArray(KEYS.breeding, all); return record;
  },
  update(id: string, updates: Partial<BreedingRecord>): BreedingRecord {
    const all = loadArray<BreedingRecord>(KEYS.breeding); const idx = all.findIndex(r=>r.id===id); if(idx===-1) throw new Error('Registro reprodutivo não encontrado');
    const updated: BreedingRecord = { ...all[idx], ...updates, updated_at: new Date().toISOString() }; all[idx]=updated; saveArray(KEYS.breeding, all); return updated;
  }
};

// Financial
export const localFinancial = {
  all(): FinancialRecord[] { return loadArray<FinancialRecord>(KEYS.financial).sort((a,b)=> new Date(b.date).getTime()-new Date(a.date).getTime()); },
  create(input: Omit<FinancialRecord, 'id' | 'created_at' | 'updated_at'>): FinancialRecord {
    const now = new Date().toISOString();
    const record: FinancialRecord = { id: genId('fin'), created_at: now, updated_at: now, ...input };
    const all = loadArray<FinancialRecord>(KEYS.financial); all.push(record); saveArray(KEYS.financial, all); return record;
  },
  update(id: string, updates: Partial<FinancialRecord>): FinancialRecord {
    const all = loadArray<FinancialRecord>(KEYS.financial); const idx = all.findIndex(r=>r.id===id); if(idx===-1) throw new Error('Registro financeiro não encontrado');
    const updated: FinancialRecord = { ...all[idx], ...updates, updated_at: new Date().toISOString() }; all[idx]=updated; saveArray(KEYS.financial, all); return updated;
  },
  delete(id: string) { const all = loadArray<FinancialRecord>(KEYS.financial); saveArray(KEYS.financial, all.filter(r=>r.id!==id)); }
};

// Reports
export const localReports = {
  all(): Report[] { return loadArray<Report>(KEYS.reports).sort((a,b)=> new Date(b.generated_at).getTime()-new Date(a.generated_at).getTime()); },
  create(input: Omit<Report, 'id' | 'generated_at'>): Report {
    const record: Report = { id: genId('rep'), generated_at: new Date().toISOString(), ...input };
    const all = loadArray<Report>(KEYS.reports); all.push(record); saveArray(KEYS.reports, all); return record;
  }
};

// Animal Weights
export interface AnimalWeight {
  id: string;
  animal_id: string;
  date: string; // YYYY-MM-DD
  weight: number;
  created_at: string;
  updated_at: string;
}

export const localWeights = {
  all(): AnimalWeight[] {
    return loadArray<AnimalWeight>(KEYS.weights);
  },
  forAnimal(animal_id: string): AnimalWeight[] {
    return this.all().filter(w => w.animal_id === animal_id)
      .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
  },
  create(input: Omit<AnimalWeight, 'id' | 'created_at' | 'updated_at'>): AnimalWeight {
    const now = new Date().toISOString();
    const record: AnimalWeight = { id: genId('weight'), created_at: now, updated_at: now, ...input };
    const all = loadArray<AnimalWeight>(KEYS.weights);
    all.push(record);
    saveArray(KEYS.weights, all);
    return record;
  },
  update(id: string, updates: Partial<AnimalWeight>): AnimalWeight {
    const all = loadArray<AnimalWeight>(KEYS.weights);
    const idx = all.findIndex(w => w.id === id);
    if (idx === -1) throw new Error('Peso não encontrado');
    const updated: AnimalWeight = { ...all[idx], ...updates, updated_at: new Date().toISOString() };
    all[idx] = updated;
    saveArray(KEYS.weights, all);
    return updated;
  },
  delete(id: string) {
    const all = loadArray<AnimalWeight>(KEYS.weights);
    saveArray(KEYS.weights, all.filter(w => w.id !== id));
  }
};

export const localStats = {
  compute(): AnimalStats {
    const animals = localAnimals.all();
    const vaccinations = localVaccinations.all();
    const financial = localFinancial.all();
    const now = new Date();
    const thisMonth = now.getMonth();
    const thisYear = now.getFullYear();

    const vaccinesThisMonth = vaccinations.filter(v => {
      const d = new Date(v.scheduled_date); return d.getMonth()===thisMonth && d.getFullYear()===thisYear;
    }).length;

    const birthsThisMonth = animals.filter(a => {
      const d = new Date(a.birth_date); return d.getMonth()===thisMonth && d.getFullYear()===thisYear;
    }).length;

    const totalWeight = animals.reduce((s,a)=> s + (a.weight||0), 0);
    const avgWeight = animals.length ? totalWeight / animals.length : 0;

    const revenue = localFinancial.all().filter(r=> r.type==='receita').reduce((s,r)=> s + (r.amount||0), 0);

    return {
      totalAnimals: animals.length,
      healthy: animals.filter(a => a.status === 'Saudável').length,
      pregnant: animals.filter(a => a.pregnant).length,
      underTreatment: animals.filter(a => a.status === 'Em tratamento').length,
      vaccinesThisMonth,
      birthsThisMonth,
      avgWeight,
      revenue
    };
  }
};

export const localSync = {
  getLastSync(): Date | null { const raw = localStorage.getItem(KEYS.lastSync); return raw ? new Date(raw) : null; },
  setLastSync() { localStorage.setItem(KEYS.lastSync, new Date().toISOString()); }
};

// Database migrations
const DB_VERSION = 2;

function getCurrentVersion(): number {
  const raw = localStorage.getItem(KEYS.dbVersion);
  return raw ? parseInt(raw, 10) : 0;
}

function setVersion(version: number) {
  localStorage.setItem(KEYS.dbVersion, version.toString());
}

// Migration functions
function migrateV1toV2() {
  // Add status and applied_date to existing medications
  const medications = loadArray<any>(KEYS.medications);
  const migrated = medications.map(med => ({
    ...med,
    status: med.status || 'Agendado',
    applied_date: med.applied_date || undefined
  }));
  saveArray(KEYS.medications, migrated);
  console.log(`✅ Migração v1→v2: ${migrated.length} medicamentos atualizados`);
}

export function runMigrations() {
  const currentVersion = getCurrentVersion();
  
  if (currentVersion >= DB_VERSION) {
    return; // Already up to date
  }

  console.log(`🔄 Iniciando migrações do banco local (v${currentVersion} → v${DB_VERSION})`);

  if (currentVersion < 1) {
    // First time, just set version
    setVersion(1);
  }

  if (currentVersion < 2) {
    migrateV1toV2();
    setVersion(2);
  }

  console.log('✅ Migrações concluídas com sucesso!');
}

// Run migrations on import
runMigrations();
