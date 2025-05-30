import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/tournament_participant.dart';
import 'package:topdeck_app_flutter/network/service/base_service.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Implementation of TournamentParticipantService using Supabase
class TournamentParticipantServiceImpl implements BaseService {
  static const String _tableName = 'tournament_participants';

  @override
  String get tableName => _tableName;

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await supabase
        .from(_tableName)
        .insert(data)
        .select()
        .single();
    return response;
  }

  @override
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await supabase
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await supabase
        .from(_tableName)
        .select()
        .order('joined_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    final response = await supabase
        .from(_tableName)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  @override
  Future<void> delete(String id) async {
    await supabase
        .from(_tableName)
        .delete()
        .eq('id', id);
  }

  /// Finds participants by tournament ID
  Future<List<Map<String, dynamic>>> findByTournament(String tournamentId) async {
    final response = await supabase
        .from(_tableName)
        .select('*, profiles(id, username, display_name)')
        .eq('tournament_id', tournamentId)
        .order('joined_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Finds tournaments by user ID
  Future<List<Map<String, dynamic>>> findByUser(String userId) async {
    final response = await supabase
        .from(_tableName)
        .select('*, tournaments(*)')
        .eq('user_id', userId)
        .order('joined_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Checks if a user is already participating in a tournament
  Future<bool> isUserParticipating(String tournamentId, String userId) async {
    final response = await supabase
        .from(_tableName)
        .select('id')
        .eq('tournament_id', tournamentId)
        .eq('user_id', userId)
        .maybeSingle();
    return response != null;
  }

  /// Joins a user to a tournament
  Future<Map<String, dynamic>> joinTournament(String tournamentId, String userId) async {
    final participant = TournamentParticipant.create(
      tournamentId: tournamentId,
      userId: userId,
    );
    return await insert(participant.toJson());
  }

  /// Removes a user from a tournament
  Future<void> leaveTournament(String tournamentId, String userId) async {
    await supabase
        .from(_tableName)
        .delete()
        .eq('tournament_id', tournamentId)
        .eq('user_id', userId);
  }

  /// Gets the count of participants for a tournament
  Future<int> getParticipantCount(String tournamentId) async {
    final count = await supabase
        .from(_tableName)
        .count()
        .eq('tournament_id', tournamentId);
    return count;
  }
} 