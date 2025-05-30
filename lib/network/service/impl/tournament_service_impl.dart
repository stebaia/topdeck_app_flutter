import 'package:topdeck_app_flutter/model/entities/tournament.dart';
import 'package:topdeck_app_flutter/network/service/impl/base_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/tournament_participant_service_impl.dart';
import 'package:uuid/uuid.dart';

/// Service implementation for the tournaments table
class TournamentServiceImpl extends BaseServiceImpl {
  final TournamentParticipantServiceImpl _participantService;

  /// Constructor
  TournamentServiceImpl(this._participantService);

  @override
  String get tableName => 'tournaments';
  
  /// Finds tournaments by creator ID
  Future<List<Map<String, dynamic>>> findByCreator(String creatorId) async {
    final response = await client.from(tableName)
        .select()
        .eq('created_by', creatorId);
    return response;
  }
  
  /// Finds tournaments by status
  Future<List<Map<String, dynamic>>> findByStatus(TournamentStatus status) async {
    final response = await client.from(tableName)
        .select()
        .eq('status', status.name);
    return response;
  }
  
  /// Finds tournaments by format
  Future<List<Map<String, dynamic>>> findByFormat(String format) async {
    final response = await client.from(tableName)
        .select()
        .eq('format', format);
    return response;
  }
  
  /// Updates the status of a tournament
  Future<Map<String, dynamic>> updateStatus(String id, TournamentStatus status) async {
    final response = await client.from(tableName)
        .update({'status': status.name})
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Finds public tournaments that are open for registration
  Future<List<Map<String, dynamic>>> findPublicTournaments({String? excludeCreatedBy}) async {
    var query = client.from(tableName)
        .select()
        .eq('is_public', true)
        .eq('status', 'upcoming');
    
    // Exclude tournaments created by a specific user if provided
    if (excludeCreatedBy != null) {
      query = query.neq('created_by', excludeCreatedBy);
    }
    
    final response = await query.order('created_at', ascending: false);
    return response;
  }

  /// Finds a tournament by invite code
  Future<Map<String, dynamic>?> findByInviteCode(String inviteCode) async {
    final response = await client.from(tableName)
        .select()
        .eq('invite_code', inviteCode)
        .maybeSingle();
    return response;
  }

  /// Generates a unique invite code for a tournament
  Future<String> generateInviteCode(String tournamentId) async {
    String inviteCode;
    bool isUnique = false;
    
    // Generate a unique 8-character code
    while (!isUnique) {
      inviteCode = const Uuid().v4().substring(0, 8).toUpperCase();
      
      // Check if this code already exists
      final existing = await findByInviteCode(inviteCode);
      if (existing == null) {
        // Update the tournament with this invite code
        await client.from(tableName)
            .update({'invite_code': inviteCode})
            .eq('id', tournamentId);
        return inviteCode;
      }
    }
    
    throw Exception('Failed to generate unique invite code');
  }

  /// Gets the current participant count for a tournament
  Future<int> getParticipantCount(String tournamentId) async {
    return await _participantService.getParticipantCount(tournamentId);
  }

  /// Checks if a tournament has available spots
  Future<bool> hasAvailableSpots(String tournamentId) async {
    // Get tournament details
    final tournament = await client.from(tableName)
        .select('max_participants')
        .eq('id', tournamentId)
        .single();
    
    final maxParticipants = tournament['max_participants'] as int?;
    
    // If no limit is set, there are always available spots
    if (maxParticipants == null) {
      return true;
    }
    
    // Check current participant count
    final currentCount = await getParticipantCount(tournamentId);
    return currentCount < maxParticipants;
  }
} 