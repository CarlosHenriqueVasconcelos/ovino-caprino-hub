// lib/utils/labels_ptbr.dart
// Mapeia chaves (em inglês/snake_case) para rótulos PT-BR.
// Use: ptBrHeader('expected_birth') => 'Previsão de Parto'

String ptBrHeader(String key) {
  final map = <String, String>{
    // Gerais
    'id': 'ID',
    'code': 'Código',
    'name': 'Nome',
    'notes': 'Observações',
    'status': 'Status',
    'created_at': 'Criado em',
    'updated_at': 'Atualizado em',

    // Animais
    'species': 'Espécie',
    'gender': 'Gênero',
    'breed': 'Raça',
    'category': 'Categoria',
    'weight': 'Peso (kg)',
    'birth_date': 'Data de Nascimento',
    'age_months': 'Idade (meses)',
    'pregnant': 'Gestante',
    'expected_delivery': 'Parto Previsto',
    'mother_id': 'Mãe (ID)',
    'father_id': 'Pai (ID)',

    // Vacinas
    'vaccine_name': 'Vacina',
    'vaccine_type': 'Tipo de Vacina',
    'application_date': 'Data de Aplicação',
    'scheduled_date': 'Data Agendada',
    'next_date': 'Próxima Dose',
    'applied_by': 'Aplicado por',

    // Medicações
    'medication_name': 'Medicamento',
    'dosage': 'Dosagem',
    'veterinarian': 'Veterinário',
    'application_status': 'Status da Aplicação',

    // Reprodução
    'stage': 'Estágio',
    'breeding_date': 'Data da Cobertura',
    'mating_start_date': 'Entrada no Encabritamento',
    'mating_end_date': 'Saída do Encabritamento',
    'separation_date': 'Data de Separação',
    'ultrasound_date': 'Data de Ultrassom',
    'ultrasound_result': 'Resultado do Ultrassom',
    'expected_birth': 'Previsão de Parto',
    'birth_date_real': 'Data do Parto',

    // Financeiro
    'type': 'Tipo',
    'category_fin': 'Categoria',
    'amount': 'Valor (R\$)',            // <- escapar $ em strings
    'revenue': 'Receita (R\$)',
    'expense': 'Despesa (R\$)',
    'balance': 'Saldo (R\$)',
    'due_date': 'Vencimento',
    'paid_date': 'Data de Pagamento',

    // Anotações
    'priority': 'Prioridade',
    'is_read': 'Lida',
  };

  return map[key] ?? _titleize(key);
}

String _titleize(String s) {
  // "expected_birth" -> "Expected Birth"
  final cleaned = s.replaceAll('_', ' ').trim();
  if (cleaned.isEmpty) return s;
  final parts = cleaned.split(RegExp(r'\s+'));
  final titled = parts.map((w) {
    if (w.isEmpty) return w;
    final first = w[0].toUpperCase();
    final rest = w.length > 1 ? w.substring(1) : '';
    return '$first$rest';
  }).join(' ');
  return titled;
}
