import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Valida em debug que as variáveis obrigatórias estão definidas.
  static void validate() {
    assert(
      supabaseUrl.isNotEmpty,
      'SUPABASE_URL não encontrada. Crie o arquivo .env baseado no .env.example.',
    );
    assert(
      supabaseAnonKey.isNotEmpty,
      'SUPABASE_ANON_KEY não encontrada. Crie o arquivo .env baseado no .env.example.',
    );
  }
}
