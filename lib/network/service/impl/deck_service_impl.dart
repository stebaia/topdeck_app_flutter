import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

/// Service implementation for deck operations using Edge Functions
class DeckServiceImpl {
  /// The Supabase client
  final SupabaseClient client = supabase;
  
  /// Lists all decks for the current user
  Future<List<Map<String, dynamic>>> listDecks() async {
    try {
      // Verifica che l'utente sia autenticato
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      // Ottieni il token di accesso
      final session = await client.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        throw AuthException('No valid session found');
      }
      
      print('Attempting to list decks with token: ${session.accessToken.substring(0, 10)}...');
      print('Current user in listDecks: ${currentUser.id}');
      
      // Invoca la funzione con l'autorizzazione corretta
      final response = await client.functions.invoke(
        'list-deck',
        // Passiamo esplicitamente l'header Authorization con il token
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.status != 200) {
        print('Error from list-deck: ${response.status} - ${response.data}');
        
        if (response.status == 401) {
          // Prova a refreshare il token
          print('Refreshing session for list-deck...');
          await client.auth.refreshSession();
          final newSession = await client.auth.currentSession;
          
          if (newSession != null) {
            final retryResponse = await client.functions.invoke(
              'list-deck',
              headers: {
                'Authorization': 'Bearer ${newSession.accessToken}',
                'Content-Type': 'application/json',
              },
            );
            
            if (retryResponse.status == 200) {
              // Controlla che la risposta sia una lista prima di fare il cast
              if (retryResponse.data is List || (retryResponse.data is String && retryResponse.data.toString().startsWith('['))) {
                var dataList = retryResponse.data is List 
                    ? retryResponse.data as List 
                    : jsonDecode(retryResponse.data.toString()) as List;
                
                return dataList.map((item) {
                  // Controlla che ogni elemento della lista sia una Map<String, dynamic>
                  if (item is Map<String, dynamic>) {
                    return item;
                  } else {
                    print('Warning: item in list is not a Map: $item');
                    // Ritorna una mappa vuota per mantenere la struttura
                    return <String, dynamic>{};
                  }
                }).toList();
              } else {
                print('Warning: response.data is not a List: ${retryResponse.data}');
                return [];
              }
            }
          }
          
          // Se il refresh e il retry non funzionano, usa l'approccio diretto
          print('Falling back to direct DB query...');
          return await listDecksDirectly();
        }
        
        throw Exception(response.data['error'] ?? 'Failed to list decks');
      }
      
      // Controlla che la risposta sia una lista prima di fare il cast
      if (response.data is List || (response.data is String && response.data.toString().startsWith('['))) {
        var dataList = response.data is List 
            ? response.data as List 
            : jsonDecode(response.data.toString()) as List;
        
        return dataList.map((item) {
          // Controlla che ogni elemento della lista sia una Map<String, dynamic>
          if (item is Map<String, dynamic>) {
            return item;
          } else {
            print('Warning: item in list is not a Map: $item');
            // Ritorna una mappa vuota per mantenere la struttura
            return <String, dynamic>{};
          }
        }).toList();
      } else {
        print('Warning: response.data is not a List: ${response.data}');
        // Proviamo a vedere se possiamo convertirlo in una lista
        try {
          // Aggiungi l'import in cima al file: import 'dart:convert';
          var data = response.data;
          if (data is Map<String, dynamic> && data.containsKey('data') && data['data'] is List) {
            return (data['data'] as List).map((item) => item as Map<String, dynamic>).toList();
          } else if (data is String) {
            var decodedData = jsonDecode(data);
            if (decodedData is List) {
              return decodedData.map((item) => item as Map<String, dynamic>).toList();
            }
          }
          
          // Se la risposta contiene un singolo elemento, creiamo una lista con quell'elemento
          if (data is Map<String, dynamic> && data.containsKey('id')) {
            return [data];
          }
        } catch (e) {
          print('Error trying to convert response data to list: $e');
        }
        
        return [];
      }
    } on AuthException catch (e) {
      print('Auth exception in listDecks: ${e.message}');
      throw AuthException('Authentication error: ${e.message}');
    } catch (e) {
      // In caso di errore, prova con l'approccio diretto
      print('General exception in listDecks: $e');
      return await listDecksDirectly();
    }
  }
  
  /// Lists all decks for the current user directly from the database
  /// Questo è un fallback nel caso l'edge function non funzioni
  Future<List<Map<String, dynamic>>> listDecksDirectly() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      print('Listing decks directly from database for user: ${currentUser.id}');
      
      final response = await client
        .from('decks')
        .select('id, name, format, shared, created_at')
        .eq('user_id', currentUser.id);
      
      print('Direct DB response: $response');
      
      // Controlla che la risposta sia una lista prima di ritornare
      if (response is List) {
        return response.map((item) {
          // Controlla che ogni elemento della lista sia una Map<String, dynamic>
          if (item is Map<String, dynamic>) {
            // Controlla che 'format' sia una stringa e non null
            if (item['format'] == null) {
              print('Warning: format is null for deck: ${item['id']}');
              item['format'] = 'advanced'; // Imposta un valore predefinito se null
            }
            
            // Assicurati che tutti i campi necessari siano presenti
            final processedItem = <String, dynamic>{
              'id': item['id'] ?? const Uuid().v4().toString(),
              'user_id': item['user_id'] ?? currentUser.id,
              'name': item['name'] ?? 'Unnamed Deck',
              'format': item['format'] ?? 'advanced',
              'shared': item['shared'] ?? false,
              'created_at': item['created_at'] ?? DateTime.now().toIso8601String(),
            };
            
            print('Processed deck item: $processedItem');
            return processedItem;
          } else {
            print('Warning: item in direct response is not a Map: $item');
            // Ritorna una mappa vuota per mantenere la struttura
            return <String, dynamic>{
              'id': const Uuid().v4().toString(),
              'user_id': currentUser.id,
              'name': 'Unknown Deck',
              'format': 'advanced',
              'shared': false,
              'created_at': DateTime.now().toIso8601String(),
            };
          }
        }).toList();
      } else {
        print('Warning: direct response is not a List: $response');
        return [];
      }
    } catch (e) {
      print('Failed to list decks directly: $e');
      throw Exception('Failed to list decks directly: $e');
    }
  }
  
  /// Gets deck details
  Future<Map<String, dynamic>> getDeckDetails(String deckId) async {
    try {
      final session = await client.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        throw AuthException('No valid session found');
      }
      
      final response = await client.functions.invoke(
        'deck-detail',
        body: {'deck_id': deckId},
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to get deck details');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to get deck details: $e');
    }
  }
  
  /// Get public decks for a user (for opponent deck selection)
  Future<List<Map<String, dynamic>>> getPublicDecksByUser(String userId) async {
    try {
      // This uses the database query directly since there's no edge function for this specific operation
      final response = await client
        .from('decks')
        .select('id, name, format')
        .eq('user_id', userId)
        .eq('shared', true);
      
      return response;
    } catch (e) {
      throw Exception('Failed to get public decks: $e');
    }
  }
  
  /// Creates a new deck directly in the database (fallback)
  Future<Map<String, dynamic>> createDeckDirectly({
    required String name,
    required String format,
    bool shared = false,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw AuthException('User not authenticated');
      }
      
      // Genera un UUID unico per il deck
      final deckId = const Uuid().v4();
      
      print('Creating deck directly in database with ID: $deckId');
      
      // Inserisci il deck direttamente nella tabella
      final response = await client
        .from('decks')
        .insert({
          'id': deckId,
          'user_id': currentUser.id,
          'name': name,
          'format': format,
          'shared': shared,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
      
      return {
        'message': 'Deck created successfully',
        'deck_id': deckId,
      };
    } catch (e) {
      print('Failed to create deck directly: $e');
      throw Exception('Failed to create deck directly: $e');
    }
  }
  
  /// Creates a new deck
  Future<Map<String, dynamic>> createDeck({
    required String name,
    required String format,
    bool shared = false,
  }) async {
    try {
      final session = await client.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        throw AuthException('No valid session found');
      }
      
      print('Attempting to create deck with token: ${session.accessToken.substring(0, 10)}...');
      print('Current user: ${client.auth.currentUser?.id}');
      
      final response = await client.functions.invoke(
        'clever-endpoint',  // This is the actual name in Supabase
        body: {
          'name': name,
          'format': format,
          'shared': shared,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.status != 200) {
        print('Error response from create deck: ${response.status} - ${response.data}');
        
        // Se riceviamo un 401, proviamo a refreshare la sessione
        if (response.status == 401) {
          print('Trying to refresh session and retry...');
          await client.auth.refreshSession();
          
          // Otteniamo una nuova sessione
          final newSession = await client.auth.currentSession;
          if (newSession == null) {
            print('Session refresh failed, trying direct database method');
            return await createDeckDirectly(name: name, format: format, shared: shared);
          }
          
          // Riproviamo con il nuovo token
          final retryResponse = await client.functions.invoke(
            'clever-endpoint',
            body: {
              'name': name,
              'format': format,
              'shared': shared,
            },
            headers: {
              'Authorization': 'Bearer ${newSession.accessToken}',
              'Content-Type': 'application/json',
            },
          );
          
          if (retryResponse.status != 200) {
            print('Retry failed with status: ${retryResponse.status}, using direct database method');
            return await createDeckDirectly(name: name, format: format, shared: shared);
          }
          
          return retryResponse.data;
        }
        
        // Se è un altro errore oltre a 401, proviamo direttamente con il database
        print('Error status ${response.status}, using direct database method');
        return await createDeckDirectly(name: name, format: format, shared: shared);
      }
      
      return response.data;
    } catch (e) {
      print('Exception during deck creation: $e');
      // In caso di qualsiasi eccezione, prova con l'approccio diretto
      print('Falling back to direct database insertion');
      return await createDeckDirectly(name: name, format: format, shared: shared);
    }
  }
  
  /// Edits an existing deck
  Future<Map<String, dynamic>> editDeck({
    required String deckId,
    String? name,
    String? format,
    bool? shared,
  }) async {
    try {
      final session = await client.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        throw AuthException('No valid session found');
      }
      
      final response = await client.functions.invoke(
        'edit-deck',
        body: {
          'deck_id': deckId,
          if (name != null) 'name': name,
          if (format != null) 'format': format,
          if (shared != null) 'shared': shared,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to edit deck');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to edit deck: $e');
    }
  }
  
  /// Deletes a deck
  Future<Map<String, dynamic>> deleteDeck(String deckId) async {
    try {
      final session = await client.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        throw AuthException('No valid session found');
      }
      
      final response = await client.functions.invoke(
        'delete-deck',
        body: {'deck_id': deckId},
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Failed to delete deck');
      }
      
      return response.data;
    } catch (e) {
      throw Exception('Failed to delete deck: $e');
    }
  }
  
  /// Gets all decks for the current user
  Future<List<Map<String, dynamic>>> getUserDecks() async {
    try {
      // Utilizziamo il metodo listDecks che già esiste nella classe
      return await listDecks();
    } catch (e) {
      print('Failed to get user decks: $e');
      // In caso di errore nella funzione Edge, prova a interrogare direttamente il DB
      try {
        final currentUser = client.auth.currentUser;
        if (currentUser == null) {
          throw AuthException('User not authenticated');
        }
        
        final response = await client
          .from('decks')
          .select('*')
          .eq('user_id', currentUser.id);
          
        return response;
      } catch (dbError) {
        print('Failed to get user decks from DB: $dbError');
        throw Exception('Failed to get user decks: $e');
      }
    }
  }
} 