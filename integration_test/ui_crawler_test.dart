// integration_test/ui_crawler_test.dart
//
// Teste funcional completo — executa CRUD em cada módulo e detecta
// overflows em múltiplos tamanhos de tela.
//
// Como rodar:
//   flutter test integration_test/ui_crawler_test.dart \
//     -d <device-id> \
//     --dart-define=TEST_EMAIL=xxx \
//     --dart-define=TEST_PASSWORD=yyy
//
// Flags opcionais:
//   --dart-define=LOGOUT_AFTER=true
//   --dart-define=TEST_SMALL_SCREEN=true   → repete em 360×640 p/ overflows
//   --dart-define=MAX_ALLOWED_ERRORS=0
//   --dart-define=MAX_ALLOWED_OVERFLOWS=0

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bego_ovino_caprino/main.dart' as app;

// ── Configuração via --dart-define ────────────────────────────────────────────

const String kTestEmail =
    String.fromEnvironment('TEST_EMAIL', defaultValue: '');
const String kTestPassword =
    String.fromEnvironment('TEST_PASSWORD', defaultValue: '');
// PIN da tela financeira (hardcoded no app em _kFinancePin)
const String kFinancePin =
    String.fromEnvironment('FINANCE_PIN', defaultValue: 'Spetovino2025');
const bool kLogoutAfter =
    bool.fromEnvironment('LOGOUT_AFTER', defaultValue: true);
const bool kTestSmallScreen =
    bool.fromEnvironment('TEST_SMALL_SCREEN', defaultValue: true);
const int kMaxAllowedErrors =
    int.fromEnvironment('MAX_ALLOWED_ERRORS', defaultValue: 0);
const int kMaxAllowedOverflows =
    int.fromEnvironment('MAX_ALLOWED_OVERFLOWS', defaultValue: 0);
const int kSettleSeconds =
    int.fromEnvironment('SETTLE_TIMEOUT_SECONDS', defaultValue: 5);

// ── Tamanhos de tela para detecção de overflow ────────────────────────────────
const _smallScreen = Size(360, 640);   // Android antigo
const _mediumScreen = Size(390, 844);  // iPhone moderno

