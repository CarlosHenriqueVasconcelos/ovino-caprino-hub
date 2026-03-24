class ReportFilters {
  final DateTime startDate;
  final DateTime endDate;
  final String? species;
  final String? gender;
  final String? status;
  final String? category;
  final String? vaccineType;
  final String? medicationStatus;
  final String? breedingStage;
  final String? financialType;
  final String? financialCategory;
  final String? notesPriority;
  final bool? notesIsRead;
  final int? limit;
  final int? offset;

  ReportFilters({
    required this.startDate,
    required this.endDate,
    this.species,
    this.gender,
    this.status,
    this.category,
    this.vaccineType,
    this.medicationStatus,
    this.breedingStage,
    this.financialType,
    this.financialCategory,
    this.notesPriority,
    this.notesIsRead,
    this.limit,
    this.offset,
  });
}
