import { supabase } from "@/integrations/supabase/client";
import type { Animal, Vaccination, Report, AnimalStats, Note, BreedingRecord, FinancialRecord } from "./types";

export class AnimalService {
  async getAnimals(): Promise<Animal[]> {
    const { data, error } = await supabase
      .from('animals')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return (data || []) as Animal[];
  }

  async getAnimal(id: string): Promise<Animal | null> {
    const { data, error } = await supabase
      .from('animals')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    
    if (error) throw error;
    return data as Animal | null;
  }

  async createAnimal(animal: Omit<Animal, 'id' | 'created_at' | 'updated_at'>): Promise<Animal> {
    const { data, error } = await supabase
      .from('animals')
      .insert(animal)
      .select()
      .single();
    
    if (error) throw error;
    return data as Animal;
  }

  async updateAnimal(id: string, updates: Partial<Animal>): Promise<Animal> {
    const { data, error } = await supabase
      .from('animals')
      .update(updates)
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data as Animal;
  }

  async deleteAnimal(id: string): Promise<void> {
    const { error } = await supabase
      .from('animals')
      .delete()
      .eq('id', id);
    
    if (error) throw error;
  }

  // Vaccination methods
  async getVaccinations(animalId?: string): Promise<Vaccination[]> {
    let query = supabase
      .from('vaccinations')
      .select('*')
      .order('scheduled_date', { ascending: true });
    
    if (animalId) {
      query = query.eq('animal_id', animalId);
    }
    
    const { data, error } = await query;
    
    if (error) throw error;
    return (data || []) as Vaccination[];
  }

  async createVaccination(vaccination: Omit<Vaccination, 'id' | 'created_at' | 'updated_at'>): Promise<Vaccination> {
    const { data, error } = await supabase
      .from('vaccinations')
      .insert(vaccination)
      .select()
      .single();
    
    if (error) throw error;
    return data as Vaccination;
  }

  async updateVaccination(id: string, updates: Partial<Vaccination>): Promise<Vaccination> {
    const { data, error } = await supabase
      .from('vaccinations')
      .update(updates)
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data as Vaccination;
  }

  // Notes methods
  async getNotes(animalId?: string): Promise<Note[]> {
    let query = supabase
      .from('notes')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (animalId) {
      query = query.eq('animal_id', animalId);
    }
    
    const { data, error } = await query;
    
    if (error) throw error;
    return (data || []) as Note[];
  }

  async createNote(note: Omit<Note, 'id' | 'created_at' | 'updated_at'>): Promise<Note> {
    const { data, error } = await supabase
      .from('notes')
      .insert(note)
      .select()
      .single();
    
    if (error) throw error;
    return data as Note;
  }

  async updateNote(id: string, updates: Partial<Note>): Promise<Note> {
    const { data, error } = await supabase
      .from('notes')
      .update(updates)
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data as Note;
  }

  async deleteNote(id: string): Promise<void> {
    const { error } = await supabase
      .from('notes')
      .delete()
      .eq('id', id);
    
    if (error) throw error;
  }

  // Breeding methods
  async getBreedingRecords(): Promise<BreedingRecord[]> {
    const { data, error } = await supabase
      .from('breeding_records')
      .select('*')
      .order('breeding_date', { ascending: false });
    
    if (error) throw error;
    return (data || []) as BreedingRecord[];
  }

  async createBreedingRecord(record: Omit<BreedingRecord, 'id' | 'created_at' | 'updated_at'>): Promise<BreedingRecord> {
    const { data, error } = await supabase
      .from('breeding_records')
      .insert(record)
      .select()
      .single();
    
    if (error) throw error;
    return data as BreedingRecord;
  }

  async updateBreedingRecord(id: string, updates: Partial<BreedingRecord>): Promise<BreedingRecord> {
    const { data, error } = await supabase
      .from('breeding_records')
      .update(updates)
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data as BreedingRecord;
  }

  // Financial methods
  async getFinancialRecords(): Promise<FinancialRecord[]> {
    const { data, error } = await supabase
      .from('financial_records')
      .select('*')
      .order('date', { ascending: false });
    
    if (error) throw error;
    return (data || []) as FinancialRecord[];
  }

  async createFinancialRecord(record: Omit<FinancialRecord, 'id' | 'created_at' | 'updated_at'>): Promise<FinancialRecord> {
    const { data, error } = await supabase
      .from('financial_records')
      .insert(record)
      .select()
      .single();
    
    if (error) throw error;
    return data as FinancialRecord;
  }

  async updateFinancialRecord(id: string, updates: Partial<FinancialRecord>): Promise<FinancialRecord> {
    const { data, error } = await supabase
      .from('financial_records')
      .update(updates)
      .eq('id', id)
      .select()
      .single();
    
    if (error) throw error;
    return data as FinancialRecord;
  }

  async deleteFinancialRecord(id: string): Promise<void> {
    const { error } = await supabase
      .from('financial_records')
      .delete()
      .eq('id', id);
    
    if (error) throw error;
  }

  // Reports methods
  async getReports(): Promise<Report[]> {
    const { data, error } = await supabase
      .from('reports')
      .select('*')
      .order('generated_at', { ascending: false });
    
    if (error) throw error;
    return (data || []) as Report[];
  }

  async createReport(report: Omit<Report, 'id' | 'generated_at'>): Promise<Report> {
    const { data, error } = await supabase
      .from('reports')
      .insert(report)
      .select()
      .single();
    
    if (error) throw error;
    return data as Report;
  }

  async getStats(): Promise<AnimalStats> {
    const animals = await this.getAnimals();
    const vaccinations = await this.getVaccinations();
    const financialRecords = await this.getFinancialRecords();
    
    const now = new Date();
    const thisMonth = now.getMonth();
    const thisYear = now.getFullYear();
    
    const vaccinesThisMonth = vaccinations.filter(v => {
      const date = new Date(v.scheduled_date);
      return date.getMonth() === thisMonth && date.getFullYear() === thisYear;
    }).length;
    
    const birthsThisMonth = animals.filter(a => {
      const birthDate = new Date(a.birth_date);
      return birthDate.getMonth() === thisMonth && birthDate.getFullYear() === thisYear;
    }).length;
    
    const totalWeight = animals.reduce((sum, a) => sum + a.weight, 0);
    const avgWeight = animals.length > 0 ? totalWeight / animals.length : 0;
    
    // Calculate real revenue from financial records
    const totalRevenue = financialRecords
      .filter(r => r.type === 'receita')
      .reduce((sum, r) => sum + r.amount, 0);
    
    return {
      totalAnimals: animals.length,
      healthy: animals.filter(a => a.status === 'Saudável').length,
      pregnant: animals.filter(a => a.pregnant).length,
      underTreatment: animals.filter(a => a.status === 'Em tratamento').length,
      vaccinesThisMonth,
      birthsThisMonth,
      avgWeight,
      revenue: totalRevenue
    };
  }
}