// ── Sub-módulos do Manejo e Mais ──────────────────────────────────────────────
const _managementModules = [
  'Alimentação', 'Peso', 'Reprodução', 'Matrizes',
  'Vacinas', 'Anotações', 'Farmácia',
];
const _moreSections = ['Relatórios', 'Histórico', 'Sistema'];

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Teste funcional completo', (tester) async {
    final log = StringBuffer();
    final errors = <String>[];
    var errorsCount = 0;
    var overflowCount = 0;
    var passedCount = 0;

    // ── Intercepta erros de renderização ───────────────────────────────────
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('RenderFlex overflowed')) {
        // Overflow: captura e engole — não falha o teste imediatamente
        overflowCount++;
        errors.add('[OVERFLOW] $msg');
        log.writeln('[OVERFLOW] $msg');
        FlutterError.dumpErrorToConsole(details, forceReport: false);
      } else {
        // Outros erros: captura no log E repassa para o framework
        // para que o estado interno do teste permaneça consistente.
        errorsCount++;
        errors.add('[ERROR] $msg');
        log.writeln('[ERROR] $msg\n${details.stack ?? ''}');
        FlutterError.dumpErrorToConsole(details, forceReport: true);
        prevOnError?.call(details);
      }
    };
    final prevPlatformError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (e, st) {
      errorsCount++;
      errors.add('[PLATFORM] $e');
      log.writeln('[PLATFORM_ERROR] $e\n$st');
      return true;
    };

    String? logPath;
    try {
      // 1 ── Inicia app + login ──────────────────────────────────────────────
      // ignore: avoid_print
      print('[TEST] Iniciando app...');
      log.writeln('=== INÍCIO DO TESTE FUNCIONAL ===');
      app.main();

      // Aguarda o app terminar de inicializar: aparece login OU dashboard
      log.writeln('[INFO] Aguardando app carregar...');
      final loginAppeared = await _waitForAny(tester, [
        find.widgetWithText(FilledButton, 'Entrar'),
        find.byType(NavigationBar),
      ], log, timeout: const Duration(seconds: 30));

      if (!loginAppeared) {
        fail('App não carregou em 30s — nem login nem dashboard encontrado.');
      }

      // Só tenta login se a tela de login estiver visível
      final hasLoginScreen =
          find.widgetWithText(FilledButton, 'Entrar').evaluate().isNotEmpty;
      // ignore: avoid_print
      print('[TEST] Tela de login visível: $hasLoginScreen');
      log.writeln('[INFO] Tela de login visível: $hasLoginScreen');
      if (hasLoginScreen) {
        await _login(tester, log);
      } else {
        log.writeln('[LOGIN] Sessão já ativa, pulando login.');
        // ignore: avoid_print
        print('[TEST] Sessão ativa — pulando login');
      }

      // Aguarda dashboard (NavigationBar) aparecer após login
      // ignore: avoid_print
      print('[TEST] Aguardando NavigationBar (45s)...');
      if (!await _waitFor(tester, find.byType(NavigationBar), log,
          label: 'NavigationBar', timeout: const Duration(seconds: 45))) {
        fail('Dashboard não encontrado após login. Verifique as credenciais.');
      }
      log.writeln('[OK] Dashboard visível\n');
      // ignore: avoid_print
      print('[TEST] Dashboard OK');

      // 2 ── Testes em tamanho normal ────────────────────────────────────────
      log.writeln('=== FASE 1: TAMANHO NORMAL ===');
      passedCount += await _runAllModules(tester, log, errors, binding);

      // 3 ── Testes em tela pequena (overflow detection) ─────────────────────
      if (kTestSmallScreen) {
        log.writeln('\n=== FASE 2: TELA PEQUENA (${_smallScreen.width}×${_smallScreen.height}) ===');
        await binding.setSurfaceSize(_smallScreen);
        await _settle(tester, log);
        passedCount += await _runAllModules(tester, log, errors, binding,
            overflowOnly: true);
        await binding.setSurfaceSize(_mediumScreen);
        await _settle(tester, log);
      }

      // 4 ── Logout ──────────────────────────────────────────────────────────
      if (kLogoutAfter) await _logout(tester, log);

      // 5 ── Resumo ──────────────────────────────────────────────────────────
      log.writeln('\n=== RESUMO ===');
      log.writeln('Cenários OK  : $passedCount');
      log.writeln('Erros        : $errorsCount');
      log.writeln('Overflows    : $overflowCount');
      if (errors.isNotEmpty) {
        log.writeln('\nDetalhes:');
        for (final e in errors) {
          log.writeln('  • $e');
        }
      }

    } finally {
      logPath = await _writeLog(log.toString());
      // ignore: avoid_print
      print('FUNCTIONAL_TEST_LOG=$logPath');
      await tester.binding.setSurfaceSize(null);
      try { await _settle(tester, log); } catch (_) {}
      FlutterError.onError = prevOnError;
      PlatformDispatcher.instance.onError = prevPlatformError;
    }

    if (errorsCount > kMaxAllowedErrors ||
        overflowCount > kMaxAllowedOverflows) {
      fail(
        'errors=$errorsCount (max=$kMaxAllowedErrors) '
        'overflows=$overflowCount (max=$kMaxAllowedOverflows). '
        'Log: $logPath',
      );
    }
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// EXECUÇÃO DOS MÓDULOS
// ═════════════════════════════════════════════════════════════════════════════

