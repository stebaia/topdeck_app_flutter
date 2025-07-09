import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_state.dart';
import 'package:topdeck_app_flutter/model/entities/match.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Widget per mostrare i match attivi nella dashboard
class ActiveMatchesDashboardWidget extends StatelessWidget {
  const ActiveMatchesDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchListBloc, MatchListState>(
      builder: (context, state) {
        return SizedBox(
        
          child: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, MatchListState state) {
    switch (state) {
      case MatchListInitialState():
        return const SizedBox.shrink();
      case MatchListLoadingState():
        return _buildLoadingWidget(context);
      case MatchListLoadedState():
        return _buildLoadedWidget(context, state);
      case MatchListErrorState():
        return _buildErrorWidget(context, state);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLoadedWidget(BuildContext context, MatchListLoadedState state) {
    // Filtra solo i match attivi (senza vincitore)
    final activeMatches = state.matches.where((match) => match.winnerId == null).toList();
    
   
    if (activeMatches.isNotEmpty) {
    // Mostra solo l'ultimo match attivo (dovrebbe essere solo 1)
    return Center(
      child: Container(
        height: 260,
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: _buildActiveMatchCard(context, activeMatches.last),
      ),
    );
    } else {
      return  Container();
    }
  }

  Widget _buildErrorWidget(BuildContext context, MatchListErrorState state) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Errore nel caricamento match',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMatchCard(BuildContext context, Match match) {
    final currentUserId = supabase.auth.currentUser?.id;
    final isPlayer1 = match.player1Id == currentUserId;
    
    // Use joined data if available, otherwise fall back to IDs
    final String player1Name = match.player1?.username ?? 
                              match.player1Id?.substring(0, 8) ?? 'Giocatore 1';
    final String player2Name = match.player2?.username ?? 
                              match.player2Id?.substring(0, 8) ?? 'Giocatore 2';
    final String opponentName = isPlayer1 ? player2Name : player1Name;
    final String currentUserName = isPlayer1 ? player1Name : player2Name;
    
    final String player1DeckName = match.player1Deck?.name ?? 
                                  match.player1DeckId?.substring(0, 8) ?? 'Mazzo 1';
    final String player2DeckName = match.player2Deck?.name ?? 
                                  match.player2DeckId?.substring(0, 8) ?? 'Mazzo 2';
    final String opponentDeckName = isPlayer1 ? player2DeckName : player1DeckName;
    final String currentUserDeckName = isPlayer1 ? player1DeckName : player2DeckName;
    
    final format = match.format.toUpperCase();
    
    // Calcola il tempo trascorso dall'inizio
    final date = match.date ?? DateTime.now();
    final now = DateTime.now();
    final difference = now.difference(date);
    
    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d fa';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h fa';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}min fa';
    } else {
      timeAgo = 'Appena iniziato';
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Create a complete map with all data for the route
          final matchMap = {
            'id': match.id,
            'player1_id': match.player1Id,
            'player2_id': match.player2Id,
            'winner_id': match.winnerId,
            'format': match.format,
            'date': match.date?.toIso8601String(),
            'player1_deck_id': match.player1DeckId,
            'player2_deck_id': match.player2DeckId,
            // Include joined data if available
            'player1': match.player1?.toJson(),
            'player2': match.player2?.toJson(),
            'player1_deck': match.player1Deck?.toJson(),
            'player2_deck': match.player2Deck?.toJson(),
          };
          context.router.push(MatchDetailPageRoute(match: matchMap));
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode 
                ? [
                    Colors.orange.shade900,
                    Colors.orange.shade700,
                    Colors.orange.shade600,
                  ]
                : [
                    Colors.orange.shade500,
                    Colors.orange.shade600,
                    Colors.orange.shade700,
                  ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Pattern decorativo di sfondo
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
              ),
              
              // Contenuto principale
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header con formato, tempo e status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.casino, color: Colors.white, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    format,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                timeAgo,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_filled, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'IN CORSO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Sezione giocatori con avatar
                    Row(
                      children: [
                        // Tu
                        Expanded(
                          child: Column(
                            children: [
                              // Avatar del giocatore corrente
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withOpacity(0.3),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                                                      child: Text(
                                      currentUserName.isNotEmpty ? currentUserName[0].toUpperCase() : 'T',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                                              Text(
                                  'Tu',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.style, color: Colors.white.withOpacity(0.8), size: 12),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        currentUserDeckName,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.95),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // VS Section centrale
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                ),
                                                                  child: const Text(
                                    'VS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                              Icon(
                                Icons.flash_on,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        
                        // Avversario
                        Expanded(
                          child: Column(
                            children: [
                              // Avatar dell'avversario
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withOpacity(0.3),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                                                      child: Text(
                                      opponentName.isNotEmpty ? opponentName[0].toUpperCase() : 'O',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                                              Text(
                                  opponentName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.style, color: Colors.white.withOpacity(0.8), size: 12),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        opponentDeckName,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.95),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Footer con call to action
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: Colors.white.withOpacity(0.9),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tocca per inserire il risultato',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withOpacity(0.8),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 