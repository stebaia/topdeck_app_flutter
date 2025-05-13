import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';

@RoutePage()
class DeckSelectionPage extends StatelessWidget {
  final DeckFormat format;
  
  const DeckSelectionPage({
    super.key,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona deck'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Seleziona il tuo deck per formato ${_formatToDisplayName(format)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // In a real implementation, this would load decks from a repository
            // For now, we'll use a placeholder
            Expanded(
              child: FutureBuilder<List<Deck>>(
                future: Future.value(_getMockDecks(format)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Errore: ${snapshot.error}'),
                    );
                  }
                  
                  final decks = snapshot.data ?? [];
                  
                  if (decks.isEmpty) {
                    return const Center(
                      child: Text('Nessun deck trovato per questo formato'),
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
                                format: format,
                                selectedDeckId: deck.id,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
  
  // Mock data for demonstration
  List<Deck> _getMockDecks(DeckFormat format) {
    return [
      Deck(
        id: '1',
        userId: 'current-user',
        name: 'Dragon Link',
        format: format,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Deck(
        id: '2',
        userId: 'current-user',
        name: 'Eldlich',
        format: format,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Deck(
        id: '3',
        userId: 'current-user',
        name: 'Sky Striker',
        format: format,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
} 