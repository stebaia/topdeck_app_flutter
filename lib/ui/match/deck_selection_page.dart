import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/network/service/impl/deck_service_impl.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/received_invitation_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_event.dart';

@RoutePage()
/// Pagina per selezionare il mazzo da utilizzare in un match
class DeckSelectionPage extends StatefulWidget {
  /// L'invito al match
  final Map<String, dynamic> invitation;
  
  /// Constructor
  const DeckSelectionPage({
    Key? key,
    required this.invitation,
  }) : super(key: key);

  @override
  State<DeckSelectionPage> createState() => _DeckSelectionPageState();
}

class _DeckSelectionPageState extends State<DeckSelectionPage> {
  final DeckServiceImpl _deckService = DeckServiceImpl();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _userDecks = [];
  String? _selectedDeckId;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadDecks();
  }
  
  Future<void> _loadDecks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Recupera il formato dall'invito
      final format = widget.invitation['format'];
      
      // Recupera i mazzi dell'utente che corrispondono al formato dell'invito
      final allDecks = await _deckService.getUserDecks();
      
      // Filtra i mazzi per formato
      final formatDecks = allDecks.where((deck) => deck['format'] == format).toList();
      
      setState(() {
        _userDecks = formatDecks;
        
        // Se c'è almeno un mazzo, preseleziona il primo
        if (formatDecks.isNotEmpty) {
          _selectedDeckId = formatDecks.first['id'];
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore nel caricamento dei mazzi: $e';
        _isLoading = false;
      });
    }
  }
  
  void _acceptInvitationWithSelectedDeck() {
    if (_selectedDeckId == null) {
      setState(() {
        _errorMessage = 'Seleziona un mazzo per continuare';
      });
      return;
    }
    
    // Ottieni l'ID dell'invito
    final invitationId = widget.invitation['id'];
    
    // Invia l'evento di accettazione con il mazzo selezionato
    context.read<ReceivedInvitationListBloc>().add(
      AcceptInvitationWithDeckEvent(invitationId, _selectedDeckId!),
    );
    
    // Torna alla pagina precedente
    context.maybePop();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona un mazzo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _userDecks.isEmpty ? null : _acceptInvitationWithSelectedDeck,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Accetta invito e crea match',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDecks,
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }
    
    if (_userDecks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Non hai mazzi disponibili per questo formato.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Crea un nuovo mazzo prima di accettare l\'invito.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Qui potresti navigare alla pagina di creazione del mazzo
                context.maybePop();
              },
              child: const Text('Torna indietro'),
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Scegli un mazzo per il match di formato: ${widget.invitation['format']}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Invito da: ${widget.invitation['sender']['username']}',
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        ..._userDecks.map((deck) => _buildDeckItem(deck)),
      ],
    );
  }
  
  Widget _buildDeckItem(Map<String, dynamic> deck) {
    final bool isSelected = _selectedDeckId == deck['id'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDeckId = deck['id'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const Icon(Icons.circle_outlined),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Formato: ${deck['format']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 