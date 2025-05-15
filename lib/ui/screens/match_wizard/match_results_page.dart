import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/model/entities/match.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_state.dart';

@RoutePage()
class MatchResultsPage extends StatefulWidget {
  final DeckFormat format;
  final String playerDeckId;
  final String opponentId;
  
  const MatchResultsPage({
    super.key,
    required this.format,
    required this.playerDeckId,
    required this.opponentId,
  });

  @override
  State<MatchResultsPage> createState() => _MatchResultsPageState();
}

class _MatchResultsPageState extends State<MatchResultsPage> {
  String? _opponentDeckId;
  String? _winnerId;
  
  @override
  void initState() {
    super.initState();
    // Load opponent decks when the page is initialized
    context.read<MatchWizardBloc>().add(LoadOpponentDecksEvent(widget.opponentId));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Risultati partita'),
        centerTitle: true,
      ),
      body: BlocConsumer<MatchWizardBloc, MatchWizardState>(
        listener: (context, state) {
          if (state is MatchSavedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Partita salvata con successo!'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate back to home
            context.router.popUntilRoot();
          } else if (state is MatchWizardErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MatchWizardLoadingState || state is SavingMatchState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MatchWizardErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MatchWizardBloc>().add(LoadOpponentDecksEvent(widget.opponentId));
                    },
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          } else if (state is OpponentDecksLoadedState) {
            return _buildResultsForm(state.decks);
          } else {
            return const Center(child: Text('Caricamento dati in corso...'));
          }
        },
      ),
    );
  }
  
  Widget _buildResultsForm(List<Map<String, dynamic>> opponentDecks) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Inserisci i risultati della partita',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Opponent deck selection
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deck dell\'avversario',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  opponentDecks.isEmpty
                      ? const Text('Nessun deck disponibile per questo avversario', 
                          style: TextStyle(fontStyle: FontStyle.italic))
                      : _buildDeckDropdown(opponentDecks),
                ],
              ),
            ),
          ),
          
          // Winner selection
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vincitore',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildWinnerSelection(),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Save button
          ElevatedButton(
            onPressed: _canSave() 
                ? () => _saveMatch() 
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('SALVA PARTITA'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeckDropdown(List<Map<String, dynamic>> decks) {
    return DropdownButtonFormField<String>(
      value: _opponentDeckId,
      decoration: InputDecoration(
        hintText: 'Seleziona deck',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: decks.map((deck) {
        return DropdownMenuItem<String>(
          value: deck['id'],
          child: Text(deck['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _opponentDeckId = value;
        });
      },
    );
  }
  
  Widget _buildWinnerSelection() {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      return const Text('Errore: utente non autenticato');
    }
    
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Ho vinto io'),
          value: currentUser.id,
          groupValue: _winnerId,
          onChanged: (value) {
            setState(() {
              _winnerId = value;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Ha vinto l\'avversario'),
          value: widget.opponentId,
          groupValue: _winnerId,
          onChanged: (value) {
            setState(() {
              _winnerId = value;
            });
          },
        ),
      ],
    );
  }
  
  bool _canSave() {
    return _opponentDeckId != null && _winnerId != null;
  }
  
  void _saveMatch() {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore: utente non autenticato'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    context.read<MatchWizardBloc>().add(
      SaveMatchResultEvent(
        playerId: currentUser.id,
        opponentId: widget.opponentId,
        playerDeckId: widget.playerDeckId,
        opponentDeckId: _opponentDeckId!,
        format: widget.format,
        winnerId: _winnerId!,
      ),
    );
  }
} 