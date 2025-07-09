import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/repositories/friend_repository.dart';
import 'package:topdeck_app_flutter/repositories/user_search_repository.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_state.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_state.dart';
import 'package:topdeck_app_flutter/ui/dialogs/match_invitation_dialog.dart';
import 'package:topdeck_app_flutter/utils/toast_service.dart';

@RoutePage()
class OpponentSearchPage extends StatefulWidget implements AutoRouteWrapper {
  final DeckFormat format;
  final String selectedDeckId;
  
  const OpponentSearchPage({
    super.key,
    required this.format,
    required this.selectedDeckId,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserSearchBloc(context.read<UserSearchRepository>(), context.read<FriendRepository>())..getAllMyFriends(),)
      ],
      child: this,
    );
  }

  @override
  State<OpponentSearchPage> createState() => _OpponentSearchPageState();
}

class _OpponentSearchPageState extends State<OpponentSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerca avversario'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cerca il tuo avversario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca per username',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  context.read<UserSearchBloc>().add(const GetAllMyFriends());
                } else {
                  context.read<UserSearchBloc>().add(SearchUsers(value));
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<UserSearchBloc, UserSearchState>(
                builder: (context, state) {
                  if (state is UserSearchLoading || state is TryToGetAllMyFriendsState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserSearchError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Colors.red[700], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (state is ErrorGetAllMyFriendsState) {
                    return Center(
                      child: Text(
                        state.error,
                        style: TextStyle(color: Colors.red[700], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (state is UserSearchSuccess) {
                    return _buildSearchResults(state.users);
                  } else if (state is SuccessGetAllMyFriendsState) {
                    return _buildSearchResults(state.friends);
                  } else {
                    return Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'I tuoi amici appariranno qui'
                            : 'Inizia a digitare per cercare',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchResults(List<UserProfile> users) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          'Nessun utente trovato',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.username[0].toUpperCase()),
            ),
            title: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(user.displayName ?? user.username),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showInvitationDialog(context, user);
            },
          ),
        );
      },
    );
  }
  
  Future<void> _showInvitationDialog(BuildContext context, UserProfile opponent) async {
    // Otteniamo il nome del mazzo selezionato
    final deckBloc = context.read<MatchWizardBloc>();
    String deckName = "Mazzo selezionato";
    
    if (deckBloc.state is UserDecksLoadedState) {
      final decksState = deckBloc.state as UserDecksLoadedState;
      final selectedDeck = decksState.decks.firstWhere(
        (deck) => deck.id == widget.selectedDeckId,
        orElse: () => throw Exception('Mazzo non trovato')
      );
      
      deckName = selectedDeck.name;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MatchInvitationDialog(
        opponent: opponent,
        format: widget.format,
        playerDeckName: deckName,
      ),
    );
    
    if (result == true) {
      // L'invito è stato inviato con successo
      if (!mounted) return;
      ToastService.showSuccess(context, 'Invito inviato a ${opponent.username}');
      
      // Torniamo alla home
      if (!mounted) return;
      context.router.popUntil((route) => route.isFirst);
    }
  }
} 