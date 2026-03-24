import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/animal_lifecycle_repository.dart';
import '../data/animal_repository.dart';
import '../data/local_db.dart';
import '../services/animal_service.dart';
import '../services/deceased_service.dart';
import '../services/system_maintenance_service.dart';
import 'diagnostic_runner.dart';

class DevToolsScreen extends StatefulWidget {
  const DevToolsScreen({super.key});

  @override
  State<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends State<DevToolsScreen> {
  DiagnosticResult? _lastResult;
  bool _running = false;

  Future<void> _runDiagnostics({required bool stress}) async {
    setState(() => _running = true);
    try {
      final runner = DiagnosticRunner(
        appDb: context.read<AppDatabase>(),
        animalRepo: context.read<AnimalRepository>(),
        lifecycleRepo: context.read<AnimalLifecycleRepository>(),
        animalService: context.read<AnimalService>(),
        deceasedService: context.read<DeceasedService>(),
        maintenanceService: context.read<SystemMaintenanceService>(),
      );
      final result = await runner.run(stress: stress);
      if (!mounted) return;
      setState(() {
        _lastResult = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.summary),
          backgroundColor: result.ok ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao rodar diagnóstico: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _running = false);
      }
    }
  }

  Future<void> _copyPath() async {
    final path = _lastResult?.filePath;
    if (path == null || path.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: path));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caminho do log copiado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ferramentas de Diagnóstico'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suíte de Diagnóstico (debug-only)',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gera dados no SQLite, executa cenários críticos e salva '
                      'um arquivo de log em Documentos.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _running
                              ? null
                              : () => _runDiagnostics(stress: false),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Seed Small + Run'),
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              _running ? null : () => _runDiagnostics(stress: true),
                          icon: const Icon(Icons.bolt),
                          label: const Text('Seed Stress + Run'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_running)
              const LinearProgressIndicator(minHeight: 2)
            else
              const SizedBox(height: 2),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Último resultado',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_lastResult?.summary ?? 'Nenhum diagnóstico executado.'),
                    const SizedBox(height: 8),
                    if (_lastResult?.filePath != null)
                      Text(
                        _lastResult!.filePath,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed:
                          (_lastResult?.filePath ?? '').isEmpty ? null : _copyPath,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar caminho do log'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (kDebugMode)
              Text(
                'Dica: você pode passar --dart-define=ENABLE_DEVTOOLS=true '
                'para manter a tela habilitada.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
