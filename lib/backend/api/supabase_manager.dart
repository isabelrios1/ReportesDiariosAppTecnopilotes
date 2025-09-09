// backend/api/supabase_manager.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static final SupabaseManager _instance = SupabaseManager._internal();
  factory SupabaseManager() => _instance;
  SupabaseManager._internal();

  // ✅ Cambiar a método getter que verifica inicialización
  SupabaseClient get client {
    if (!Supabase.instance.isInitialized) {
      throw Exception('Supabase no inicializado. Llama a ensureConnected() primero');
    }
    return Supabase.instance.client;
  }

  bool get isConnected => Supabase.instance.isInitialized;

  String? get userId => isConnected ? client.auth.currentUser?.id : null;

  Future<void> ensureConnected() async {
    if (!isConnected) {
      await Supabase.initialize(
        url: 'https://velslnijjypssjehoucj.supabase.co',
        anonKey: 'tu-publishable-key-aqui',
      );
    }
  }

  void handleSupabaseError(Exception e) {
    print('Error de Supabase: $e');
    throw Exception('Error de conexión: $e');
  }
}