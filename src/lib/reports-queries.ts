// Reports queries and data processing for the Reports Hub
import { localAnimals, localVaccinations, localMedications, localNotes, localBreeding, localFinancial, localWeights } from "./local-db";
import type { Animal } from "./types";

export interface DateRange {
  start: Date;
  end: Date;
}

export interface PeriodPreset {
  label: string;
  value: string;
  getDates: () => DateRange;
}

export const PERIOD_PRESETS: PeriodPreset[] = [
  {
    label: 'Últimos 7 dias',
    value: 'last7',
    getDates: () => {
      const end = new Date();
      const start = new Date();
      start.setDate(start.getDate() - 7);
      return { start, end };
    }
  },
  {
    label: 'Últimos 30 dias',
    value: 'last30',
    getDates: () => {
      const end = new Date();
      const start = new Date();
      start.setDate(start.getDate() - 30);
      return { start, end };
    }
  },
  {
    label: 'Últimos 90 dias',
    value: 'last90',
    getDates: () => {
      const end = new Date();
      const start = new Date();
      start.setDate(start.getDate() - 90);
      return { start, end };
    }
  },
  {
    label: 'Mês atual',
    value: 'currentMonth',
    getDates: () => {
      const now = new Date();
      const start = new Date(now.getFullYear(), now.getMonth(), 1);
      const end = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
      return { start, end };
    }
  },
  {
    label: 'Ano atual',
    value: 'currentYear',
    getDates: () => {
      const now = new Date();
      const start = new Date(now.getFullYear(), 0, 1);
      const end = new Date(now.getFullYear(), 11, 31, 23, 59, 59);
      return { start, end };
    }
  },
  {
    label: 'Customizado',
    value: 'custom',
    getDates: () => ({ start: new Date(), end: new Date() })
  }
];

function isDateInRange(date: string | undefined, range: DateRange): boolean {
  if (!date) return false;
  const d = new Date(date);
  return d >= range.start && d <= range.end;
}

// ============ Animais Report ============
export interface AnimalsFilters {
  period: DateRange;
  species?: string;
  gender?: string;
  status?: string;
  category?: string;
}

