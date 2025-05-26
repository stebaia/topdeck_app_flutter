import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:topdeck_app_flutter/network/service/impl/match_result_service_impl.dart';

/// Pagina per l'inserimento dei risultati di un match
@RoutePage()
class MatchResultPage extends StatefulWidget {
  /// Il match di cui inserire i risultati
  final Map<String, dynamic> match;
  
  /// Constructor
  const MatchResultPage({
    Key? key,
    required this.match,
  }) : super(key: key);

  @override
  State<MatchResultPage> createState() => _MatchResultPageState();
}

class _MatchResultPageState extends State<MatchResultPage> {
  final MatchResultServiceImpl _matchResultService = MatchResultServiceImpl();
  final _formKey = GlobalKey<FormState>();
  
  late String _player1Name;
  late String _player2Name;
  String? _winnerId;
  int _player1Score = 0;
  int _player2Score = 0;
  final TextEditingController _notesController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, dynamic>? _result;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  void _initializeData() {
    _player1Name = widget.match['player1']?['username'] ?? 'Giocatore 1';
    _player2Name = widget.match['player2']?['username'] ?? 'Giocatore 2';
    
    // Se il match ha già un vincitore, inizializziamo i dati
    if (widget.match['winner_id'] != null) {
      _winnerId = widget.match['winner_id'];
      _player1Score = widget.match['player1_score'] ?? 0;
      _player2Score = widget.match['player2_score'] ?? 0;
      _notesController.text = widget.match['notes'] ?? '';
    }
  }
  
  Future<void> _submitResult() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (_winnerId == null) {
      setState(() {
        _errorMessage = 'Seleziona un vincitore';
      });
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _matchResultService.submitMatchResult(
        matchId: widget.match['id'],
        winnerId: _winnerId!,
        player1Score: _player1Score,
        player2Score: _player2Score,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      
      setState(() {
        _isSubmitting = false;
        _result = result;
      });
      
      // Mostra il risultato all'utente
      _showResultDialog();
      
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Errore nell\'invio dei risultati: $e';
      });
    }
  }
  
  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Risultato registrato'),
        content: SingleChildScrollView(
          child: _result != null && _result!.containsKey('ratings')
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Il risultato è stato registrato con successo.'),
                    const SizedBox(height: 16),
                    const Text(
                      'Variazioni ELO:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildEloChange(_player1Name, _result!['ratings']['player1']),
                    const SizedBox(height: 8),
                    _buildEloChange(_player2Name, _result!['ratings']['player2']),
                  ],
                )
              : const Text('Il risultato è stato registrato con successo.'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiudi il dialog
              Navigator.of(context).pop(true); // Torna alla pagina precedente con risultato positivo
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEloChange(String playerName, Map<String, dynamic> ratingData) {
    final int before = ratingData['before'];
    final int after = ratingData['after'];
    final int change = ratingData['change'];
    
    final Color changeColor = change >= 0 ? Colors.green : Colors.red;
    final String changeText = change >= 0 ? '+$change' : '$change';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(playerName),
        Row(
          children: [
            Text('$before → $after'),
            const SizedBox(width: 8),
            Text(
              changeText,
              style: TextStyle(
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final player1Id = widget.match['player1_id'];
    final player2Id = widget.match['player2_id'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserisci risultato'),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informazioni match
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Formato: ${widget.match['format']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _player1Name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'VS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _player2Name,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.match['player1_deck'] != null && widget.match['player2_deck'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.match['player1_deck']['name'] ?? 'Mazzo sconosciuto',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.match['player2_deck']['name'] ?? 'Mazzo sconosciuto',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Selezione vincitore
                    const Text(
                      'Seleziona il vincitore',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildWinnerSelection(
                            player1Id,
                            _player1Name,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildWinnerSelection(
                            player2Id,
                            _player2Name,
                          ),
                        ),
                      ],
                    ),
                    
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Punteggio
                    const Text(
                      'Punteggio (opzionale)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildScoreInput(
                            _player1Name,
                            (value) {
                              setState(() {
                                _player1Score = int.tryParse(value) ?? 0;
                              });
                            },
                            initialValue: _player1Score.toString(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildScoreInput(
                            _player2Name,
                            (value) {
                              setState(() {
                                _player2Score = int.tryParse(value) ?? 0;
                              });
                            },
                            initialValue: _player2Score.toString(),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Note
                    const Text(
                      'Note (opzionale)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Inserisci eventuali note sul match',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Pulsante invio
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitResult,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Invia risultato',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildWinnerSelection(String playerId, String playerName) {
    final bool isSelected = _winnerId == playerId;
    
    return InkWell(
      onTap: () {
        setState(() {
          _winnerId = playerId;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        ),
        child: Column(
          children: [
            isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  )
                : const Icon(
                    Icons.circle_outlined,
                    color: Colors.grey,
                    size: 28,
                  ),
            const SizedBox(height: 8),
            Text(
              playerName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScoreInput(String label, Function(String) onChanged, {required String initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final int? score = int.tryParse(value);
              if (score == null || score < 0) {
                return 'Inserisci un numero valido';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
} 