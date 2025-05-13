import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/network/service/impl/user_search_service_impl.dart';

@RoutePage()
class OpponentSearchPage extends StatefulWidget {
  final DeckFormat format;
  final String selectedDeckId;
  
  const OpponentSearchPage({
    super.key,
    required this.format,
    required this.selectedDeckId,
  });

  @override
  State<OpponentSearchPage> createState() => _OpponentSearchPageState();
}

class _OpponentSearchPageState extends State<OpponentSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final UserSearchServiceImpl _userSearchService = UserSearchServiceImpl();
  List<UserProfile> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      // Use the UserSearchServiceImpl to call the search-users edge function
      final results = await _userSearchService.searchUsers(query);
      
      setState(() {
        _searchResults = results.map((userData) => UserProfile(
          id: userData['id'],
          username: userData['username'],
          displayName: userData['display_name'],
        )).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Error searching for users: $e';
        _searchResults = [];
      });
    }
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
                _performSearch(value);
              },
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[700], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Inizia a digitare per cercare'
                              : 'Nessun utente trovato',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
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
                                context.router.push(
                                  MatchResultsPageRoute(
                                    format: widget.format,
                                    playerDeckId: widget.selectedDeckId,
                                    opponentId: user.id,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
} 