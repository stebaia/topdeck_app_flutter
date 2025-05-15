import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_state.dart';

@RoutePage()
class DeckSelectionPage extends StatefulWidget {
  final DeckFormat format;
  
  const DeckSelectionPage({
    super.key,
    required this.format,
  });

  @override
  State<DeckSelectionPage> createState() => _DeckSelectionPageState();
}

class _DeckSelectionPageState extends State<DeckSelectionPage> {
  @override
  void initState() {
    super.initState();
    // Verifichiamo che l'utente sia autenticato prima di caricare i mazzi
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      // Carica i mazzi quando la pagina viene inizializzata
      context.read<MatchWizardBloc>().add(LoadUserDecksByFormatEvent(widget.format));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Ottieni l'utente corrente
    final currentUser = supabase.auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona deck'),
        centerTitle: true,
      ),
      body: currentUser == null 
          ? _buildUnauthenticatedView()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Seleziona il tuo deck per formato ${_formatToDisplayName(widget.format)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: BlocConsumer<MatchWizardBloc, MatchWizardState>(
                      listener: (context, state) {
                        if (state is MatchWizardErrorState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is MatchWizardLoadingState) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is UserDecksLoadedState && state.format == widget.format) {
                          return _buildDecksList(state.decks);
                        } else if (state is MatchWizardErrorState) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Errore: ${state.errorMessage}',
                                  style: TextStyle(color: Colors.red[700]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<MatchWizardBloc>().add(
                                      LoadUserDecksByFormatEvent(widget.format)
                                    );
                                  },
                                  child: const Text('Riprova'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Se lo stato non è quello che ci aspettiamo, richiedi i dati
                          return const Center(child: Text('Caricamento mazzi...'));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildUnauthenticatedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Devi essere autenticato per visualizzare i mazzi',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Normalmente qui si farebbe il redirect alla pagina di login
              context.router.popUntilRoot();
            },
            child: const Text('Torna alla Home'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDecksList(List<Deck> decks) {
    if (decks.isEmpty) {
      return const Center(
        child: Text(
          'Nessun mazzo trovato per questo formato',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              deck.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Creato il ${_formatDate(deck.createdAt)}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.router.push(
                OpponentSearchPageRoute(
                  format: widget.format,
                  selectedDeckId: deck.id,
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  String _formatToDisplayName(DeckFormat format) {
    switch (format) {
      case DeckFormat.advanced:
        return 'Advanced';
      case DeckFormat.goat:
        return 'GOAT';
      case DeckFormat.edison:
        return 'Edison';
      case DeckFormat.hat:
        return 'HAT';
      case DeckFormat.custom:
        return 'Custom';
    }
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
} 