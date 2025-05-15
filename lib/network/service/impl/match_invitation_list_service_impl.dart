import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for match invitation list operations
class MatchInvitationListServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;

  /// Get invitations received by the current user
  Future<List<Map<String, dynamic>>> getUserInvitations() async {
    try {
      final response = await client.functions.invoke(
        'see-match-invitations',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        throw Exception('Failed to load invitations: ${response.data}');
      }

      return List<Map<String, dynamic>>.from(response.data['received']);
    } catch (e) {
      print('Error in getUserInvitations: $e');
      throw Exception('Failed to load invitations: ${e.toString()}');
    }
  }

  /// Get invitations sent by the current user
  Future<List<Map<String, dynamic>>> getSentInvitations() async {
    try {
      final response = await client.functions.invoke(
        'see-match-invitations',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        throw Exception('Failed to load sent invitations: ${response.data}');
      }

      return List<Map<String, dynamic>>.from(response.data['sent']);
    } catch (e) {
      print('Error in getSentInvitations: $e');
      throw Exception('Failed to load sent invitations: ${e.toString()}');
    }
  }

  /// Accept an invitation
  Future<Map<String, dynamic>> acceptInvitation(String invitationId) async {
    try {
      final response = await client.functions.invoke(
        'accept-match-invitation',
        body: {
          'invitation_id': invitationId,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to accept invitation: ${response.data}');
      }

      // Recupera l'invito aggiornato
      final updatedInvitation = await _getInvitationById(invitationId);
      return updatedInvitation;
    } catch (e) {
      print('Error in acceptInvitation: $e');
      throw Exception('Failed to accept invitation: ${e.toString()}');
    }
  }

  /// Decline an invitation
  Future<void> declineInvitation(String invitationId) async {
    try {
      final response = await client
        .from('match_invitations')
        .update({'status': 'declined'})
        .eq('id', invitationId);

      // Check for errors
      if (response != null && response is Map && response.containsKey('error')) {
        throw Exception(response['error'] ?? 'Failed to decline invitation');
      }
    } catch (e) {
      print('Error in declineInvitation: $e');
      throw Exception('Failed to decline invitation: ${e.toString()}');
    }
  }

  /// Get a specific invitation by ID
  Future<Map<String, dynamic>> _getInvitationById(String invitationId) async {
    try {
      final response = await client
        .from('match_invitations')
        .select('*, sender:sender_id(username, nome, cognome), receiver:receiver_id(username, nome, cognome)')
        .eq('id', invitationId)
        .single();

      return response;
    } catch (e) {
      print('Error in _getInvitationById: $e');
      throw Exception('Failed to get invitation: ${e.toString()}');
    }
  }
} 