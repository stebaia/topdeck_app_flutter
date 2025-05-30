import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/tournament_invitation.dart';
import 'package:topdeck_app_flutter/network/service/tournament_invitation_service.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Implementation of TournamentInvitationService using Supabase
class TournamentInvitationServiceImpl implements TournamentInvitationService {
  static const String _tableName = 'tournament_invitations';

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
        .order('created_at', ascending: false);
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

  @override
  Future<List<Map<String, dynamic>>> findByTournament(String tournamentId) async {
    final response = await supabase
        .from(_tableName)
        .select()
        .eq('tournament_id', tournamentId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> findByReceiver(String receiverId) async {
    final response = await supabase
        .from(_tableName)
        .select()
        .eq('receiver_id', receiverId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> findBySender(String senderId) async {
    final response = await supabase
        .from(_tableName)
        .select()
        .eq('sender_id', senderId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> findByStatus(TournamentInvitationStatus status) async {
    final response = await supabase
        .from(_tableName)
        .select()
        .eq('status', status.name)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> updateStatus(String id, TournamentInvitationStatus status) async {
    final response = await supabase
        .from(_tableName)
        .update({'status': status.name})
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  @override
  Future<Map<String, dynamic>?> findPendingInvitation(String tournamentId, String receiverId) async {
    final response = await supabase
        .from(_tableName)
        .select()
        .eq('tournament_id', tournamentId)
        .eq('receiver_id', receiverId)
        .eq('status', 'pending')
        .maybeSingle();
    return response;
  }

  @override
  Future<Map<String, dynamic>> sendInvitation({
    required String tournamentId,
    required String receiverId,
    String? message,
  }) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Check if there's already a pending invitation
    final existingInvitation = await findPendingInvitation(tournamentId, receiverId);
    if (existingInvitation != null) {
      throw Exception('An invitation for this tournament is already pending for this user');
    }

    final invitation = TournamentInvitation.create(
      tournamentId: tournamentId,
      senderId: currentUser.id,
      receiverId: receiverId,
      message: message,
    );

    return await insert(invitation.toJson());
  }
} 