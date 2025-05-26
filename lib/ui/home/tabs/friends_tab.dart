import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:topdeck_app_flutter/model/entities/friend_request.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/friends/friends_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/friends/friends_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/friends/friends_state.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_state.dart';

@RoutePage(name: 'FriendsTabRoute')
class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    
    // Carica i dati iniziali
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadInitialData() {
    // Carica le richieste di amicizia pendenti
    context.read<FriendsBloc>().add(LoadFriendRequestsEvent());
    
    // Carica la lista degli amici
    context.read<FriendsBloc>().add(LoadFriendsEvent());
  }
  
  void _onSearchChanged() {
    if (_searchController.text.length >= 2) {
      context.read<UserSearchBloc>().add(SearchUsers(_searchController.text));
    } else {
      context.read<UserSearchBloc>().add(const ClearSearch());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FriendsBloc, FriendsState>(
      listener: (context, state) {
        if (state is FriendshipsDebugLoaded) {
          _showDebugDialog(context, state.debugData);
        } else if (state is FriendRequestAccepted) {
          // Mostra messaggio di successo quando una richiesta viene accettata
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Richiesta di amicizia accettata!'),
              backgroundColor: Colors.green,
            ),
          );
          // Cambia tab per mostrare la lista amici
          _tabController.animateTo(2); // Indice della tab "Amici"
        } else if (state is FriendRequestDeclined) {
          // Mostra messaggio quando una richiesta viene rifiutata
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Richiesta di amicizia rifiutata'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is FriendRemoved) {
          // Mostra messaggio quando un'amicizia viene rimossa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Amicizia rimossa con successo'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (state is FriendsError) {
          // Mostra errori
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Amici'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Debug',
              onPressed: () {
                context.read<FriendsBloc>().add(DebugFriendshipsEvent());
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Cerca'),
              Tab(text: 'Richieste'),
              Tab(text: 'Amici'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSearchTab(),
            _buildRequestsTab(),
            _buildFriendsTab(),
          ],
        ),
      ),
    );
  }
  
  void _showDebugDialog(BuildContext context, Map<String, dynamic> debugData) {
    final summary = debugData['summary'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('UserID: ${debugData['userId']}'),
              const Divider(),
              Text('Total records: ${summary['total']}'),
              Text('Incoming requests: ${summary['incoming']}'),
              Text('Outgoing requests: ${summary['outgoing']}'),
              Text('Accepted friends: ${summary['accepted']}'),
              const Divider(),
              const SizedBox(height: 16),
              const Text('Incoming requests:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                debugData['incomingRequests'].isNotEmpty 
                    ? const JsonEncoder.withIndent('  ').convert(debugData['incomingRequests'])
                    : 'None',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text('Outgoing requests:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                debugData['outgoingRequests'].isNotEmpty 
                    ? const JsonEncoder.withIndent('  ').convert(debugData['outgoingRequests'])
                    : 'None',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cerca utenti...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<UserSearchBloc>().add(const ClearSearch());
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<UserSearchBloc, UserSearchState>(
            builder: (context, state) {
              if (state is UserSearchLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is UserSearchSuccess) {
                if (state.users.isEmpty) {
                  return const Center(
                    child: Text('Nessun utente trovato'),
                  );
                }
                return ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return _buildUserListTile(user);
                  },
                );
              } else if (state is UserSearchError) {
                return Center(
                  child: Text('Errore: ${state.message}'),
                );
              } else {
                return const Center(
                  child: Text('Cerca utenti per nome o username'),
                );
              }
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildUserListTile(UserProfile user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        backgroundColor: Colors.grey.shade400,
        child: user.avatarUrl == null
            ? Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      title: Text(user.username),
      subtitle: user.displayName != null ? Text(user.displayName!) : null,
      onTap: () {
        // Naviga al profilo dell'utente
        _navigateToUserProfile(user);
      },
    );
  }
  
  void _navigateToUserProfile(UserProfile user) {
    context.pushRoute(
      UserProfilePageRoute(
        userId: user.id,
        username: user.username,
        avatarUrl: user.avatarUrl,
        displayName: user.displayName,
      ),
    );
  }
  
  Widget _buildRequestsTab() {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FriendRequestsLoaded) {
          final requests = state.requests;
          
          if (requests.isEmpty) {
            return const Center(
              child: Text('Non hai richieste di amicizia in sospeso'),
            );
          }
          
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildFriendRequestTile(request);
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
  
  Widget _buildFriendRequestTile(FriendRequest request) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: request.sender?.avatarUrl != null 
            ? NetworkImage(request.sender!.avatarUrl!) 
            : null,
        backgroundColor: Colors.grey.shade400,
        child: request.sender?.avatarUrl == null
            ? Text(
                request.sender?.username.isNotEmpty == true 
                    ? request.sender!.username[0].toUpperCase() 
                    : '?',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      title: Text(request.sender?.username ?? 'Utente'),
      subtitle: const Text('Vuole aggiungerti come amico'),
      onTap: request.sender != null ? () {
        // Naviga al profilo dell'utente che ha inviato la richiesta
        _navigateToUserProfile(request.sender!);
      } : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () {
              context.read<FriendsBloc>().add(AcceptFriendRequestEvent(request.senderId));
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              context.read<FriendsBloc>().add(DeclineFriendRequestEvent(request.senderId));
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildFriendsTab() {
    return BlocBuilder<FriendsBloc, FriendsState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FriendsLoaded) {
          final friends = state.friends;
          
          if (friends.isEmpty) {
            return const Center(
              child: Text('Non hai ancora amici'),
            );
          }
          
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return _buildUserListTile(friend);
            },
          );
        } else {
          return Center(
            child: TextButton.icon(
              onPressed: () {
                context.read<FriendsBloc>().add(LoadFriendsEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Carica amici'),
            ),
          );
        }
      },
    );
  }
} 