export function getAnimalsReport(filters: AnimalsFilters) {
  let animals = localAnimals.all();
  
  // Filter by created_at
  animals = animals.filter(a => isDateInRange(a.created_at, filters.period));
  
  if (filters.species && filters.species !== 'Todos') {
    animals = animals.filter(a => a.species === filters.species);
  }
  if (filters.gender && filters.gender !== 'Todos') {
    animals = animals.filter(a => a.gender === filters.gender);
  }
  if (filters.status && filters.status !== 'Todos') {
    animals = animals.filter(a => a.status === filters.status);
  }
  if (filters.category && filters.category !== 'Todos') {
    animals = animals.filter(a => a.category === filters.category);
  }
  
  const bySpecies = animals.reduce((acc, a) => {
    acc[a.species] = (acc[a.species] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
  
  const byGender = animals.reduce((acc, a) => {
    acc[a.gender] = (acc[a.gender] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
  
  return {
    summary: {
      total: animals.length,
      ovinos: bySpecies['Ovino'] || 0,
      caprinos: bySpecies['Caprino'] || 0,
      machos: byGender['Macho'] || 0,
      femeas: byGender['Fêmea'] || 0
    },
    data: animals.map(a => ({
      code: a.code,
      name: a.name,
      species: a.species,
      breed: a.breed,
      gender: a.gender,
      birth_date: a.birth_date,
      weight: a.weight,
      status: a.status,
      location: a.location,
      category: a.category,
      pregnant: a.pregnant,
      expected_delivery: a.expected_delivery
    }))
  };
}

// ============ Pesos Report ============
export interface WeightsFilters {
  period: DateRange;
}

export function getWeightsReport(filters: WeightsFilters) {
  const weights = localWeights.all().filter(w => isDateInRange(w.date, filters.period));
  const animals = localAnimals.all();
  const animalMap = new Map(animals.map(a => [a.id, a]));
  
  // Group by animal
  const byAnimal = weights.reduce((acc, w) => {
    if (!acc[w.animal_id]) {
      acc[w.animal_id] = [];
    }
    acc[w.animal_id].push(w);
    return acc;
  }, {} as Record<string, typeof weights>);
  
  const animalStats = Object.entries(byAnimal).map(([animalId, weighings]) => {
    const animal = animalMap.get(animalId);
    const weights = weighings.map(w => w.weight);
    const sorted = weighings.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    
    return {
      animal_id: animalId,
      animal_code: animal?.code || 'N/A',
      animal_name: animal?.name || 'N/A',
      count: weights.length,
      min: Math.min(...weights),
      max: Math.max(...weights),
      avg: weights.reduce((s, w) => s + w, 0) / weights.length,
      last_weight: sorted[0]?.weight || 0,
      last_date: sorted[0]?.date || ''
    };
  });
  
  const allLastWeights = animalStats.map(s => s.last_weight).filter(w => w > 0);
  
  return {
    summary: {
      total_weighings: weights.length,
      animals_weighed: Object.keys(byAnimal).length,
      avg_last_weight: allLastWeights.length ? 
        allLastWeights.reduce((s, w) => s + w, 0) / allLastWeights.length : 0
    },
    data: animalStats
  };
}

// ============ Vacinações Report ============
export interface VaccinationsFilters {
  period: DateRange;
  status?: string;
  vaccine_type?: string;
}

export function getVaccinationsReport(filters: VaccinationsFilters) {
  let vaccinations = localVaccinations.all();
  const animals = localAnimals.all();
  const animalMap = new Map(animals.map(a => [a.id, a]));
  
  // Filter by effective date (applied_date if exists, else scheduled_date)
  vaccinations = vaccinations.filter(v => {
    const effectiveDate = v.applied_date || v.scheduled_date;
    return isDateInRange(effectiveDate, filters.period);
  });
  
  if (filters.status && filters.status !== 'Todos') {
    vaccinations = vaccinations.filter(v => v.status === filters.status);
  }
  if (filters.vaccine_type && filters.vaccine_type !== 'Todos') {
    vaccinations = vaccinations.filter(v => v.vaccine_type === filters.vaccine_type);
  }
  
  const byStatus = vaccinations.reduce((acc, v) => {
    acc[v.status] = (acc[v.status] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
  
  return {
    summary: {
      total: vaccinations.length,
      scheduled: byStatus['Agendada'] || 0,
      applied: byStatus['Aplicada'] || 0,
      cancelled: byStatus['Cancelada'] || 0
    },
    data: vaccinations.map(v => {
      const animal = animalMap.get(v.animal_id);
      return {
        animal_code: animal?.code || 'N/A',
        animal_name: animal?.name || 'N/A',
        vaccine_name: v.vaccine_name,
        vaccine_type: v.vaccine_type,
        scheduled_date: v.scheduled_date,
        applied_date: v.applied_date,
        status: v.status,
        veterinarian: v.veterinarian,
        notes: v.notes
      };
    })
  };
}

// ============ Medicações Report ============
export interface MedicationsFilters {
  period: DateRange;
  status?: string;
}

export function getMedicationsReport(filters: MedicationsFilters) {
  let medications = localMedications.all();
  const animals = localAnimals.all();
  const animalMap = new Map(animals.map(a => [a.id, a]));
  
  // Filter by event date (applied_date if applied, else date)
  medications = medications.filter(m => {
    const eventDate = (m.status === 'Aplicado' && m.applied_date) ? m.applied_date : m.date;
    return isDateInRange(eventDate, filters.period);
  });
  
  if (filters.status && filters.status !== 'Todos') {
    medications = medications.filter(m => m.status === filters.status);
  }
  
  const byStatus = medications.reduce((acc, m) => {
    acc[m.status] = (acc[m.status] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
  
  return {
    summary: {
      total: medications.length,
      scheduled: byStatus['Agendado'] || 0,
      applied: byStatus['Aplicado'] || 0,
      cancelled: byStatus['Cancelado'] || 0
    },
    data: medications.map(m => {
      const animal = animalMap.get(m.animal_id);
      return {
        animal_code: animal?.code || 'N/A',
        animal_name: animal?.name || 'N/A',
        medication_name: m.medication_name,
        date: m.date,
        next_date: m.next_date,
        applied_date: m.applied_date,
        status: m.status,
        dosage: m.dosage,
        veterinarian: m.veterinarian,
        notes: m.notes
      };
    })
  };
}

// ============ Reprodução Report ============
export interface BreedingFilters {
  period: DateRange;
  stage?: string;
}

export function getBreedingReport(filters: BreedingFilters) {
  let breeding = localBreeding.all();
  const animals = localAnimals.all();
  const animalMap = new Map(animals.map(a => [a.id, a]));
  
  // Filter by breeding_date
  breeding = breeding.filter(b => isDateInRange(b.breeding_date, filters.period));
  
  if (filters.stage && filters.stage !== 'Todos') {
    breeding = breeding.filter(b => b.stage === filters.stage);
  }
  
  const byStage = breeding.reduce((acc, b) => {
    const stage = b.stage || 'Não definido';
    acc[stage] = (acc[stage] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
  
  return {
    summary: {
      total: breeding.length,
      ...byStage
    },
    data: breeding.map(b => {
      const female = animalMap.get(b.female_animal_id || '');
      const male = animalMap.get(b.male_animal_id || '');
      return {
        female_code: female?.code || 'N/A',
        female_name: female?.name || 'N/A',
        male_code: male?.code || 'N/A',
        male_name: male?.name || 'N/A',
        breeding_date: b.breeding_date,
        expected_birth: b.expected_birth,
        stage: b.stage,
        status: b.status,
        mating_start_date: b.mating_start_date,
        mating_end_date: b.mating_end_date,
        separation_date: b.separation_date,
        ultrasound_date: b.ultrasound_date,
        ultrasound_result: b.ultrasound_result,
        birth_date: b.birth_date
      };
    })
  };
}

// ============ Financeiro Report ============
export interface FinancialFilters {
  period: DateRange;
  type?: string;
  category?: string;
}

export function getFinancialReport(filters: FinancialFilters) {
  let financial = localFinancial.all();
  const animals = localAnimals.all();
  const animalMap = new Map(animals.map(a => [a.id, a]));
  
  // Filter by date
  financial = financial.filter(f => isDateInRange(f.date, filters.period));
  
  if (filters.type && filters.type !== 'Todos') {
    financial = financial.filter(f => f.type === filters.type);
  }
  if (filters.category && filters.category !== 'Todos') {
    financial = financial.filter(f => f.category === filters.category);
  }
  
  const revenue = financial.filter(f => f.type === 'receita')
    .reduce((sum, f) => sum + f.amount, 0);
  const expense = financial.filter(f => f.type === 'despesa')
    .reduce((sum, f) => sum + f.amount, 0);
  
  return {
    summary: {
      revenue,
      expense,
      balance: revenue - expense
    },
    data: financial.map(f => {
      const animal = f.animal_id ? animalMap.get(f.animal_id) : null;
      return {
        date: f.date,
        type: f.type,
        category: f.category,
        amount: f.amount,
        description: f.description,
        animal_code: animal?.code || ''
      };
    })
  };
}

// ============ Anotações Report ============
export interface NotesFilters {
  period: DateRange;
  is_read?: boolean | null;
  priority?: string;
}

export function getNotesReport(filters: NotesFilters) {
  let notes = localNotes.all();
  const animals = localAnimals.all();
  const animalMap = new Map(animals.map(a => [a.id, a]));
  
  // Filter by date
  notes = notes.filter(n => isDateInRange(n.date, filters.period));
  
  if (filters.is_read !== null && filters.is_read !== undefined) {
    notes = notes.filter(n => n.is_read === filters.is_read);
  }
  if (filters.priority && filters.priority !== 'Todos') {
    notes = notes.filter(n => n.priority === filters.priority);
  }
  
  const read = notes.filter(n => n.is_read).length;
  const unread = notes.filter(n => !n.is_read).length;
  
  const byPriority = notes.reduce((acc, n) => {
    acc[n.priority] = (acc[n.priority] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);
  
  return {
    summary: {
      total: notes.length,
      read,
      unread,
      high: byPriority['Alta'] || 0,
      medium: byPriority['Média'] || 0,
      low: byPriority['Baixa'] || 0
    },
    data: notes.map(n => {
      const animal = n.animal_id ? animalMap.get(n.animal_id) : null;
      return {
        date: n.date,
        title: n.title,
        category: n.category,
        priority: n.priority,
        is_read: n.is_read,
        animal_code: animal?.code || ''
      };
    })
  };
}
