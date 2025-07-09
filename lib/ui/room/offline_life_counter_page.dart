import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Data model per storico partita offline
class OfflineGameHistoryItem {
  final int player1LP;
  final int player2LP;
  final int player1Change;
  final int player2Change;
  final String timestamp;

  OfflineGameHistoryItem({
    required this.player1LP,
    required this.player2LP,
    required this.player1Change,
    required this.player2Change,
    required this.timestamp,
  });
}

@RoutePage()
class OfflineLifeCounterPage extends StatefulWidget {
  const OfflineLifeCounterPage({Key? key}) : super(key: key);

  @override
  State<OfflineLifeCounterPage> createState() => _OfflineLifeCounterPageState();
}

class _OfflineLifeCounterPageState extends State<OfflineLifeCounterPage> with TickerProviderStateMixin {
  // Life points
  int _player1Life = 8000;
  int _player2Life = 8000;
  
  // Timer e stato del gioco
  Timer? _gameTimer;
  int _timeLeftInSeconds = 45 * 60; // 45 minuti in secondi
  bool _isTimerRunning = false;
  bool _gameStarted = false;
  
  // Input e controllo giocatori
  String _currentInput = '';
  bool _isForPlayer1 = true;
  
  // Controller per animazioni
  late AnimationController _player1ScaleController;
  late AnimationController _player2ScaleController;
  
  // Storico della partita
  List<OfflineGameHistoryItem> _gameHistory = [];
  
  // Nomi giocatori
  String _player1Name = 'Giocatore 1';
  String _player2Name = 'Giocatore 2';

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _player1ScaleController.dispose();
    _player2ScaleController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _isTimerRunning = true;
    });
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeftInSeconds > 0) {
          _timeLeftInSeconds--;
        } else {
          _gameTimer?.cancel();
          _isTimerRunning = false;
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
        } else {
          _gameTimer?.cancel();
          _isTimerRunning = false;
        }
      });
    });
  }

  void _resetGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Partita'),
        content: const Text('Sei sicuro di voler resettare la partita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _player1Life = 8000;
                _player2Life = 8000;
                _gameHistory.clear();
                _timeLeftInSeconds = 45 * 60;
                _gameStarted = false;
                _isTimerRunning = false;
                _currentInput = '';
              });
              _gameTimer?.cancel();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _addDigit(String digit) {
    setState(() {
      _currentInput = _currentInput + digit;
    });
  }

  void _clearInput() {
    setState(() {
      _currentInput = '';
    });
  }

  void _backspace() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      });
    }
  }

  void _applyInput(bool isPositive) {
    if (_currentInput.isEmpty) return;
    
    final inputValue = int.tryParse(_currentInput) ?? 0;
    final change = isPositive ? inputValue : -inputValue;
    
    if (_isForPlayer1) {
      final newLife = (_player1Life + change).clamp(0, 99999);
      _addToHistory(true, newLife - _player1Life);
      setState(() {
        _player1Life = newLife;
      });
      _player1ScaleController.forward().then((_) => _player1ScaleController.reverse());
    } else {
      final newLife = (_player2Life + change).clamp(0, 99999);
      _addToHistory(false, newLife - _player2Life);
      setState(() {
        _player2Life = newLife;
      });
      _player2ScaleController.forward().then((_) => _player2ScaleController.reverse());
    }
    
    setState(() {
      _currentInput = '';
    });
    
    HapticFeedback.lightImpact();
  }

  void _halveLifePoints() {
    if (_isForPlayer1) {
      final newLife = (_player1Life / 2).round();
      _addToHistory(true, newLife - _player1Life);
      setState(() {
        _player1Life = newLife;
      });
      _player1ScaleController.forward().then((_) => _player1ScaleController.reverse());
    } else {
      final newLife = (_player2Life / 2).round();
      _addToHistory(false, newLife - _player2Life);
      setState(() {
        _player2Life = newLife;
      });
      _player2ScaleController.forward().then((_) => _player2ScaleController.reverse());
    }
  }

  void _addToHistory(bool isPlayer1, int change) {
    if (change == 0) return;
    
    setState(() {
      _gameHistory.add(OfflineGameHistoryItem(
        player1LP: _player1Life,
        player2LP: _player2Life,
        player1Change: isPlayer1 ? change : 0,
        player2Change: !isPlayer1 ? change : 0,
        timestamp: DateTime.now().toString(),
      ));
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _editPlayerNames() {
    final TextEditingController player1Controller = TextEditingController(text: _player1Name);
    final TextEditingController player2Controller = TextEditingController(text: _player2Name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica Nomi Giocatori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: player1Controller,
              decoration: const InputDecoration(
                labelText: 'Nome Giocatore 1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: player2Controller,
              decoration: const InputDecoration(
                labelText: 'Nome Giocatore 2',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _player1Name = player1Controller.text.isNotEmpty ? player1Controller.text : 'Giocatore 1';
                _player2Name = player2Controller.text.isNotEmpty ? player2Controller.text : 'Giocatore 2';
              });
              Navigator.of(context).pop();
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Controlli superiori
            _buildTopControls(primaryColor, positiveColor, negativeColor, textColor),
            
            // Life points display
            _buildLifePointsDisplay(primaryColor, cardColor, textColor),
            
            // Input display
            _buildInputDisplay(cardColor, textColor),
            
            // Pulsanti operazione
            _buildOperationButtons(positiveColor, negativeColor),
            
            // Pulsanti per divisione e storico
            _buildSpecialButtons(),
            
            // Tastierino numerico
            Expanded(
              child: _buildNumericKeypad(primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls(Color primaryColor, Color positiveColor, Color negativeColor, Color textColor) {
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

  Widget _buildLifePointsDisplay(Color primaryColor, Color cardColor, Color textColor) {
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
                        _player1Name,
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
                              _player1Life.toString(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: _player1Life >= 10000 ? 32 : 38,
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
                        ? primaryColor.withOpacity(0.2)
                        : cardColor.withOpacity(0.7),
                    border: Border.all(
                      color: !_isForPlayer1 ? primaryColor : Color(0xFF6B7280),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: !_isForPlayer1 ? [
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
                        _player2Name,
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
                              _player2Life.toString(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: _player2Life >= 10000 ? 32 : 38,
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

  Widget _buildInputDisplay(Color cardColor, Color textColor) {
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
              'Operazione per: ${_isForPlayer1 ? _player1Name : _player2Name}',
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

  Widget _buildOperationButtons(Color positiveColor, Color negativeColor) {
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

  Widget _buildSpecialButtons() {
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
                  backgroundColor: Color(0xFF374151),
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
                  backgroundColor: Color(0xFF374151),
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
                  backgroundColor: Color(0xFF374151),
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
                  backgroundColor: Color(0xFF374151),
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
                      color: Color(0xFF111827),
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
                          color: Color(0xFFF9FAFB),
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