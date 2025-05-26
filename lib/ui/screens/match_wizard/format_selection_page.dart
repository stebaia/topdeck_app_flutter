import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';

@RoutePage()
class FormatSelectionPage extends StatelessWidget {
  const FormatSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona formato'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Scegli il formato della partita',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: DeckFormat.values.map((format) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        _formatToDisplayName(format),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.router.push(

                          DeckSelectionWizardPageRoute(format: format),
                        );
                      },
                    ),
                  );
                }).toList(),
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
} 