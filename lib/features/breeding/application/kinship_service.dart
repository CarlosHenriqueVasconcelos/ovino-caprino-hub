import '../data/kinship_repository.dart';
import '../../../models/kinship_report.dart';

class KinshipService {
  final KinshipRepository _repository;

  KinshipService(this._repository);

  Future<bool> getBlockCousinBreedingEnabled() {
    return _repository.getBlockCousinBreedingEnabled();
  }

  Future<void> setBlockCousinBreedingEnabled(bool enabled) {
    return _repository.setBlockCousinBreedingEnabled(enabled);
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
      return _buildBlockingReport(
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
      return _buildBlockingReport(
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
      return _buildBlockingReport(
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
      return _buildBlockingReport(
        femaleLabel: femaleLabel,
        maleLabel: maleLabel,
        degreeLabel: '2º grau (linha colateral)',
        relationLabel: 'meio-irmãos',
        detail: 'Progenitor em comum: $parentLabel',
      );
    }

    if (femaleToMaleDepth == 2 || maleToFemaleDepth == 2) {
      return _buildBlockingReport(
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
      final shouldBlockCousins = await _repository.getBlockCousinBreedingEnabled();
      final sharedAncestor = await _repository.getAnimalRefById(
        sharedGrandparents.first,
      );
      final detail = sharedAncestor != null
          ? 'Avô/avó em comum: ${sharedAncestor.label}'
          : null;
      if (shouldBlockCousins) {
        return _buildBlockingReport(
          femaleLabel: femaleLabel,
          maleLabel: maleLabel,
          degreeLabel: '4º grau (linha colateral)',
          relationLabel: 'primos de 1º grau',
          detail: detail,
        );
      }
      return _buildWarningReport(
        femaleLabel: femaleLabel,
        maleLabel: maleLabel,
        degreeLabel: '4º grau (linha colateral)',
        relationLabel: 'primos de 1º grau',
        detail: detail,
      );
    }

    return null;
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
