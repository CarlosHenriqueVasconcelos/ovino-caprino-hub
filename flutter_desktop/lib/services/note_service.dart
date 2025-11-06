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

  /// Retorna todas as notas, ordenadas da mais recente para a mais antiga.
  Future<List<Map<String, dynamic>>> getNotes() async {
    try {
      return await _repository.getAll();
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
