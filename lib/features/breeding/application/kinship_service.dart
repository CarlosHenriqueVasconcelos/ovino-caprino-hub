import '../data/kinship_repository.dart';
import '../../../models/kinship_report.dart';

enum KinshipBlockRule {
  sameAnimal(
    settingKey: 'block_same_animal_breeding',
    settingsTitle: 'Bloquear 0º grau (mesmo animal)',
    settingsSubtitle: 'Impede usar o mesmo animal nas duas seleções.',
  ),
  parentChild(
    settingKey: 'block_parent_child_breeding',
    settingsTitle: 'Bloquear 1º grau (pai/mãe e filho)',
    settingsSubtitle: 'Impede cruzamentos em linha reta de 1º grau.',
  ),
  siblings(
    settingKey: 'block_sibling_breeding',
    settingsTitle: 'Bloquear 2º grau (irmãos)',
    settingsSubtitle: 'Impede irmãos completos e meio-irmãos.',
  ),
  grandparentGrandchild(
    settingKey: 'block_grandparent_breeding',
    settingsTitle: 'Bloquear 2º grau (avô/avó e neto)',
    settingsSubtitle: 'Impede cruzamentos em linha reta de 2º grau.',
  ),
  cousins(
    settingKey: 'block_cousin_breeding',
    settingsTitle: 'Bloquear 4º grau (primos)',
    settingsSubtitle: 'Impede coberturas com avô/avó em comum.',
  );

  const KinshipBlockRule({
    required this.settingKey,
    required this.settingsTitle,
    required this.settingsSubtitle,
  });

  final String settingKey;
  final String settingsTitle;
  final String settingsSubtitle;
}

class KinshipService {
  final KinshipRepository _repository;

  KinshipService(this._repository);

  Future<Map<KinshipBlockRule, bool>> getKinshipBlockRules() async {
    final out = <KinshipBlockRule, bool>{};
    for (final rule in KinshipBlockRule.values) {
      out[rule] = await getKinshipBlockRuleEnabled(rule);
    }
    return out;
  }

  Future<bool> getKinshipBlockRuleEnabled(KinshipBlockRule rule) {
    return _repository.getKinshipBlockSetting(
      rule.settingKey,
      defaultEnabled: true,
    );
  }

  Future<void> setKinshipBlockRuleEnabled(
    KinshipBlockRule rule,
    bool enabled,
  ) {
    return _repository.setKinshipBlockSetting(rule.settingKey, enabled);
  }

  Future<bool> getBlockCousinBreedingEnabled() {
    return getKinshipBlockRuleEnabled(KinshipBlockRule.cousins);
  }

  Future<void> setBlockCousinBreedingEnabled(bool enabled) {
    return setKinshipBlockRuleEnabled(KinshipBlockRule.cousins, enabled);
  }

