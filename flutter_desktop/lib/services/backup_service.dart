import 'package:supabase/supabase.dart';
import '../data/local_db.dart';

class BackupService {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  BackupService({
    required AppDatabase db,
    required String supabaseUrl,
    required String supabaseAnonKey,
  })  : _db = db,
        _supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);

  static const List<String> _order = [
    'animals',
    'breeding_records',
    'financial_records',
    'medications',
    'notes',
    'reports',
    'vaccinations',
    'push_tokens',
  ];

  static const Map<String, List<String>> _cols = {
    'animals': [
      'id','code','name','species','breed','gender','birth_date','weight','status',
      'location','last_vaccination','pregnant','expected_delivery','health_issue',
      'created_at','updated_at','name_color','category','birth_weight',
      'weight_30_days','weight_60_days','weight_90_days',
    ],
    'breeding_records': [
      'id','female_animal_id','male_animal_id','breeding_date','expected_birth',
      'status','notes','created_at','updated_at',
    ],
    'financial_records': [
      'id','type','category','description','amount','date','animal_id','created_at','updated_at',
    ],
    'medications': [
      'id','animal_id','medication_name','date','next_date','dosage',
      'veterinarian','notes','created_at','updated_at',
    ],
    'notes': [
      'id','animal_id','title','content','category','priority','date',
      'created_by','created_at','updated_at',
    ],
    'push_tokens': [
      'id','token','platform','device_info','created_at',
    ],
    'reports': [
      'id','title','report_type','parameters','generated_at','generated_by',
    ],
    'vaccinations': [
      'id','animal_id','vaccine_name','vaccine_type','scheduled_date',
      'applied_date','veterinarian','notes','status','created_at','updated_at',
    ],
  };

  static String _onConflict(String table) {
    // Use a valid unique/PK column for upsert conflicts
    return 'id';
  }

  Stream<String> backupAll() async* {
    for (final table in _order) {
      final columns = _cols[table]!;
      yield 'Lendo $table...';
      final rows = await _db.db.query(table, columns: columns);
      if (rows.isEmpty) {
        yield '$table: nada a enviar';
        continue;
      }
      final payload = rows.map((m) => Map<String, dynamic>.from(m)).toList();

      yield 'Enviando $table (${payload.length})...';
      await _supabase.from(table).upsert(payload, onConflict: _onConflict(table));

      yield '$table: OK';
    }
    yield 'Backup concluído ✅';
  }
}
