import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_state.dart';
import 'package:topdeck_app_flutter/model/entities/match.dart';
import 'package:intl/intl.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Widget that displays a list of matches
class MatchListWidget extends StatefulWidget {
  const MatchListWidget({Key? key}) : super(key: key);

  @override
  State<MatchListWidget> createState() => _MatchListWidgetState();
}

class _MatchListWidgetState extends State<MatchListWidget> {
  @override
  void initState() {
    super.initState();
    context.read<MatchListBloc>().add(LoadMatchesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchListBloc, MatchListState>(
      builder: (context, state) {
        if (state is MatchListLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is MatchListLoadedState) {
          return _buildMatchList(state.matches);
        } else if (state is MatchListErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Errore nel caricamento delle partite',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<MatchListBloc>().add(LoadMatchesEvent()),
                  child: const Text('Riprova'),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text('Nessuna partita trovata'),
          );
        }
      },
    );
  }

  Widget _buildMatchList(List<Match> matches) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nessuna partita giocata',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inizia una partita per vedere la cronologia qui',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: matches.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return _buildMatchCard(matches[index]);
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    context.read<MatchListBloc>().add(RefreshMatchesEvent());
    // Attendi un po' per permettere alla richiesta di completarsi
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildMatchCard(Match match) {
    final currentUserId = supabase.auth.currentUser?.id;
    final isPlayer1 = match.player1Id == currentUserId;
    
    // Use joined data if available, otherwise fall back to IDs
    final String player1Name = match.player1?.username ?? 
                              match.player1Id?.substring(0, 8) ?? 'Giocatore 1';
    final String player2Name = match.player2?.username ?? 
                              match.player2Id?.substring(0, 8) ?? 'Giocatore 2';
    
    // Use joined deck data if available, otherwise fall back to IDs
    final String player1DeckName = match.player1Deck?.name ?? 
                                  match.player1DeckId?.substring(0, 8) ?? 'Mazzo 1';
    final String player2DeckName = match.player2Deck?.name ?? 
                                  match.player2DeckId?.substring(0, 8) ?? 'Mazzo 2';
    
    final isWinner = match.winnerId == currentUserId;
    final isCompleted = match.winnerId != null;
    
    final format = match.format.toUpperCase();
    
    final date = match.date != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(match.date!)
        : 'Data sconosciuta';
    
    final Color cardColor = isCompleted
        ? (isWinner ? Colors.green.shade50 : Colors.red.shade50)
        : Colors.grey.shade50;
        
    final Color borderColor = isCompleted
        ? (isWinner ? Colors.green : Colors.red)
        : Colors.grey;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(format),
                  backgroundColor: Colors.blue.shade100,
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPlayer1 ? 'Tu' : player1Name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: match.winnerId == match.player1Id 
                              ? Colors.green 
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        player1DeckName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isPlayer1 ? player2Name : 'Tu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: match.winnerId == match.player2Id 
                              ? Colors.green 
                              : Colors.black,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        player2DeckName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isWinner ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isWinner ? 'Hai vinto' : 'Hai perso',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isWinner ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 