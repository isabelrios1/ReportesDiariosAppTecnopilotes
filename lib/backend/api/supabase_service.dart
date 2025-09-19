// lib/backend/api/supabase_service.dart
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        await Supabase.initialize(
          url: 'https://velslnijjypssjehoucj.supabase.co',
          anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlbHNsbmlqanlwc3NqZWhvdWNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MTgzOTksImV4cCI6MjA3MDQ5NDM5OX0.zwK7vM4y-EgeKNAESmszAiIlanC-WR9GFQZPh0Ba5mo',
        );
        _isInitialized = true;
        debugPrint('✅ SupabaseService inicializado');
      } catch (e) {
        debugPrint('❌ Error inicializando SupabaseService: $e');
        rethrow; // Relanza el error para manejarlo en main()
      }
    }
  }

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('SupabaseService no está inicializado. Llama a SupabaseService.initialize() primero');
    }
    return Supabase.instance.client;
  }

  static bool get isInitialized => _isInitialized;
}