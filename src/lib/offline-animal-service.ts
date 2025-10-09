import type { Animal, Vaccination, Medication, Report, AnimalStats, Note, BreedingRecord, FinancialRecord } from "./types";
import { localAnimals, localVaccinations, localMedications, localNotes, localBreeding, localFinancial, localReports, localStats } from "./local-db";

// Event system for real-time updates
const dispatchDataUpdate = (type: 'vaccination' | 'medication') => {
  window.dispatchEvent(new CustomEvent('bego-data-update', { detail: { type } }));
};

export class AnimalService {
  async getAnimals(): Promise<Animal[]> { return localAnimals.all(); }
  async getAnimal(id: string): Promise<Animal | null> { return localAnimals.get(id) || null; }
  async createAnimal(animal: Omit<Animal, 'id' | 'created_at' | 'updated_at'>): Promise<Animal> { return localAnimals.create(animal); }
  async updateAnimal(id: string, updates: Partial<Animal>): Promise<Animal> { return localAnimals.update(id, updates); }
  async deleteAnimal(id: string): Promise<void> { await localAnimals.delete(id); }

  // Vaccinations
  async getVaccinations(animalId?: string): Promise<Vaccination[]> { return localVaccinations.forAnimal(animalId); }
  async createVaccination(vaccination: Omit<Vaccination, 'id' | 'created_at' | 'updated_at'>): Promise<Vaccination> { 
    const result = localVaccinations.create(vaccination);
    dispatchDataUpdate('vaccination');
    return result;
  }
  async updateVaccination(id: string, updates: Partial<Vaccination>): Promise<Vaccination> { 
    const result = localVaccinations.update(id, updates);
    dispatchDataUpdate('vaccination');
    return result;
  }

  // Medications
  async getMedications(animalId?: string): Promise<Medication[]> { return localMedications.forAnimal(animalId); }
  async createMedication(medication: Omit<Medication, 'id' | 'created_at' | 'updated_at'>): Promise<Medication> { 
    const result = localMedications.create(medication);
    dispatchDataUpdate('medication');
    return result;
  }
  async updateMedication(id: string, updates: Partial<Medication>): Promise<Medication> { 
    const result = localMedications.update(id, updates);
    dispatchDataUpdate('medication');
    return result;
  }

  // Notes
  async getNotes(animalId?: string): Promise<Note[]> { return localNotes.forAnimal(animalId); }
  async createNote(note: Omit<Note, 'id' | 'created_at' | 'updated_at'>): Promise<Note> { return localNotes.create(note); }
  async updateNote(id: string, updates: Partial<Note>): Promise<Note> { return localNotes.update(id, updates); }
  async deleteNote(id: string): Promise<void> { return localNotes.delete(id); }

  // Breeding
  async getBreedingRecords(): Promise<BreedingRecord[]> { return localBreeding.all(); }
  async createBreedingRecord(record: Omit<BreedingRecord, 'id' | 'created_at' | 'updated_at'>): Promise<BreedingRecord> { return localBreeding.create(record); }
  async updateBreedingRecord(id: string, updates: Partial<BreedingRecord>): Promise<BreedingRecord> { return localBreeding.update(id, updates); }

  // Financial
  async getFinancialRecords(): Promise<FinancialRecord[]> { return localFinancial.all(); }
  async createFinancialRecord(record: Omit<FinancialRecord, 'id' | 'created_at' | 'updated_at'>): Promise<FinancialRecord> { return localFinancial.create(record); }
  async updateFinancialRecord(id: string, updates: Partial<FinancialRecord>): Promise<FinancialRecord> { return localFinancial.update(id, updates); }
  async deleteFinancialRecord(id: string): Promise<void> { return localFinancial.delete(id); }

  // Reports
  async getReports(): Promise<Report[]> { return localReports.all(); }
  async createReport(report: Omit<Report, 'id' | 'generated_at'>): Promise<Report> { return localReports.create(report); }

  async getStats(): Promise<AnimalStats> { return localStats.compute(); }
}
