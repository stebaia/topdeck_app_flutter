import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for match creation using Edge Functions
class MatchCreationServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;
  
  /// Creates a new match using the Edge Function
  Future<Map<String, dynamic>> createMatch({
    required String homeTeam,
    required String awayTeam,
    required DateTime matchDate,
  }) async {
    try {
      final response = await client.functions.invoke(
        'create-match',
        body: {
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'matchDate': matchDate.toIso8601String(),
        },
      );
      
      if (response.status != 201) {
        throw Exception(response.data['error'] ?? 'Failed to create match');
      }
      
      return response.data[0];
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }
} 