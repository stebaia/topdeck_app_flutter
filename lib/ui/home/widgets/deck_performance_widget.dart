import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/model/entities/match_extended.dart';
import 'package:topdeck_app_flutter/repositories/deck_repository.dart';
import 'package:topdeck_app_flutter/ui/widgets/current_user_builder.dart';

class DeckPerformanceWidget extends StatefulWidget {
  const DeckPerformanceWidget({super.key});

  @override
  State<DeckPerformanceWidget> createState() => _DeckPerformanceWidgetState();
}

class _DeckPerformanceWidgetState extends State<DeckPerformanceWidget> {
  bool _isLoading = true;
  String? _selectedFormat;
  String? _selectedDeck;
  String _selectedPeriod = '30'; // Default 30 days
  
  List<Deck> _userDecks = [];
  List<MatchExtended> _matchHistory = [];
  Map<String, DeckStats> _deckStats = {};

  final List<String> _periods = ['7', '30', '90', 'Tutto'];
  final List<String> _formats = ['Tutti', 'advanced', 'goat', 'edison', 'hat', 'custom'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final currentUser = CurrentUserHelper.getCurrentUser(context);
    if (currentUser == null) return;

    if (!mounted) return;
    
    // Store context references before async operations
    final deckRepository = context.read<DeckRepository>();
    
    setState(() => _isLoading = true);

    try {
      // Carica i deck dell'utente
      _userDecks = await deckRepository.findByUserId(currentUser.id);
      debugPrint('Loaded ${_userDecks.length} user decks:');
      for (final deck in _userDecks) {
        debugPrint('  Deck: ${deck.name} (${deck.id}) - Format: ${deck.format.name}');
      }

      // Carica la match history direttamente dal database usando Supabase
      await _loadMatchHistory(currentUser.id);

      // Calcola le statistiche
      _calculateStats();
    } catch (e) {
      debugPrint('Error loading deck performance data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMatchHistory(String userId) async {
    try {
      debugPrint('Loading match history for user: $userId');
      
      // Usa Supabase direttamente per caricare i match
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('matches_extended')
          .select('''
            id,
            player1_id,
            player2_id,
            winner_id,
            format,
            date,
            player1_deck_id,
            player2_deck_id,
            player1_elo_before,
            player2_elo_before,
            player1_elo_after,
            player2_elo_after,
            player1_elo_change,
            player2_elo_change,
            tournament_id,
            is_friendly,
            is_bye,
            round
          ''')
          .or('player1_id.eq.$userId,player2_id.eq.$userId')
          .order('date', ascending: false)
          .limit(200);
      
      debugPrint('Raw Supabase response: ${response.length} rows');
      if (response.isNotEmpty) {
        debugPrint('First match sample: ${response.first}');
      }
      
      _matchHistory = response.map<MatchExtended>((matchData) {
        try {
          final match = MatchExtended(
            id: matchData['id'],
            player1Id: matchData['player1_id'],
            player2Id: matchData['player2_id'],
            player1DeckId: matchData['player1_deck_id'],
            player2DeckId: matchData['player2_deck_id'],
            winnerId: matchData['winner_id'],
            format: matchData['format'],
            date: matchData['date'] != null ? DateTime.parse(matchData['date']) : null,
            tournamentId: matchData['tournament_id'],
            isFriendly: matchData['is_friendly'] ?? false,
            isBye: matchData['is_bye'] ?? false,
            player1EloBefore: matchData['player1_elo_before'],
            player2EloBefore: matchData['player2_elo_before'],
            player1EloAfter: matchData['player1_elo_after'],
            player2EloAfter: matchData['player2_elo_after'],
            player1EloChange: matchData['player1_elo_change'],
            player2EloChange: matchData['player2_elo_change'],
            round: matchData['round'],
          );
          return match;
        } catch (e) {
          debugPrint('Error parsing match data: $e');
          debugPrint('Match data: $matchData');
          rethrow;
        }
      }).toList();
      
      debugPrint('Successfully loaded ${_matchHistory.length} matches for user $userId');
      for (int i = 0; i < _matchHistory.length && i < 3; i++) {
        final match = _matchHistory[i];
        debugPrint('  Sample match $i: ${match.id}, p1: ${match.player1Id}, p2: ${match.player2Id}, winner: ${match.winnerId}, deck1: ${match.player1DeckId}, deck2: ${match.player2DeckId}');
      }
    } catch (e) {
      debugPrint('Error loading match history: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      _matchHistory = [];
    }
  }

  void _calculateStats() {
    debugPrint('=== CALCULATING DECK PERFORMANCE STATS ===');
    debugPrint('Match history: ${_matchHistory.length} matches');
    debugPrint('User decks: ${_userDecks.length} decks');
    
    _deckStats.clear();
    final currentUser = CurrentUserHelper.getCurrentUser(context);
    if (currentUser == null) {
      debugPrint('No current user found');
      return;
    }

    debugPrint('Current user ID: ${currentUser.id}');

    // Filtra i match per periodo
    final filteredMatches = _filterMatchesByPeriod(_matchHistory);
    debugPrint('Filtered matches: ${filteredMatches.length} from ${_matchHistory.length} total');

    // Raggruppa per deck e calcola statistiche
    int processedMatches = 0;
    for (final match in filteredMatches) {
      // Determina quale deck ha usato l'utente corrente
      String? userDeckId;
      bool isPlayer1 = match.player1Id == currentUser.id;
      
      if (isPlayer1 && match.player1DeckId != null) {
        userDeckId = match.player1DeckId!;
        debugPrint('Match ${match.id}: User is player1, deck: $userDeckId');
      } else if (!isPlayer1 && match.player2DeckId != null) {
        userDeckId = match.player2DeckId!;
        debugPrint('Match ${match.id}: User is player2, deck: $userDeckId');
      } else {
        debugPrint('Match ${match.id}: User not found or no deck ID (p1: ${match.player1Id}, p2: ${match.player2Id})');
        continue;
      }

      if (userDeckId == null) {
        debugPrint('Match ${match.id}: No deck ID found');
        continue;
      }

      // Trova il deck corrispondente
      final deck = _userDecks.where((d) => d.id == userDeckId).firstOrNull;
      if (deck == null) {
        debugPrint('Match ${match.id}: Deck not found in user decks: $userDeckId');
        continue;
      }

      // Applica filtri
      if (_selectedFormat != null && _selectedFormat != 'Tutti' && deck.format.name != _selectedFormat) {
        debugPrint('Match ${match.id}: Filtered out by format (${deck.format.name} != $_selectedFormat)');
        continue;
      }
      if (_selectedDeck != null && deck.id != _selectedDeck) {
        debugPrint('Match ${match.id}: Filtered out by deck selection');
        continue;
      }

      // Inizializza stats se non esistono
      if (!_deckStats.containsKey(deck.id)) {
        _deckStats[deck.id] = DeckStats(
          deckId: deck.id,
          deckName: deck.name,
          totalMatches: 0,
          wins: 0,
          losses: 0,
          draws: 0,
        );
        debugPrint('Created stats for deck: ${deck.name}');
      }

      final stats = _deckStats[deck.id]!;
      stats.totalMatches++;

      // Determina il risultato
      final result = match.getResultForPlayer(currentUser.id);
      debugPrint('Match ${match.id} result for user: $result');
      switch (result) {
        case MatchResult.win:
          stats.wins++;
          break;
        case MatchResult.loss:
          stats.losses++;
          break;
        case MatchResult.draw:
          stats.draws++;
          break;
        case MatchResult.bye:
          // I bye non contano per le statistiche di performance
          stats.totalMatches--;
          break;
      }
      processedMatches++;
    }

    debugPrint('Processed $processedMatches matches');
    debugPrint('Calculated stats for ${_deckStats.length} decks:');
    _deckStats.forEach((key, value) {
      debugPrint('  ${value.deckName}: ${value.wins}/${value.totalMatches} (${(value.totalMatches > 0 ? (value.wins / value.totalMatches) * 100 : 0).toStringAsFixed(1)}%)');
    });
    debugPrint('=== END STATS CALCULATION ===');
  }

  List<MatchExtended> _filterMatchesByPeriod(List<MatchExtended> matches) {
    if (_selectedPeriod == 'Tutto') return matches;

    final days = int.parse(_selectedPeriod);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return matches.where((match) {
      return match.date != null && match.date!.isAfter(cutoffDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildChart(),
          ],
        ),
      ),
    );
  }

    Widget _buildHeader() {
    // Calcola win rate generale
    int totalWins = _deckStats.values.fold(0, (sum, stats) => sum + stats.wins);
    int totalMatches = _deckStats.values.fold(0, (sum, stats) => sum + stats.totalMatches);
    double winRate = totalMatches > 0 ? (totalWins / totalMatches) * 100 : 0;

    // Conta filtri attivi
    int activeFilters = 0;
    if (_selectedPeriod != '30') activeFilters++; // default è 30 giorni
    if (_selectedFormat != null) activeFilters++;
    if (_selectedDeck != null) activeFilters++;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deck Performance',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${winRate.toStringAsFixed(0)}% Win Rate',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              Text(
                _buildSubtitle(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        // Pulsante filtri elegante
        Stack(
          children: [
            Material(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showFiltersBottomSheet,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.tune_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
              ),
            ),
            if (activeFilters > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$activeFilters',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _buildSubtitle() {
    List<String> parts = [];
    
    if (_selectedPeriod == 'Tutto') {
      parts.add('All time');
    } else {
      parts.add('Last $_selectedPeriod days');
    }
    
    if (_selectedFormat != null) {
      parts.add(_selectedFormat!.toUpperCase());
    }
    
    if (_selectedDeck != null) {
      final deck = _userDecks.firstWhere((d) => d.id == _selectedDeck);
      parts.add(deck.name);
    }
    
    return parts.join(' • ');
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Filtri Performance',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedPeriod = '30';
                          _selectedFormat = null;
                          _selectedDeck = null;
                          _calculateStats();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    _buildFilterSection(
                      'Periodo di tempo',
                      Icons.schedule_rounded,
                      _periods.map((period) => FilterOption(
                        label: period == "Tutto" ? "Tutti i match" : "Ultimi $period giorni",
                        value: period,
                        isSelected: _selectedPeriod == period,
                        onTap: () => _selectPeriod(period),
                      )).toList(),
                    ),
                    const SizedBox(height: 32),
                    _buildFilterSection(
                      'Formato',
                      Icons.style_rounded,
                      _formats.map((format) => FilterOption(
                        label: format == 'Tutti' ? 'Tutti i formati' : format.toUpperCase(),
                        value: format,
                        isSelected: (_selectedFormat ?? 'Tutti') == format,
                        onTap: () => _selectFormat(format == 'Tutti' ? null : format),
                      )).toList(),
                    ),
                    if (_userDecks.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      _buildFilterSection(
                        'Deck specifico',
                        Icons.style_rounded,
                        [
                          FilterOption(
                            label: 'Tutti i deck',
                            value: null,
                            isSelected: _selectedDeck == null,
                            onTap: () => _selectDeck(null),
                          ),
                          ..._userDecks.map((deck) => FilterOption(
                            label: deck.name,
                            value: deck.id,
                            isSelected: _selectedDeck == deck.id,
                            onTap: () => _selectDeck(deck.id),
                          )),
                        ],
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, List<FilterOption> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...options.map((option) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: option.isSelected 
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                option.onTap();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: option.isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: option.isSelected ? FontWeight.w500 : FontWeight.normal,
                          color: option.isSelected 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                    ),
                    if (option.isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  void _selectPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      _calculateStats();
    });
  }

  void _selectFormat(String? format) {
    setState(() {
      _selectedFormat = format;
      _calculateStats();
    });
  }

  void _selectDeck(String? deckId) {
    setState(() {
      _selectedDeck = deckId;
      _calculateStats();
    });
  }



  Widget _buildChart() {
    if (_deckStats.isEmpty) {
             return SizedBox(
         height: 200,
         child: Center(
          child: Text(
                         'Nessun dato disponibile per il periodo selezionato',
             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
               color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
             ),
          ),
        ),
      );
    }

    // Ordina i deck per win rate
    final sortedStats = _deckStats.values.toList()
      ..sort((a, b) => b.winRate.compareTo(a.winRate));

    // Prendi i top 4 deck
    final topStats = sortedStats.take(4).toList();
    final maxWinRate = topStats.isEmpty ? 100.0 : topStats.first.winRate;

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: topStats.map((stats) => _buildBar(stats, maxWinRate)).toList(),
      ),
    );
  }

  Widget _buildBar(DeckStats stats, double maxWinRate) {
    final barHeight = maxWinRate > 0 ? (stats.winRate / maxWinRate) * 150 : 0.0;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: barHeight.clamp(10.0, 150.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stats.deckName,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class FilterOption {
  final String label;
  final dynamic value;
  final bool isSelected;
  final VoidCallback onTap;

  FilterOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });
}

class DeckStats {
  final String deckId;
  final String deckName;
  int totalMatches;
  int wins;
  int losses;
  int draws;

  DeckStats({
    required this.deckId,
    required this.deckName,
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
  });

  double get winRate {
    if (totalMatches == 0) return 0.0;
    return (wins / totalMatches) * 100;
  }
} 