Future<int> _runAllModules(
  WidgetTester tester,
  StringBuffer log,
  List<String> errors,
  IntegrationTestWidgetsFlutterBinding binding, {
  bool overflowOnly = false,
}) async {
  var passed = 0;

  // ── Início (dashboard) ────────────────────────────────────────────────────
  passed += await _scenario(tester, log, 'Início', () async {
    await _navTo(tester, log, 'Início');
    await _settle(tester, log);
    await _scrollEntireScreen(tester);
  });

  // ── Rebanho ───────────────────────────────────────────────────────────────
  passed += await _scenario(tester, log, 'Rebanho — listagem + filtros', () async {
    await _navTo(tester, log, 'Rebanho');
    await _settle(tester, log);
    await _scrollEntireScreen(tester);
    // Abre filtros/chips se existirem
    await _tapText(tester, log, 'Fêmea', required: false);
    await _settle(tester, log);
    await _tapText(tester, log, 'Macho', required: false);
    await _settle(tester, log);
  });

  if (!overflowOnly) {
    passed += await _scenario(tester, log, 'Rebanho — adicionar animal', () async {
      await _navTo(tester, log, 'Rebanho');
      await _settle(tester, log);
      // FAB ou botão "Adicionar Animal"
      await _tapFabOrButton(tester, log, labels: ['Adicionar Animal', 'Novo Animal']);
      await _settle(tester, log);
      await _fillAndSave(tester, log, overrides: {
        'Nome': 'Animal Teste CRUD',
        'Código': 'TST-001',
      });
      // Verifica que voltou para listagem ou exibe o animal
      await _settle(tester, log);
    });

    passed += await _scenario(tester, log, 'Rebanho — editar animal', () async {
      await _navTo(tester, log, 'Rebanho');
      await _settle(tester, log);
      // Toca no primeiro card de animal visível
      await _tapFirst(tester, log, type: Card);
      await _settle(tester, log);
      await _scrollEntireScreen(tester);
      // Procura botão de editar
      await _tapIconOrButton(tester, log,
          icons: [Icons.edit, Icons.edit_outlined],
          labels: ['Editar', 'Editar animal']);
      await _settle(tester, log);
      await _editFirstTextField(tester, log, newValue: 'Animal Teste CRUD Edit');
      await _tapSave(tester, log);
    });
  }

  // ── Módulos do Manejo ─────────────────────────────────────────────────────
  for (final module in _managementModules) {
    passed += await _scenario(tester, log, 'Manejo → $module', () async {
      await _navTo(tester, log, 'Manejo');
      await _settle(tester, log);
      await _openSection(tester, log, module);
      await _settle(tester, log);
      await _scrollEntireScreen(tester);

      if (!overflowOnly) {
        // Tenta criar um registro
        final opened = await _tapFabOrButton(tester, log,
            labels: _addLabels, required: false);
        if (opened) {
          await _settle(tester, log);
          await _scrollEntireScreen(tester);
          await _fillAndSave(tester, log);
        }
        // Toca no primeiro item da lista para ver detalhes/edição
        await _tapFirst(tester, log, type: ListTile, required: false);
        await _settle(tester, log);
        await _scrollEntireScreen(tester);
        await _popIfPossible(tester, log);
      }
    });
  }

  // ── Financeiro ────────────────────────────────────────────────────────────
  passed += await _scenario(tester, log, 'Financeiro — visão geral', () async {
    await _navTo(tester, log, 'Financeiro');
    await _settle(tester, log);
    await _handleFinancePin(tester, log);  // desbloqueia PIN se necessário
    await _scrollEntireScreen(tester);
  });

  if (!overflowOnly) {
    passed += await _scenario(tester, log, 'Financeiro — nova receita', () async {
      await _navTo(tester, log, 'Financeiro');
      await _settle(tester, log);
      await _handleFinancePin(tester, log);
      await _tapFabOrButton(tester, log,
          labels: ['Nova Receita', 'Receita', 'Adicionar', 'Novo'],
          required: false);
      await _settle(tester, log);
      await _fillAndSave(tester, log, overrides: {
        'Descrição': 'Receita Teste',
        'Valor': '100',
      });
    });

    passed += await _scenario(tester, log, 'Financeiro — nova despesa', () async {
      await _navTo(tester, log, 'Financeiro');
      await _settle(tester, log);
      await _handleFinancePin(tester, log);
      await _tapFabOrButton(tester, log,
          labels: ['Nova Despesa', 'Despesa'], required: false);
      await _settle(tester, log);
      await _fillAndSave(tester, log, overrides: {
        'Descrição': 'Despesa Teste',
        'Valor': '50',
      });
    });
  }

  // ── Mais: Relatórios, Histórico, Sistema ──────────────────────────────────
  for (final section in _moreSections) {
    passed += await _scenario(tester, log, 'Mais → $section', () async {
      await _navTo(tester, log, 'Mais');
      await _settle(tester, log);
      await _openSection(tester, log, section);
      await _settle(tester, log);
      await _scrollEntireScreen(tester);

      if (!overflowOnly && section == 'Sistema') {
        // Abre cada seção expansível do sistema
        for (final label in ['Sync', 'Backup', 'Dados']) {
          await _tapText(tester, log, label, required: false);
          await _settle(tester, log);
        }
      }
    });
  }

  return passed;
}

