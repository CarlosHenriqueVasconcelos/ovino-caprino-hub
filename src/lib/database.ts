// BEGO Agritech - Sistema de Banco de Dados Local (Offline-First)
// Este arquivo simula um banco de dados local usando localStorage
// Em produção, seria substituído por SQLite via Capacitor

export interface Animal {
  id: string;
  name: string;
  species: 'Ovino' | 'Caprino';
  breed: string;
  gender: 'Macho' | 'Fêmea';
  birthDate: string;
  weight: number;
  status: 'Saudável' | 'Em tratamento' | 'Reprodutor' | 'Descarte';
  location: string;
  lastVaccination: string;
  pregnant?: boolean;
  expectedDelivery?: string;
  healthIssue?: string;
  motherid?: string;
  fatherId?: string;
  notes?: string;
  createdAt: string;
  updatedAt: string;
  syncStatus: 'synced' | 'pending' | 'error';
}

export interface VaccinationRecord {
  id: string;
  animalId: string;
  vaccineName: string;
  applicationDate: string;
  nextDue: string;
  veterinarian?: string;
  notes?: string;
  createdAt: string;
  syncStatus: 'synced' | 'pending' | 'error';
}

export interface WeightRecord {
  id: string;
  animalId: string;
  weight: number;
  measureDate: string;
  notes?: string;
  createdAt: string;
  syncStatus: 'synced' | 'pending' | 'error';
}

class BegoDatabase {
  private readonly ANIMALS_KEY = 'bego_animals';
  private readonly VACCINATIONS_KEY = 'bego_vaccinations';
  private readonly WEIGHTS_KEY = 'bego_weights';
  private readonly LAST_SYNC_KEY = 'bego_last_sync';

  // ANIMALS CRUD
  async getAllAnimals(): Promise<Animal[]> {
    try {
      const data = localStorage.getItem(this.ANIMALS_KEY);
      return data ? JSON.parse(data) : this.getInitialData();
    } catch (error) {
      console.error('Erro ao carregar animais:', error);
      return this.getInitialData();
    }
  }

  async getAnimalById(id: string): Promise<Animal | null> {
    const animals = await this.getAllAnimals();
    return animals.find(animal => animal.id === id) || null;
  }

  async saveAnimal(animal: Omit<Animal, 'createdAt' | 'updatedAt' | 'syncStatus'>): Promise<Animal> {
    const animals = await this.getAllAnimals();
    const now = new Date().toISOString();
    
    const newAnimal: Animal = {
      ...animal,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending'
    };

    const existingIndex = animals.findIndex(a => a.id === animal.id);
    if (existingIndex >= 0) {
      animals[existingIndex] = { ...newAnimal, createdAt: animals[existingIndex].createdAt };
    } else {
      animals.push(newAnimal);
    }

    localStorage.setItem(this.ANIMALS_KEY, JSON.stringify(animals));
    return newAnimal;
  }

  async deleteAnimal(id: string): Promise<boolean> {
    try {
      const animals = await this.getAllAnimals();
      const filteredAnimals = animals.filter(animal => animal.id !== id);
      localStorage.setItem(this.ANIMALS_KEY, JSON.stringify(filteredAnimals));
      return true;
    } catch (error) {
      console.error('Erro ao deletar animal:', error);
      return false;
    }
  }

  // VACCINATION RECORDS CRUD
  async getVaccinationsByAnimal(animalId: string): Promise<VaccinationRecord[]> {
    try {
      const data = localStorage.getItem(this.VACCINATIONS_KEY);
      const vaccinations: VaccinationRecord[] = data ? JSON.parse(data) : [];
      return vaccinations.filter(v => v.animalId === animalId);
    } catch (error) {
      console.error('Erro ao carregar vacinações:', error);
      return [];
    }
  }

  async saveVaccination(vaccination: Omit<VaccinationRecord, 'createdAt' | 'syncStatus'>): Promise<VaccinationRecord> {
    try {
      const data = localStorage.getItem(this.VACCINATIONS_KEY);
      const vaccinations: VaccinationRecord[] = data ? JSON.parse(data) : [];
      
      const newVaccination: VaccinationRecord = {
        ...vaccination,
        createdAt: new Date().toISOString(),
        syncStatus: 'pending'
      };

      vaccinations.push(newVaccination);
      localStorage.setItem(this.VACCINATIONS_KEY, JSON.stringify(vaccinations));
      return newVaccination;
    } catch (error) {
      console.error('Erro ao salvar vacinação:', error);
      throw error;
    }
  }

