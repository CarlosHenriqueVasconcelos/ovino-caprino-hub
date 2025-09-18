// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // -------------------- Animais --------------------
  static Future<List<Map<String, dynamic>>> getAnimals() async {
    final response = await _client.from('animals').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> addAnimal(Map<String, dynamic> animal) async {
    await _client.from('animals').insert(animal);
  }

  static Future<void> updateAnimal(String id, Map<String, dynamic> animal) async {
    await _client.from('animals').update(animal).eq('id', id);
  }

  static Future<void> deleteAnimal(String id) async {
    await _client.from('animals').delete().eq('id', id);
  }

  // -------------------- Vacinações --------------------
  static Future<List<Map<String, dynamic>>> getVaccinations() async {
    final response = await _client.from('vaccinations').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> addVaccination(Map<String, dynamic> vaccination) async {
    await _client.from('vaccinations').insert(vaccination);
  }

  // -------------------- Reprodução --------------------
  static Future<List<Map<String, dynamic>>> getBreedingRecords() async {
    final response = await _client.from('breeding_records').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> addBreedingRecord(Map<String, dynamic> record) async {
    await _client.from('breeding_records').insert(record);
  }

  // -------------------- Anotações --------------------
  static Future<List<Map<String, dynamic>>> getNotes() async {
    final response = await _client.from('notes').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> addNote(Map<String, dynamic> note) async {
    await _client.from('notes').insert(note);
  }

  // -------------------- Financeiro --------------------
  static Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    final response = await _client.from('financial_records').select();
    return response.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> addFinancialRecord(Map<String, dynamic> record) async {
    await _client.from('financial_records').insert(record);
  }

  // -------------------- Relatórios --------------------
  static Future<void> createReport(Map<String, dynamic> report) async {
    await _client.from('reports').insert(report);
  }
}
