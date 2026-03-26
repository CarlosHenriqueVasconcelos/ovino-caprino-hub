import 'package:sqflite_common/sqlite_api.dart'
    show ConflictAlgorithm, DatabaseExecutor;

import '../../../data/animal_repository.dart';
import '../../../data/local_db.dart';

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
  static const String _blockCousinBreedingKey = 'block_cousin_breeding';
  static const Duration _lineageRefreshDebounce = Duration(seconds: 2);

  final AppDatabase? _appDb;
  final AnimalRepository? _animalRepository;
  DateTime? _lastLineageCheckAt;

  KinshipRepository(this._appDb) : _animalRepository = null;

  KinshipRepository.fromAnimalRepository(this._animalRepository)
      : _appDb = null;

  bool get _supportsLineageTable => _appDb != null;

  Future<void> ensureLineageIsFresh() async {
    if (!_supportsLineageTable) return;

    final now = DateTime.now();
    if (_lastLineageCheckAt != null &&
        now.difference(_lastLineageCheckAt!) < _lineageRefreshDebounce) {
      return;
    }
    _lastLineageCheckAt = now;

    await _ensureLineageTables();
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
    if (!_supportsLineageTable) return false;
    await _ensureSettingsTable();
    final value = await _getSettingValue(_blockCousinBreedingKey);
    if (value == null) return false;
    final normalized = value.trim().toLowerCase();
    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'on';
  }

  Future<void> setBlockCousinBreedingEnabled(bool enabled) async {
    if (!_supportsLineageTable) return;
    await _ensureSettingsTable();
    await _appDb!.db.insert(
      'app_settings',
      {
        'setting_key': _blockCousinBreedingKey,
        'setting_value': enabled ? '1' : '0',
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
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

    final rows = await _appDb!.db.rawQuery(
      '''
      SELECT MIN(depth) AS depth
      FROM animal_lineage
      WHERE descendant_id = ? AND ancestor_id = ?
      ''',
      [descendantId, ancestorId],
    );
    if (rows.isEmpty) return null;

    final value = rows.first['depth'];
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

    final rows = await _appDb!.db.rawQuery(
      '''
      SELECT DISTINCT l1.ancestor_id AS ancestor_id
      FROM animal_lineage l1
      JOIN animal_lineage l2
        ON l2.ancestor_id = l1.ancestor_id
      WHERE l1.descendant_id = ?
        AND l2.descendant_id = ?
        AND l1.depth = 1
        AND l2.depth = 1
      ''',
      [leftDescendantId, rightDescendantId],
    );

    return rows
        .map((row) => row['ancestor_id']?.toString() ?? '')
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

    final rows = await _appDb!.db.rawQuery(
      '''
      SELECT DISTINCT l1.ancestor_id AS ancestor_id
      FROM animal_lineage l1
      JOIN animal_lineage l2
        ON l2.ancestor_id = l1.ancestor_id
      WHERE l1.descendant_id = ?
        AND l2.descendant_id = ?
        AND l1.depth = 2
        AND l2.depth = 2
      ''',
      [leftDescendantId, rightDescendantId],
    );

    return rows
        .map((row) => row['ancestor_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<Map<String, KinshipAnimalRef>> _getAnimalRefsByIdsFromDb(
    Set<String> ids,
  ) async {
    final db = _appDb!.db;
    final idList = ids.toList(growable: false);
    final placeholders = List.filled(idList.length, '?').join(',');

    final refs = <String, KinshipAnimalRef>{};
    for (final table in const ['animals', 'sold_animals', 'deceased_animals']) {
      final rows = await db.query(
        table,
        columns: ['id', 'code', 'name', 'mother_id', 'father_id'],
        where: 'id IN ($placeholders)',
        whereArgs: idList,
      );
      for (final row in rows) {
        final ref = KinshipAnimalRef.fromMap(row);
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
    final descendant = graph.refsById[descendantId];
    if (descendant == null) return null;

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

  Future<void> _ensureLineageTables() async {
    final db = _appDb!.db;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS animal_lineage (
        descendant_id TEXT NOT NULL,
        ancestor_id TEXT NOT NULL,
        depth INTEGER NOT NULL CHECK (depth > 0),
        line_type TEXT NOT NULL DEFAULT 'unknown'
          CHECK (line_type IN ('maternal','paternal','mixed','unknown')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        PRIMARY KEY (descendant_id, ancestor_id)
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS animal_lineage_meta (
        meta_key TEXT PRIMARY KEY,
        meta_value TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_animal_lineage_descendant ON animal_lineage(descendant_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_animal_lineage_ancestor ON animal_lineage(ancestor_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_animal_lineage_depth ON animal_lineage(depth);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_animal_lineage_desc_depth ON animal_lineage(descendant_id, depth);',
    );
  }

  Future<void> _ensureSettingsTable() async {
    final db = _appDb!.db;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');
    await db.insert(
      'app_settings',
      {
        'setting_key': _blockCousinBreedingKey,
        'setting_value': '1',
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<String?> _getMetaValue(String key) async {
    final rows = await _appDb!.db.query(
      'animal_lineage_meta',
      columns: ['meta_value'],
      where: 'meta_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['meta_value']?.toString();
  }

  Future<String?> _getSettingValue(String key) async {
    final rows = await _appDb!.db.query(
      'app_settings',
      columns: ['setting_value'],
      where: 'setting_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['setting_value']?.toString();
  }

  Future<String> _computeSourceSignature() async {
    final rows = await _appDb!.db.rawQuery('''
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
        SELECT id, code, mother_id, father_id, updated_at FROM animals
        UNION ALL
        SELECT id, code, mother_id, father_id, updated_at FROM sold_animals
        UNION ALL
        SELECT id, code, mother_id, father_id, updated_at FROM deceased_animals
      ) src
    ''');

    final row = rows.first;
    final count = row['source_count']?.toString() ?? '0';
    final maxUpdated = row['max_updated_at']?.toString() ?? '';
    final hash = row['source_hash']?.toString() ?? '0';
    return '$count|$maxUpdated|$hash';
  }

  Future<List<KinshipAnimalRef>> _loadAllRefs(DatabaseExecutor db) async {
    final rows = await db.rawQuery('''
      SELECT id, code, name, mother_id, father_id FROM animals
      UNION ALL
      SELECT id, code, name, mother_id, father_id FROM sold_animals
      UNION ALL
      SELECT id, code, name, mother_id, father_id FROM deceased_animals
    ''');

    final refs = <String, KinshipAnimalRef>{};
    for (final row in rows) {
      final ref = KinshipAnimalRef.fromMap(row);
      if (ref.id.isEmpty) continue;
      refs.putIfAbsent(ref.id, () => ref);
    }
    return refs.values.toList(growable: false);
  }

  Future<void> _rebuildLineage(String sourceSignature) async {
    final db = _appDb!.db;
    final nowIso = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      final refs = await _loadAllRefs(txn);
      final refsById = <String, KinshipAnimalRef>{for (final r in refs) r.id: r};
      final resolver = _ParentRefResolver.fromRefs(refs);

      await txn.delete('animal_lineage');

      final batch = txn.batch();
      for (final descendant in refs) {
        final entries = _buildAncestorEntries(
          descendant: descendant,
          refsById: refsById,
          resolver: resolver,
        );
        for (final entry in entries) {
          batch.insert(
            'animal_lineage',
            {
              'descendant_id': descendant.id,
              'ancestor_id': entry.ancestorId,
              'depth': entry.depth,
              'line_type': entry.lineType,
              'created_at': nowIso,
              'updated_at': nowIso,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      await batch.commit(noResult: true);

      await txn.insert(
        'animal_lineage_meta',
        {
          'meta_key': _metaSourceSignatureKey,
          'meta_value': sourceSignature,
          'updated_at': nowIso,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'animal_lineage_meta',
        {
          'meta_key': _metaLastRebuildAtKey,
          'meta_value': nowIso,
          'updated_at': nowIso,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
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
        queue.add(
          _QueueNode(
            ancestorId: ancestorMotherId,
            depth: node.depth + 1,
            lineType: node.lineType,
          ),
        );
      }

      final ancestorFatherId = resolver.resolve(ancestorRef.fatherId);
      if (ancestorFatherId != null) {
        queue.add(
          _QueueNode(
            ancestorId: ancestorFatherId,
            depth: node.depth + 1,
            lineType: node.lineType,
          ),
        );
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
