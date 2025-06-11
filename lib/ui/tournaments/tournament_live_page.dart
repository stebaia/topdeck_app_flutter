import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/tournament.dart';
import 'package:topdeck_app_flutter/model/entities/tournament_match.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/swiss_system_bloc.dart';

/// Page for managing live tournament with Swiss system
class TournamentLivePage extends StatefulWidget {
  final Tournament tournament;

  const TournamentLivePage({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentLivePage> createState() => _TournamentLivePageState();
}

class _TournamentLivePageState extends State<TournamentLivePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load current round when page opens
    if (widget.tournament.currentRound > 0) {
      context.read<SwissSystemBloc>().add(
        LoadCurrentRoundEvent(
          tournamentId: widget.tournament.id,
          round: widget.tournament.currentRound,
        ),
      );
    }
    
    // Load standings
    context.read<SwissSystemBloc>().add(
      LoadStandingsEvent(tournamentId: widget.tournament.id),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pairings', icon: Icon(Icons.people)),
            Tab(text: 'Classifica', icon: Icon(Icons.leaderboard)),
            Tab(text: 'Gestione', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPairingsTab(),
          _buildStandingsTab(),
          _buildManagementTab(),
        ],
      ),
    );
  }

  Widget _buildPairingsTab() {
    return BlocBuilder<SwissSystemBloc, SwissSystemState>(
      builder: (context, state) {
        if (state is SwissSystemLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is SwissSystemError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Errore: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshCurrentRound,
                  child: const Text('Riprova'),
                ),
              ],
            ),
          );
        }

        if (state is CurrentRoundLoaded) {
          return _buildCurrentRoundView(state.matches, state.round);
        }

        if (state is PairingsGenerated) {
          return _buildCurrentRoundView(state.pairings, state.round);
        }

        // No current round
        return _buildNoCurrentRoundView();
      },
    );
  }

  Widget _buildCurrentRoundView(List<TournamentMatch> matches, int round) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nessun match nel round $round',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Round header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Round $round',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.tournament.roundTimerEnd != null)
                _buildRoundTimer(),
            ],
          ),
        ),
        
        // Matches list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return _buildMatchCard(match);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoundTimer() {
    if (widget.tournament.roundTimerEnd == null) {
      return const SizedBox.shrink();
    }

    final timeLeft = widget.tournament.roundTimerEnd!.difference(DateTime.now());
    if (timeLeft.isNegative) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Tempo scaduto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    final minutes = timeLeft.inMinutes;
    final seconds = timeLeft.inSeconds % 60;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: minutes < 10 ? Colors.orange : Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildMatchCard(TournamentMatch match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tavolo ${match.tableNumber ?? 'N/A'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildMatchStatusChip(match.matchStatus),
              ],
            ),
            const SizedBox(height: 12),
            
            // Players or bye
            if (match.isBye)
              _buildByeDisplay(match)
            else
              _buildPlayersDisplay(match),
            
            // Result display
            if (match.resultScore != null) ...[
              const SizedBox(height: 12),
              _buildResultDisplay(match),
            ],
            
            // Actions
            const SizedBox(height: 16),
            _buildMatchActions(match),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchStatusChip(MatchStatus status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case MatchStatus.pending:
        color = Colors.grey;
        text = 'In attesa';
        icon = Icons.schedule;
        break;
      case MatchStatus.inProgress:
        color = Colors.blue;
        text = 'In corso';
        icon = Icons.play_arrow;
        break;
      case MatchStatus.finished:
        color = Colors.green;
        text = 'Finito';
        icon = Icons.check;
        break;
      case MatchStatus.disputed:
        color = Colors.red;
        text = 'Disputato';
        icon = Icons.warning;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildByeDisplay(TournamentMatch match) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BYE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                Text(
                  'Player ID: ${match.activePlayerId ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersDisplay(TournamentMatch match) {
    return Column(
      children: [
        // Player 1
        _buildPlayerRow(
          playerId: match.player1Id ?? 'N/A',
          isWinner: match.winnerId == match.player1Id,
        ),
        const SizedBox(height: 8),
        const Text('VS', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Player 2
        _buildPlayerRow(
          playerId: match.player2Id ?? 'N/A',
          isWinner: match.winnerId == match.player2Id,
        ),
      ],
    );
  }

  Widget _buildPlayerRow({required String playerId, required bool isWinner}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isWinner ? Colors.green.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(6),
        border: isWinner ? Border.all(color: Colors.green) : null,
      ),
      child: Row(
        children: [
          if (isWinner) ...[
            const Icon(Icons.emoji_events, color: Colors.green, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              'Player: $playerId', // Qui potresti caricare il nome del player
              style: TextStyle(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultDisplay(TournamentMatch match) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.score, size: 16),
          const SizedBox(width: 8),
          Text(
            'Risultato: ${match.resultScore}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchActions(TournamentMatch match) {
    return Row(
      children: [
        if (match.matchStatus == MatchStatus.pending) ...[
          ElevatedButton.icon(
            onPressed: () => _startMatch(match.id),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Inizia'),
          ),
          const SizedBox(width: 8),
        ],
        if (match.matchStatus == MatchStatus.inProgress) ...[
          ElevatedButton.icon(
            onPressed: () => _submitResult(match),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Risultato'),
          ),
          const SizedBox(width: 8),
        ],
        OutlinedButton.icon(
          onPressed: () => _showMatchDetails(match),
          icon: const Icon(Icons.info, size: 16),
          label: const Text('Dettagli'),
        ),
      ],
    );
  }

  Widget _buildNoCurrentRoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_esports, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nessun round attivo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Genera i pairing per iniziare il torneo'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateFirstRound,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Genera Round 1'),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingsTab() {
    return BlocBuilder<SwissSystemBloc, SwissSystemState>(
      builder: (context, state) {
        if (state is StandingsLoaded) {
          return _buildStandingsList(state.standings);
        }
        
        if (state is SwissSystemLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is SwissSystemError) {
          return Center(child: Text('Errore: ${state.message}'));
        }
        
        return const Center(child: Text('Carica la classifica'));
      },
    );
  }

  Widget _buildStandingsList(List<Map<String, dynamic>> standings) {
    if (standings.isEmpty) {
      return const Center(child: Text('Nessun dato nella classifica'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: standings.length,
      itemBuilder: (context, index) {
        final standing = standings[index];
        return _buildStandingCard(standing, index + 1);
      },
    );
  }

  Widget _buildStandingCard(Map<String, dynamic> standing, int position) {
    final points = standing['points'] ?? 0;
    final matchWins = standing['match_wins'] ?? 0;
    final matchLosses = standing['match_losses'] ?? 0;
    final matchDraws = standing['match_draws'] ?? 0;
    final username = standing['username'] ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPositionColor(position),
          child: Text(
            position.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$matchWins-$matchLosses-$matchDraws',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$points pts',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber[700]!; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return Colors.brown[400]!; // Bronze
      default:
        return Colors.blue[400]!;
    }
  }

  Widget _buildManagementTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informazioni Torneo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Round corrente: ${widget.tournament.currentRound}'),
                  Text('Round totali: ${widget.tournament.totalRounds ?? 'N/A'}'),
                  Text('Formato: ${widget.tournament.format}'),
                  if (widget.tournament.maxParticipants != null)
                    Text('Max partecipanti: ${widget.tournament.maxParticipants}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Actions
          ElevatedButton.icon(
            onPressed: _generateNextRound,
            icon: const Icon(Icons.skip_next),
            label: const Text('Genera Prossimo Round'),
          ),
          const SizedBox(height: 8),
          
          OutlinedButton.icon(
            onPressed: _refreshStandings,
            icon: const Icon(Icons.refresh),
            label: const Text('Aggiorna Classifica'),
          ),
          const SizedBox(height: 8),
          
          OutlinedButton.icon(
            onPressed: _exportResults,
            icon: const Icon(Icons.download),
            label: const Text('Esporta Risultati'),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _refreshCurrentRound() {
    if (widget.tournament.currentRound > 0) {
      context.read<SwissSystemBloc>().add(
        LoadCurrentRoundEvent(
          tournamentId: widget.tournament.id,
          round: widget.tournament.currentRound,
        ),
      );
    }
  }

  void _generateFirstRound() {
    context.read<SwissSystemBloc>().add(
      GeneratePairingsEvent(
        tournamentId: widget.tournament.id,
        roundNumber: 1,
      ),
    );
  }

  void _generateNextRound() {
    final nextRound = widget.tournament.currentRound + 1;
    context.read<SwissSystemBloc>().add(
      GeneratePairingsEvent(
        tournamentId: widget.tournament.id,
        roundNumber: nextRound,
      ),
    );
  }

  void _startMatch(String matchId) {
    context.read<SwissSystemBloc>().add(
      StartMatchEvent(matchId: matchId),
    );
  }

  void _submitResult(TournamentMatch match) {
    // Qui mostreresti un dialog per inserire il risultato
    showDialog(
      context: context,
      builder: (context) => _buildResultDialog(match),
    );
  }

  void _showMatchDetails(TournamentMatch match) {
    // Mostra dettagli del match
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Match Tavolo ${match.tableNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Player 1: ${match.player1Id}'),
            Text('Player 2: ${match.player2Id ?? 'BYE'}'),
            Text('Status: ${match.matchStatus.name}'),
            if (match.resultScore != null)
              Text('Risultato: ${match.resultScore}'),
          ],
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

  void _refreshStandings() {
    context.read<SwissSystemBloc>().add(
      LoadStandingsEvent(tournamentId: widget.tournament.id),
    );
  }

  void _exportResults() {
    // Implementa esportazione risultati
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funzione esportazione non ancora implementata')),
    );
  }

  Widget _buildResultDialog(TournamentMatch match) {
    String? selectedWinner;
    String selectedScore = '2-0';
    
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Inserisci Risultato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Winner selection
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Vincitore'),
                value: selectedWinner,
                items: [
                  DropdownMenuItem(
                    value: match.player1Id,
                    child: Text('Player 1: ${match.player1Id}'), 
                  ),
                  DropdownMenuItem(
                    value: match.player2Id,
                    child: Text('Player 2: ${match.player2Id}'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedWinner = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Score selection
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Punteggio'),
                value: selectedScore,
                items: const [
                  DropdownMenuItem(value: '2-0', child: Text('2-0')),
                  DropdownMenuItem(value: '2-1', child: Text('2-1')),
                  DropdownMenuItem(value: '1-2', child: Text('1-2')),
                  DropdownMenuItem(value: '0-2', child: Text('0-2')),
                  DropdownMenuItem(value: '1-1', child: Text('1-1 (Pareggio)')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedScore = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: selectedWinner != null
                  ? () {
                      context.read<SwissSystemBloc>().add(
                        SubmitMatchResultEvent(
                          matchId: match.id,
                          winnerId: selectedWinner!,
                          score: selectedScore,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );
  }
} 