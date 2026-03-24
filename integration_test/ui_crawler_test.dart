import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bego_ovino_caprino/main.dart' as app;
import 'package:bego_ovino_caprino/features/navigation/dashboard_tabs.dart';

const bool kRunSeed = bool.fromEnvironment('RUN_SEED', defaultValue: true);
const bool kSkipSettingsTab =
    bool.fromEnvironment('SKIP_SETTINGS_TAB', defaultValue: true);
const bool kAggressive =
    bool.fromEnvironment('AGGRESSIVE_CRAWL', defaultValue: false);
const bool kSkipNetworkActions =
    bool.fromEnvironment('SKIP_NETWORK_ACTIONS', defaultValue: true);
const bool kResizeViewports =
    bool.fromEnvironment('RESIZE_VIEWPORTS', defaultValue: false);
const int kMaxActionsPerTab =
    int.fromEnvironment('MAX_ACTIONS_PER_TAB', defaultValue: 80);
const int kMaxAllowedErrors =
    int.fromEnvironment('MAX_ALLOWED_ERRORS', defaultValue: 0);
const int kMaxAllowedOverflows =
    int.fromEnvironment('MAX_ALLOWED_OVERFLOWS', defaultValue: 0);
const int kSettleTimeoutSeconds =
    int.fromEnvironment('SETTLE_TIMEOUT_SECONDS', defaultValue: 3);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UI crawler', (tester) async {
    final log = StringBuffer();
    final errorSummaries = <String>[];
    final recentActions = <String>[];
    var errorsCount = 0;
    var overflowCount = 0;
    var totalActions = 0;
    var screenshotCount = 0;
    final pendingScreenshots = <String>[];

    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errorsCount += 1;
      final msg = details.exceptionAsString();
      if (msg.contains('RenderFlex overflowed')) {
        overflowCount += 1;
        pendingScreenshots.add('overflow_$overflowCount');
      } else {
        pendingScreenshots.add('error_$errorsCount');
      }
      final summary = '$msg\n${details.stack ?? ''}';
      errorSummaries.add(_truncate(summary, 1200));
      log.writeln('[ERROR] $msg');
      if (details.stack != null) {
        log.writeln(details.stack);
      }
      FlutterError.dumpErrorToConsole(details, forceReport: true);
    };

    final prevPlatformError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      errorsCount += 1;
      pendingScreenshots.add('platform_$errorsCount');
      final summary = '$error\n$stack';
      errorSummaries.add(_truncate(summary, 1200));
      log.writeln('[PLATFORM_ERROR] $error');
      log.writeln(stack);
      return true;
    };

    log.writeln('[INFO] App start');
    app.main();
    await _safePumpAndSettle(tester, log, reason: 'app_start');

    if (kRunSeed && !kSkipSettingsTab) {
      log.writeln('[INFO] Running seed via DevTools');
      await _openTab(tester, 'Sistema', log);
      final devtoolsTile =
          find.widgetWithText(ListTile, 'Ferramentas de Diagnóstico');
      final devtoolsTapTarget = devtoolsTile.evaluate().isNotEmpty
          ? devtoolsTile.first
          : find.ancestor(
              of: find.text('Ferramentas de Diagnóstico'),
              matching: find.byType(InkWell),
            );
      await _tapIfExists(tester, devtoolsTapTarget, log);
      await _safePumpAndSettle(tester, log, reason: 'open_devtools');
      await _tapIfExists(tester, find.text('Seed Stress + Run'), log);
      await _waitForButtonEnabled(
        tester,
        find.widgetWithText(OutlinedButton, 'Copiar caminho do log'),
        log,
      );
      await _returnToDashboard(tester, log);
    } else if (kRunSeed && kSkipSettingsTab) {
      log.writeln(
        '[INFO] Seed skipped because SKIP_SETTINGS_TAB=true (default).',
      );
    }

    final isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final originalSize =
        tester.view.physicalSize / tester.view.devicePixelRatio;
    final sizeVariants = <Size>[
      const Size(360, 640),
      const Size(480, 800),
      const Size(1024, 768),
      const Size(1280, 720),
    ];

    String? logPath;
    try {
      final tabsToCrawl = dashboardTabs.where((tab) {
        if (!kSkipSettingsTab) return true;
        return !_isSettingsTabLabel(tab.label);
      });

      for (final tab in tabsToCrawl) {
        log.writeln('[TAB] ${tab.label}');
        await _openTab(tester, tab.label, log);

        var actionsInTab = 0;
        if (isDesktop && kResizeViewports) {
          final perSize =
              (kMaxActionsPerTab / sizeVariants.length).floor().clamp(10, 80);
          for (final size in sizeVariants) {
            await binding.setSurfaceSize(size);
            await _safePumpAndSettle(tester, log, reason: 'set_surface');
            actionsInTab += await _crawlCurrentView(
              tester,
              log: log,
              maxActions: perSize,
              aggressive: kAggressive,
              recentActions: recentActions,
              pendingScreenshots: pendingScreenshots,
              binding: binding,
              onAction: () => totalActions += 1,
              onScreenshot: () => screenshotCount += 1,
            );
          }
          await binding.setSurfaceSize(originalSize);
          await _safePumpAndSettle(tester, log, reason: 'restore_surface');
        }

        actionsInTab += await _crawlCurrentView(
          tester,
          log: log,
          maxActions: kMaxActionsPerTab,
          aggressive: kAggressive,
          recentActions: recentActions,
          pendingScreenshots: pendingScreenshots,
          binding: binding,
          onAction: () => totalActions += 1,
          onScreenshot: () => screenshotCount += 1,
        );

        log.writeln(
          '[TAB_DONE] ${tab.label} actions=$actionsInTab errors=$errorsCount overflows=$overflowCount',
        );
      }

      log.writeln('[SUMMARY] totalActions=$totalActions');
      log.writeln('[SUMMARY] errors=$errorsCount overflows=$overflowCount');
      log.writeln('[SUMMARY] screenshots=$screenshotCount');

      if (errorSummaries.isNotEmpty) {
        log.writeln('[ERRORS]');
        for (final summary in errorSummaries) {
          log.writeln('---');
          log.writeln(summary);
        }
      }

      if (recentActions.isNotEmpty) {
        log.writeln('[LAST_ACTIONS]');
        for (final action in recentActions) {
          log.writeln(action);
        }
      }

      logPath = await _writeLogFile(log.toString());
      // ignore: avoid_print
      print('UI_CRAWL_LOG_PATH=$logPath');
    } finally {
      await tester.binding.setSurfaceSize(null);
      await _safePumpAndSettle(tester, log, reason: 'cleanup_surface');

      FlutterError.onError = prevOnError;
      PlatformDispatcher.instance.onError = prevPlatformError;
    }

    if (errorsCount > kMaxAllowedErrors ||
        overflowCount > kMaxAllowedOverflows) {
      fail(
        'UI crawl found errors=$errorsCount (max=$kMaxAllowedErrors) '
        'overflows=$overflowCount (max=$kMaxAllowedOverflows). '
        'Log: $logPath',
      );
    }
  });
}

