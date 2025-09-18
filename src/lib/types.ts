export interface Animal {
  id: string;
  code: string;
  name: string;
  species: 'Ovino' | 'Caprino';
  breed: string;
  gender: 'Macho' | 'Fêmea';
  birth_date: string;
  weight: number;
  status: string;
  location: string;
  last_vaccination?: string;
  pregnant: boolean;
  expected_delivery?: string;
  health_issue?: string;
  created_at: string;
  updated_at: string;
}

export interface Vaccination {
  id: string;
  animal_id: string;
  vaccine_name: string;
  vaccine_type: string;
  scheduled_date: string;
  applied_date?: string;
  veterinarian?: string;
  notes?: string;
  status: 'Agendada' | 'Aplicada' | 'Cancelada';
  created_at: string;
  updated_at: string;
}

export interface Report {
  id: string;
  title: string;
  report_type: 'Animais' | 'Vacinações' | 'Reprodução' | 'Saúde' | 'Financeiro';
  parameters: Record<string, any>;
  generated_at: string;
  generated_by?: string;
}

export interface Note {
  id: string;
  animal_id?: string;
  title: string;
  content?: string;
  category: string;
  priority: 'Baixa' | 'Média' | 'Alta';
  date: string;
  created_by?: string;
  created_at: string;
  updated_at: string;
}

export interface BreedingRecord {
  id: string;
  female_animal_id: string;
  male_animal_id?: string;
  breeding_date: string;
  expected_birth?: string;
  status: 'Cobertura' | 'Confirmada' | 'Nasceu' | 'Perdida';
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface FinancialRecord {
  id: string;
  type: 'receita' | 'despesa';
  category: string;
  description?: string;
  amount: number;
  date: string;
  animal_id?: string;
  created_at: string;
  updated_at: string;
}

export interface AnimalStats {
  totalAnimals: number;
  healthy: number;
  pregnant: number;
  underTreatment: number;
  vaccinesThisMonth: number;
  birthsThisMonth: number;
  avgWeight: number;
  revenue: number;
}