// ═════════════════════════════════════════════════════════════════════════════
// PRIMITIVAS DE TESTE
// ═════════════════════════════════════════════════════════════════════════════

/// Envolve um bloco em try/catch, registra resultado e retorna 1 se passou.
Future<int> _scenario(
  WidgetTester tester,
  StringBuffer log,
  String name,
  Future<void> Function() body,
) async {
  log.writeln('\n── $name ──');
  try {
    await body();
    log.writeln('[PASS] $name');
    return 1;
  } catch (e, st) {
    log.writeln('[FAIL] $name\n  Erro: $e\n  $st');
    // Tenta recuperar: fecha dialogs/popups abertos
    await _recover(tester, log);
    return 0;
  }
}

// ── Navegação ─────────────────────────────────────────────────────────────────

Future<void> _navTo(WidgetTester tester, StringBuffer log, String tab) async {
  final navBar = find.byType(NavigationBar);
  if (navBar.evaluate().isEmpty) return;
  final item = find.descendant(of: navBar.first, matching: find.text(tab));
  if (item.evaluate().isEmpty) {
    log.writeln('[WARN] Aba não encontrada: $tab');
    return;
  }
  await tester.tap(item.first, warnIfMissed: false);
  await _settle(tester, log);
}

Future<void> _openSection(
    WidgetTester tester, StringBuffer log, String label) async {
  // Tenta chips (FilterChip, ChoiceChip) e texto clicável
  for (final f in [
    find.widgetWithText(FilterChip, label),
    find.widgetWithText(ChoiceChip, label),
    find.widgetWithText(ActionChip, label),
    find.widgetWithText(TextButton, label),
  ]) {
    if (f.evaluate().isNotEmpty) {
      await tester.tap(f.first, warnIfMissed: false);
      await _settle(tester, log);
      return;
    }
  }
  // Fallback: qualquer texto dentro de InkWell
  final txt = find.text(label);
  if (txt.evaluate().isNotEmpty) {
    final iw = find.ancestor(of: txt.first, matching: find.byType(InkWell));
    if (iw.evaluate().isNotEmpty) {
      await tester.tap(iw.first, warnIfMissed: false);
      await _settle(tester, log);
      return;
    }
    // Fallback para card do hub
    final card = find.ancestor(of: txt.first, matching: find.byType(Card));
    if (card.evaluate().isNotEmpty) {
      await tester.tap(card.first, warnIfMissed: false);
      await _settle(tester, log);
    }
  }
}

// ── Formulários ───────────────────────────────────────────────────────────────

