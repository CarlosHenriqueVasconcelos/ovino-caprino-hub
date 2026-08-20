import 'package:drift/drift.dart' show Variable;

import '../../../data/animal_repository.dart';
import '../../../data/drift/app_database.dart';

class KinshipAnimalRef {
  final String id;
  final String code;
  final String name;
  final String? motherId;
  final String? fatherId;

  const KinshipAnimalRef({
    required this.id,
    required this.code,
    required this.name,
    required this.motherId,
    required this.fatherId,
  });

  factory KinshipAnimalRef.fromMap(Map<String, dynamic> row) {
    return KinshipAnimalRef(
      id: row['id']?.toString() ?? '',
      code: row['code']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      motherId: row['mother_id']?.toString(),
      fatherId: row['father_id']?.toString(),
    );
  }

  String get label {
    final safeName = name.trim().isEmpty ? 'Sem nome' : name.trim();
    final safeCode = code.trim().isEmpty ? 'sem código' : code.trim();
    return '$safeName ($safeCode)';
  }
}

class KinshipRepository {
  static const String _metaSourceSignatureKey = 'source_signature';
  static const String _metaLastRebuildAtKey = 'last_rebuild_at';
  static const String _blockSameAnimalBreedingKey = 'block_same_animal_breeding';
  static const String _blockParentChildBreedingKey = 'block_parent_child_breeding';
  static const String _blockSiblingBreedingKey = 'block_sibling_breeding';
  static const String _blockGrandparentBreedingKey =
      'block_grandparent_breeding';
  static const String _blockCousinBreedingKey = 'block_cousin_breeding';
  static const Map<String, bool> _defaultKinshipBlockSettings = {
    _blockSameAnimalBreedingKey: true,
    _blockParentChildBreedingKey: true,
    _blockSiblingBreedingKey: true,
    _blockGrandparentBreedingKey: true,
    _blockCousinBreedingKey: true,
  };
  static const Duration _lineageRefreshDebounce = Duration(seconds: 2);

  final AppDriftDatabase? _db;
  final AnimalRepository? _animalRepository;
  final String? Function()? _farmIdProvider;
  DateTime? _lastLineageCheckAt;

  KinshipRepository(AppDriftDatabase db, {String? Function()? farmIdProvider})
      : _db = db,
        _animalRepository = null,
        _farmIdProvider = farmIdProvider;

  KinshipRepository.fromAnimalRepository(this._animalRepository)
      : _db = null,
        _farmIdProvider = null;

  String? get _currentFarmId => _farmIdProvider?.call();

  // Prefixa chave de meta com o farmId para isolar por fazenda na
  // animal_lineage_meta (que tem PK única meta_key).
  String _farmKey(String key) => '${_currentFarmId ?? 'global'}_$key';

  bool get _supportsLineageTable => _db != null;

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Future<void> ensureLineageIsFresh() async {
    if (!_supportsLineageTable) return;

    final now = DateTime.now();
    if (_lastLineageCheckAt != null &&
        now.difference(_lastLineageCheckAt!) < _lineageRefreshDebounce) {
      return;
    }
    _lastLineageCheckAt = now;

    final sourceSignature = await _computeSourceSignature();
    final storedSignature = await _getMetaValue(_metaSourceSignatureKey);
    if (storedSignature == sourceSignature) return;

    await _rebuildLineage(sourceSignature);
  }

  Future<Map<String, KinshipAnimalRef>> getAnimalRefsByIds(Set<String> ids) async {
    if (ids.isEmpty) return <String, KinshipAnimalRef>{};

    if (_supportsLineageTable) {
      return _getAnimalRefsByIdsFromDb(ids);
    }

    return _getAnimalRefsByIdsFromRepository(ids);
  }

  Future<KinshipAnimalRef?> getAnimalRefById(String id) async {
    if (id.trim().isEmpty) return null;
    final refs = await getAnimalRefsByIds({id.trim()});
    return refs[id.trim()];
  }

  Future<bool> getBlockCousinBreedingEnabled() async {
    return getKinshipBlockSetting(
      _blockCousinBreedingKey,
      defaultEnabled: true,
    );
  }

