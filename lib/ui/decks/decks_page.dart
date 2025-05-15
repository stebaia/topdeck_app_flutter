import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/cubit/decks/decks_cubit.dart';
import 'package:topdeck_app_flutter/cubit/decks/decks_state.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/ui/widgets/loading_indicator.dart';

@RoutePage(name: 'DecksPageRoute')
class DecksPage extends StatelessWidget {
  const DecksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    
    // Carica i mazzi quando la pagina viene mostrata
    context.read<DecksCubit>().loadDecks();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Decks'),
        centerTitle: true,
      ),
      body: user == null 
          ? _buildUnauthenticatedView()
          : _buildDecksList(),
      floatingActionButton: user != null 
          ? FloatingActionButton(
              onPressed: () => _showAddDeckDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildUnauthenticatedView() {
    return const Center(
      child: Text('Please sign in to view your decks'),
    );
  }
  
  Widget _buildDecksList() {
    return BlocBuilder<DecksCubit, DecksState>(
      builder: (context, state) {
        if (state is DecksLoading) {
          return const Center(child: LoadingIndicator());
        }
        
        if (state is DecksError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DecksCubit>().loadDecks();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state is DecksLoaded) {
          final decks = state.decks;
          
          if (decks.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t created any decks yet.\nPress + to add a new one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(deck.name),
                  subtitle: Text('Format: ${_formatToString(deck.format)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      deck.shared ?? false
                          ? const Icon(Icons.public, color: Colors.green)
                          : const Icon(Icons.public_off, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    // Navigate to deck detail page
                  },
                ),
              );
            },
          );
        }
        
        // Initial state or unknown state
        return const Center(child: Text('Loading decks...'));
      },
    );
  }
  
  Future<void> _showAddDeckDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String deckName = '';
    DeckFormat deckFormat = DeckFormat.advanced;
    bool isShared = false;
    
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Add New Deck'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Deck Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name for your deck';
                    }
                    return null;
                  },
                  onSaved: (newValue) => deckName = newValue!.trim(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DeckFormat>(
                  decoration: const InputDecoration(
                    labelText: 'Format',
                    border: OutlineInputBorder(),
                  ),
                  value: deckFormat,
                  items: DeckFormat.values.map((format) {
                    return DropdownMenuItem(
                      value: format,
                      child: Text(_formatToString(format)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setDialogState(() {
                        deckFormat = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Share publicly'),
                  value: isShared,
                  onChanged: (value) {
                    setDialogState(() {
                      isShared = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.of(dialogCtx).pop();
                  
                  final user = supabase.auth.currentUser;
                  if (user != null) {
                    try {
                      // Use the cubit from the parent context
                      context.read<DecksCubit>().createDeck(
                        userId: user.id,
                        name: deckName,
                        format: deckFormat,
                        shared: isShared,
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Deck created successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating deck: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatToString(DeckFormat format) {
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