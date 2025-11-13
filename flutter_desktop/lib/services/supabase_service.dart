import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/animal.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // Propriedades para compatibilidade
  static SupabaseClient get supabase => _client;
  static bool get isConfigured => true; // Sempre configurado neste projeto

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

  static Future<void> updateVaccination(
      String id, Map<String, dynamic> updates) async {
    await _client.from('vaccinations').update(updates).eq('id', id);
  }

  static Future<void> deleteVaccination(String id) async {
    await _client.from('vaccinations').delete().eq('id', id);
  }

  // -------------------- Medicamentos --------------------
  static Future<List<Map<String, dynamic>>> getMedications() async {
    final response = await _client.from('medications').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createMedication(Map<String, dynamic> medication) async {
    await _client.from('medications').insert(medication);
  }

  static Future<void> updateMedication(
      String id, Map<String, dynamic> updates) async {
    await _client.from('medications').update(updates).eq('id', id);
  }

  static Future<void> deleteMedication(String id) async {
    await _client.from('medications').delete().eq('id', id);
  }

  // -------------------- Pesos dos Animais --------------------
  static Future<List<Map<String, dynamic>>> getAnimalWeights() async {
    final response = await _client.from('animal_weights').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createAnimalWeight(Map<String, dynamic> weight) async {
    await _client.from('animal_weights').insert(weight);
  }

  static Future<void> updateAnimalWeight(
      String id, Map<String, dynamic> updates) async {
    await _client.from('animal_weights').update(updates).eq('id', id);
  }

  static Future<void> deleteAnimalWeight(String id) async {
    await _client.from('animal_weights').delete().eq('id', id);
  }

  // -------------------- Reprodução --------------------
  static Future<List<Map<String, dynamic>>> getBreedingRecords() async {
    final response = await _client.from('breeding_records').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createBreedingRecord(Map<String, dynamic> record) async {
    await _client.from('breeding_records').insert(record);
  }

  static Future<void> updateBreedingRecord(
      String id, Map<String, dynamic> updates) async {
    await _client.from('breeding_records').update(updates).eq('id', id);
  }

  static Future<void> deleteBreedingRecord(String id) async {
    await _client.from('breeding_records').delete().eq('id', id);
  }

  // -------------------- Anotações --------------------
  static Future<List<Map<String, dynamic>>> getNotes() async {
    final response = await _client.from('notes').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createNote(Map<String, dynamic> note) async {
    await _client.from('notes').insert(note);
  }

  static Future<void> updateNote(
      String id, Map<String, dynamic> updates) async {
    await _client.from('notes').update(updates).eq('id', id);
  }

  static Future<void> deleteNote(String id) async {
    await _client.from('notes').delete().eq('id', id);
  }

  // -------------------- Financeiro --------------------
  static Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    final response = await _client.from('financial_records').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createFinancialRecord(Map<String, dynamic> record) async {
    await _client.from('financial_records').insert(record);
  }

  static Future<void> updateFinancialRecord(
      String id, Map<String, dynamic> updates) async {
    await _client.from('financial_records').update(updates).eq('id', id);
  }

  static Future<void> deleteFinancialRecord(String id) async {
    await _client.from('financial_records').delete().eq('id', id);
  }

  // -------------------- Contas Financeiras --------------------
  static Future<List<Map<String, dynamic>>> getFinancialAccounts() async {
    final response = await _client.from('financial_accounts').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createFinancialAccount(
      Map<String, dynamic> account) async {
    await _client.from('financial_accounts').insert(account);
  }

  static Future<void> updateFinancialAccount(
      String id, Map<String, dynamic> updates) async {
    await _client.from('financial_accounts').update(updates).eq('id', id);
  }

  static Future<void> deleteFinancialAccount(String id) async {
    await _client.from('financial_accounts').delete().eq('id', id);
  }

  // -------------------- Relatórios --------------------
  static Future<List<Map<String, dynamic>>> getReports() async {
    final response = await _client.from('reports').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createReport(Map<String, dynamic> report) async {
    await _client.from('reports').insert(report);
  }

  // -------------------- Push Tokens --------------------
  static Future<List<Map<String, dynamic>>> getPushTokens() async {
    final response = await _client.from('push_tokens').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createPushToken(Map<String, dynamic> token) async {
    await _client.from('push_tokens').insert(token);
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
  static Future<void> upsertRows(
      String table, List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    await _client.from(table).upsert(rows);
  }

  // -------------------- Animais Vendidos --------------------
  static Future<List<Map<String, dynamic>>> getSoldAnimals() async {
    final response = await _client.from('sold_animals').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createSoldAnimal(Map<String, dynamic> animal) async {
    await _client.from('sold_animals').insert(animal);
  }

  static Future<void> updateSoldAnimal(
      String id, Map<String, dynamic> updates) async {
    await _client.from('sold_animals').update(updates).eq('id', id);
  }

  static Future<void> deleteSoldAnimal(String id) async {
    await _client.from('sold_animals').delete().eq('id', id);
  }

  // -------------------- Animais Falecidos --------------------
  static Future<List<Map<String, dynamic>>> getDeceasedAnimals() async {
    final response = await _client.from('deceased_animals').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> createDeceasedAnimal(Map<String, dynamic> animal) async {
    await _client.from('deceased_animals').insert(animal);
  }

  static Future<void> updateDeceasedAnimal(
      String id, Map<String, dynamic> updates) async {
    await _client.from('deceased_animals').update(updates).eq('id', id);
  }

  static Future<void> deleteDeceasedAnimal(String id) async {
    await _client.from('deceased_animals').delete().eq('id', id);
  }
}
