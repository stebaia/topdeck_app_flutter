import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/ui/widgets/current_user_builder.dart';

class DeckPerformanceDebugWidget extends StatefulWidget {
  const DeckPerformanceDebugWidget({super.key});

  @override
  State<DeckPerformanceDebugWidget> createState() => _DeckPerformanceDebugWidgetState();
}

class _DeckPerformanceDebugWidgetState extends State<DeckPerformanceDebugWidget> {
  bool _isLoading = true;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _loadDebugData();
  }

  Future<void> _loadDebugData() async {
    final currentUser = CurrentUserHelper.getCurrentUser(context);
    if (currentUser == null) {
      setState(() {
        _debugInfo = 'No current user found';
        _isLoading = false;
      });
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      
      // Test 1: Conta i match dell'utente
      final matchCount = await supabase
          .from('matches_extended')
          .select('id')
          .or('player1_id.eq.${currentUser.id},player2_id.eq.${currentUser.id}')
          .count();
      
      // Test 2: Conta i deck dell'utente  
      final deckCount = await supabase
          .from('decks')
          .select('id')
          .eq('user_id', currentUser.id)
          .count();
      
      // Test 3: Prendi un sample di match
      final sampleMatches = await supabase
          .from('matches_extended')
          .select('id, player1_id, player2_id, winner_id, format, date')
          .or('player1_id.eq.${currentUser.id},player2_id.eq.${currentUser.id}')
          .limit(3);

      setState(() {
        _debugInfo = '''
User ID: ${currentUser.id}
Match Count: $matchCount
Deck Count: $deckCount

Sample Matches:
${sampleMatches.map((m) => 'ID: ${m['id']}, Winner: ${m['winner_id']}, Format: ${m['format']}').join('\n')}
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DEBUG WIDGET',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Text(
                _debugInfo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
          ],
        ),
      ),
    );
  }
} 