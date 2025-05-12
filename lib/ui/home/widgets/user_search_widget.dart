import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_state.dart';

/// Widget for searching users
class UserSearchWidget extends StatefulWidget {
  /// Constructor
  const UserSearchWidget({
    super.key,
    this.onUserSelected,
  });

  /// Callback called when a user is selected
  final void Function(UserProfile)? onUserSelected;

  @override
  State<UserSearchWidget> createState() => _UserSearchWidgetState();
}

class _UserSearchWidgetState extends State<UserSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<UserSearchBloc>().add(
          SearchUsers(_searchController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<UserSearchBloc>().add(
                              const ClearSearch(),
                            );
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
                    child: Text('No users found'),
                  );
                }
                return ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return UserListTile(
                      user: user,
                      onTap: () {
                        if (widget.onUserSelected != null) {
                          widget.onUserSelected!(user);
                        }
                      },
                    );
                  },
                );
              } else if (state is UserSearchError) {
                return Center(
                  child: Text('Error: ${state.message}'),
                );
              } else {
                return const Center(
                  child: Text('Search for users using their username'),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

/// List tile for displaying a user
class UserListTile extends StatelessWidget {
  /// Constructor
  const UserListTile({
    super.key,
    required this.user,
    this.onTap,
  });

  /// User to display
  final UserProfile user;
  
  /// Callback when the tile is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null
            ? Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?')
            : null,
      ),
      title: Text(user.username),
      subtitle: user.displayName != null ? Text(user.displayName!) : null,
      onTap: onTap,
    );
  }
} 