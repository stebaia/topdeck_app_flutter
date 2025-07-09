import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Service implementation for match invitation list operations
class MatchInvitationListServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;

  

  /// Get all invitations (both received and sent) for the current user
  Future<List<Map<String, dynamic>>> getAllInvitations() async {
    try {
      final response = await client.functions.invoke(
        'see-match-invitations',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        throw Exception('Failed to load invitations: ${response.data}');
      }

      // La edge function ora restituisce direttamente una lista combinata
      final allInvitations = List<Map<String, dynamic>>.from(response.data);
      
      print('Loaded ${allInvitations.length} total invitations');
      return allInvitations;
    } catch (e) {
      print('Error in getAllInvitations: $e');
      throw Exception('Failed to load invitations: ${e.toString()}');
    }
  }

  /// Get invitations received by the current user
  Future<List<Map<String, dynamic>>> getReceivedInvitations() async {
    try {
      final response = await client.functions.invoke(
        'see-match-invitations/received-invitations',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        throw Exception('Failed to load received invitations: ${response.data}');
      }

      // Questo endpoint restituisce solo gli inviti ricevuti
      final receivedInvitations = List<Map<String, dynamic>>.from(response.data);
      
      print('Loaded ${receivedInvitations.length} received invitations');
      return receivedInvitations;
    } catch (e) {
      print('Error in getReceivedInvitations: $e');
      throw Exception('Failed to load received invitations: ${e.toString()}');
    }
  }

  /// Get invitations sent by the current user
  Future<List<Map<String, dynamic>>> getSentInvitations() async {
    try {
      final response = await client.functions.invoke(
        'see-match-invitations/sent-invitations',
        method: HttpMethod.get,
      );

      if (response.status != 200) {
        throw Exception('Failed to load sent invitations: ${response.data}');
      }

      // Questo endpoint restituisce solo gli inviti inviati
      final sentInvitations = List<Map<String, dynamic>>.from(response.data);
      
      print('Loaded ${sentInvitations.length} sent invitations');
      return sentInvitations;
    } catch (e) {
      print('Error in getSentInvitations: $e');
      throw Exception('Failed to load sent invitations: ${e.toString()}');
    }
  }

  /// Accept an invitation with a selected deck
  Future<Map<String, dynamic>> acceptInvitation(String invitationId, {String? selectedDeckId}) async {
    try {
      print('Trying to accept invitation: $invitationId with deck: $selectedDeckId');
      
      final response = await client.functions.invoke(
        'hyper-api',
        body: {
          'invitation_id': invitationId,
          'selected_deck_id': selectedDeckId,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to accept invitation via Edge Function: ${response.data}');
      }

      print('Successfully accepted invitation and created match: ${response.data}');
      
      // Se tutto è andato bene, ritorniamo i dati completi della risposta
      return response.data;
    } catch (e) {
      print('Error in acceptInvitation: $e');
      
      // Se l'Edge Function fallisce, tentiamo di aggiornare solo lo stato dell'invito direttamente
      try {
        final currentUser = client.auth.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }
        
        // Verifica che l'invito appartenga all'utente
        final invitation = await client
          .from('match_invitations')
          .select()
          .eq('id', invitationId)
          .eq('receiver_id', currentUser.id)
          .single();
        
        // Aggiorna lo stato dell'invito
        await client
          .from('match_invitations')
          .update({'status': 'accepted'})
          .eq('id', invitationId);
        
        // Ottieni l'invito aggiornato
        final updatedInvitation = await _getInvitationById(invitationId);
        print('Successfully accepted invitation directly in DB (fallback)');
        return {'invitation': updatedInvitation, 'message': 'Invitation accepted but match was not created'};
      } catch (dbError) {
        print('Complete failure in accepting invitation: $dbError');
        throw Exception('Failed to accept invitation: ${e.toString()}');
      }
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