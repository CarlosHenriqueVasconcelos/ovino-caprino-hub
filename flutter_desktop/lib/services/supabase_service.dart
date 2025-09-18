import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/animal.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Animals
  static Future<List<Animal>> getAnimals() async {
    try {
      final response = await _client
          .from('animals')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((data) => Animal.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching animals: $e');
      return [];
    }
  }

  static Future<Animal?> createAnimal(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('animals')
          .insert(data)
          .select()
          .single();

      return Animal.fromJson(response);
    } catch (e) {
      print('Error creating animal: $e');
      return null;
    }
  }

  static Future<Animal?> updateAnimal(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('animals')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Animal.fromJson(response);
    } catch (e) {
      print('Error updating animal: $e');
      return null;
    }
  }

  static Future<bool> deleteAnimal(String id) async {
    try {
      await _client
          .from('animals')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting animal: $e');
      return false;
    }
  }

  // Vaccinations
  static Future<List<Map<String, dynamic>>> getVaccinations([String? animalId]) async {
    try {
      var query = _client.from('vaccinations').select();
      
      if (animalId != null) {
        query = query.eq('animal_id', animalId);
      }
      
      final response = await query.order('scheduled_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching vaccinations: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createVaccination(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('vaccinations')
          .insert(data)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating vaccination: $e');
      return null;
    }
  }

  // Financial Records
  static Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    try {
      final response = await _client
          .from('financial_records')
          .select()
          .order('date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching financial records: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createFinancialRecord(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('financial_records')
          .insert(data)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating financial record: $e');
      return null;
    }
  }

  // Notes
  static Future<List<Map<String, dynamic>>> getNotes([String? animalId]) async {
    try {
      var query = _client.from('notes').select();
      
      if (animalId != null) {
        query = query.eq('animal_id', animalId);
      }
      
      final response = await query.order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createNote(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('notes')
          .insert(data)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating note: $e');
      return null;
    }
  }

  // Breeding Records
  static Future<List<Map<String, dynamic>>> getBreedingRecords() async {
    try {
      final response = await _client
          .from('breeding_records')
          .select()
          .order('breeding_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching breeding records: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createBreedingRecord(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('breeding_records')
          .insert(data)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating breeding record: $e');
      return null;
    }
  }

  // Statistics calculation
  static Future<AnimalStats> getStats() async {
    try {
      final animals = await getAnimals();
      final financialRecords = await getFinancialRecords();
      
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      
      // Calculate statistics
      final totalAnimals = animals.length;
      final healthy = animals.where((a) => a.status == 'Saudável').length;
      final pregnant = animals.where((a) => a.pregnant).length;
      final underTreatment = animals.where((a) => a.status == 'Em tratamento').length;
      
      final avgWeight = totalAnimals > 0 
          ? animals.map((a) => a.weight).reduce((a, b) => a + b) / totalAnimals
          : 0.0;
      
      // Calculate revenue from this month
      final thisMonthRecords = financialRecords.where((record) {
        final date = DateTime.parse(record['date']);
        return date.year == now.year && date.month == now.month && record['type'] == 'receita';
      });
      
      final revenue = thisMonthRecords.fold(0.0, (sum, record) => sum + (record['amount'] as num).toDouble());
      
      // Get vaccinations for this month
      final vaccinations = await getVaccinations();
      final vaccinesThisMonth = vaccinations.where((v) {
        final date = DateTime.parse(v['scheduled_date']);
        return date.year == now.year && date.month == now.month;
      }).length;
      
      // Calculate births this month (simplified - based on expected delivery)
      final birthsThisMonth = animals.where((a) {
        if (a.expectedDelivery == null) return false;
        return a.expectedDelivery!.year == now.year && a.expectedDelivery!.month == now.month;
      }).length;
      
      return AnimalStats(
        totalAnimals: totalAnimals,
        healthy: healthy,
        pregnant: pregnant,
        underTreatment: underTreatment,
        vaccinesThisMonth: vaccinesThisMonth,
        birthsThisMonth: birthsThisMonth,
        avgWeight: avgWeight,
        revenue: revenue,
      );
    } catch (e) {
      print('Error calculating stats: $e');
      return AnimalStats(
        totalAnimals: 0,
        healthy: 0,
        pregnant: 0,
        underTreatment: 0,
        vaccinesThisMonth: 0,
        birthsThisMonth: 0,
        avgWeight: 0.0,
        revenue: 0.0,
      );
    }
  }

  static Future<void> createReport({
    required String title,
    required String reportType,
    Map<String, dynamic>? parameters,
    String? generatedBy,
  }) async {
    final report = {
      'title': title,
      'report_type': reportType,
      'parameters': parameters ?? {},
      'generated_by': generatedBy ?? 'system',
      'generated_at': DateTime.now().toIso8601String(),
    };

    await _client.from('reports').insert(report);
  }




}