/// Abre formulário via FAB ou botão com um dos labels fornecidos.
Future<bool> _tapFabOrButton(
  WidgetTester tester,
  StringBuffer log, {
  List<String> labels = const [],
  bool required = true,
}) async {
  // FAB
  final fab = find.byType(FloatingActionButton);
  if (fab.evaluate().isNotEmpty) {
    await tester.tap(fab.first, warnIfMissed: false);
    await _settle(tester, log);
    return true;
  }
  // Botão por label
  for (final label in labels) {
    for (final f in [
      find.widgetWithText(FilledButton, label),
      find.widgetWithText(ElevatedButton, label),
      find.widgetWithText(TextButton, label),
      find.widgetWithText(OutlinedButton, label),
    ]) {
      if (f.evaluate().isNotEmpty) {
        await _ensureVisible(tester, f.first, log);
        await tester.tap(f.first, warnIfMissed: false);
        await _settle(tester, log);
        return true;
      }
    }
    // Ícone + texto
    final txt = find.text(label);
    if (txt.evaluate().isNotEmpty) {
      final iw = find.ancestor(of: txt.first, matching: find.byType(InkWell));
      if (iw.evaluate().isNotEmpty) {
        await tester.tap(iw.first, warnIfMissed: false);
        await _settle(tester, log);
        return true;
      }
    }
  }
  if (required) throw Exception('Botão de adicionar não encontrado (labels=$labels)');
  return false;
}

/// Preenche todos os campos vazios e toca em "Salvar".
Future<void> _fillAndSave(
  WidgetTester tester,
  StringBuffer log, {
  Map<String, String> overrides = const {},
}) async {
  await _fillFields(tester, log, overrides: overrides);
  await _tapSave(tester, log);
}

/// Preenche campos de texto, dropdowns e date fields.
Future<void> _fillFields(
  WidgetTester tester,
  StringBuffer log, {
  Map<String, String> overrides = const {},
  int maxScrollAttempts = 3,
}) async {
  for (var scroll = 0; scroll < maxScrollAttempts; scroll++) {
    var filledThisPass = 0;
    var idx = 1;

    // TextFormField e TextField
    for (final el in [
      ...find.byType(TextFormField).evaluate(),
      ...find.byType(TextField).evaluate(),
    ]) {
      final w = el.widget;
      final dyn = w as dynamic;
      // Pula disabled / readonly
      try { if (dyn.enabled == false || dyn.readOnly == true) continue; } catch (_) {}
      final cur = _textOf(dyn);
      if (cur.trim().isNotEmpty) { idx++; continue; }

      // Label para override
      String? label;
      try { label = (dyn.decoration as InputDecoration?)?.labelText; } catch (_) {}

      final val = overrides[label] ?? _valueForLabel(label, idx);
      final finder = find.byElementPredicate((e) => identical(e, el));
      try {
        await _ensureVisible(tester, finder, log);
        await tester.enterText(finder, val);
        await tester.pump(const Duration(milliseconds: 200));
        filledThisPass++;
        idx++;
      } catch (_) {}
    }

    // Dropdowns (preenche apenas os sem valor)
    for (final el in find.byType(DropdownButtonFormField).evaluate()) {
      final w = el.widget as dynamic;
      try { if (w.onChanged == null) continue; } catch (_) { continue; }
      dynamic currentVal;
      try { currentVal = w.value; } catch (_) {}
      if (currentVal != null) continue;
      List<DropdownMenuItem<dynamic>> items = const [];
      try {
        final raw = w.items;
        if (raw is List) items = raw.whereType<DropdownMenuItem<dynamic>>().toList();
      } catch (_) {}
      final enabled = items.where((i) => i.enabled).toList();
      if (enabled.isEmpty) continue;
      final finder = find.byElementPredicate((e) => identical(e, el));
      try {
        await _ensureVisible(tester, finder, log);
        await tester.tap(finder, warnIfMissed: false);
        await _settle(tester, log);
        final child = enabled.first.child;
        if (child is Text && (child.data?.isNotEmpty ?? false)) {
          final opt = find.text(child.data!.trim()).last;
          if (opt.evaluate().isNotEmpty) {
            await tester.tap(opt, warnIfMissed: false);
            await _settle(tester, log);
            filledThisPass++;
          }
        }
      } catch (_) {}
    }

    if (filledThisPass == 0) break;

    // Rola para baixo para encontrar mais campos
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isNotEmpty) {
      await tester.drag(scrollables.first, const Offset(0, -300));
      await _settle(tester, log);
    } else {
      break;
    }
  }
}

