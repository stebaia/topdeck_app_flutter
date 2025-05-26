import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';

/// Page to display match details
@RoutePage()
class MatchDetailPage extends StatelessWidget {
  /// Match data
  final Map<String, dynamic> match;
  
  /// Constructor
  const MatchDetailPage({
    Key? key,
    required this.match,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final String player1Name = match['player1']?['username'] ?? 'Giocatore 1';
    final String player2Name = match['player2']?['username'] ?? 'Giocatore 2';
    final String format = match['format'] ?? 'Formato sconosciuto';
    
    final String matchDateStr = match['date'] != null 
      ? DateFormat('dd/MM/yyyy').format(DateTime.parse(match['date']))
      : 'Data sconosciuta';
    
    final String winnerName = match['winner_id'] == match['player1_id'] 
      ? player1Name 
      : (match['winner_id'] == match['player2_id'] ? player2Name : 'In corso');
      
    final bool isMatchCompleted = match['winner_id'] != null;
    
    // Mazzi utilizzati
    final String deck1Name = match['player1_deck']?['name'] ?? 'Mazzo sconosciuto';
    final String deck2Name = match['player2_deck']?['name'] ?? 'Mazzo sconosciuto';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli partita'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              player1Name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text(
                              'VS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              player2Name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          format,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isMatchCompleted)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(
                              'Vincitore: $winnerName',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule, color: Colors.orange, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Partita in corso',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
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
              
              // Info partita
              _buildSectionTitle(context, 'Informazioni partita'),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(context, 'Data', matchDateStr),
                      const Divider(),
                      _buildInfoRow(context, 'Mazzo di ${player1Name}', deck1Name),
                      const Divider(),
                      _buildInfoRow(context, 'Mazzo di ${player2Name}', deck2Name),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Azioni
              _buildSectionTitle(context, 'Azioni'),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!isMatchCompleted)
                        _buildActionButton(
                          context,
                          Icons.edit_note,
                          'Inserisci risultato',
                          () {
                            context.router.push(MatchResultPageRoute(match: match))
                              .then((value) {
                                // If result was successfully submitted, refresh the page and return to home with refresh flag
                                if (value == true) {
                                  // Return to previous page (e.g. home) with refresh flag
                                  Navigator.of(context).pop(true);
                                }
                              });
                          },
                        ),
                      _buildActionButton(
                        context,
                        Icons.replay,
                        'Rivincita',
                        () {
                          // TODO: Implementare la funzionalità di rivincita
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funzionalità di rivincita non ancora implementata')),
                          );
                        },
                      ),
                      _buildActionButton(
                        context,
                        Icons.share,
                        'Condividi',
                        () {
                          // TODO: Implementare la funzionalità di condivisione
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funzionalità di condivisione non ancora implementata')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 