Future<void> _openTab(
  WidgetTester tester,
  String label,
  StringBuffer log,
) async {
  final tabBars = find.byType(TabBar);
  if (tabBars.evaluate().isEmpty) {
    log.writeln('[WARN] TabBar not found while opening tab: $label');
    return;
  }

  final tabFinder = find.descendant(
    of: tabBars.first,
    matching: find.byWidgetPredicate(
      (w) => w is Tab && w.text == label,
      description: 'Tab("$label")',
    ),
  );
  if (tabFinder.evaluate().isEmpty) {
    log.writeln('[WARN] Tab not found: $label');
    return;
  }
  await _tapIfExists(tester, tabFinder.first, log);
}

Future<bool> _tapIfExists(
  WidgetTester tester,
  Finder finder,
  StringBuffer log,
) async {
  if (finder.evaluate().isEmpty) {
    log.writeln('[WARN] Finder not found for tap.');
    return false;
  }
  await _bringIntoView(tester, finder, log);
  try {
    await tester.tap(finder, warnIfMissed: false);
    await _safePumpAndSettle(tester, log, reason: 'tap');
    return true;
  } catch (e) {
    log.writeln('[WARN] Tap failed: $e');
    return false;
  }
}

Future<void> _waitForButtonEnabled(
  WidgetTester tester,
  Finder finder,
  StringBuffer log,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 60));
  while (DateTime.now().isBefore(deadline)) {
    await _safePumpAndSettle(tester, log, reason: 'wait_button');
    if (finder.evaluate().isNotEmpty) {
      final widget = tester.widget<OutlinedButton>(finder);
      if (widget.onPressed != null) {
        log.writeln('[INFO] Seed completed, log button enabled');
        return;
      }
    }
  }
  log.writeln('[WARN] Timeout waiting for log button to enable');
}

