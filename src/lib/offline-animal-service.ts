import type { Animal, Vaccination, Report, AnimalStats, Note, BreedingRecord, FinancialRecord } from "./types";
import { localAnimals, localVaccinations, localNotes, localBreeding, localFinancial, localReports, localStats } from "./local-db";

export class AnimalService {
  async getAnimals(): Promise<Animal[]> { return localAnimals.all(); }
  async getAnimal(id: string): Promise<Animal | null> { return localAnimals.get(id) || null; }
  async createAnimal(animal: Omit<Animal, 'id' | 'created_at' | 'updated_at'>): Promise<Animal> { return localAnimals.create(animal); }
  async updateAnimal(id: string, updates: Partial<Animal>): Promise<Animal> { return localAnimals.update(id, updates); }
  async deleteAnimal(id: string): Promise<void> { await localAnimals.delete(id); }

  // Vaccinations
  async getVaccinations(animalId?: string): Promise<Vaccination[]> { return localVaccinations.forAnimal(animalId); }
  async createVaccination(vaccination: Omit<Vaccination, 'id' | 'created_at' | 'updated_at'>): Promise<Vaccination> { return localVaccinations.create(vaccination); }
  async updateVaccination(id: string, updates: Partial<Vaccination>): Promise<Vaccination> { return localVaccinations.update(id, updates); }

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