  Future<KinshipReport?> getKinshipReport({
    required String femaleId,
    required String maleId,
  }) async {
    final female = femaleId.trim();
    final male = maleId.trim();
    if (female.isEmpty || male.isEmpty) return null;

    await _repository.ensureLineageIsFresh();

    final refs = await _repository.getAnimalRefsByIds({female, male});
    final femaleAnimal = refs[female];
    final maleAnimal = refs[male];

    if (female == male) {
      final label = femaleAnimal?.label ?? 'ID $female';
      return _buildRuleAwareReport(
        rule: KinshipBlockRule.sameAnimal,
        femaleLabel: label,
        maleLabel: label,
        degreeLabel: '0º grau',
        relationLabel: 'identidade (animal selecionado duas vezes)',
      );
    }

    // Se não temos ambos os animais carregados, não bloqueamos o fluxo.
    if (femaleAnimal == null || maleAnimal == null) return null;

    final femaleLabel = femaleAnimal.label;
    final maleLabel = maleAnimal.label;

    final femaleToMaleDepth = await _repository.getAncestorDepth(
      descendantId: female,
      ancestorId: male,
    );
    final maleToFemaleDepth = await _repository.getAncestorDepth(
      descendantId: male,
      ancestorId: female,
    );

    if (femaleToMaleDepth == 1 || maleToFemaleDepth == 1) {
      return _buildRuleAwareReport(
        rule: KinshipBlockRule.parentChild,
        femaleLabel: femaleLabel,
        maleLabel: maleLabel,
        degreeLabel: '1º grau (linha reta)',
        relationLabel: 'pai/mãe e filho(a)',
      );
    }

    final sharedParents = await _repository.getSharedDirectParentIds(
      leftDescendantId: female,
      rightDescendantId: male,
    );
    if (sharedParents.length >= 2) {
      return _buildRuleAwareReport(
        rule: KinshipBlockRule.siblings,
        femaleLabel: femaleLabel,
        maleLabel: maleLabel,
        degreeLabel: '2º grau (linha colateral)',
        relationLabel: 'irmãos completos (mesmo pai e mesma mãe)',
      );
    }

    if (sharedParents.length == 1) {
      final sharedParentId = sharedParents.first;
      final sharedParent = await _repository.getAnimalRefById(sharedParentId);
      final parentLabel = sharedParent?.label ?? 'progenitor comum';
      return _buildRuleAwareReport(
        rule: KinshipBlockRule.siblings,
        femaleLabel: femaleLabel,
        maleLabel: maleLabel,
        degreeLabel: '2º grau (linha colateral)',
        relationLabel: 'meio-irmãos',
        detail: 'Progenitor em comum: $parentLabel',
      );
    }

    if (femaleToMaleDepth == 2 || maleToFemaleDepth == 2) {
      return _buildRuleAwareReport(
        rule: KinshipBlockRule.grandparentGrandchild,
        femaleLabel: femaleLabel,
        maleLabel: maleLabel,
        degreeLabel: '2º grau (linha reta)',
        relationLabel: 'avô/avó e neto(a)',
      );
    }

    final sharedGrandparents = await _repository.getSharedGrandparentIds(
      leftDescendantId: female,
      rightDescendantId: male,
    );
    if (sharedGrandparents.isNotEmpty) {
      final sharedAncestor = await _repository.getAnimalRefById(
        sharedGrandparents.first,
      );
      final detail = sharedAncestor != null
          ? 'Avô/avó em comum: ${sharedAncestor.label}'
          : null;
      return _buildRuleAwareReport(
        rule: KinshipBlockRule.cousins,
        femaleLabel: femaleLabel,
        maleLabel: maleLabel,
        degreeLabel: '4º grau (linha colateral)',
        relationLabel: 'primos de 1º grau',
        detail: detail,
      );
    }

    return null;
  }

  Future<KinshipReport> _buildRuleAwareReport({
    required KinshipBlockRule rule,
    required String femaleLabel,
    required String maleLabel,
    required String degreeLabel,
    required String relationLabel,
    String? detail,
  }) async {
    final shouldBlock = await getKinshipBlockRuleEnabled(rule);
    if (shouldBlock) {
      return _buildBlockingReport(
        femaleLabel: femaleLabel,
        maleLabel: maleLabel,
        degreeLabel: degreeLabel,
        relationLabel: relationLabel,
        detail: detail,
      );
    }
    return _buildWarningReport(
      femaleLabel: femaleLabel,
      maleLabel: maleLabel,
      degreeLabel: degreeLabel,
      relationLabel: relationLabel,
      detail: detail,
    );
  }

  static KinshipReport _buildBlockingReport({
    required String femaleLabel,
    required String maleLabel,
    required String degreeLabel,
    required String relationLabel,
    String? detail,
  }) {
    return KinshipReport(
      riskLevel: KinshipRiskLevel.block,
      degreeLabel: degreeLabel,
      relationLabel: relationLabel,
      femaleLabel: femaleLabel,
      maleLabel: maleLabel,
      detail: detail,
    );
  }

  static KinshipReport _buildWarningReport({
    required String femaleLabel,
    required String maleLabel,
    required String degreeLabel,
    required String relationLabel,
    String? detail,
  }) {
    return KinshipReport(
      riskLevel: KinshipRiskLevel.warning,
      degreeLabel: degreeLabel,
      relationLabel: relationLabel,
      femaleLabel: femaleLabel,
      maleLabel: maleLabel,
      detail: detail,
    );
  }
}