Future<int> _crawlCurrentView(
  WidgetTester tester, {
  required StringBuffer log,
  required int maxActions,
  required bool aggressive,
  required List<String> recentActions,
  required List<String> pendingScreenshots,
  required IntegrationTestWidgetsFlutterBinding binding,
  required VoidCallback onAction,
  required VoidCallback onScreenshot,
}) async {
  final tapped = <String>{};
  var actions = 0;

  while (actions < maxActions) {
    final candidates = _collectCandidates(tester, aggressive: aggressive);
    if (candidates.isEmpty) break;

    var progressed = false;
    for (final candidate in candidates) {
      if (actions >= maxActions) break;
      if (tapped.contains(candidate.signature)) continue;
      if (candidate.isDestructive && !aggressive) continue;

      if (candidate.isSaveOrAdd) {
        await _fillAllEmptyFields(tester, log);
      }

      log.writeln('[ACTION] ${candidate.signature}');
      _rememberAction(recentActions, candidate.signature);
      tapped.add(candidate.signature);
      if (!await _tapIfExists(tester, candidate.finder, log)) {
        continue;
      }
      progressed = true;
      actions += 1;
      onAction();

      await _handleDialogs(tester, log, aggressive: aggressive);

      if (pendingScreenshots.isNotEmpty) {
        final tag = pendingScreenshots.removeAt(0);
        await _captureScreenshot(binding, tester, tag);
        onScreenshot();
      }
    }

    if (!progressed) break;
  }

  return actions;
}

List<_Candidate> _collectCandidates(WidgetTester tester,
    {required bool aggressive}) {
  final candidates = <_Candidate>[];

  void collect<T extends Widget>(bool Function(T w) enabled, int basePriority) {
    for (final element in find.byType(T).evaluate()) {
      final widget = element.widget;
      if (widget is! T) continue;
      if (!enabled(widget)) continue;
      final finder = find.byElementPredicate((e) => identical(e, element));
      final signature = _signatureForWidget(widget);
      final inlineText = _extractText(widget) ?? '';
      final elementText = _extractTextFromElement(element);
      final text = '$inlineText $elementText'.trim();
      if (kSkipNetworkActions &&
          _isNetworkActionText('$text ${signature.toLowerCase()}')) {
        continue;
      }
      candidates.add(
        _Candidate(
          finder: finder,
          signature: signature,
          priority: _priorityForText(text, basePriority),
          isDestructive: _isDestructiveText(text),
          isSaveOrAdd: _isSaveOrAdd(text),
        ),
      );
    }
  }

  collect<IconButton>((w) => w.onPressed != null, 80);
  collect<ElevatedButton>((w) => w.onPressed != null, 70);
  collect<TextButton>((w) => w.onPressed != null, 60);
  collect<OutlinedButton>((w) => w.onPressed != null, 50);
  collect<FloatingActionButton>((w) => w.onPressed != null, 90);
  collect<ListTile>((w) => w.onTap != null, 40);
  collect<InkWell>((w) => w.onTap != null, 30);
  collect<GestureDetector>((w) => w.onTap != null, 20);

  candidates.sort((a, b) => b.priority.compareTo(a.priority));
  return candidates;
}

