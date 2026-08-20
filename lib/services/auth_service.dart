import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/drift/app_database.dart';

/// Gerencia autenticação Supabase + cache local de farm_id.
///
/// Fluxo de startup:
///   1. Lê SecureStorage (< 20ms, sem isolate) — libera UI com estado correto.
///   2. Se vazio, fallback para Drift + migra para SecureStorage.
///   3. Sessão Supabase restaurada em background sem bloquear o primeiro frame.
class AuthService extends ChangeNotifier {
  final AppDriftDatabase _db;
  // SecureStorage: leitura < 20ms sem isolate — ideal para startup rápido.
  static const _ss = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _kFarmId = 'auth_farm_id';
  static const _kFarmName = 'auth_farm_name';
  static const _kUserId = 'auth_user_id';

  String? _cachedFarmId;
  String? _cachedFarmName;
  String? _cachedUserId;
  bool _loading = true;
  bool _isOfflineMode = false;
  Future<void>? _supabaseReady;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  AuthService(this._db);

  bool get isLoading => _loading;
  String? get currentFarmId => _cachedFarmId;
  String? get currentFarmName => _cachedFarmName;
  String? get currentUserId => _cachedUserId;

  /// True quando o usuário está autenticado apenas com dados locais (offline).
  /// O sync ficará desabilitado até a sessão Supabase ser restaurada.
  bool get isOfflineMode => _isOfflineMode;

  /// Autenticado se tiver farm_id local — não exige sessão Supabase ativa,
  /// permitindo uso offline quando a sessão expirou sem internet disponível.
  bool get isAuthenticated => _cachedFarmId != null;

  /// Chama no bootstrap antes do primeiro frame.
  ///
  /// [supabaseReady] é o Future que resolve quando Supabase.initialize() termina.
  ///
  /// Fluxo:
  ///   1. Lê banco local (Drift) — rápido após fix v7 do beforeOpen (< 100 ms).
  ///   2. Libera a UI com o estado local correto — sem flash de tela de login.
  ///   3. Restaura sessão Supabase em background sem bloquear o primeiro frame.
  Future<void> initialize({Future<void>? supabaseReady}) async {
    _supabaseReady = supabaseReady;
    final startupWatch = Stopwatch()..start();
    _debugStartupLog(startupWatch, 'initialize:start');

    // SecureStorage: leitura < 20ms, sem isolate, sem SQLite.
    // O primeiro frame constrói o splash enquanto isso roda.
    await _readLocalState();
    _debugStartupLog(startupWatch, 'local_state:loaded');

    _loading = false;
    notifyListeners();
    _debugStartupLog(startupWatch, 'release_ui:authenticated=${_cachedFarmId != null}');

    // Restaura sessão Supabase em background — não bloqueia o primeiro frame.
    if (_cachedFarmId != null) {
      unawaited(_restoreSessionInBackground(supabaseReady: supabaseReady));
    } else {
      unawaited(
        _resolveUnauthenticatedBootstrapInBackground(
          supabaseReady: supabaseReady,
        ),
      );
    }
    _debugStartupLog(startupWatch, 'initialize:done');
  }

  /// Lê estado local priorizando SecureStorage (< 20 ms, sem isolate).
  /// Fallback para Drift para usuários que ainda não migraram.
  Future<void> _readLocalState() async {
    // Fast path: SecureStorage — não abre isolate, não abre SQLite.
    try {
      final farmId = (await _ss.read(key: _kFarmId))?.trim();
      if (farmId != null && farmId.isNotEmpty) {
        _cachedFarmId = farmId;
        _cachedFarmName = await _ss.read(key: _kFarmName);
        _cachedUserId = await _ss.read(key: _kUserId);
        _isOfflineMode = true;
        return;
      }
    } catch (e) {
      debugPrint('AuthService._readLocalState secure_storage error: $e');
    }

    // Slow fallback: Drift (abre isolate + SQLite na primeira chamada).
    // Só chega aqui em instalações que ainda não gravaram no SecureStorage.
    try {
      final farmId = (await _readLocalFarmId())?.trim();
      if (farmId == null || farmId.isEmpty) return;
      _cachedFarmId = farmId;
      _cachedFarmName = await _readLocalFarmName();
      _cachedUserId = await _readLocalUserId();
      _isOfflineMode = true;
      // Migra para SecureStorage — próximo cold start será rápido.
      unawaited(_migrateSessionToSecureStorage(farmId, _cachedUserId, _cachedFarmName));
    } catch (e) {
      debugPrint('AuthService._readLocalState drift fallback error: $e');
    }
  }

