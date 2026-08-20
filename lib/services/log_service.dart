// lib/services/log_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// Serviço de captura e gerenciamento de logs de erros
class LogService {
  static const int _maxLogEntries = 1000;
  static const String _logFileName = 'app_errors.log';
  
  File? _logFile;
  final List<LogEntry> _memoryLogs = [];

  /// Inicializa o serviço de logs
  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');
      
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }
      
      _logFile = File('${logsDir.path}/$_logFileName');
      
      // Carregar logs existentes na memória
      if (await _logFile!.exists()) {
        await _loadLogsFromFile();
      }
    } catch (e) {
      debugPrint('❌ Erro ao inicializar LogService: $e');
    }
  }

  /// Carrega logs do arquivo para a memória
  Future<void> _loadLogsFromFile() async {
    try {
      if (_logFile == null || !await _logFile!.exists()) return;
      
      final lines = await _logFile!.readAsLines();
      _memoryLogs.clear();
      
      for (final line in lines.take(_maxLogEntries)) {
        final parts = line.split(' | ');
        if (parts.length >= 3) {
          _memoryLogs.add(LogEntry(
            timestamp: parts[0],
            type: parts[1],
            message: parts.sublist(2).join(' | '),
          ));
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar logs: $e');
    }
  }

  /// Salva um log de erro
  Future<void> logError(String message, {StackTrace? stackTrace, String? widget}) async {
    await _writeLog(
      type: 'ERROR',
      message: message,
      stackTrace: stackTrace,
      widget: widget,
    );
  }

  /// Salva um log de overflow
  Future<void> logOverflow(String message, {StackTrace? stackTrace}) async {
    await _writeLog(
      type: 'OVERFLOW',
      message: message,
      stackTrace: stackTrace,
    );
  }

  /// Salva um log de warning
  Future<void> logWarning(String message) async {
    await _writeLog(
      type: 'WARNING',
      message: message,
    );
  }

  /// Escreve log no arquivo e memória
  Future<void> _writeLog({
    required String type,
    required String message,
    StackTrace? stackTrace,
    String? widget,
  }) async {
    try {
      final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      
      // Adicionar widget afetado se disponível
      String fullMessage = message;
      if (widget != null) {
        fullMessage = '[$widget] $message';
      }
      
      // Adicionar stack trace se disponível (primeiras 3 linhas)
      if (stackTrace != null) {
        final stackLines = stackTrace.toString().split('\n').take(3).join('\n');
        fullMessage += '\nStack: $stackLines';
      }
      
      // Adicionar à memória
      final entry = LogEntry(
        timestamp: timestamp,
        type: type,
        message: fullMessage,
      );
      _memoryLogs.insert(0, entry); // Mais recente primeiro
      
      // Limitar tamanho da memória
      if (_memoryLogs.length > _maxLogEntries) {
        _memoryLogs.removeRange(_maxLogEntries, _memoryLogs.length);
      }
      
      // Escrever no arquivo
      if (_logFile != null) {
        final logLine = '$timestamp | $type | $fullMessage\n';
        await _logFile!.writeAsString(
          logLine,
          mode: FileMode.append,
          flush: true,
        );
        
        // Limitar tamanho do arquivo (manter últimas N entradas)
        await _trimLogFile();
      }
      
      // Debug print
      debugPrint('📝 [$type] $fullMessage');
    } catch (e) {
      debugPrint('❌ Erro ao escrever log: $e');
    }
  }

  /// Remove entradas antigas do arquivo para evitar crescimento excessivo
  Future<void> _trimLogFile() async {
    try {
      if (_logFile == null || !await _logFile!.exists()) return;
      
      final lines = await _logFile!.readAsLines();
      
      if (lines.length > _maxLogEntries) {
        // Manter apenas as últimas N entradas
        final recentLines = lines.skip(lines.length - _maxLogEntries).toList();
        await _logFile!.writeAsString('${recentLines.join('\n')}\n');
      }
    } catch (e) {
      debugPrint('❌ Erro ao limitar arquivo de log: $e');
    }
  }

  /// Retorna todos os logs em memória
  List<LogEntry> getLogs() {
    return List.unmodifiable(_memoryLogs);
  }

  /// Retorna logs filtrados por tipo
  List<LogEntry> getLogsByType(String type) {
    return _memoryLogs.where((log) => log.type == type).toList();
  }

  /// Retorna quantidade de logs por tipo
  Map<String, int> getLogCounts() {
    final counts = <String, int>{};
    for (final log in _memoryLogs) {
      counts[log.type] = (counts[log.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Limpa todos os logs
  Future<void> clearLogs() async {
    try {
      _memoryLogs.clear();
      
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.delete();
        
        // Recriar arquivo vazio
        await _logFile!.create();
      }
      
      debugPrint('🗑️ Logs limpos com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao limpar logs: $e');
    }
  }

  /// Exporta logs como texto para compartilhamento
  Future<void> exportLogs() async {
    try {
      if (_logFile == null || !await _logFile!.exists()) {
        debugPrint('⚠️ Nenhum arquivo de log encontrado');
        return;
      }
      
      final XFile file = XFile(_logFile!.path);
      await Share.shareXFiles(
        [file],
        subject: 'Logs do Sistema - Terra Tech',
        text: 'Logs de erros e overflow do aplicativo',
      );
      
      debugPrint('📤 Logs exportados com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao exportar logs: $e');
    }
  }

  /// Retorna o caminho do arquivo de log
  String? getLogFilePath() {
    return _logFile?.path;
  }
}

/// Modelo de entrada de log
class LogEntry {
  final String timestamp;
  final String type;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.type,
    required this.message,
  });

  /// Retorna ícone apropriado para o tipo de log
  String get icon {
    switch (type) {
      case 'ERROR':
        return '❌';
      case 'OVERFLOW':
        return '⚠️';
      case 'WARNING':
        return '⚠️';
      default:
        return 'ℹ️';
    }
  }

  @override
  String toString() => '$timestamp | $type | $message';
}
