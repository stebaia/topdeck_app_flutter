import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

class _FriendsTabState extends State<FriendsTab> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    // Carica i dati iniziali
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadInitialData() {
    // Carica entrambi i dati insieme
    context.read<FriendsBloc>().add(LoadFriendsAndRequestsEvent());
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
          // Ricarica i dati dopo aver accettato la richiesta
          _loadInitialData();
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Friends'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Debug',
              onPressed: () {
                context.read<FriendsBloc>().add(DebugFriendshipsEvent());
              },
            ),
          ],
        ),
        body: _buildUnifiedFriendsPage(),
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
  
  Widget _buildUnifiedFriendsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Section
          _buildSearchSection(),
          const SizedBox(height: 24),
          
          // Friend Requests Section
          _buildFriendRequestsSection(),
          const SizedBox(height: 24),
          
          // Friends Section
          _buildFriendsSection(),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      children: [
        // Search Input
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          CupertinoIcons.clear,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          context.read<UserSearchBloc>().add(const ClearSearch());
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
        BlocBuilder<UserSearchBloc, UserSearchState>(
          builder: (context, state) {
            if (state is UserSearchLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is UserSearchSuccess) {
              if (state.users.isEmpty) {
                return _buildEmptyState(
                  icon: CupertinoIcons.search,
                  title: 'No users found',
                  subtitle: 'Try a different search term',
                );
              }
              return Column(
                children: state.users.map((user) => _buildUserCard(user)).toList(),
              );
            } else if (state is UserSearchError) {
              return _buildEmptyState(
                icon: CupertinoIcons.exclamationmark_triangle,
                title: 'Error',
                subtitle: state.message,
              );
            } else {
              return _buildEmptyState(
                icon: CupertinoIcons.person_2,
                title: 'Search for friends',
                subtitle: 'Enter a username or name to find users',
              );
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildUserCard(UserProfile user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToUserProfile(user),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: user.avatarUrl == null
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                          ],
                        )
                      : null,
                  image: user.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(user.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.avatarUrl == null
                    ? Icon(
                        CupertinoIcons.person_fill,
                        size: 28,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (user.displayName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.displayName!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Action button
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.person_add,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
  
  Widget _buildFriendRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Friend Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            if (state is FriendsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FriendsAndRequestsLoaded) {
              final requests = state.requests;
              
              if (requests.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No pending friend requests',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              
              return Column(
                children: requests.map((request) => _buildFriendRequestCard(request)).toList(),
              );
            } else if (state is FriendRequestsLoaded) {
              final requests = state.requests;
              
              if (requests.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No pending friend requests',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              
              return Column(
                children: requests.map((request) => _buildFriendRequestCard(request)).toList(),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildFriendRequestCard(FriendRequest request) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isIncoming = request.recipientId == currentUserId;
    final otherUser = request.sender;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isIncoming 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: otherUser != null ? () => _navigateToUserProfile(otherUser) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: otherUser?.avatarUrl == null
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                          ],
                        )
                      : null,
                  image: otherUser?.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(otherUser!.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: otherUser?.avatarUrl == null
                    ? Icon(
                        CupertinoIcons.person_fill,
                        size: 28,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUser?.username ?? 'User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isIncoming ? CupertinoIcons.arrow_down_circle : CupertinoIcons.arrow_up_circle,
                          size: 16,
                          color: isIncoming ? Colors.blue : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isIncoming ? 'Wants to be your friend' : 'Request sent',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              if (isIncoming) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(CupertinoIcons.check_mark, color: Colors.green),
                        onPressed: () {
                          context.read<FriendsBloc>().add(AcceptFriendRequestEvent(request.senderId));
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(CupertinoIcons.xmark, color: Colors.red),
                        onPressed: () {
                          context.read<FriendsBloc>().add(DeclineFriendRequestEvent(request.senderId));
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.clock,
                    size: 20,
                    color: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFriendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Friends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            if (state is FriendsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FriendsAndRequestsLoaded) {
              final friends = state.friends;
              
              if (friends.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No friends yet. Search for users to add as friends!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              
              return Column(
                children: friends.map((friend) => _buildFriendCard(friend)).toList(),
              );
            } else if (state is FriendsLoaded) {
              final friends = state.friends;
              
              if (friends.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No friends yet. Search for users to add as friends!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              
              return Column(
                children: friends.map((friend) => _buildFriendCard(friend)).toList(),
              );
            } else {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.refresh,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Load Friends',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () {
                        context.read<FriendsBloc>().add(LoadFriendsAndRequestsEvent());
                      },
                      icon: const Icon(CupertinoIcons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildFriendCard(UserProfile friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToUserProfile(friend),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: friend.avatarUrl == null
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                          ],
                        )
                      : null,
                  image: friend.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(friend.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: friend.avatarUrl == null
                    ? Icon(
                        CupertinoIcons.person_fill,
                        size: 28,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.username,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (friend.displayName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        friend.displayName!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  size: 20,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 