  Future<void> _migrateSessionToSecureStorage(
    String farmId,
    String? userId,
    String? farmName,
  ) async {
    try {
      await _ss.write(key: _kFarmId, value: farmId);
      if (userId != null) await _ss.write(key: _kUserId, value: userId);
      if (farmName != null) await _ss.write(key: _kFarmName, value: farmName);
    } catch (e) {
      debugPrint('AuthService._migrateSessionToSecureStorage error: $e');
    }
  }

  /// Tenta restaurar sessão Supabase em background após o fast path.
  Future<void> _restoreSessionInBackground({
    Future<void>? supabaseReady,
  }) async {
    try {
      await (supabaseReady ?? _supabaseReady ?? Future<void>.value());
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        _cachedUserId = session.user.id;
        _isOfflineMode = false;
        notifyListeners();
        return;
      }
      _startOfflineConnectivityListener();
    } catch (_) {
      _startOfflineConnectivityListener();
    }
  }

  Future<void> _resolveUnauthenticatedBootstrapInBackground({
    Future<void>? supabaseReady,
  }) async {
    try {
      await (supabaseReady ?? _supabaseReady ?? Future<void>.value());
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        _cachedUserId = session.user.id;
        _cachedFarmId = await _readLocalFarmId();
        _cachedFarmName = await _readLocalFarmName();

        if (_cachedFarmId == null) {
          final context = await _fetchFarmContextFromSupabase(session.user.id);
          if (context != null) {
            _cachedFarmId = context.farmId;
            _cachedFarmName = context.farmName;
            await _saveLocalFarmContext(
              context.farmId,
              session.user.id,
              farmName: context.farmName,
            );
          }
        }

        if (_cachedFarmId != null &&
            (_cachedFarmName == null || _cachedFarmName!.trim().isEmpty)) {
          unawaited(
            _refreshFarmNameInBackground(
              userId: session.user.id,
              currentFarmId: _cachedFarmId!,
            ),
          );
        }
        notifyListeners();
        return;
      }
    } catch (_) {
      // Falhas de infraestrutura não bloqueiam a tela de login.
    }
  }

  /// Login com email e senha.
  Future<void> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();

    try {
      await (_supabaseReady ?? Future<void>.value());
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Login falhou — usuário não encontrado.');

      _cachedUserId = user.id;

      final context = await _fetchFarmContextFromSupabase(user.id);
      if (context == null) {
        throw Exception(
          'Nenhuma fazenda associada a este usuário. '
          'Entre em contato com o administrador.',
        );
      }

      _cachedFarmId = context.farmId;
      _cachedFarmName = context.farmName;
      await _saveLocalFarmContext(
        context.farmId,
        user.id,
        farmName: context.farmName,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  /// Quando em modo offline, aguarda a rede voltar e reautentica silenciosamente.
  void _startOfflineConnectivityListener() {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      (results) async {
        final online = results.any((r) => r != ConnectivityResult.none);
        if (!online || !_isOfflineMode) return;
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          _cachedUserId = session.user.id;
          _isOfflineMode = false;
          _connectivitySub?.cancel();
          _connectivitySub = null;
          notifyListeners();
        }
      },
    );
  }

  /// Logout — encerra sessão Supabase e limpa a sessão local.
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    await _clearLocalSession();
    _cachedFarmId = null;
    _cachedFarmName = null;
    _cachedUserId = null;
    notifyListeners();
  }

  /// Alias semântico para fluxos de "trocar conta".
  Future<void> signOutAndForgetCredentials() async {
    await signOut();
  }

  void _debugStartupLog(Stopwatch watch, String message) {
    if (!kDebugMode) return;
    debugPrint('AUTH_STARTUP +${watch.elapsedMilliseconds}ms $message');
  }

  Future<_FarmContext?> _fetchFarmContextFromSupabase(String userId) async {
    try {
      final farmUserRows = List<Map<String, dynamic>>.from(
        await Supabase.instance.client
          .from('farm_users')
          .select()
          .eq('user_id', userId)
          .limit(1)
          .timeout(const Duration(seconds: 4)),
      );

      if (farmUserRows.isEmpty) return null;
      final farmUser = farmUserRows.first;
      final farmId = farmUser['farm_id']?.toString().trim();
      if (farmId == null || farmId.isEmpty) return null;

      final inlineName = _extractFarmName(farmUser);
      final farmName = inlineName ?? await _fetchFarmNameById(farmId);
      return _FarmContext(
        farmId: farmId,
        farmName: farmName,
      );
    } catch (e) {
      debugPrint('Erro ao buscar contexto da fazenda: $e');
      return null;
    }
  }

  Future<String?> _fetchFarmNameById(String farmId) async {
    try {
      final farmRows = List<Map<String, dynamic>>.from(
        await Supabase.instance.client
            .from('farms')
            .select()
            .eq('id', farmId)
            .limit(1)
            .timeout(const Duration(seconds: 4)),
      );
      if (farmRows.isEmpty) return null;
      return _extractFarmName(farmRows.first);
    } catch (e) {
      // Nem todos os projetos expõem a tabela/colunas de fazenda da mesma forma.
      debugPrint('Erro ao buscar nome da fazenda: $e');
      return null;
    }
  }

  String? _extractFarmName(Map<String, dynamic> row) {
    for (final key in const ['farm_name', 'name', 'nome', 'title']) {
      final value = row[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }

    final nestedCandidates = [row['farm'], row['farms'], row['fazenda']];
    for (final candidate in nestedCandidates) {
      if (candidate is Map) {
        final nested = _extractFarmName(Map<String, dynamic>.from(candidate));
        if (nested != null) return nested;
      }
      if (candidate is List && candidate.isNotEmpty) {
        final first = candidate.first;
        if (first is Map) {
          final nested = _extractFarmName(Map<String, dynamic>.from(first));
          if (nested != null) return nested;
        }
      }
    }

    return null;
  }

  Future<void> _refreshFarmNameInBackground({
    required String userId,
    required String currentFarmId,
  }) async {
    final context = await _fetchFarmContextFromSupabase(userId);
    if (context == null || context.farmId != currentFarmId) return;
    final remoteName = context.farmName?.trim();
    if (remoteName == null || remoteName.isEmpty) return;
    if (_cachedFarmName == remoteName) return;

    _cachedFarmName = remoteName;
    await _saveLocalFarmContext(
      currentFarmId,
      userId,
      farmName: remoteName,
    );
    notifyListeners();
  }

  Future<String?> _readLocalUserId() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.settingKey.equals('current_user_id')))
        .getSingleOrNull();
    return row?.settingValue;
  }

  Future<String?> _readLocalFarmName() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.settingKey.equals('current_farm_name')))
        .getSingleOrNull();
    final value = row?.settingValue.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<String?> _readLocalFarmId() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.settingKey.equals('current_farm_id')))
        .getSingleOrNull();
    return row?.settingValue;
  }

  Future<void> _saveLocalFarmContext(
    String farmId,
    String userId, {
    String? farmName,
  }) async {
    // SecureStorage: leitura rápida no próximo cold start.
    try {
      await _ss.write(key: _kFarmId, value: farmId);
      await _ss.write(key: _kUserId, value: userId);
      final trimmedName = farmName?.trim();
      if (trimmedName != null && trimmedName.isNotEmpty) {
        await _ss.write(key: _kFarmName, value: trimmedName);
      }
    } catch (e) {
      debugPrint('AuthService._saveLocalFarmContext secure_storage error: $e');
    }

    // Drift: necessário para sync (farm_id usado em queries de sincronização).
    final now = DateTime.now();
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        settingKey: const Value('current_farm_id'),
        settingValue: Value(farmId),
        updatedAt: Value(now),
      ),
    );
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        settingKey: const Value('current_user_id'),
        settingValue: Value(userId),
        updatedAt: Value(now),
      ),
    );
    final trimmedName = farmName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      await _db.into(_db.appSettings).insertOnConflictUpdate(
        AppSettingsCompanion(
          settingKey: const Value('current_farm_name'),
          settingValue: Value(trimmedName),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Future<void> _clearLocalSession() async {
    try {
      await _ss.delete(key: _kFarmId);
      await _ss.delete(key: _kFarmName);
      await _ss.delete(key: _kUserId);
    } catch (e) {
      debugPrint('AuthService._clearLocalSession secure_storage error: $e');
    }
    await (_db.delete(_db.appSettings)
          ..where((s) => s.settingKey.isIn([
                'current_farm_id',
                'current_farm_name',
                'current_user_id',
              ])))
        .go();
  }
}

class _FarmContext {
  final String farmId;
  final String? farmName;

  const _FarmContext({
    required this.farmId,
    required this.farmName,
  });
}