Future<void> _handleDialogs(
  WidgetTester tester,
  StringBuffer log, {
  required bool aggressive,
}) async {
  final safeLabels = ['Fechar', 'Cancelar', 'OK', 'Voltar', 'Não'];
  final riskyLabels = ['Confirmar', 'Excluir', 'Apagar', 'Sim'];

  // Wait a short window after each action because some errors pop up async.
  for (var i = 0; i < 15; i++) {
    final hasDialog = find.byType(Dialog).evaluate().isNotEmpty ||
        find.byType(AlertDialog).evaluate().isNotEmpty ||
        find.byType(SimpleDialog).evaluate().isNotEmpty;
    if (!hasDialog) {
      await tester.pump(const Duration(milliseconds: 200));
      continue;
    }

    if (await _tapDialogButton(tester, safeLabels)) {
      log.writeln('[DIALOG] closed safely');
      await _safePumpAndSettle(tester, log, reason: 'close_dialog');
      continue;
    }

    if (aggressive && await _tapDialogButton(tester, riskyLabels)) {
      log.writeln('[DIALOG] closed aggressively');
      await _safePumpAndSettle(tester, log, reason: 'close_dialog_aggressive');
      continue;
    }

    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _safePumpAndSettle(
  WidgetTester tester,
  StringBuffer log, {
  required String reason,
}) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: kSettleTimeoutSeconds),
    );
  } catch (e) {
    // Keep crawler moving if a long animation/progress blocks full settling.
    log.writeln('[WARN] pumpAndSettle timeout ($reason): $e');
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<bool> _tapDialogButton(
  WidgetTester tester,
  List<String> labels,
) async {
  for (final label in labels) {
    final candidates = [
      find.widgetWithText(TextButton, label),
      find.widgetWithText(ElevatedButton, label),
      find.widgetWithText(OutlinedButton, label),
    ];
    for (final finder in candidates) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pump(const Duration(milliseconds: 250));
        return true;
      }
    }
  }
  return false;
}

Future<void> _fillAllEmptyFields(
  WidgetTester tester,
  StringBuffer log,
) async {
  var filledCount = 0;
  var fieldIndex = 1;

  final fields = find.byType(TextFormField);
  for (final element in fields.evaluate()) {
    final widget = element.widget;
    if (widget is! TextFormField) continue;
    if (widget.enabled == false || _isReadOnlyWidget(widget)) continue;
    final current = widget.controller?.text ?? widget.initialValue ?? '';
    if (current.trim().isNotEmpty) continue;

    final finder = find.byElementPredicate((e) => identical(e, element));
    final text = _valueForTextInput(_keyboardTypeFromWidget(widget), fieldIndex);
    await _bringIntoView(tester, finder, log);
    await tester.enterText(finder, text);
    await _safePumpAndSettle(tester, log, reason: 'fill_text_form_field');
    filledCount += 1;
    fieldIndex += 1;
  }

  final textFields = find.byType(TextField);
  for (final element in textFields.evaluate()) {
    final widget = element.widget;
    if (widget is! TextField) continue;
    if (widget.enabled == false || widget.readOnly) continue;
    final current = widget.controller?.text ?? '';
    if (current.trim().isNotEmpty) continue;

    final finder = find.byElementPredicate((e) => identical(e, element));
    final text = _valueForTextInput(widget.keyboardType, fieldIndex);
    await _bringIntoView(tester, finder, log);
    await tester.enterText(finder, text);
    await _safePumpAndSettle(tester, log, reason: 'fill_text_field');
    filledCount += 1;
    fieldIndex += 1;
  }

  final dropdowns = find.byType(DropdownButtonFormField);
  for (final element in dropdowns.evaluate()) {
    final widget = element.widget;
    if (widget is! DropdownButtonFormField<dynamic>) continue;
    final hasOnChanged = widget.onChanged != null;
    final currentValue = _dropdownCurrentValue(widget);
    if (!hasOnChanged || currentValue != null) continue;
    final items = _dropdownItems(widget);
    final firstEnabled = items.where((item) => item.enabled).toList();
    if (firstEnabled.isEmpty) continue;

    final fieldFinder = find.byElementPredicate((e) => identical(e, element));
    await _bringIntoView(tester, fieldFinder, log);
    await tester.tap(fieldFinder, warnIfMissed: false);
    await _safePumpAndSettle(tester, log, reason: 'open_dropdown');

    final selected = await _selectDropdownItemByLabel(tester, firstEnabled.first);
    if (selected) {
      await _safePumpAndSettle(tester, log, reason: 'select_dropdown_item');
      filledCount += 1;
    }
  }

  if (filledCount > 0) {
    log.writeln('[INPUT] filled fields=$filledCount');
  }
}

Future<bool> _selectDropdownItemByLabel(
  WidgetTester tester,
  DropdownMenuItem<dynamic> item,
) async {
  final child = item.child;
  if (child is Text && child.data != null && child.data!.trim().isNotEmpty) {
    final label = child.data!.trim();
    final candidates = find.text(label);
    if (candidates.evaluate().isNotEmpty) {
      await tester.tap(candidates.first, warnIfMissed: false);
      return true;
    }
  }
  return false;
}