  // STATS & REPORTS
  async getStats() {
    const animals = await this.getAllAnimals();
    const today = new Date();
    const thirtyDaysAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000);

    return {
      totalAnimals: animals.length,
      healthy: animals.filter(a => a.status === 'Saudável').length,
      pregnant: animals.filter(a => a.pregnant).length,
      underTreatment: animals.filter(a => a.status === 'Em tratamento').length,
      bySpecies: {
        ovinos: animals.filter(a => a.species === 'Ovino').length,
        caprinos: animals.filter(a => a.species === 'Caprino').length,
      },
      avgWeight: animals.reduce((sum, a) => sum + a.weight, 0) / animals.length || 0,
      recentBirths: animals.filter(a => new Date(a.birthDate) > thirtyDaysAgo).length
    };
  }

  // SYNC METHODS (preparação para sincronização com servidor)
  async getPendingSync(): Promise<{
    animals: Animal[];
    vaccinations: VaccinationRecord[];
    weights: WeightRecord[];
  }> {
    const animals = await this.getAllAnimals();
    const data = localStorage.getItem(this.VACCINATIONS_KEY);
    const vaccinations: VaccinationRecord[] = data ? JSON.parse(data) : [];
    const weightData = localStorage.getItem(this.WEIGHTS_KEY);
    const weights: WeightRecord[] = weightData ? JSON.parse(weightData) : [];

    return {
      animals: animals.filter(a => a.syncStatus === 'pending'),
      vaccinations: vaccinations.filter(v => v.syncStatus === 'pending'),
      weights: weights.filter(w => w.syncStatus === 'pending')
    };
  }

  async markAsSynced(type: 'animals' | 'vaccinations' | 'weights', ids: string[]) {
    // Implementação para marcar itens como sincronizados
    // Será usado quando a sincronização com servidor estiver implementada
    console.log(`Marcando como sincronizado - ${type}:`, ids);
  }

  async getLastSyncDate(): Promise<Date | null> {
    const lastSync = localStorage.getItem(this.LAST_SYNC_KEY);
    return lastSync ? new Date(lastSync) : null;
  }

  async updateLastSyncDate(): Promise<void> {
    localStorage.setItem(this.LAST_SYNC_KEY, new Date().toISOString());
  }

  // DADOS INICIAIS PARA DEMO
  private getInitialData(): Animal[] {
    return [
      {
        id: "OV001",
        name: "Benedita",
        species: "Ovino",
        breed: "Santa Inês",
        gender: "Fêmea",
        birthDate: "2022-03-15",
        weight: 45.5,
        status: "Saudável",
        location: "Pasto A1",
        lastVaccination: "2024-08-15",
        pregnant: true,
        expectedDelivery: "2024-12-20",
        createdAt: "2024-01-01T00:00:00Z",
        updatedAt: "2024-09-01T00:00:00Z",
        syncStatus: "synced"
      },
      {
        id: "CP002",
        name: "Joaquim",
        species: "Caprino",
        breed: "Boer",
        gender: "Macho",
        birthDate: "2021-07-22",
        weight: 65.2,
        status: "Reprodutor",
        location: "Pasto B2",
        lastVaccination: "2024-09-01",
        pregnant: false,
        createdAt: "2024-01-01T00:00:00Z",
        updatedAt: "2024-09-01T00:00:00Z",
        syncStatus: "synced"
      },
      {
        id: "OV003",
        name: "Esperança",
        species: "Ovino",
        breed: "Morada Nova",
        gender: "Fêmea",
        birthDate: "2023-01-10",
        weight: 38.0,
        status: "Em tratamento",
        location: "Enfermaria",
        lastVaccination: "2024-07-20",
        pregnant: false,
        healthIssue: "Verminose",
        createdAt: "2024-01-01T00:00:00Z",
        updatedAt: "2024-09-01T00:00:00Z",
        syncStatus: "synced"
      }
    ];
  }
}

// Instância singleton do banco
export const begoDb = new BegoDatabase();

// Utilitários para geração de IDs
export function generateAnimalId(species: 'Ovino' | 'Caprino'): string {
  const prefix = species === 'Ovino' ? 'OV' : 'CP';
  const timestamp = Date.now().toString().slice(-6);
  return `${prefix}${timestamp}`;
}

export function generateRecordId(): string {
  return `REC_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`;
}