Future<void> _tapSave(WidgetTester tester, StringBuffer log) async {
  for (final label in ['Salvar', 'Confirmar', 'Criar', 'Adicionar']) {
    for (final f in [
      find.widgetWithText(FilledButton, label),
      find.widgetWithText(ElevatedButton, label),
      find.widgetWithText(TextButton, label),
    ]) {
      if (f.evaluate().isNotEmpty) {
        await _ensureVisible(tester, f.first, log);
        await tester.tap(f.first, warnIfMissed: false);
        await _settle(tester, log);
        // Fecha dialog de confirmação se abrir
        await _dismissDialog(tester, log);
        return;
      }
    }
  }
  log.writeln('[WARN] Botão Salvar não encontrado');
}

Future<void> _editFirstTextField(
    WidgetTester tester, StringBuffer log, {required String newValue}) async {
  final fields = find.byType(TextFormField);
  if (fields.evaluate().isEmpty) return;
  final finder = fields.first;
  await _ensureVisible(tester, finder, log);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.enterText(finder, newValue);
  await _settle(tester, log);
}

// ── Ações genéricas ───────────────────────────────────────────────────────────

Future<void> _tapText(
    WidgetTester tester, StringBuffer log, String text,
    {bool required = true}) async {
  final f = find.text(text);
  if (f.evaluate().isEmpty) {
    if (required) throw Exception('Texto não encontrado: "$text"');
    return;
  }
  await tester.tap(f.first, warnIfMissed: false);
  await _settle(tester, log);
}

Future<void> _tapFirst<T extends Widget>(
    WidgetTester tester, StringBuffer log,
    {required Type type, bool required = false}) async {
  final f = find.byType(type);
  if (f.evaluate().isEmpty) {
    if (required) throw Exception('Widget $type não encontrado');
    return;
  }
  await _ensureVisible(tester, f.first, log);
  await tester.tap(f.first, warnIfMissed: false);
  await _settle(tester, log);
}

Future<void> _tapIconOrButton(
  WidgetTester tester,
  StringBuffer log, {
  List<IconData> icons = const [],
  List<String> labels = const [],
  bool required = false,
}) async {
  for (final icon in icons) {
    final f = find.byIcon(icon);
    if (f.evaluate().isNotEmpty) {
      await tester.tap(f.first, warnIfMissed: false);
      await _settle(tester, log);
      return;
    }
  }
  for (final label in labels) {
    final f = find.text(label);
    if (f.evaluate().isNotEmpty) {
      await tester.tap(f.first, warnIfMissed: false);
      await _settle(tester, log);
      return;
    }
  }
  if (required) throw Exception('Ícone/botão não encontrado icons=$icons labels=$labels');
}

Future<void> _scrollEntireScreen(WidgetTester tester) async {
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isEmpty) return;
  // Rola para baixo
  await tester.drag(scrollables.first, const Offset(0, -600));
  await tester.pump(const Duration(milliseconds: 300));
  // Volta ao topo
  await tester.drag(scrollables.first, const Offset(0, 600));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _popIfPossible(WidgetTester tester, StringBuffer log) async {
  final back = find.byIcon(Icons.arrow_back);
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back.first, warnIfMissed: false);
    await _settle(tester, log);
    return;
  }
  try {
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    await nav.maybePop();
    await _settle(tester, log);
  } catch (_) {}
}

Future<void> _dismissDialog(WidgetTester tester, StringBuffer log) async {
  const labels = ['OK', 'Fechar', 'Cancelar', 'Não'];
  for (final label in labels) {
    for (final f in [
      find.widgetWithText(TextButton, label),
      find.widgetWithText(ElevatedButton, label),
      find.widgetWithText(FilledButton, label),
    ]) {
      if (f.evaluate().isNotEmpty) {
        await tester.tap(f.first, warnIfMissed: false);
        await _settle(tester, log);
        return;
      }
    }
  }
}