bool _isReadOnlyWidget(Object widget) {
  try {
    final dynamic w = widget;
    return (w.readOnly as bool?) ?? false;
  } catch (_) {
    return false;
  }
}

TextInputType? _keyboardTypeFromWidget(Object widget) {
  try {
    final dynamic w = widget;
    final value = w.keyboardType;
    return value is TextInputType ? value : null;
  } catch (_) {
    return null;
  }
}

dynamic _dropdownCurrentValue(DropdownButtonFormField<dynamic> widget) {
  try {
    final dynamic w = widget;
    return w.value;
  } catch (_) {
    return null;
  }
}

List<DropdownMenuItem<dynamic>> _dropdownItems(
  DropdownButtonFormField<dynamic> widget,
) {
  try {
    final dynamic w = widget;
    final dynamic raw = w.items;
    if (raw is List<DropdownMenuItem<dynamic>>) return raw;
    if (raw is List) {
      return raw.whereType<DropdownMenuItem<dynamic>>().toList();
    }
  } catch (_) {
    // ignore and fallback below
  }
  return const <DropdownMenuItem<dynamic>>[];
}

Future<void> _bringIntoView(
  WidgetTester tester,
  Finder target,
  StringBuffer log,
) async {
  if (target.evaluate().isEmpty) return;

  try {
    await tester.ensureVisible(target);
    await _safePumpAndSettle(tester, log, reason: 'ensure_visible');
    return;
  } catch (_) {
    final scrollable =
        find.ancestor(of: target, matching: find.byType(Scrollable));
    if (scrollable.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        target,
        250.0,
        scrollable: scrollable.first,
      );
      await _safePumpAndSettle(tester, log, reason: 'scroll_until_visible');
      return;
    }

    final previousSize =
        tester.view.physicalSize / tester.view.devicePixelRatio;
    try {
      await tester.binding.setSurfaceSize(const Size(1264, 2000));
      await _safePumpAndSettle(tester, log, reason: 'grow_surface');
      await tester.ensureVisible(target);
      await _safePumpAndSettle(tester, log, reason: 'ensure_visible_fallback');
    } finally {
      await tester.binding.setSurfaceSize(previousSize);
      await _safePumpAndSettle(tester, log, reason: 'restore_surface');
    }
  }
}

Future<void> _returnToDashboard(WidgetTester tester, StringBuffer log) async {
  for (var i = 0; i < 8; i++) {
    if (find.byType(TabBar).evaluate().isNotEmpty) {
      await _safePumpAndSettle(tester, log, reason: 'dashboard_visible');
      return;
    }

    if (await _tapIfExists(tester, find.byTooltip('Back'), log)) {
      continue;
    }
    if (await _tapIfExists(tester, find.byIcon(Icons.arrow_back), log)) {
      continue;
    }
    if (await _tapDialogButton(tester, const ['Fechar', 'Cancelar', 'OK'])) {
      continue;
    }

    try {
      final navigatorFinder = find.byType(Navigator);
      if (navigatorFinder.evaluate().isNotEmpty) {
        final navigator = tester.state<NavigatorState>(navigatorFinder.first);
        final popped = await navigator.maybePop();
        await _safePumpAndSettle(tester, log, reason: 'maybe_pop');
        if (popped) {
          continue;
        }
      }
    } catch (e) {
      log.writeln('[WARN] maybePop failed: $e');
      break;
    }
    // Nothing to pop and no known back affordance.
    break;
  }
  log.writeln('[WARN] Could not return to dashboard after seed');
}

String _signatureForWidget(Widget widget) {
  final key = widget.key?.toString() ?? 'no-key';
  final text = _extractText(widget) ?? '';
  final tooltip = _extractTooltip(widget) ?? '';
  return '${widget.runtimeType}|$key|$text|$tooltip';
}

