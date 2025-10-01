import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/animal.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // -------------------- Animais --------------------
  static Future<List<Animal>> getAnimals() async {
    final response = await _client.from('animals').select();
    return response.map((data) => Animal.fromMap(data)).toList();
  }

  static Future<Animal?> createAnimal(Map<String, dynamic> animal) async {
    final response =
        await _client.from('animals').insert(animal).select().maybeSingle();
    return response != null ? Animal.fromMap(response) : null;
  }

  static Future<Animal?> updateAnimal(
      String id, Map<String, dynamic> animal) async {
    final response = await _client
        .from('animals')
        .update(animal)
        .eq('id', id)
        .select()
        .maybeSingle();
    return response != null ? Animal.fromMap(response) : null;
  }

  static Future<bool> deleteAnimal(String id) async {
    await _client.from('animals').delete().eq('id', id);
    return true;
  }

  // -------------------- Vacinações --------------------
  static Future<List<Map<String, dynamic>>> getVaccinations() async {
    final response = await _client.from('vaccinations').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createVaccination(
      Map<String, dynamic> vaccination) async {
    await _client.from('vaccinations').insert(vaccination);
  }

  // -------------------- Reprodução --------------------
  static Future<List<Map<String, dynamic>>> getBreedingRecords() async {
    final response = await _client.from('breeding_records').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createBreedingRecord(Map<String, dynamic> record) async {
    await _client.from('breeding_records').insert(record);
  }

  // -------------------- Anotações --------------------
  static Future<List<Map<String, dynamic>>> getNotes() async {
    final response = await _client.from('notes').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createNote(Map<String, dynamic> note) async {
    await _client.from('notes').insert(note);
  }

  // -------------------- Financeiro --------------------
  static Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    final response = await _client.from('financial_records').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createFinancialRecord(
      Map<String, dynamic> record) async {
    await _client.from('financial_records').insert(record);
  }

  // -------------------- Relatórios --------------------
  static Future<void> createReport(Map<String, dynamic> report) async {
    await _client.from('reports').insert(report);
  }

  // -------------------- Estatísticas --------------------
  static Future<Map<String, dynamic>> getStats() async {
    final totalAnimals = await _client.from('animals').count();
    final healthy =
        await _client.from('animals').count().eq('status', 'Saudável');
    final pregnant =
        await _client.from('animals').count().eq('status', 'Gestante');
    final revenueResult = await _client
        .from('financial_records')
        .select('amount')
        .eq('type', 'receita');

    final revenue = revenueResult.fold<double>(
      0,
      (sum, item) => sum + (item['amount'] as num).toDouble(),
    );

    return {
      'totalAnimals': totalAnimals,
      'healthy': healthy,
      'pregnant': pregnant,
      'revenue': revenue,
    };
  }
  // -------------------- Backup (Upsert) --------------------
  static Future<void> upsertRows(String table, List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    await _client.from(table).upsert(rows);
  }
}
