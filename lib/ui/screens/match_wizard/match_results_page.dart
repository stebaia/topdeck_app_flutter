import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/model/entities/match.dart';
import 'package:topdeck_app_flutter/network/service/impl/deck_service_impl.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_creation_service_impl.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';

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
  final DeckServiceImpl _deckService = DeckServiceImpl();
  final MatchCreationServiceImpl _matchService = MatchCreationServiceImpl();
  
  String? _opponentDeckId;
  String? _winnerId;
  List<Map<String, dynamic>> _opponentDecks = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _loadOpponentDecks();
  }
  
  Future<void> _loadOpponentDecks() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final decks = await _deckService.getPublicDecksByUser(widget.opponentId);
      
      setState(() {
        _opponentDecks = decks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading opponent decks: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Risultati partita'),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOpponentDecks,
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                )
              : Padding(
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
                              _opponentDecks.isEmpty
                                  ? const Text('Nessun deck disponibile per questo avversario', 
                                      style: TextStyle(fontStyle: FontStyle.italic))
                                  : _buildDeckDropdown(),
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
                        onPressed: (_canSave() && !_isSaving) ? _saveMatch : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSaving 
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('SALVATAGGIO...'),
                                ],
                              )
                            : const Text('SALVA PARTITA'),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildDeckDropdown() {
    return DropdownButtonFormField<String>(
      value: _opponentDeckId,
      decoration: InputDecoration(
        hintText: 'Seleziona deck',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: _opponentDecks.map((deck) {
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
  
  Future<void> _saveMatch() async {
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
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      await _matchService.recordMatchResult(
        player1Id: currentUser.id,
        player2Id: widget.opponentId,
        player1DeckId: widget.playerDeckId,
        player2DeckId: _opponentDeckId!,
        format: widget.format.toString().split('.').last,
        winnerId: _winnerId!,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partita salvata con successo!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to home
      context.router.popUntilRoot();
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante il salvataggio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 