String? _extractText(Widget widget) {
  if (widget is Text) return widget.data ?? widget.toStringShort();
  if (widget is TextButton && widget.child is Text) {
    return (widget.child as Text).data;
  }
  if (widget is ElevatedButton && widget.child is Text) {
    return (widget.child as Text).data;
  }
  if (widget is OutlinedButton && widget.child is Text) {
    return (widget.child as Text).data;
  }
  if (widget is ListTile && widget.title is Text) {
    return (widget.title as Text).data;
  }
  if (widget is FloatingActionButton && widget.tooltip != null) {
    return widget.tooltip;
  }
  if (widget is FloatingActionButton && widget.child is Text) {
    return (widget.child as Text).data;
  }
  return null;
}

String? _extractTooltip(Widget widget) {
  if (widget is IconButton) return widget.tooltip;
  if (widget is FloatingActionButton) return widget.tooltip;
  return null;
}

String _extractTextFromElement(Element root) {
  final values = <String>[];

  void walk(Element e) {
    final w = e.widget;
    if (w is Text) {
      final data = w.data?.trim();
      if (data != null && data.isNotEmpty) {
        values.add(data);
      }
    }
    e.visitChildren(walk);
  }

  walk(root);
  if (values.isEmpty) return '';
  return values.join(' ');
}

int _priorityForText(String text, int base) {
  final t = text.toLowerCase();
  if (t.contains('adicionar') ||
      t.contains('novo') ||
      t.contains('cadastrar') ||
      t.contains('criar')) {
    return base + 40;
  }
  if (t.contains('salvar') || t.contains('atualizar')) {
    return base + 20;
  }
  if (t.contains('config') || t.contains('detal')) {
    return base + 10;
  }
  return base;
}

bool _isDestructiveText(String text) {
  final t = text.toLowerCase();
  return t.contains('excluir') ||
      t.contains('apagar') ||
      t.contains('limpar') ||
      t.contains('deletar') ||
      t.contains('remover');
}

bool _isSaveOrAdd(String text) {
  final t = text.toLowerCase();
  return t.contains('salvar') ||
      t.contains('adicionar') ||
      t.contains('cadastrar') ||
      t.contains('criar');
}

bool _isNetworkActionText(String text) {
  final t = text.toLowerCase();
  return t.contains('supabase') ||
      t.contains('backup') ||
      t.contains('fazer backup') ||
      t.contains('backup manual') ||
      t.contains('backup e dados') ||
      t.contains('upload para') ||
      t.contains('enviar para') ||
      t.contains('sincronizar') ||
      t.contains('upload') ||
      t.contains('download') ||
      t.contains('sincron') ||
      t.contains('importar') ||
      t.contains('exportar') ||
      t.contains('restaurar') ||
      t.contains('nuvem') ||
      t.contains('cloud');
}

bool _isSettingsTabLabel(String label) {
  final normalized = label.trim().toLowerCase();
  return normalized == 'sistema' ||
      normalized == 'configurações' ||
      normalized == 'configuracoes';
}

void _rememberAction(List<String> recentActions, String signature) {
  recentActions.add(signature);
  if (recentActions.length > 50) {
    recentActions.removeAt(0);
  }
}

Future<void> _captureScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String tag,
) async {
  if (Platform.isAndroid) {
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
  }
  final bytes = await binding.takeScreenshot(tag);
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/ui_crawl_$tag.png');
  await file.writeAsBytes(bytes, flush: true);
}

Future<String> _writeLogFile(String text) async {
  final dir = await getApplicationDocumentsDirectory();
  final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
  final file = File('${dir.path}/ui_crawl_log_$ts.txt');
  await file.writeAsString(text, flush: true);
  return file.path;
}

String _truncate(String text, int max) {
  if (text.length <= max) return text;
  return '${text.substring(0, max)}...';
}

String _valueForTextInput(TextInputType? keyboardType, int index) {
  final kind = (keyboardType ?? TextInputType.text).toString().toLowerCase();
  if (kind.contains('number')) {
    return '$index';
  }
  if (kind.contains('phone')) return '1199999000$index';
  if (kind.contains('email')) {
    return 'teste$index@example.com';
  }
  if (kind.contains('datetime')) return '01/01/2020';
  return 'Teste $index';
}

class _Candidate {
  final Finder finder;
  final String signature;
  final int priority;
  final bool isDestructive;
  final bool isSaveOrAdd;

  _Candidate({
    required this.finder,
    required this.signature,
    required this.priority,
    required this.isDestructive,
    required this.isSaveOrAdd,
  });
}
