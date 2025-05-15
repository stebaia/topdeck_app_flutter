import 'package:flutter/material.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_invitation_service_impl.dart';

/// Dialog per l'invio di inviti a match
class MatchInvitationDialog extends StatefulWidget {
  /// L'utente a cui inviare l'invito
  final UserProfile opponent;
  
  /// Il formato del match
  final DeckFormat format;
  
  /// Il mazzo selezionato dell'utente
  final String playerDeckName;
  
  /// Il mazzo selezionato dell'avversario (se disponibile)
  final String? opponentDeckName;
  
  /// Constructor
  const MatchInvitationDialog({
    Key? key,
    required this.opponent,
    required this.format,
    required this.playerDeckName,
    this.opponentDeckName,
  }) : super(key: key);

  @override
  State<MatchInvitationDialog> createState() => _MatchInvitationDialogState();
}

class _MatchInvitationDialogState extends State<MatchInvitationDialog> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  String? _errorMessage;
  bool _invitationSent = false;
  
  final MatchInvitationServiceImpl _invitationService = MatchInvitationServiceImpl();
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  
  Future<void> _sendInvitation() async {
    if (_isSending) return;
    
    setState(() {
      _isSending = true;
      _errorMessage = null;
    });
    
    try {
      final formatString = widget.format.toString().split('.').last;
      
      await _invitationService.sendInvitation(
        receiverId: widget.opponent.id,
        format: formatString,
        message: _messageController.text.isNotEmpty ? _messageController.text : null,
      );
      
      setState(() {
        _isSending = false;
        _invitationSent = true;
      });
      
      // Chiudiamo la dialog dopo 2 secondi
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    } catch (e) {
      setState(() {
        _isSending = false;
        _errorMessage = 'Errore nell\'invio dell\'invito: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: _invitationSent
            ? _buildSuccessContent()
            : _buildInvitationForm(),
      ),
    );
  }
  
  Widget _buildInvitationForm() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invia invito di match',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Destinatario
          Row(
            children: [
              const Icon(Icons.person, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Avversario:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.opponent.username),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Formato
          Row(
            children: [
              const Icon(Icons.format_list_bulleted, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Formato:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.format.toString().split('.').last.toUpperCase()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Il tuo mazzo
          Row(
            children: [
              const Icon(Icons.inventory_2, color: Colors.purple),
              const SizedBox(width: 8),
              const Text(
                'Il tuo mazzo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.playerDeckName),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Campo messaggio
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Messaggio (opzionale)',
              border: OutlineInputBorder(),
              hintText: 'Inserisci un messaggio per il tuo avversario...',
            ),
          ),
          
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Pulsanti
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSending ? null : () => Navigator.of(context).pop(false),
                child: const Text('Annulla'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSending ? null : _sendInvitation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Invia invito'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        const SizedBox(height: 20),
        const Text(
          'Invito inviato con successo!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Attendi che ${widget.opponent.username} accetti la tua sfida.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 