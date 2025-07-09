import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/life_point.dart';

// Data model per storico partita
class GameHistoryItem {
  final int player1LP;
  final int player2LP;
  final int player1Change;
  final int player2Change;
  final String timestamp;

  GameHistoryItem({
    required this.player1LP,
    required this.player2LP,
    required this.player1Change,
    required this.player2Change,
    required this.timestamp,
  });
}

@RoutePage()
class LifeCounterPage extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> match;

  const LifeCounterPage({
    Key? key,
    required this.matchId,
    required this.match,
  }) : super(key: key);

  @override
  State<LifeCounterPage> createState() => _LifeCounterPageState();
}

class _LifeCounterPageState extends State<LifeCounterPage> with TickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  int? _roomId;
  List<LifePoint> _lifePoints = [];
  bool _isLoading = true;
  String? _error;
  RealtimeChannel? _channel;
  
  // Timer e stato del gioco
  Timer? _gameTimer;
  int _timeLeftInSeconds = 45 * 60; // 45 minuti in secondi
  int _totalGameTimeSeconds = 0;
  bool _isTimerRunning = false;
  bool _gameStarted = false;
  
  // Input e controllo giocatori
  String _currentInput = '';
  bool _isForPlayer1 = true;
  
  // Controller per animazioni
  late AnimationController _player1ScaleController;
  late AnimationController _player2ScaleController;
  int _lastPlayer1LifePoints = 8000;
  int _lastPlayer2LifePoints = 8000;
  
  // Storico della partita
  List<GameHistoryItem> _gameHistory = [];

  @override
  void initState() {
    super.initState();
    _loadRoomAndStartListening();
    _initAnimationControllers();
  }

  void _initAnimationControllers() {
    _player1ScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _player2ScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _player1ScaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _player1ScaleController.reverse();
      }
    });
    
    _player2ScaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _player2ScaleController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _gameTimer?.cancel();
    _player1ScaleController.dispose();
    _player2ScaleController.dispose();
    super.dispose();
  }

  Future<void> _loadRoomAndStartListening() async {
    try {
      final roomResponse = await _supabase
          .from('room')
          .select()
          .eq('match_id', widget.matchId)
          .single();
      
      final roomId = roomResponse['id'] as int;
      await _loadLifePoints(roomId);
      _startRealTimeListening(roomId);
      
      setState(() {
        _roomId = roomId;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = 'Errore caricamento room: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLifePoints(int roomId) async {
    try {
      final response = await _supabase
          .from('life_points')
          .select()
          .eq('room_id', roomId);
      
      final lifePoints = response.map<LifePoint>((json) => LifePoint.fromJson(json)).toList();
      
      setState(() {
        _lifePoints = lifePoints;
        // Aggiorna i valori per le animazioni
        final player1Id = widget.match['player1_id'] ?? '';
        final player2Id = widget.match['player2_id'] ?? '';
        
        if (player1Id.isNotEmpty) {
          final player1LP = lifePoints.firstWhere(
            (lp) => lp.playerId == player1Id,
            orElse: () => LifePoint(id: 0, roomId: 0, playerId: player1Id, life: 8000),
          );
          _lastPlayer1LifePoints = player1LP.life;
        }
        
        if (player2Id.isNotEmpty) {
          final player2LP = lifePoints.firstWhere(
            (lp) => lp.playerId == player2Id,
            orElse: () => LifePoint(id: 0, roomId: 0, playerId: player2Id, life: 8000),
          );
          _lastPlayer2LifePoints = player2LP.life;
        }
      });
      
    } catch (e) {
      throw e;
    }
  }

  void _startRealTimeListening(int roomId) {
    _channel = _supabase
        .channel('life_points_$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'life_points',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            _loadLifePoints(roomId);
          },
        )
        .subscribe();
  }

  Future<void> _updateLifePoints(String playerId, int newLifePoints) async {
    if (_roomId == null) return;
    if (newLifePoints < 0) newLifePoints = 0;
    
    try {
      await _supabase
          .from('life_points')
          .update({
            'life': newLifePoints,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('room_id', _roomId!)
          .eq('player_id', playerId);
      
    } catch (e) {
      print('❌ Update error: $e');
    }
  }

  // Metodi per il gioco e timer
  void _startGame() {
    setState(() {
      _gameStarted = true;
      _isTimerRunning = true;
      _timeLeftInSeconds = 45 * 60; // Reset a 45 minuti
    });
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeftInSeconds > 0) {
          _timeLeftInSeconds--;
          _totalGameTimeSeconds++;
        } else {
          // Timer finito
          _pauseGame();
        }
      });
    });
  }

  void _pauseGame() {
    _gameTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resumeGame() {
    setState(() {
      _isTimerRunning = true;
    });
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeftInSeconds > 0) {
          _timeLeftInSeconds--;
          _totalGameTimeSeconds++;
        } else {
          // Timer finito
          _pauseGame();
        }
      });
    });
  }

  void _resetGame() {
    _gameTimer?.cancel();
    setState(() {
      _gameStarted = false;
      _isTimerRunning = false;
      _timeLeftInSeconds = 45 * 60; // Reset a 45 minuti
      _totalGameTimeSeconds = 0;
      _currentInput = '';
      _gameHistory.clear();
    });
    
    // Reset dei life points a 8000
    if (_roomId != null) {
      final player1Id = widget.match['player1_id'] ?? '';
      final player2Id = widget.match['player2_id'] ?? '';
      
      if (player1Id.isNotEmpty) _updateLifePoints(player1Id, 8000);
      if (player2Id.isNotEmpty) _updateLifePoints(player2Id, 8000);
    }
  }

  // Metodi di input
  void _addDigit(String digit) {
    HapticFeedback.lightImpact(); // Feedback aptico
    setState(() {
      if (_currentInput.length < 5) {
        _currentInput += digit;
      }
    });
  }

  void _clearInput() {
    HapticFeedback.selectionClick(); // Feedback aptico per clear
    setState(() {
      _currentInput = '';
    });
  }

  void _backspace() {
    HapticFeedback.lightImpact(); // Feedback aptico per backspace
    setState(() {
      if (_currentInput.length > 1) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      } else {
        _currentInput = '';
      }
    });
  }

  void _applyInput(bool isAddition) {
    if (_currentInput.isEmpty) return;
    
    HapticFeedback.mediumImpact(); // Feedback aptico per operazioni
    
    final value = int.parse(_currentInput);
    final amount = isAddition ? value : -value;
    
    final playerId = _isForPlayer1 
        ? widget.match['player1_id'] ?? ''
        : widget.match['player2_id'] ?? '';
    
    if (playerId.isEmpty) return;
    
    final currentLifePoints = _lifePoints.firstWhere(
      (lp) => lp.playerId == playerId,
      orElse: () => LifePoint(id: 0, roomId: 0, playerId: playerId, life: 8000),
    );
    
    final newLife = (currentLifePoints.life + amount).clamp(0, 99999);
    
    // Aggiungi al history
    _addToHistory(playerId, amount);
    
    // Aggiorna i life points
    _updateLifePoints(playerId, newLife);
    
    // Attiva l'animazione
    if (_isForPlayer1) {
      _player1ScaleController.forward();
    } else {
      _player2ScaleController.forward();
    }
    
    _clearInput();
  }

  void _halveLifePoints() {
    HapticFeedback.heavyImpact(); // Feedback aptico più forte per dimezza
    
    final playerId = _isForPlayer1 
        ? widget.match['player1_id'] ?? ''
        : widget.match['player2_id'] ?? '';
    
    if (playerId.isEmpty) return;
    
    final currentLifePoints = _lifePoints.firstWhere(
      (lp) => lp.playerId == playerId,
      orElse: () => LifePoint(id: 0, roomId: 0, playerId: playerId, life: 8000),
    );
    
    final result = currentLifePoints.life ~/ 2;
    final difference = currentLifePoints.life - result;
    
    if (difference != 0) {
      _addToHistory(playerId, -difference);
      _updateLifePoints(playerId, result);
      
      if (_isForPlayer1) {
        _player1ScaleController.forward();
      } else {
        _player2ScaleController.forward();
      }
    }
    
    _clearInput();
  }

  void _addToHistory(String playerId, int change) {
    final player1Id = widget.match['player1_id'] ?? '';
    final player2Id = widget.match['player2_id'] ?? '';
    
    final player1LP = _lifePoints.firstWhere(
      (lp) => lp.playerId == player1Id,
      orElse: () => LifePoint(id: 0, roomId: 0, playerId: player1Id, life: 8000),
    ).life;
    
    final player2LP = _lifePoints.firstWhere(
      (lp) => lp.playerId == player2Id,
      orElse: () => LifePoint(id: 0, roomId: 0, playerId: player2Id, life: 8000),
    ).life;
    
    setState(() {
      _gameHistory.add(GameHistoryItem(
        player1LP: playerId == player1Id ? player1LP + change : player1LP,
        player2LP: playerId == player2Id ? player2LP + change : player2LP,
        player1Change: playerId == player1Id ? change : 0,
        player2Change: playerId == player2Id ? change : 0,
        timestamp: DateTime.now().toString(),
      ));
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF6366F1);
    final positiveColor = Color(0xFF10B981);
    final negativeColor = Color(0xFFEF4444);
    final neutralColor = Color(0xFF6B7280);
    final cardColor = isDarkMode ? Color(0xFF2D2D2D) : Color(0xFFFFFFFF);
    final textColor = isDarkMode ? Color(0xFFE6E1E5) : Color(0xFF1C1B1F);
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_lifePoints.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('No life points', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final String player1Name = widget.match['player1']?['username'] ?? 'Player 1';
    final String player2Name = widget.match['player2']?['username'] ?? 'Player 2';
    final String player1Id = widget.match['player1_id'] ?? '';
    final String player2Id = widget.match['player2_id'] ?? '';

    final player1LifePoints = _lifePoints.firstWhere(
      (lp) => lp.playerId == player1Id,
      orElse: () => LifePoint(id: 0, roomId: 0, playerId: player1Id, life: 8000),
    );
    final player2LifePoints = _lifePoints.firstWhere(
      (lp) => lp.playerId == player2Id,
      orElse: () => LifePoint(id: 0, roomId: 0, playerId: player2Id, life: 8000),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Controlli superiori
            _buildTopControls(primaryColor, textColor),
            
            // Life points display
            _buildLifePointsDisplay(player1Name, player2Name, player1LifePoints, player2LifePoints, 
                                  primaryColor, cardColor, textColor),
            
            // Input display
            _buildInputDisplay(player1Name, player2Name, cardColor, textColor),
            
            // Pulsanti operazione
            _buildOperationButtons(positiveColor, negativeColor, neutralColor, textColor),
            
            // Pulsanti per divisione e storico
            _buildSpecialButtons(neutralColor, primaryColor, textColor),
            
            // Tastierino numerico
            Expanded(
              child: _buildNumericKeypad(primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls(Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
                     // Timer
           Text(
             _formatTime(_timeLeftInSeconds),
             style: TextStyle(
               color: primaryColor,
               fontSize: 24,
               fontWeight: FontWeight.bold,
               fontFamily: 'monospace',
             ),
           ),
          
          // Controlli gioco
          Row(
            children: [
              if (!_gameStarted)
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('INIZIA'),
                )
              else if (_isTimerRunning)
                ElevatedButton(
                  onPressed: _pauseGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('PAUSA'),
                )
              else
                ElevatedButton(
                  onPressed: _resumeGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('RIPRENDI'),
                ),
                
              const SizedBox(width: 6),
              
              ElevatedButton(
                onPressed: _resetGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('RESET'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifePointsDisplay(String player1Name, String player2Name, 
      LifePoint player1LifePoints, LifePoint player2LifePoints, 
      Color primaryColor, Color cardColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.22,
        child: Row(
          children: [
            // Player 1
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isForPlayer1 = true),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isForPlayer1 
                        ? primaryColor.withOpacity(0.2)
                        : cardColor.withOpacity(0.7),
                    border: Border.all(
                      color: _isForPlayer1 ? primaryColor : Color(0xFF6B7280),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _isForPlayer1 ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        player1Name,
                        style: TextStyle(color: textColor, fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      AnimatedBuilder(
                        animation: _player1ScaleController,
                        builder: (context, child) {
                          double scale = 1.0 + (_player1ScaleController.value * 0.2);
                          return Transform.scale(
                            scale: scale,
                            child: Text(
                              player1LifePoints.life.toString(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: player1LifePoints.life >= 10000 ? 32 : 38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Player 2
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isForPlayer1 = false),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                  decoration: BoxDecoration(
                    color: !_isForPlayer1 
                        ? Color(0xFFF59E0B).withOpacity(0.2)
                        : cardColor.withOpacity(0.7),
                    border: Border.all(
                      color: !_isForPlayer1 ? Color(0xFFF59E0B) : Color(0xFF6B7280),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: !_isForPlayer1 ? [
                      BoxShadow(
                        color: Color(0xFFF59E0B).withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        player2Name,
                        style: TextStyle(color: textColor, fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      AnimatedBuilder(
                        animation: _player2ScaleController,
                        builder: (context, child) {
                          double scale = 1.0 + (_player2ScaleController.value * 0.2);
                          return Transform.scale(
                            scale: scale,
                            child: Text(
                              player2LifePoints.life.toString(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: player2LifePoints.life >= 10000 ? 32 : 38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputDisplay(String player1Name, String player2Name, Color cardColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFF6B7280), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Operazione per: ${_isForPlayer1 ? player1Name : player2Name}',
              style: TextStyle(color: textColor, fontSize: 14),
            ),
            Text(
              _currentInput.isEmpty ? '0' : _currentInput,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationButtons(Color positiveColor, Color negativeColor, Color neutralColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _applyInput(false),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: negativeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('-', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _applyInput(true),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: positiveColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('+', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialButtons(Color neutralColor, Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Dimezza
          Expanded(
            child: Container(
              height: 48,
              child: ElevatedButton(
                onPressed: _halveLifePoints,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF374151), // Grigio scuro uniforme
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Icon(Icons.content_cut, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Storico
          Expanded(
            child: Container(
              height: 48,
              child: ElevatedButton(
                onPressed: _showHistoryDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF374151), // Grigio scuro uniforme
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Icon(Icons.history, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Clear
          Expanded(
            child: Container(
              height: 48,
              child: ElevatedButton(
                onPressed: _clearInput,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF374151), // Grigio scuro uniforme
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Icon(Icons.clear, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Backspace
          Expanded(
            child: Container(
              height: 48,
              child: ElevatedButton(
                onPressed: _backspace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF374151), // Grigio scuro uniforme
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Icon(Icons.backspace_outlined, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericKeypad(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildKeypadRow(['1', '2', '3'], primaryColor),
          _buildKeypadRow(['4', '5', '6'], primaryColor),
          _buildKeypadRow(['7', '8', '9'], primaryColor),
          _buildKeypadRow(['0', '00', '000'], primaryColor),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers, Color primaryColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: numbers.map((number) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _addDigit(number),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF111827), // Grigio molto scuro, quasi nero
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFF374151).withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        number,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFF9FAFB), // Bianco leggermente caldo
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showHistoryDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Color(0xFFE6E1E5) : Color(0xFF1C1B1F);
    final primaryColor = Color(0xFF6366F1);
    final positiveColor = Color(0xFF10B981);
    final negativeColor = Color(0xFFEF4444);
    final cardColor = isDarkMode ? Color(0xFF2D2D2D) : Color(0xFFFFFFFF);
    
    final player1Name = widget.match['player1']?['username'] ?? 'Player 1';
    final player2Name = widget.match['player2']?['username'] ?? 'Player 2';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storico della partita', style: TextStyle(color: textColor)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (_gameHistory.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Nessuna azione registrata finora',
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ..._gameHistory.asMap().entries.map((entry) {
                  final index = entry.key;
                  final historyItem = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text((index + 1).toString(), style: TextStyle(color: textColor)),
                        ),
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Text(historyItem.player1LP.toString(), style: TextStyle(color: textColor)),
                              if (historyItem.player1Change != 0)
                                Text(
                                  ' (${historyItem.player1Change > 0 ? '+' : ''}${historyItem.player1Change})',
                                  style: TextStyle(
                                    color: historyItem.player1Change > 0 ? positiveColor : negativeColor,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Text(historyItem.player2LP.toString(), style: TextStyle(color: textColor)),
                              if (historyItem.player2Change != 0)
                                Text(
                                  ' (${historyItem.player2Change > 0 ? '+' : ''}${historyItem.player2Change})',
                                  style: TextStyle(
                                    color: historyItem.player2Change > 0 ? positiveColor : negativeColor,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
        backgroundColor: cardColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Chiudi', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
} 