import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'dart:convert';

/// Service implementation for match invitations
class MatchInvitationServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;
  
  /// Send a match invitation to another user
  Future<Map<String, dynamic>> sendInvitation({
    required String receiverId,
    required String format,
    String? message,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      final session = await client.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        throw AuthException('No valid session found');
      }
      
      // Prima proviamo con l'edge function
      try {
        print('Sending match invitation via edge function');
        final response = await client.functions.invoke(
          'send-match-invitation',
          body: {
            'receiver_id': receiverId,
            'format': format,
            'message': message,
          },
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        );
        
        if (response.status != 200) {
          print('Error response from edge function: ${response.status} - ${response.data}');
          throw Exception(response.data['error'] ?? 'Failed to send match invitation');
        }
        
        return response.data;
      } catch (e) {
        print('Error using edge function, falling back to direct DB: $e');
        // Se l'edge function fallisce, usiamo l'approccio diretto
        return await sendInvitationDirectly(
          receiverId: receiverId,
          format: format,
          message: message,
        );
      }
    } catch (e) {
      print('Failed to send match invitation: $e');
      throw Exception('Failed to send match invitation: $e');
    }
  }
  
  /// Send a match invitation directly using database
  Future<Map<String, dynamic>> sendInvitationDirectly({
    required String receiverId,
    required String format,
    String? message,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      print('Sending match invitation directly to DB');
      
      final invitationId = await client
        .from('match_invitations')
        .insert({
          'sender_id': currentUser.id,
          'receiver_id': receiverId,
          'format': format,
          'message': message,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();
      
      return {
        'success': true,
        'message': 'Invitation sent successfully',
        'invitation_id': invitationId['id'],
      };
    } catch (e) {
      print('Failed to send match invitation directly: $e');
      throw Exception('Failed to send match invitation: $e');
    }
  }
  
  /// Get all received invitations for the current user
  Future<List<Map<String, dynamic>>> getReceivedInvitations() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      final response = await client
        .from('match_invitations')
        .select('*, sender:sender_id(username, nome, cognome)')
        .eq('receiver_id', currentUser.id)
        .eq('status', 'pending');
      
      return response;
    } catch (e) {
      throw Exception('Failed to get received invitations: $e');
    }
  }
  
  /// Get all sent invitations by the current user
  Future<List<Map<String, dynamic>>> getSentInvitations() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      final response = await client
        .from('match_invitations')
        .select('*, receiver:receiver_id(username, nome, cognome)')
        .eq('sender_id', currentUser.id);
      
      return response;
    } catch (e) {
      throw Exception('Failed to get sent invitations: $e');
    }
  }
  
  /// Accept a match invitation
  Future<Map<String, dynamic>> acceptInvitation(String invitationId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      // Prima verifichiamo che l'invito sia per l'utente corrente
      final invitation = await client
        .from('match_invitations')
        .select()
        .eq('id', invitationId)
        .eq('receiver_id', currentUser.id)
        .single();
      
      // Aggiorniamo lo stato dell'invito
      await client
        .from('match_invitations')
        .update({'status': 'accepted'})
        .eq('id', invitationId);
      
      return {
        'success': true,
        'message': 'Invitation accepted',
        'invitation': invitation,
      };
    } catch (e) {
      throw Exception('Failed to accept invitation: $e');
    }
  }
  
  /// Decline a match invitation
  Future<Map<String, dynamic>> declineInvitation(String invitationId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      // Aggiorniamo lo stato dell'invito
      await client
        .from('match_invitations')
        .update({'status': 'declined'})
        .eq('id', invitationId)
        .eq('receiver_id', currentUser.id);
      
      return {
        'success': true,
        'message': 'Invitation declined',
      };
    } catch (e) {
      throw Exception('Failed to decline invitation: $e');
    }
  }

  Future<void> cancelInvitation(String invitationId) async {
    try {
      final session = await client.auth.currentSession;
      if(session == null || session.accessToken.isEmpty) {
        throw AuthException('No valid session found');
      }
      
      final response = await client.functions.invoke('cancel-match-invitation', body: {
        'invitation_id': invitationId,
        
      }, headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },);

      if (response.status != 200) {
        throw Exception('Failed to cancel invitation: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to cancel invitation: $e');
    }
  }
} 