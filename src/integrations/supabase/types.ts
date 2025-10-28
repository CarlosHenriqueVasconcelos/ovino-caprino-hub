export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.5"
  }
  public: {
    Tables: {
      animal_weights: {
        Row: {
          animal_id: string
          created_at: string
          date: string
          id: string
          milestone: string | null
          updated_at: string
          weight: number
        }
        Insert: {
          animal_id: string
          created_at?: string
          date: string
          id?: string
          milestone?: string | null
          updated_at?: string
          weight: number
        }
        Update: {
          animal_id?: string
          created_at?: string
          date?: string
          id?: string
          milestone?: string | null
          updated_at?: string
          weight?: number
        }
        Relationships: [
          {
            foreignKeyName: "animal_weights_animal_id_fkey"
            columns: ["animal_id"]
            isOneToOne: false
            referencedRelation: "animals"
            referencedColumns: ["id"]
          },
        ]
      }
      animals: {
        Row: {
          birth_date: string
          birth_weight: number | null
          breed: string
          category: string | null
          code: string
          created_at: string
          expected_delivery: string | null
          gender: string
          health_issue: string | null
          id: string
          last_vaccination: string | null
          location: string
          lote: string | null
          mother_id: string | null
          name: string
          name_color: string | null
          pregnant: boolean | null
          species: string
          status: string
          updated_at: string
          weight: number
          weight_120_days: number | null
          weight_30_days: number | null
          weight_60_days: number | null
          weight_90_days: number | null
          year: number | null
        }
        Insert: {
          birth_date: string
          birth_weight?: number | null
          breed: string
          category?: string | null
          code: string
          created_at?: string
          expected_delivery?: string | null
          gender: string
          health_issue?: string | null
          id?: string
          last_vaccination?: string | null
          location: string
          lote?: string | null
          mother_id?: string | null
          name: string
          name_color?: string | null
          pregnant?: boolean | null
          species: string
          status?: string
          updated_at?: string
          weight: number
          weight_120_days?: number | null
          weight_30_days?: number | null
          weight_60_days?: number | null
          weight_90_days?: number | null
          year?: number | null
        }
        Update: {
          birth_date?: string
          birth_weight?: number | null
          breed?: string
          category?: string | null
          code?: string
          created_at?: string
          expected_delivery?: string | null
          gender?: string
          health_issue?: string | null
          id?: string
          last_vaccination?: string | null
          location?: string
          lote?: string | null
          mother_id?: string | null
          name?: string
          name_color?: string | null
          pregnant?: boolean | null
          species?: string
          status?: string
          updated_at?: string
          weight?: number
          weight_120_days?: number | null
          weight_30_days?: number | null
          weight_60_days?: number | null
          weight_90_days?: number | null
          year?: number | null
        }
        Relationships: []
      }
      breeding_records: {
        Row: {
          birth_date: string | null
          breeding_date: string
          created_at: string
          expected_birth: string | null
          female_animal_id: string | null
          id: string
          male_animal_id: string | null
          mating_end_date: string | null
          mating_start_date: string | null
          notes: string | null
          separation_date: string | null
          stage: string | null
          status: string
          ultrasound_date: string | null
          ultrasound_result: string | null
          updated_at: string
        }
        Insert: {
          birth_date?: string | null
          breeding_date: string
          created_at?: string
          expected_birth?: string | null
          female_animal_id?: string | null
          id?: string
          male_animal_id?: string | null
          mating_end_date?: string | null
          mating_start_date?: string | null
          notes?: string | null
          separation_date?: string | null
          stage?: string | null
          status?: string
          ultrasound_date?: string | null
          ultrasound_result?: string | null
          updated_at?: string
        }
        Update: {
          birth_date?: string | null
          breeding_date?: string
          created_at?: string
          expected_birth?: string | null
          female_animal_id?: string | null
          id?: string
          male_animal_id?: string | null
          mating_end_date?: string | null
          mating_start_date?: string | null
          notes?: string | null
          separation_date?: string | null
          stage?: string | null
          status?: string
          ultrasound_date?: string | null
          ultrasound_result?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "breeding_records_female_animal_id_fkey"
            columns: ["female_animal_id"]
            isOneToOne: false
            referencedRelation: "animals"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "breeding_records_male_animal_id_fkey"
            columns: ["male_animal_id"]
            isOneToOne: false
            referencedRelation: "animals"
            referencedColumns: ["id"]
          },
        ]
      }
      deceased_animals: {
        Row: {
          birth_date: string
          birth_weight: number | null
          breed: string
          category: string | null
          cause_of_death: string | null
          code: string
          created_at: string
          death_date: string
          death_notes: string | null
          gender: string
          id: string
          location: string
          lote: string | null
          mother_id: string | null
          name: string
          name_color: string | null
          original_animal_id: string
          species: string
          updated_at: string
          weight: number
          weight_120_days: number | null
          weight_30_days: number | null
          weight_60_days: number | null
          weight_90_days: number | null
          year: number | null
        }
        Insert: {
          birth_date: string
          birth_weight?: number | null
          breed: string
          category?: string | null
          cause_of_death?: string | null
          code: string
          created_at?: string
          death_date: string
          death_notes?: string | null
          gender: string
          id?: string
          location: string
          lote?: string | null
          mother_id?: string | null
          name: string
          name_color?: string | null
          original_animal_id: string
          species: string
          updated_at?: string
          weight: number
          weight_120_days?: number | null
          weight_30_days?: number | null
          weight_60_days?: number | null
          weight_90_days?: number | null
          year?: number | null
        }
        Update: {
          birth_date?: string
          birth_weight?: number | null
          breed?: string
          category?: string | null
          cause_of_death?: string | null
          code?: string
          created_at?: string
          death_date?: string
          death_notes?: string | null
          gender?: string
          id?: string
          location?: string
          lote?: string | null
          mother_id?: string | null
          name?: string
          name_color?: string | null
          original_animal_id?: string
          species?: string
          updated_at?: string
          weight?: number
          weight_120_days?: number | null
          weight_30_days?: number | null
          weight_60_days?: number | null
          weight_90_days?: number | null
          year?: number | null
        }
        Relationships: []
      }
      feeding_pens: {
        Row: {
          created_at: string
          id: string
          name: string
          notes: string | null
          number: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          name: string
          notes?: string | null
          number?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          name?: string
          notes?: string | null
          number?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      feeding_schedules: {
        Row: {
          created_at: string
          feed_type: string
          feeding_times: string
          id: string
          notes: string | null
          pen_id: string
          quantity: number
          times_per_day: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          feed_type: string
          feeding_times: string
          id?: string
          notes?: string | null
          pen_id: string
          quantity: number
          times_per_day?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          feed_type?: string
          feeding_times?: string
          id?: string
          notes?: string | null
          pen_id?: string
          quantity?: number
          times_per_day?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "feeding_schedules_pen_id_fkey"
            columns: ["pen_id"]
            isOneToOne: false
            referencedRelation: "feeding_pens"
            referencedColumns: ["id"]
          },
        ]
      }
      financial_accounts: {
        Row: {
          amount: number
          animal_id: string | null
          category: string
          created_at: string
          description: string | null
          due_date: string
          id: string
          installment_number: number | null
          installments: number | null
          is_recurring: boolean | null
          notes: string | null
          parent_id: string | null
          payment_date: string | null
          payment_method: string | null
          recurrence_end_date: string | null
          recurrence_frequency: string | null
          status: string
          supplier_customer: string | null
          type: string
          updated_at: string
        }
        Insert: {
          amount: number
          animal_id?: string | null
          category: string
          created_at?: string
          description?: string | null
          due_date: string
          id?: string
          installment_number?: number | null
          installments?: number | null
          is_recurring?: boolean | null
          notes?: string | null
          parent_id?: string | null
          payment_date?: string | null
          payment_method?: string | null
          recurrence_end_date?: string | null
          recurrence_frequency?: string | null
          status?: string
          supplier_customer?: string | null
          type: string
          updated_at?: string
        }
        Update: {
          amount?: number
          animal_id?: string | null
          category?: string
          created_at?: string
          description?: string | null
          due_date?: string
          id?: string
          installment_number?: number | null
          installments?: number | null
          is_recurring?: boolean | null
          notes?: string | null
          parent_id?: string | null
          payment_date?: string | null
          payment_method?: string | null
          recurrence_end_date?: string | null
          recurrence_frequency?: string | null
          status?: string
          supplier_customer?: string | null
          type?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "financial_accounts_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "financial_accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      financial_records: {
        Row: {
          amount: number
          animal_id: string | null
          category: string
          created_at: string
          date: string
          description: string | null
          id: string
          type: string
          updated_at: string
        }
        Insert: {
          amount: number
          animal_id?: string | null
          category: string
          created_at?: string
          date?: string
          description?: string | null
          id?: string
          type: string
          updated_at?: string
        }
        Update: {
          amount?: number
          animal_id?: string | null
          category?: string
          created_at?: string
          date?: string
          description?: string | null
          id?: string
          type?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "financial_records_animal_id_fkey"
            columns: ["animal_id"]
            isOneToOne: false
            referencedRelation: "animals"
            referencedColumns: ["id"]
          },
        ]
      }
      medications: {
        Row: {
          animal_id: string
          applied_date: string | null
          created_at: string
          date: string
          dosage: string | null
          id: string
          medication_name: string
          next_date: string | null
          notes: string | null
          pharmacy_stock_id: string | null
          quantity_used: number | null
          status: string
          updated_at: string
          veterinarian: string | null
        }
        Insert: {
          animal_id: string
          applied_date?: string | null
          created_at?: string
          date: string
          dosage?: string | null
          id?: string
          medication_name: string
          next_date?: string | null
          notes?: string | null
          pharmacy_stock_id?: string | null
          quantity_used?: number | null
          status?: string
          updated_at?: string
          veterinarian?: string | null
        }
        Update: {
          animal_id?: string
          applied_date?: string | null
          created_at?: string
          date?: string
          dosage?: string | null
          id?: string
          medication_name?: string
          next_date?: string | null
          notes?: string | null
          pharmacy_stock_id?: string | null
          quantity_used?: number | null
          status?: string
          updated_at?: string
          veterinarian?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_medications_animal"
            columns: ["animal_id"]
            isOneToOne: false
            referencedRelation: "animals"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "medications_pharmacy_stock_id_fkey"
            columns: ["pharmacy_stock_id"]
            isOneToOne: false
            referencedRelation: "pharmacy_stock"
            referencedColumns: ["id"]
          },
        ]
      }
      notes: {
        Row: {
          animal_id: string | null
          category: string
          content: string | null
          created_at: string
          created_by: string | null
          date: string
          id: string
          is_read: boolean
          priority: string
          title: string
          updated_at: string
        }
        Insert: {
          animal_id?: string | null
          category: string
          content?: string | null
          created_at?: string
          created_by?: string | null
          date?: string
          id?: string
          is_read?: boolean
          priority?: string
          title: string
          updated_at?: string
        }
        Update: {
          animal_id?: string | null
          category?: string
          content?: string | null
          created_at?: string
          created_by?: string | null
          date?: string
          id?: string
          is_read?: boolean
          priority?: string
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "notes_animal_id_fkey"
            columns: ["animal_id"]
            isOneToOne: false
            referencedRelation: "animals"
            referencedColumns: ["id"]
          },
        ]
      }
      pharmacy_stock: {
        Row: {
          created_at: string
          expiration_date: string | null
          id: string
          is_opened: boolean | null
          medication_name: string
          medication_type: string
          min_stock_alert: number | null
          notes: string | null
          quantity_per_unit: number | null
          total_quantity: number
          unit_of_measure: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          expiration_date?: string | null
          id?: string
          is_opened?: boolean | null
          medication_name: string
          medication_type: string
          min_stock_alert?: number | null
          notes?: string | null
          quantity_per_unit?: number | null
          total_quantity?: number
          unit_of_measure: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          expiration_date?: string | null
          id?: string
          is_opened?: boolean | null
          medication_name?: string
          medication_type?: string
          min_stock_alert?: number | null
          notes?: string | null
          quantity_per_unit?: number | null
          total_quantity?: number
          unit_of_measure?: string
          updated_at?: string
        }
        Relationships: []
      }
      pharmacy_stock_movements: {
        Row: {
          created_at: string
          id: string
          medication_id: string | null
          movement_type: string
          pharmacy_stock_id: string
          quantity: number
          reason: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          medication_id?: string | null
          movement_type: string
          pharmacy_stock_id: string
          quantity: number
          reason?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          medication_id?: string | null
          movement_type?: string
          pharmacy_stock_id?: string
          quantity?: number
          reason?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "pharmacy_stock_movements_medication_id_fkey"
            columns: ["medication_id"]
            isOneToOne: false
            referencedRelation: "medications"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pharmacy_stock_movements_pharmacy_stock_id_fkey"
            columns: ["pharmacy_stock_id"]
            isOneToOne: false
            referencedRelation: "pharmacy_stock"
            referencedColumns: ["id"]
          },
        ]
      }
      push_tokens: {
        Row: {
          created_at: string
          device_info: Json | null
          id: string
          platform: string | null
          token: string
        }
        Insert: {
          created_at?: string
          device_info?: Json | null
          id?: string
          platform?: string | null
          token: string
        }
        Update: {
          created_at?: string
          device_info?: Json | null
          id?: string
          platform?: string | null
          token?: string
        }
        Relationships: []
      }
      reports: {
        Row: {
          generated_at: string
          generated_by: string | null
          id: string
          parameters: Json
          report_type: string
          title: string
        }
        Insert: {
          generated_at?: string
          generated_by?: string | null
          id?: string
          parameters?: Json
          report_type: string
          title: string
        }
        Update: {
          generated_at?: string
          generated_by?: string | null
          id?: string
          parameters?: Json
          report_type?: string
          title?: string
        }
        Relationships: []
      }
      sold_animals: {
        Row: {
          birth_date: string
          birth_weight: number | null
          breed: string
          buyer: string | null
          category: string | null
          code: string
          created_at: string
          gender: string
          id: string
          location: string
          lote: string | null
          mother_id: string | null
          name: string
          name_color: string | null
          original_animal_id: string
          sale_date: string
          sale_notes: string | null
          sale_price: number | null
          species: string
          updated_at: string
          weight: number
          weight_120_days: number | null
          weight_30_days: number | null
          weight_60_days: number | null
          weight_90_days: number | null
          year: number | null
        }
        Insert: {
          birth_date: string
          birth_weight?: number | null
          breed: string
          buyer?: string | null
          category?: string | null
          code: string
          created_at?: string
          gender: string
          id?: string
          location: string
          lote?: string | null
          mother_id?: string | null
          name: string
          name_color?: string | null
          original_animal_id: string
          sale_date: string
          sale_notes?: string | null
          sale_price?: number | null
          species: string
          updated_at?: string
          weight: number
          weight_120_days?: number | null
          weight_30_days?: number | null
          weight_60_days?: number | null
          weight_90_days?: number | null
          year?: number | null
        }
        Update: {
          birth_date?: string
          birth_weight?: number | null
          breed?: string
          buyer?: string | null
          category?: string | null
          code?: string
          created_at?: string
          gender?: string
          id?: string
          location?: string
          lote?: string | null
          mother_id?: string | null
          name?: string
          name_color?: string | null
          original_animal_id?: string
          sale_date?: string
          sale_notes?: string | null
          sale_price?: number | null
          species?: string
          updated_at?: string
          weight?: number
          weight_120_days?: number | null
          weight_30_days?: number | null
          weight_60_days?: number | null
          weight_90_days?: number | null
          year?: number | null
        }
        Relationships: []
      }
      vaccinations: {
        Row: {
          animal_id: string
          applied_date: string | null
          created_at: string
          id: string
          notes: string | null
          scheduled_date: string
          status: string
          updated_at: string
          vaccine_name: string
          vaccine_type: string
          veterinarian: string | null
        }
        Insert: {
          animal_id: string
          applied_date?: string | null
          created_at?: string
          id?: string
          notes?: string | null
          scheduled_date: string
          status?: string
          updated_at?: string
          vaccine_name: string
          vaccine_type: string
          veterinarian?: string | null
        }
        Update: {
          animal_id?: string
          applied_date?: string | null
          created_at?: string
          id?: string
          notes?: string | null
          scheduled_date?: string
          status?: string
          updated_at?: string
          vaccine_name?: string
          vaccine_type?: string
          veterinarian?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "vaccinations_animal_id_fkey"
            columns: ["animal_id"]
            isOneToOne: false
            referencedRelation: "animals"
            referencedColumns: ["id"]
          },
        ]
      }
      weight_alerts: {
        Row: {
          alert_type: string
          animal_id: string
          completed: boolean | null
          created_at: string
          due_date: string
          id: string
          updated_at: string
        }
        Insert: {
          alert_type: string
          animal_id: string
          completed?: boolean | null
          created_at?: string
          due_date: string
          id?: string
          updated_at?: string
        }
        Update: {
          alert_type?: string
          animal_id?: string
          completed?: boolean | null
          created_at?: string
          due_date?: string
          id?: string
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
