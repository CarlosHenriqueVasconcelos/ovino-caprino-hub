enum KinshipRiskLevel {
  warning,
  block,
}

class KinshipReport {
  final KinshipRiskLevel riskLevel;
  final String degreeLabel;
  final String relationLabel;
  final String femaleLabel;
  final String maleLabel;
  final String? detail;

  const KinshipReport({
    required this.riskLevel,
    required this.degreeLabel,
    required this.relationLabel,
    required this.femaleLabel,
    required this.maleLabel,
    this.detail,
  });

  bool get isBlocking => riskLevel == KinshipRiskLevel.block;

  String get animalsLabel => '$femaleLabel x $maleLabel';

  String buildMessage() {
    final title = riskLevel == KinshipRiskLevel.block
        ? 'Cruzamento bloqueado.'
        : 'Atenção: parentesco detectado.';
    final detailText =
        (detail != null && detail!.trim().isNotEmpty) ? '\n$detail' : '';
    return '$title\n'
        'Grau detectado: $degreeLabel.\n'
        'Relação: $relationLabel.\n'
        'Animais: $animalsLabel.$detailText';
  }
}