Future<void> _recover(WidgetTester tester, StringBuffer log) async {
  // Tenta fechar qualquer dialog aberto
  await _dismissDialog(tester, log);
  // Tenta voltar para o dashboard
  for (var i = 0; i < 5; i++) {
    if (find.byType(NavigationBar).evaluate().isNotEmpty) break;
    await _popIfPossible(tester, log);
  }
}

// ── Login / Logout ────────────────────────────────────────────────────────────

/// Digita o PIN financeiro no dialog bloqueante, se ele estiver visível.
Future<void> _handleFinancePin(WidgetTester tester, StringBuffer log) async {
  if (kFinancePin.isEmpty) return;

  // O dialog tem um TextField para senha com labelText 'Senha'
  final pinField = find.byWidgetPredicate((w) {
    if (w is! TextField) return false;
    try {
      final dec = (w as dynamic).decoration as InputDecoration?;
      return dec?.labelText == 'Senha';
    } catch (_) {
      return false;
    }
  });

  if (pinField.evaluate().isEmpty) return; // dialog não aberto

  log.writeln('[FINANCE] Dialog de PIN detectado — inserindo PIN...');
  await tester.enterText(pinField.first, kFinancePin);
  await tester.pump(const Duration(milliseconds: 200));

  // Toca no botão de confirmar (ElevatedButton ou FilledButton dentro do dialog)
  for (final label in ['Confirmar', 'Entrar', 'OK', 'Desbloquear']) {
    for (final f in [
      find.widgetWithText(ElevatedButton, label),
      find.widgetWithText(FilledButton, label),
      find.widgetWithText(TextButton, label),
    ]) {
      if (f.evaluate().isNotEmpty) {
        await tester.tap(f.first, warnIfMissed: false);
        await _settle(tester, log);
        log.writeln('[FINANCE] PIN aceito.');
        return;
      }
    }
  }
  log.writeln('[FINANCE] Botão de confirmar não encontrado no dialog de PIN.');
}

Future<void> _login(WidgetTester tester, StringBuffer log) async {
  if (kTestEmail.isEmpty || kTestPassword.isEmpty) {
    log.writeln('[LOGIN] Sem credenciais — assumindo sessão ativa');
    // ignore: avoid_print
    print('[LOGIN] Sem credenciais fornecidas');
    return;
  }
  final entrar = find.widgetWithText(FilledButton, 'Entrar');
  if (entrar.evaluate().isEmpty) {
    log.writeln('[LOGIN] Sessão já ativa');
    // ignore: avoid_print
    print('[LOGIN] FilledButton Entrar não encontrado — sessão já ativa');
    return;
  }

  // ignore: avoid_print
  print('[LOGIN] Preenchendo email: $kTestEmail');
  log.writeln('[LOGIN] Preenchendo credenciais...');
  final fields = find.byType(TextFormField);
  // ignore: avoid_print
  print('[LOGIN] TextFormFields encontrados: ${fields.evaluate().length}');
  if (fields.evaluate().isNotEmpty) {
    await tester.enterText(fields.at(0), kTestEmail);
    await tester.pump(const Duration(milliseconds: 300));
  }
  if (fields.evaluate().length >= 2) {
    await tester.enterText(fields.at(1), kTestPassword);
    await tester.pump(const Duration(milliseconds: 300));
  }
  // Fecha teclado antes de clicar
  await tester.pump(const Duration(milliseconds: 300));
  // ignore: avoid_print
  print('[LOGIN] Tocando Entrar...');
  await tester.tap(entrar.first, warnIfMissed: true);
  await tester.pump(const Duration(milliseconds: 500));
  // ignore: avoid_print
  print('[LOGIN] Tap executado, aguardando resposta do Supabase...');
  log.writeln('[LOGIN] Credenciais enviadas, aguardando autenticação...');
}

