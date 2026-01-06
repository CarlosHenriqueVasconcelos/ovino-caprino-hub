// Enums compartilhados para a gestão de medicamentos e vacinações

/// Filtro de status para medicamentos
enum MedicationStatusFilter {
  overdue,
  scheduled,
  completed,
  cancelled,
  vaccinations,
}

/// Filtro de status para vacinações
enum VaccinationStatusFilter {
  overdue,
  scheduled,
  applied,
  cancelled,
}

/// Tipos de abas de medicamentos
enum MedicationTabType {
  overdue,
  scheduled,
  completed,
  cancelled,
  vaccinations,
}
