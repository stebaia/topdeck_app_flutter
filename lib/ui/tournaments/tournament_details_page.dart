import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/tournament.dart';
import 'package:topdeck_app_flutter/model/entities/tournament_participant.dart';
import 'package:topdeck_app_flutter/repositories/tournament_participant_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_operations_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_operations_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_state.dart';

/// Page that displays tournament details and manages participants
class TournamentDetailsPage extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailsPage({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentDetailsPage> createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> {
  List<TournamentParticipant> _participants = [];
  bool _isLoadingParticipants = false;
  String? _inviteCode;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
    _inviteCode = widget.tournament.inviteCode;
  }

  Future<void> _loadParticipants() async {
    setState(() {
      _isLoadingParticipants = true;
    });

    try {
      final participants = await context
          .read<TournamentParticipantRepository>()
          .findByTournament(widget.tournament.id);
      
      setState(() {
        _participants = participants;
        _isLoadingParticipants = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingParticipants = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel caricamento partecipanti: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament.name),
        actions: [
          if (widget.tournament.status == TournamentStatus.upcoming)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                if (!widget.tournament.isPublic)
                  const PopupMenuItem(
                    value: 'share_code',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Condividi codice'),
                      ],
                    ),
                  ),
                if (_inviteCode == null && !widget.tournament.isPublic)
                  const PopupMenuItem(
                    value: 'generate_code',
                    child: Row(
                      children: [
                        Icon(Icons.vpn_key),
                        SizedBox(width: 8),
                        Text('Genera codice'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'start_tournament',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow),
                      SizedBox(width: 8),
                      Text('Avvia torneo'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: BlocListener<TournamentOperationsBloc, TournamentOperationState>(
        listener: (context, state) {
          if (state is InviteCodeGeneratedState && 
              state.tournamentId == widget.tournament.id) {
            setState(() {
              _inviteCode = state.inviteCode;
            });
            _showInviteCodeDialog(state.inviteCode);
          } else if (state is TournamentOperationErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: _loadParticipants,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTournamentInfo(),
                const SizedBox(height: 24),
                _buildParticipantsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.tournament.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(widget.tournament.status),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.category,
              'Formato',
              widget.tournament.format,
            ),
            if (widget.tournament.league != null)
              _buildInfoRow(
                Icons.emoji_events,
                'Lega',
                widget.tournament.league!,
              ),
            _buildInfoRow(
              widget.tournament.isPublic ? Icons.public : Icons.lock,
              'Tipo',
              widget.tournament.isPublic ? 'Pubblico' : 'Privato',
            ),
            if (widget.tournament.maxParticipants != null)
              _buildInfoRow(
                Icons.people,
                'Max partecipanti',
                '${_participants.length}/${widget.tournament.maxParticipants}',
              )
            else
              _buildInfoRow(
                Icons.people,
                'Partecipanti',
                '${_participants.length}',
              ),
            if (_inviteCode != null)
              _buildInfoRow(
                Icons.vpn_key,
                'Codice invito',
                _inviteCode!,
                copyable: true,
              ),
            if (widget.tournament.startDate != null)
              _buildInfoRow(
                Icons.event,
                'Data inizio',
                _formatDate(widget.tournament.startDate!),
              ),
            if (widget.tournament.startTime != null)
              _buildInfoRow(
                Icons.access_time,
                'Ora inizio',
                widget.tournament.startTime!,
              ),
            if (widget.tournament.description != null)
              _buildInfoRow(
                Icons.description,
                'Descrizione',
                widget.tournament.description!,
              ),
            if (widget.tournament.createdAt != null)
              _buildInfoRow(
                Icons.calendar_today,
                'Creato il',
                _formatDate(widget.tournament.createdAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(value),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyToClipboard(value),
              tooltip: 'Copia',
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TournamentStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case TournamentStatus.upcoming:
        color = Colors.blue;
        label = 'In arrivo';
        break;
      case TournamentStatus.ongoing:
        color = Colors.green;
        label = 'In corso';
        break;
      case TournamentStatus.completed:
        color = Colors.grey;
        label = 'Completato';
        break;
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Partecipanti',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_isLoadingParticipants)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_participants.isEmpty && !_isLoadingParticipants)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nessun partecipante ancora',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.tournament.isPublic
                          ? 'I giocatori possono unirsi liberamente'
                          : 'Condividi il codice invito per far unire i giocatori',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _participants.length,
            itemBuilder: (context, index) {
              final participant = _participants[index];
              return _buildParticipantCard(participant, index + 1);
            },
          ),
      ],
    );
  }

  Widget _buildParticipantCard(TournamentParticipant participant, int position) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            position.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('Giocatore ${participant.userId.substring(0, 8)}'),
        subtitle: participant.joinedAt != null
            ? Text('Iscritto il ${_formatDate(participant.joinedAt!)}')
            : null,
        trailing: widget.tournament.status == TournamentStatus.upcoming
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeParticipant(participant),
                tooltip: 'Rimuovi partecipante',
              )
            : null,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share_code':
        if (_inviteCode != null) {
          _showInviteCodeDialog(_inviteCode!);
        }
        break;
      case 'generate_code':
        context.read<TournamentOperationsBloc>().add(
          GenerateInviteCodeOperationEvent(widget.tournament.id),
        );
        break;
      case 'start_tournament':
        _showStartTournamentDialog();
        break;
    }
  }

  void _showInviteCodeDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Codice Invito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Condividi questo codice per far unire i giocatori al torneo:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(code),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _showStartTournamentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avvia Torneo'),
        content: Text(
          'Sei sicuro di voler avviare il torneo con ${_participants.length} partecipanti?\n\n'
          'Una volta avviato, non sarà più possibile aggiungere nuovi partecipanti.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startTournament();
            },
            child: const Text('Avvia'),
          ),
        ],
      ),
    );
  }

  void _startTournament() {
    // TODO: Implement tournament start logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avvio torneo - Coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _removeParticipant(TournamentParticipant participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rimuovi Partecipante'),
        content: const Text('Sei sicuro di voler rimuovere questo partecipante dal torneo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await context
                    .read<TournamentParticipantRepository>()
                    .leaveTournament(participant.tournamentId, participant.userId);
                
                _loadParticipants();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Partecipante rimosso con successo'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Errore nella rimozione: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Rimuovi'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copiato negli appunti'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 