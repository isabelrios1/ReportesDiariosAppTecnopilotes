// lib/backend/api/supabase_manager.dart
import 'package:reportes_diarios/backend/api/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager{
  final SupabaseClient client;

  SupabaseManager() : client = SupabaseService.client;

  Future<void> ensureConnected() async {
    if (!SupabaseService.isInitialized) {
      throw Exception('Supabase no está inicializado. Llama a SupabaseService.initialize() primero');
    }

    try {
      // Consulta de prueba para verificar conexión
      await client.from('maquinaria').select('count').limit(1);
    } catch (e) {
      throw Exception('Error de conexión con Supabase: $e');
    }
  }

  void handleSupabaseError(Object e) {}
}