  Future<void> setBlockCousinBreedingEnabled(bool enabled) async {
    return setKinshipBlockSetting(_blockCousinBreedingKey, enabled);
  }

  Future<bool> getKinshipBlockSetting(
    String key, {
    bool defaultEnabled = true,
  }) async {
    if (!_supportsLineageTable) return defaultEnabled;
    await _initDefaultKinshipBlockSetting(key, defaultEnabled);
    final value = await _getSettingValue(key);
    return _parseBoolSetting(value, defaultValue: defaultEnabled);
  }

  Future<void> setKinshipBlockSetting(String key, bool enabled) async {
    if (!_supportsLineageTable) return;
    final farmId = _currentFarmId;
    final nowIso = DateTime.now().toIso8601String();
    await _db!.customStatement(
      '''
      INSERT OR REPLACE INTO app_settings(farm_id, setting_key, setting_value, updated_at)
      VALUES (?, ?, ?, ?)
      ''',
      [farmId, key, enabled ? '1' : '0', nowIso],
    );
  }

  Future<int?> getAncestorDepth({
    required String descendantId,
    required String ancestorId,
  }) async {
    if (!_supportsLineageTable) {
      final graph = await _loadFallbackGraph();
      return _computeFallbackDepth(
        graph: graph,
        descendantId: descendantId,
        ancestorId: ancestorId,
      );
    }

    final farmId = _currentFarmId;
    final rows = await _db!.customSelect(
      farmId != null
          ? 'SELECT MIN(depth) AS depth FROM animal_lineage WHERE descendant_id = ? AND ancestor_id = ? AND farm_id = ?'
          : 'SELECT MIN(depth) AS depth FROM animal_lineage WHERE descendant_id = ? AND ancestor_id = ?',
      variables: farmId != null
          ? _vars([descendantId, ancestorId, farmId])
          : _vars([descendantId, ancestorId]),
    ).get();

    if (rows.isEmpty) return null;
    final value = rows.first.data['depth'];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<Set<String>> getSharedDirectParentIds({
    required String leftDescendantId,
    required String rightDescendantId,
  }) async {
    if (!_supportsLineageTable) {
      final graph = await _loadFallbackGraph();
      final left = _resolveDirectParents(
        graph: graph,
        descendantId: leftDescendantId,
      );
      final right = _resolveDirectParents(
        graph: graph,
        descendantId: rightDescendantId,
      );
      return left.intersection(right);
    }

    final farmId = _currentFarmId;
    final rows = await _db!.customSelect(
      farmId != null
          ? '''
          SELECT DISTINCT l1.ancestor_id AS ancestor_id
          FROM animal_lineage l1
          JOIN animal_lineage l2 ON l2.ancestor_id = l1.ancestor_id
          WHERE l1.descendant_id = ? AND l2.descendant_id = ?
            AND l1.depth = 1 AND l2.depth = 1
            AND l1.farm_id = ? AND l2.farm_id = ?
          '''
          : '''
          SELECT DISTINCT l1.ancestor_id AS ancestor_id
          FROM animal_lineage l1
          JOIN animal_lineage l2 ON l2.ancestor_id = l1.ancestor_id
          WHERE l1.descendant_id = ? AND l2.descendant_id = ?
            AND l1.depth = 1 AND l2.depth = 1
          ''',
      variables: farmId != null
          ? _vars([leftDescendantId, rightDescendantId, farmId, farmId])
          : _vars([leftDescendantId, rightDescendantId]),
    ).get();

    return rows
        .map((r) => r.data['ancestor_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<Set<String>> getSharedGrandparentIds({
    required String leftDescendantId,
    required String rightDescendantId,
  }) async {
    if (!_supportsLineageTable) {
      final graph = await _loadFallbackGraph();
      final leftGrandparents = _resolveAncestorsByDepth(
        graph: graph,
        descendantId: leftDescendantId,
        targetDepth: 2,
      );
      final rightGrandparents = _resolveAncestorsByDepth(
        graph: graph,
        descendantId: rightDescendantId,
        targetDepth: 2,
      );
      return leftGrandparents.intersection(rightGrandparents);
    }

    final farmId = _currentFarmId;
    final rows = await _db!.customSelect(
      farmId != null
          ? '''
          SELECT DISTINCT l1.ancestor_id AS ancestor_id
          FROM animal_lineage l1
          JOIN animal_lineage l2 ON l2.ancestor_id = l1.ancestor_id
          WHERE l1.descendant_id = ? AND l2.descendant_id = ?
            AND l1.depth = 2 AND l2.depth = 2
            AND l1.farm_id = ? AND l2.farm_id = ?
          '''
          : '''
          SELECT DISTINCT l1.ancestor_id AS ancestor_id
          FROM animal_lineage l1
          JOIN animal_lineage l2 ON l2.ancestor_id = l1.ancestor_id
          WHERE l1.descendant_id = ? AND l2.descendant_id = ?
            AND l1.depth = 2 AND l2.depth = 2
          ''',
      variables: farmId != null
          ? _vars([leftDescendantId, rightDescendantId, farmId, farmId])
          : _vars([leftDescendantId, rightDescendantId]),
    ).get();

    return rows
        .map((r) => r.data['ancestor_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<Map<String, KinshipAnimalRef>> _getAnimalRefsByIdsFromDb(
    Set<String> ids,
  ) async {
    final farmId = _currentFarmId;
    final idList = ids.toList(growable: false);
    final placeholders = List.filled(idList.length, '?').join(',');

    final refs = <String, KinshipAnimalRef>{};
    for (final table in const ['animals', 'sold_animals', 'deceased_animals']) {
      final rows = await _db!.customSelect(
        farmId != null
            ? 'SELECT id, code, name, mother_id, father_id FROM $table WHERE id IN ($placeholders) AND farm_id = ?'
            : 'SELECT id, code, name, mother_id, father_id FROM $table WHERE id IN ($placeholders)',
        variables: farmId != null
            ? _vars([...idList, farmId])
            : _vars(idList),
      ).get();
      for (final row in rows) {
        final ref = KinshipAnimalRef.fromMap(row.data);
        if (ref.id.isEmpty) continue;
        refs.putIfAbsent(ref.id, () => ref);
      }
    }

    return refs;
  }

  Future<Map<String, KinshipAnimalRef>> _getAnimalRefsByIdsFromRepository(
    Set<String> ids,
  ) async {
    final repo = _animalRepository;
    if (repo == null) return <String, KinshipAnimalRef>{};

    final all = await repo.all();
    final out = <String, KinshipAnimalRef>{};
    for (final animal in all) {
      if (!ids.contains(animal.id)) continue;
      out[animal.id] = KinshipAnimalRef(
        id: animal.id,
        code: animal.code,
        name: animal.name,
        motherId: animal.motherId,
        fatherId: animal.fatherId,
      );
    }
    return out;
  }

  Future<_FallbackGraph> _loadFallbackGraph() async {
    final repo = _animalRepository;
    if (repo == null) {
      return _FallbackGraph(
        refsById: const <String, KinshipAnimalRef>{},
        resolver: _ParentRefResolver.fromRefs(const <KinshipAnimalRef>[]),
      );
    }

    final animals = await repo.all();
    final refsById = <String, KinshipAnimalRef>{};
    for (final animal in animals) {
      refsById[animal.id] = KinshipAnimalRef(
        id: animal.id,
        code: animal.code,
        name: animal.name,
        motherId: animal.motherId,
        fatherId: animal.fatherId,
      );
    }
    return _FallbackGraph(
      refsById: refsById,
      resolver: _ParentRefResolver.fromRefs(refsById.values),
    );
  }

  int? _computeFallbackDepth({
    required _FallbackGraph graph,
    required String descendantId,
    required String ancestorId,
  }) {
    if (descendantId == ancestorId) return 0;
    if (graph.refsById[descendantId] == null) return null;

    const int maxDepth = 8;
    final queue = <_DepthNode>[];
    final directParents = _resolveDirectParents(
      graph: graph,
      descendantId: descendantId,
    );
    for (final parentId in directParents) {
      queue.add(_DepthNode(id: parentId, depth: 1));
    }

    final visitedDepth = <String, int>{};
    var index = 0;
    while (index < queue.length) {
      final node = queue[index++];
      if (node.depth > maxDepth) continue;
      final best = visitedDepth[node.id];
      if (best != null && node.depth >= best) continue;
      visitedDepth[node.id] = node.depth;

      if (node.id == ancestorId) return node.depth;

      final parentRef = graph.refsById[node.id];
      if (parentRef == null) continue;

      final nextMother = graph.resolver.resolve(parentRef.motherId);
      if (nextMother != null) {
        queue.add(_DepthNode(id: nextMother, depth: node.depth + 1));
      }
      final nextFather = graph.resolver.resolve(parentRef.fatherId);
      if (nextFather != null) {
        queue.add(_DepthNode(id: nextFather, depth: node.depth + 1));
      }
    }

    return null;
  }

  Set<String> _resolveDirectParents({
    required _FallbackGraph graph,
    required String descendantId,
  }) {
    final descendant = graph.refsById[descendantId];
    if (descendant == null) return <String>{};

    final parentIds = <String>{};
    final motherId = graph.resolver.resolve(descendant.motherId);
    final fatherId = graph.resolver.resolve(descendant.fatherId);
    if (motherId != null) parentIds.add(motherId);
    if (fatherId != null) parentIds.add(fatherId);
    return parentIds;
  }

  Set<String> _resolveAncestorsByDepth({
    required _FallbackGraph graph,
    required String descendantId,
    required int targetDepth,
  }) {
    if (targetDepth <= 0) return <String>{};

    final directParents = _resolveDirectParents(
      graph: graph,
      descendantId: descendantId,
    );
    if (targetDepth == 1) return directParents;

    final result = <String>{};
    final queue = <_DepthNode>[
      for (final parentId in directParents) _DepthNode(id: parentId, depth: 1),
    ];
    final visitedBestDepth = <String, int>{};

    var index = 0;
    while (index < queue.length) {
      final node = queue[index++];
      if (node.depth > targetDepth) continue;

      final best = visitedBestDepth[node.id];
      if (best != null && node.depth >= best) continue;
      visitedBestDepth[node.id] = node.depth;

      if (node.depth == targetDepth) {
        result.add(node.id);
        continue;
      }

      final ref = graph.refsById[node.id];
      if (ref == null) continue;

      final motherId = graph.resolver.resolve(ref.motherId);
      if (motherId != null) {
        queue.add(_DepthNode(id: motherId, depth: node.depth + 1));
      }
      final fatherId = graph.resolver.resolve(ref.fatherId);
      if (fatherId != null) {
        queue.add(_DepthNode(id: fatherId, depth: node.depth + 1));
      }
    }

    return result;
  }

  Future<void> _initDefaultKinshipBlockSetting(
    String key,
    bool defaultEnabled,
  ) async {
    final farmId = _currentFarmId;
    final nowIso = DateTime.now().toIso8601String();
    final fallbackDefault =
        _defaultKinshipBlockSettings[key] ?? defaultEnabled;
    await _db!.customStatement(
      '''
      INSERT OR IGNORE INTO app_settings(farm_id, setting_key, setting_value, updated_at)
      VALUES (?, ?, ?, ?)
      ''',
      [farmId, key, fallbackDefault ? '1' : '0', nowIso],
    );
  }

  bool _parseBoolSetting(String? value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    final normalized = value.trim().toLowerCase();
    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'on';
  }

  Future<String?> _getMetaValue(String key) async {
    final rows = await _db!.customSelect(
      'SELECT meta_value FROM animal_lineage_meta WHERE meta_key = ? LIMIT 1',
      variables: _vars([_farmKey(key)]),
    ).get();
    if (rows.isEmpty) return null;
    return rows.first.data['meta_value']?.toString();
  }

  Future<String?> _getSettingValue(String key) async {
    final farmId = _currentFarmId;
    final rows = await _db!.customSelect(
      farmId != null
          ? 'SELECT setting_value FROM app_settings WHERE farm_id = ? AND setting_key = ? LIMIT 1'
          : 'SELECT setting_value FROM app_settings WHERE farm_id IS NULL AND setting_key = ? LIMIT 1',
      variables: farmId != null ? _vars([farmId, key]) : _vars([key]),
    ).get();
    if (rows.isEmpty) return null;
    return rows.first.data['setting_value']?.toString();
  }

  Future<String> _computeSourceSignature() async {
    final farmId = _currentFarmId;
    final farmFilter = farmId != null ? 'WHERE farm_id = ?' : '';
    final args = farmId != null
        ? _vars([farmId, farmId, farmId])
        : <Variable<Object>>[];
    final rows = await _db!.customSelect(
      '''
      SELECT
        COUNT(*) AS source_count,
        COALESCE(MAX(updated_at), '') AS max_updated_at,
        COALESCE(SUM(
          LENGTH(COALESCE(id, '')) +
          LENGTH(COALESCE(code, '')) +
          LENGTH(COALESCE(mother_id, '')) +
          LENGTH(COALESCE(father_id, ''))
        ), 0) AS source_hash
      FROM (
        SELECT id, code, mother_id, father_id, updated_at FROM animals $farmFilter
        UNION ALL
        SELECT id, code, mother_id, father_id, updated_at FROM sold_animals $farmFilter
        UNION ALL
        SELECT id, code, mother_id, father_id, updated_at FROM deceased_animals $farmFilter
      ) src
      ''',
      variables: args,
    ).get();

    final row = rows.first.data;
    final count = row['source_count']?.toString() ?? '0';
    final maxUpdated = row['max_updated_at']?.toString() ?? '';
    final hash = row['source_hash']?.toString() ?? '0';
    return '$count|$maxUpdated|$hash';
  }

  Future<List<KinshipAnimalRef>> _loadAllRefs() async {
    final farmId = _currentFarmId;
    final farmFilter = farmId != null ? 'WHERE farm_id = ?' : '';
    final args = farmId != null ? _vars([farmId, farmId, farmId]) : <Variable<Object>>[];
    final rows = await _db!.customSelect(
      '''
      SELECT id, code, name, mother_id, father_id FROM animals $farmFilter
      UNION ALL
      SELECT id, code, name, mother_id, father_id FROM sold_animals $farmFilter
      UNION ALL
      SELECT id, code, name, mother_id, father_id FROM deceased_animals $farmFilter
      ''',
      variables: args,
    ).get();

    final refs = <String, KinshipAnimalRef>{};
    for (final row in rows) {
      final ref = KinshipAnimalRef.fromMap(row.data);
      if (ref.id.isEmpty) continue;
      refs.putIfAbsent(ref.id, () => ref);
    }
    return refs.values.toList(growable: false);
  }

  Future<void> _rebuildLineage(String sourceSignature) async {
    final farmId = _currentFarmId;
    final nowIso = DateTime.now().toIso8601String();

    await _db!.transaction(() async {
      final refs = await _loadAllRefs();
      final refsById = <String, KinshipAnimalRef>{for (final r in refs) r.id: r};
      final resolver = _ParentRefResolver.fromRefs(refs);

      if (farmId != null) {
        await _db.customStatement(
          'DELETE FROM animal_lineage WHERE farm_id = ?',
          [farmId],
        );
      } else {
        await _db.customStatement('DELETE FROM animal_lineage');
      }

      for (final descendant in refs) {
        final entries = _buildAncestorEntries(
          descendant: descendant,
          refsById: refsById,
          resolver: resolver,
        );
        for (final entry in entries) {
          await _db.customStatement(
            '''
            INSERT OR REPLACE INTO animal_lineage(
              descendant_id, ancestor_id, depth, line_type, farm_id, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ''',
            [descendant.id, entry.ancestorId, entry.depth, entry.lineType, farmId, nowIso, nowIso],
          );
        }
      }

      await _db.customStatement(
        'INSERT OR REPLACE INTO animal_lineage_meta(farm_id, meta_key, meta_value, updated_at) VALUES (?, ?, ?, ?)',
        [farmId, _farmKey(_metaSourceSignatureKey), sourceSignature, nowIso],
      );
      await _db.customStatement(
        'INSERT OR REPLACE INTO animal_lineage_meta(farm_id, meta_key, meta_value, updated_at) VALUES (?, ?, ?, ?)',
        [farmId, _farmKey(_metaLastRebuildAtKey), nowIso, nowIso],
      );
    });
  }

  List<_AncestorEntry> _buildAncestorEntries({
    required KinshipAnimalRef descendant,
    required Map<String, KinshipAnimalRef> refsById,
    required _ParentRefResolver resolver,
  }) {
    const int maxDepth = 8;
    final queue = <_QueueNode>[];

    final motherId = resolver.resolve(descendant.motherId);
    final fatherId = resolver.resolve(descendant.fatherId);
    if (motherId != null) {
      queue.add(_QueueNode(ancestorId: motherId, depth: 1, lineType: 'maternal'));
    }
    if (fatherId != null) {
      queue.add(_QueueNode(ancestorId: fatherId, depth: 1, lineType: 'paternal'));
    }

    final bestDepthByAncestor = <String, int>{};
    final lineTypeByAncestor = <String, String>{};
    var index = 0;
    while (index < queue.length) {
      final node = queue[index++];
      if (node.ancestorId == descendant.id) continue;
      if (node.depth > maxDepth) continue;

      final existingDepth = bestDepthByAncestor[node.ancestorId];
      if (existingDepth != null && node.depth > existingDepth) continue;

      if (existingDepth == null || node.depth < existingDepth) {
        bestDepthByAncestor[node.ancestorId] = node.depth;
        lineTypeByAncestor[node.ancestorId] = node.lineType;
      } else if (existingDepth == node.depth) {
        final currentLineType = lineTypeByAncestor[node.ancestorId];
        if (currentLineType != node.lineType) {
          lineTypeByAncestor[node.ancestorId] = 'mixed';
        }
        continue;
      }

      final ancestorRef = refsById[node.ancestorId];
      if (ancestorRef == null) continue;

      final ancestorMotherId = resolver.resolve(ancestorRef.motherId);
      if (ancestorMotherId != null) {
        queue.add(_QueueNode(
          ancestorId: ancestorMotherId,
          depth: node.depth + 1,
          lineType: node.lineType,
        ));
      }

      final ancestorFatherId = resolver.resolve(ancestorRef.fatherId);
      if (ancestorFatherId != null) {
        queue.add(_QueueNode(
          ancestorId: ancestorFatherId,
          depth: node.depth + 1,
          lineType: node.lineType,
        ));
      }
    }

    return bestDepthByAncestor.entries.map((entry) {
      return _AncestorEntry(
        ancestorId: entry.key,
        depth: entry.value,
        lineType: lineTypeByAncestor[entry.key] ?? 'unknown',
      );
    }).toList(growable: false);
  }
}

class _QueueNode {
  final String ancestorId;
  final int depth;
  final String lineType;

  const _QueueNode({
    required this.ancestorId,
    required this.depth,
    required this.lineType,
  });
}

class _AncestorEntry {
  final String ancestorId;
  final int depth;
  final String lineType;

  const _AncestorEntry({
    required this.ancestorId,
    required this.depth,
    required this.lineType,
  });
}

class _FallbackGraph {
  final Map<String, KinshipAnimalRef> refsById;
  final _ParentRefResolver resolver;

  const _FallbackGraph({
    required this.refsById,
    required this.resolver,
  });
}

class _DepthNode {
  final String id;
  final int depth;

  const _DepthNode({
    required this.id,
    required this.depth,
  });
}

class _ParentRefResolver {
  final Set<String> _validIds;
  final Map<String, String> _codeToUniqueId;

  _ParentRefResolver._(this._validIds, this._codeToUniqueId);

  factory _ParentRefResolver.fromRefs(Iterable<KinshipAnimalRef> refs) {
    final validIds = <String>{for (final ref in refs) ref.id};
    final codeHits = <String, List<String>>{};

    for (final ref in refs) {
      final code = ref.code.trim().toLowerCase();
      if (code.isEmpty) continue;
      codeHits.putIfAbsent(code, () => <String>[]).add(ref.id);
    }

    final codeToUniqueId = <String, String>{};
    codeHits.forEach((code, ids) {
      if (ids.length == 1) {
        codeToUniqueId[code] = ids.first;
      }
    });

    return _ParentRefResolver._(validIds, codeToUniqueId);
  }

  String? resolve(String? raw) {
    final ref = raw?.trim();
    if (ref == null || ref.isEmpty) return null;
    if (_validIds.contains(ref)) return ref;
    return _codeToUniqueId[ref.toLowerCase()];
  }
}
