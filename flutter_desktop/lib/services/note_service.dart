// lib/services/note_service.dart
import 'package:flutter/foundation.dart';
import '../data/note_repository.dart';

/// Service para gerenciar lógica de anotações.
///
/// Importante: Widgets NÃO falam direto com o NoteRepository ou AppDatabase.
/// Sempre passam pelo NoteService.
class NoteService extends ChangeNotifier {
  final NoteRepository _repository;

  NoteService(this._repository);

  /// Retorna notas filtradas/paginadas.
  Future<List<Map<String, dynamic>>> getNotes({
    NoteQueryOptions options = const NoteQueryOptions(),
  }) async {
    try {
      return await _repository.fetchFiltered(
        category: options.category,
        priority: options.priority,
        unreadOnly: options.unreadOnly,
        searchTerm: options.searchTerm,
        startDate: options.startDate,
        endDate: options.endDate,
        limit: options.limit,
        offset: options.offset,
      );
    } catch (e, stack) {
      debugPrint('Erro ao carregar anotações: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Cria uma nova anotação.
  Future<void> createNote(Map<String, dynamic> note) async {
    try {
      await _repository.insert(note);
    } catch (e, stack) {
      debugPrint('Erro ao criar anotação: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Atualiza campos de uma anotação existente.
  Future<void> updateNote(String id, Map<String, dynamic> updates) async {
    try {
      await _repository.update(id, updates);
    } catch (e, stack) {
      debugPrint('Erro ao atualizar anotação: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Exclui uma anotação.
  Future<void> deleteNote(String id) async {
    try {
      await _repository.delete(id);
    } catch (e, stack) {
      debugPrint('Erro ao excluir anotação: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Marca uma anotação como lida.
  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
    } catch (e, stack) {
      debugPrint('Erro ao marcar anotação como lida: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  /// Conta quantas anotações ainda não foram lidas.
  Future<int> getUnreadCount() async {
    try {
      return await _repository.getUnreadCount();
    } catch (e, stack) {
      debugPrint('Erro ao obter quantidade de anotações não lidas: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }
}

/// Define filtros opcionais para buscas de anotações.
class NoteQueryOptions {
  final String? category;
  final String? priority;
  final bool? unreadOnly;
  final String? searchTerm;
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;
  final int offset;

  const NoteQueryOptions({
    this.category,
    this.priority,
    this.unreadOnly,
    this.searchTerm,
    this.startDate,
    this.endDate,
    this.limit = 200,
    this.offset = 0,
  });
}
