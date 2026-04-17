import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/drift/app_database.dart';

/// Gerencia autenticação Supabase + cache local de farm_id.
///
/// Fluxo:
///   1. Primeiro login → online obrigatório → busca farm_id no Supabase
///      → salva em app_settings (Drift) + credenciais no keystore seguro
///   2. Acessos seguintes → sessão em cache do supabase_flutter (offline OK)
///   3. Se sessão expirou → tenta auto-login silencioso com credenciais salvas
///   4. Só mostra tela de login se credenciais nunca foram salvas ou são inválidas
class AuthService extends ChangeNotifier {
  final AppDriftDatabase _db;
  final FlutterSecureStorage _secureStorage;

  static const _keyEmail = 'saved_email';
  static const _keyPassword = 'saved_password';

  String? _cachedFarmId;
  String? _cachedUserId;
  bool _loading = true;
  bool _isOfflineMode = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  AuthService(this._db)
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  bool get isLoading => _loading;
  String? get currentFarmId => _cachedFarmId;
  String? get currentUserId => _cachedUserId;

  /// True quando o usuário está autenticado apenas com dados locais (offline).
  /// O sync ficará desabilitado até a sessão Supabase ser restaurada.
  bool get isOfflineMode => _isOfflineMode;

  /// Autenticado se tiver farm_id local — não exige sessão Supabase ativa,
  /// permitindo uso offline quando a sessão expirou sem internet disponível.
  bool get isAuthenticated => _cachedFarmId != null;

  /// Chama no bootstrap — restaura sessão do cache local ou faz auto-login.
  Future<void> initialize() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // Sessão Supabase ainda válida — restaura dados locais
        _cachedUserId = session.user.id;
        _cachedFarmId = await _readLocalFarmId();
      } else {
        // Sessão expirada ou app instalado/limpo — tenta auto-login online
        final autoLoginOk = await _tryAutoLogin();

        if (!autoLoginOk) {
          // Sem internet ou credenciais inválidas — usa identidade local para
          // permitir uso offline com dados já cacheados no SQLite.
          final localFarmId = await _readLocalFarmId();
          final localUserId = await _readLocalUserId();
          if (localFarmId != null && localUserId != null) {
            _cachedFarmId = localFarmId;
            _cachedUserId = localUserId;
            _isOfflineMode = true;
            _startOfflineConnectivityListener();
          }
        }
      }
    } catch (e) {
      debugPrint('AuthService.initialize error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Tenta fazer login silencioso com credenciais salvas.
  /// Retorna true se conseguiu, false caso contrário.
  Future<bool> _tryAutoLogin() async {
    try {
      final email = await _secureStorage.read(key: _keyEmail);
      final password = await _secureStorage.read(key: _keyPassword);

      if (email == null || password == null) return false;

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return false;

      _cachedUserId = user.id;

      var farmId = await _readLocalFarmId();
      farmId ??= await _fetchFarmIdFromSupabase(user.id);

      if (farmId == null) return false;

      _cachedFarmId = farmId;
      await _saveLocalFarmId(farmId, user.id);
      return true;
    } catch (e) {
      debugPrint('AuthService._tryAutoLogin error: $e');
      return false;
    }
  }

  /// Login com email e senha.
  Future<void> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Login falhou — usuário não encontrado.');

      _cachedUserId = user.id;

      final farmId = await _fetchFarmIdFromSupabase(user.id);
      if (farmId == null) {
        throw Exception(
          'Nenhuma fazenda associada a este usuário. '
          'Entre em contato com o administrador.',
        );
      }

      _cachedFarmId = farmId;
      await _saveLocalFarmId(farmId, user.id);

      // Salva credenciais para auto-login futuro
      await _saveCredentials(email.trim(), password);
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
        final ok = await _tryAutoLogin();
        if (ok) {
          _isOfflineMode = false;
          _connectivitySub?.cancel();
          _connectivitySub = null;
          notifyListeners();
        }
      },
    );
  }

  /// Logout — encerra sessão Supabase mas mantém credenciais salvas.
  /// Na próxima abertura do app o auto-login é feito silenciosamente.
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    await _clearLocalSession();
    _cachedFarmId = null;
    _cachedUserId = null;
    notifyListeners();
  }

  /// Logout completo — remove também as credenciais salvas.
  /// Use apenas quando o usuário quiser trocar de conta.
  Future<void> signOutAndForgetCredentials() async {
    await signOut();
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyPassword);
  }

  /// Verifica se há credenciais salvas (para UX de "trocar conta").
  Future<bool> hasSavedCredentials() async {
    final email = await _secureStorage.read(key: _keyEmail);
    return email != null;
  }

  /// Retorna o e-mail salvo (para exibir na tela de login se necessário).
  Future<String?> getSavedEmail() async {
    return _secureStorage.read(key: _keyEmail);
  }

  // ── privados ───────────────────────────────────────────────

  Future<void> _saveCredentials(String email, String password) async {
    await _secureStorage.write(key: _keyEmail, value: email);
    await _secureStorage.write(key: _keyPassword, value: password);
  }

  Future<String?> _fetchFarmIdFromSupabase(String userId) async {
    try {
      final rows = await Supabase.instance.client
          .from('farm_users')
          .select('farm_id')
          .eq('user_id', userId)
          .limit(1);

      if (rows.isEmpty) return null;
      return rows.first['farm_id'] as String?;
    } catch (e) {
      debugPrint('Erro ao buscar farm_id: $e');
      return null;
    }
  }

  Future<String?> _readLocalUserId() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.settingKey.equals('current_user_id')))
        .getSingleOrNull();
    return row?.settingValue;
  }

  Future<String?> _readLocalFarmId() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.settingKey.equals('current_farm_id')))
        .getSingleOrNull();
    return row?.settingValue;
  }

  Future<void> _saveLocalFarmId(String farmId, String userId) async {
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
  }

  Future<void> _clearLocalSession() async {
    await (_db.delete(_db.appSettings)
          ..where((s) =>
              s.settingKey.isIn(['current_farm_id', 'current_user_id'])))
        .go();
  }
}