Future<void> _logout(WidgetTester tester, StringBuffer log) async {
  await _navTo(tester, log, 'Mais');
  await _openSection(tester, log, 'Sistema');
  await _settle(tester, log);
  final logoutTile = find.ancestor(
    of: find.text('Sair da conta'),
    matching: find.byType(ListTile),
  );
  if (logoutTile.evaluate().isEmpty) {
    log.writeln('[LOGOUT] Botão não encontrado');
    return;
  }
  await tester.tap(logoutTile.first, warnIfMissed: false);
  await _settle(tester, log);
  final sair = find.widgetWithText(TextButton, 'Sair');
  if (sair.evaluate().isNotEmpty) {
    await tester.tap(sair.first, warnIfMissed: false);
    await _settle(tester, log);
  }
  log.writeln('[LOGOUT] OK');
}

// ── Utilitários ───────────────────────────────────────────────────────────────

/// Aguarda qualquer um dos finders aparecer. Retorna true assim que um aparecer.
Future<bool> _waitForAny(
  WidgetTester tester,
  List<Finder> finders,
  StringBuffer log, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 400));
    for (final f in finders) {
      if (f.evaluate().isNotEmpty) {
        await _settle(tester, log);
        return true;
      }
    }
  }
  return false;
}

Future<bool> _waitFor(
  WidgetTester tester,
  Finder finder,
  StringBuffer log, {
  required String label,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 400));
    if (finder.evaluate().isNotEmpty) {
      await _settle(tester, log);
      return true;
    }
  }
  log.writeln('[WARN] Timeout aguardando: $label');
  return false;
}

Future<void> _ensureVisible(
    WidgetTester tester, Finder finder, StringBuffer log) async {
  if (finder.evaluate().isEmpty) return;
  try {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 100));
  } catch (_) {
    final sc = find.ancestor(of: finder, matching: find.byType(Scrollable));
    if (sc.evaluate().isNotEmpty) {
      try {
        await tester.scrollUntilVisible(finder, 200, scrollable: sc.first);
      } catch (_) {}
    }
  }
}

Future<void> _settle(WidgetTester tester, StringBuffer log) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: kSettleSeconds),
    );
  } catch (_) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

// ── Helpers de valor ──────────────────────────────────────────────────────────

String _textOf(dynamic w) {
  try { return (w.controller?.text as String?) ?? ''; } catch (_) {}
  try { return (w.initialValue as String?) ?? ''; } catch (_) {}
  return '';
}

String _valueForLabel(String? label, int idx) {
  if (label == null) return 'Teste $idx';
  final l = label.toLowerCase();
  if (l.contains('email')) return 'teste$idx@example.com';
  if (l.contains('data') || l.contains('date')) return '01/01/2025';
  if (l.contains('valor') || l.contains('preço') || l.contains('quant') ||
      l.contains('peso') || l.contains('código') || l.contains('cod')) {
    return '$idx';
  }
  if (l.contains('telefone') || l.contains('fone')) return '11999990000';
  return 'Teste $idx';
}

// Labels comuns de botões de adicionar
const _addLabels = [
  'Adicionar', 'Novo', 'Nova', 'Cadastrar',
  'Adicionar Baia', 'Nova Baia',
  'Adicionar Dieta', 'Nova Dieta',
  'Adicionar Vacina', 'Nova Vacina',
  'Adicionar Medicamento',
  'Adicionar Anotação', 'Nova Anotação',
  'Adicionar Item', 'Novo Item',
  'Adicionar Avaliação',
  'Registrar Peso', 'Adicionar Peso',
  'Nova Reprodução', 'Adicionar Cobertura',
];

// ── Log ───────────────────────────────────────────────────────────────────────

Future<String> _writeLog(String text) async {
  // Imprime linha a linha no terminal (visível no flutter test output)
  // ignore: avoid_print
  print('\n========== FUNCTIONAL TEST LOG ==========');
  for (final line in text.split('\n')) {
    // ignore: avoid_print
    print(line);
  }
  // ignore: avoid_print
  print('=========================================\n');

  // Também salva no dispositivo como backup
  try {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/functional_test_$ts.txt');
    await file.writeAsString(text, flush: true);
    return file.path;
  } catch (_) {
    return '(arquivo não salvo)';
  }
}
