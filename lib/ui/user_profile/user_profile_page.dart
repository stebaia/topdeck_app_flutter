import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/repositories/deck_repository.dart';
import 'package:topdeck_app_flutter/repositories/friend_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/friends/friends_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/friends/friends_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/friends/friends_state.dart';

@RoutePage(name: 'UserProfilePageRoute')
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    super.key,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.displayName,
  });

  final String userId;
  final String username;
  final String? avatarUrl;
  final String? displayName;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _supabase = Supabase.instance.client;

  /// Get detailed friendship status
  Future<Map<String, dynamic>> _getFriendshipStatus() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        return {'status': 'error', 'message': 'User not authenticated'};
      }
      
      // Check if user is trying to add themselves
      if (currentUserId == widget.userId) {
        return {'status': 'self', 'message': 'Cannot add yourself as friend'};
      }
      
      // Check existing friendship status
      final existingRelations = await _supabase
          .from('friends')
          .select()
          .or('and(user_id.eq.$currentUserId,friend_id.eq.${widget.userId}),and(user_id.eq.${widget.userId},friend_id.eq.$currentUserId)');
      
      if (existingRelations.isEmpty) {
        return {'status': 'none', 'message': 'Can send friend request'};
      }
      
      final relation = existingRelations.first;
      final status = relation['status'];
      final isOutgoing = relation['user_id'] == currentUserId;
      
      if (status == 'accepted') {
        return {'status': 'friends', 'message': 'Already friends'};
      } else if (status == 'pending') {
        if (isOutgoing) {
          return {'status': 'request_sent', 'message': 'Request sent'};
        } else {
          return {'status': 'request_received', 'message': 'Request received'};
        }
      }
      
      return {'status': 'none', 'message': 'Can send friend request'};
    } catch (e) {
      print('Error checking friendship status: $e');
      return {'status': 'error', 'message': 'Error checking status'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilo Utente'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(textTheme),
            const SizedBox(height: 16),
            _buildActions(),
            const Divider(),
            _buildDecksSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade400,
            backgroundImage: widget.avatarUrl != null
                ? NetworkImage(widget.avatarUrl!)
                : null,
            child: widget.avatarUrl == null
                ? Text(
                    widget.username.isNotEmpty
                        ? widget.username[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.displayName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.displayName!,
                    style: textTheme.titleMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _getFriendshipStatus(),
        builder: (context, snapshot) {
          // Durante il caricamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ElevatedButton.icon(
              onPressed: null,
              icon: const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              label: const Text('Checking status...'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            );
          }
          
          if (snapshot.hasError) {
            return ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            );
          }
          
          final statusData = snapshot.data;
          if (statusData == null) {
            return const SizedBox.shrink();
          }
          
          final status = statusData['status'];
          
          // User trying to add themselves
          if (status == 'self') {
            return ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.person),
              label: const Text('Your Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.grey,
              ),
            );
          }
          
          // Already friends
          if (status == 'friends') {
            return ElevatedButton.icon(
              onPressed: () {
                _showRemoveFriendDialog();
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Friends', style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.green,
              ),
            );
          }
          
          // Request sent (outgoing)
          if (status == 'request_sent') {
            return ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.schedule),
              label: const Text('Request Sent'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.orange,
              ),
            );
          }
          
          // Request received (incoming)
          if (status == 'request_received') {
            return ElevatedButton.icon(
              onPressed: () {
                context.read<FriendsBloc>().add(AcceptFriendRequestEvent(widget.userId));
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Accept Friend Request'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.blue,
              ),
            );
          }
          
          // Se può inviare richiesta
          return BlocBuilder<FriendsBloc, FriendsState>(
            builder: (context, state) {
              if (state is FriendsLoading) {
                return ElevatedButton.icon(
                  onPressed: null, // Disattivato durante il caricamento
                  icon: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  label: const Text('Invio richiesta...'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                );
              } else if (state is FriendRequestSent && state.recipientId == widget.userId) {
                return ElevatedButton.icon(
                  onPressed: null, // Disattivato perché già inviata
                  icon: const Icon(Icons.check),
                  label: const Text('Richiesta inviata'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is FriendsError) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<FriendsBloc>().add(
                              SendFriendRequestEvent(widget.userId),
                            );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Riprova'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: Colors.orange,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Errore: ${state.message}',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              } else {
                return ElevatedButton.icon(
                  onPressed: () {
                    // Prima mostriamo un indicatore di caricamento
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 16),
                            Text('Invio richiesta di amicizia...'),
                          ],
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    
                    // Poi inviamo la richiesta
                    context.read<FriendsBloc>().add(
                          SendFriendRequestEvent(widget.userId),
                        );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Aggiungi agli amici'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDecksSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mazzi condivisi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Deck>>(
            future: context.read<DeckRepository>().getPublicDecksByUser(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Errore nel caricamento dei mazzi: ${snapshot.error}',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                );
              }
              
              final decks = snapshot.data ?? [];
              
              if (decks.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Nessun mazzo condiviso',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: decks.length,
                itemBuilder: (context, index) {
                  final deck = decks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(deck.name),
                      subtitle: Text('Formato: ${deck.format.name}'),
                      leading: const Icon(Icons.library_books),
                      onTap: () {
                        // Naviga ai dettagli del mazzo
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Mostra una finestra di dialogo per confermare la rimozione dell'amicizia
  void _showRemoveFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rimuovere amicizia'),
        content: const Text('Sei sicuro di voler rimuovere questa persona dalla tua lista amici?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiude la dialog
            },
            child: const Text('Annulla'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              // Qui implementeremo la rimozione dell'amicizia
              _removeFriendship();
              Navigator.of(context).pop(); // Chiude la dialog
            },
            child: const Text('Rimuovi'),
          ),
        ],
      ),
    );
  }

  /// Rimuove l'amicizia con l'utente corrente
  void _removeFriendship() {
    // Avviso l'utente che l'operazione è in corso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rimozione amicizia in corso...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Invia l'evento di rimozione amicizia
    context.read<FriendsBloc>().add(RemoveFriendEvent(widget.userId));
  }
} 