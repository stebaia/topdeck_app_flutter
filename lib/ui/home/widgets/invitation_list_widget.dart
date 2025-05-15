import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_state.dart';
import 'package:intl/intl.dart';

/// Widget that displays a list of match invitations
class InvitationListWidget extends StatefulWidget {
  const InvitationListWidget({Key? key}) : super(key: key);

  @override
  State<InvitationListWidget> createState() => _InvitationListWidgetState();
}

class _InvitationListWidgetState extends State<InvitationListWidget> {
  @override
  void initState() {
    super.initState();
    context.read<InvitationListBloc>().add(LoadInvitationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvitationListBloc, InvitationListState>(
      builder: (context, state) {
        if (state is InvitationListLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is InvitationListLoadedState) {
          return _buildInvitationList(state.invitations);
        } else if (state is InvitationListErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Errore nel caricamento delle inviti',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<InvitationListBloc>().add(LoadInvitationsEvent()),
                  child: const Text('Riprova'),
                ),
              ],
            ),
          );
        } else if (state is InvitationProcessingState) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Elaborazione in corso...'),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text('Nessun invito trovato'),
          );
        }
      },
    );
  }

  Widget _buildInvitationList(List<Map<String, dynamic>> invitations) {
    if (invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nessun invito ricevuto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gli inviti ricevuti appariranno qui',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<InvitationListBloc>().add(RefreshInvitationsEvent());
      },
      child: ListView.builder(
        itemCount: invitations.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return _buildInvitationCard(invitations[index]);
        },
      ),
    );
  }

  Widget _buildInvitationCard(Map<String, dynamic> invitation) {
    final String senderName = invitation['sender']?['username'] ?? 'Sconosciuto';
    final String format = invitation['format']?.toUpperCase() ?? 'SCONOSCIUTO';
    final String? message = invitation['message'];
    
    final date = invitation['created_at'] != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(invitation['created_at']))
        : 'Data sconosciuta';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(senderName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Ti ha invitato a giocare',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(format),
                  backgroundColor: Colors.blue.shade100,
                ),
              ],
            ),
            
            if (message != null && message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(message),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Ricevuto il $date',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _declineInvitation(invitation['id']),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Rifiuta'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _acceptInvitation(invitation['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accetta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _acceptInvitation(String invitationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accettare l\'invito?'),
        content: const Text('Vuoi accettare l\'invito a giocare questa partita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<InvitationListBloc>().add(AcceptInvitationEvent(invitationId));
            },
            child: const Text('Accetta'),
          ),
        ],
      ),
    );
  }
  
  void _declineInvitation(String invitationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rifiutare l\'invito?'),
        content: const Text('Vuoi rifiutare l\'invito a giocare questa partita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<InvitationListBloc>().add(DeclineInvitationEvent(invitationId));
            },
            child: const Text('Rifiuta'),
          ),
        ],
      ),
    );
  }
} 