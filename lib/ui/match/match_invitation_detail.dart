import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_event.dart';
import 'package:topdeck_app_flutter/ui/match/deck_selection_page.dart';

/// Page to display match invitation details
@RoutePage()
class MatchInvitationDetailPage extends StatelessWidget {
  /// Invitation data
  final Map<String, dynamic> invitation;
  
  /// Whether this is a received invitation
  final bool isReceived;
  
  /// Constructor
  const MatchInvitationDetailPage({
    Key? key,
    required this.invitation,
    required this.isReceived,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final String senderName = invitation['sender']?['username'] ?? 'Sconosciuto';
    final String receiverName = invitation['receiver']?['username'] ?? 'Sconosciuto';
    final String opponentName = isReceived ? senderName : receiverName;
    
    final String status = invitation['status'] ?? 'pending';
    final String format = invitation['format'] ?? 'Formato sconosciuto';
    
    final String createdAtStr = invitation['created_at'] != null 
      ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(invitation['created_at']))
      : 'Data sconosciuta';
      
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Accettato';
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rifiutato';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'In attesa';
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio invito'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Stato'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 16,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Dettagli'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Formato', format),
                    _buildDetailRow('Data invito', createdAtStr),
                    if (invitation['message'] != null && invitation['message'].toString().isNotEmpty)
                      _buildDetailRow('Messaggio', invitation['message']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Partecipanti'),
                    const SizedBox(height: 8),
                    _buildDetailRow(isReceived ? 'Invitante' : 'Tu', senderName),
                    _buildDetailRow(isReceived ? 'Tu' : 'Invitato', receiverName),
                  ],
                ),
              ),
            ),
            
            if (isReceived && status == 'pending')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Azioni'),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.pushRoute(DeckSelectionPageRoute(invitation: invitation));
                                // Invece di accettare direttamente, andiamo alla pagina di selezione del mazzo
                                
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text(
                                'Accetta invito',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<InvitationListBloc>().add(
                                  DeclineInvitationEvent(invitation['id']),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text(
                                'Rifiuta invito',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 