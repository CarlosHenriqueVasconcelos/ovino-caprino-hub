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
  name_color?: string;
  category?: string;
  birth_weight?: number;
  weight_30_days?: number;
  weight_60_days?: number;
  weight_90_days?: number;
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

export interface Medication {
  id: string;
  animal_id: string;
  medication_name: string;
  dosage?: string;
  date: string;
  next_date?: string;
  applied_date?: string;
  veterinarian?: string;
  notes?: string;
  status: 'Agendado' | 'Aplicado' | 'Cancelado';
  created_at: string;
  updated_at: string;
}

export interface Report {
  id: string;
  title: string;
  report_type: 'Animais' | 'Pesos' | 'Vacinações' | 'Medicações' | 'Reprodução' | 'Saúde' | 'Financeiro' | 'Anotações';
  parameters: string | Record<string, any>;
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
  is_read?: boolean;
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
  stage?: string;
  mating_start_date?: string;
  mating_end_date?: string;
  separation_date?: string;
  ultrasound_date?: string;
  ultrasound_result?: string;
  birth_date?: string;
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

export interface FinancialAccount {
  id: string;
  type: 'receita' | 'despesa';
  category: string;
  description?: string;
  amount: number;
  due_date: string;
  payment_date?: string;
  status: 'Pendente' | 'Pago' | 'Vencido' | 'Cancelado';
  payment_method?: string;
  installments?: number;
  installment_number?: number;
  parent_id?: string;
  animal_id?: string;
  supplier_customer?: string;
  notes?: string;
  cost_center?: string;
  is_recurring?: boolean;
  recurrence_frequency?: 'Mensal' | 'Semanal' | 'Anual';
  recurrence_end_date?: string;
  created_at: string;
  updated_at: string;
}

export interface CostCenter {
  id: string;
  name: string;
  description?: string;
  active: boolean;
  created_at: string;
}

export interface Budget {
  id: string;
  category: string;
  cost_center?: string;
  amount: number;
  period: 'Mensal' | 'Trimestral' | 'Anual';
  year: number;
  month?: number;
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