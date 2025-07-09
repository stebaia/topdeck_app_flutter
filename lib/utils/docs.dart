/*faiimport 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/game/game_cubit.dart';
import '../cubits/game/game_state.dart';
import '../widgets/game_button.dart';
import '../widgets/game_timer.dart';
import '../themes/app_themes.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  String _currentInput = '';
  bool _isForPlayer1 = true; // Flag per indicare quale giocatore è selezionato
  
  // Controller per gli effetti di animazione dei punteggi
  late AnimationController _player1ScaleController;
  late AnimationController _player2ScaleController;
  int _lastPlayer1LifePoints = 8000;
  int _lastPlayer2LifePoints = 8000;

  @override
  void initState() {
    super.initState();
    
    // Inizializza i controller per l'effetto di pulsazione
    _player1ScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _player2ScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Quando l'animazione è completata, riporta il controller al valore iniziale
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
    _player1ScaleController.dispose();
    _player2ScaleController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    setState(() {
      if (_currentInput.length < 5) { // Limitiamo l'input a 5 cifre
        _currentInput += digit;
      }
    });
  }

  void _clearInput() {
    setState(() {
      _currentInput = '';
    });
  }

  void _applyInput(bool isAddition) {
    if (_currentInput.isEmpty) return;
    
    final value = int.parse(_currentInput);
    final amount = isAddition ? value : -value;
    
    final cubit = context.read<GameCubit>();
    
    // Aggiorna i life points
    cubit.updateLifePoints(_isForPlayer1, amount);
    
    // Applica l'effetto di pulsazione al giocatore modificato
    if (_isForPlayer1) {
      _player1ScaleController.forward();
    } else {
      _player2ScaleController.forward();
    }
    
    _clearInput();
  }

  void _toggleSelectedPlayer() {
    setState(() {
      _isForPlayer1 = !_isForPlayer1;
    });
  }
  
  // Funzione per controllare le animazioni quando cambiano i life points
  void _checkLifePointsChange(GameState state) {
    // Controlla se sono cambiati i life points del player 1
    if (_lastPlayer1LifePoints != state.player1.lifePoints) {
      _player1ScaleController.forward();
      _lastPlayer1LifePoints = state.player1.lifePoints;
    }
    
    // Controlla se sono cambiati i life points del player 2
    if (_lastPlayer2LifePoints != state.player2.lifePoints) {
      _player2ScaleController.forward();
      _lastPlayer2LifePoints = state.player2.lifePoints;
    }
  }

  // Mostra dialog con il risultato della partita
  void _showGameResultDialog(BuildContext context, GameState state) {
    // Determina chi ha vinto
    final bool player1Lost = state.player1.lifePoints <= 0;
    final bool player2Lost = state.player2.lifePoints <= 0;
    
    // Se nessuno ha ancora perso, non mostrare nulla
    if (!player1Lost && !player2Lost) return;
    
    final String winnerName = player1Lost ? state.player2.name : state.player1.name;
    final String loserName = player1Lost ? state.player1.name : state.player2.name;
    
    // Mostra il dialog
    showDialog(
      context: context,
      barrierDismissible: false, // L'utente non può chiudere cliccando fuori
      builder: (BuildContext dialogContext) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkMode ? AppThemes.darkTextColor : AppThemes.lightTextColor;
        final backgroundColor = isDarkMode ? AppThemes.darkCardBg : AppThemes.lightCardBg;
        
        return AlertDialog(
          title: Text(
            'Fine Partita',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: backgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                'Vittoria di',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 12),
              Text(
                winnerName,
                style: TextStyle(
                  color: AppThemes.positiveColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$loserName ha esaurito i Life Points',
                style: TextStyle(color: textColor.withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: textColor.withOpacity(0.8),
                  ),
                  child: const Text('Chiudi'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Chiudi il dialog e avvia un rematch
                    Navigator.of(dialogContext).pop();
                    context.read<GameCubit>().startGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.positiveColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    'Rivincita',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppThemes.darkTextColor : AppThemes.lightTextColor;
    final cardColor = isDarkMode ? AppThemes.darkCardBg : AppThemes.lightCardBg;
    final accentColor = isDarkMode ? AppThemes.darkAccent : AppThemes.lightAccent;
    
    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        // Controlla se ci sono cambiamenti nei life points
        _checkLifePointsChange(state);
        
        // Mostra dialog se la partita è terminata per life points a 0
        if (state.status == GameStatus.completed && 
            (state.player1.lifePoints <= 0 || state.player2.lifePoints <= 0)) {
          // Usa Future.delayed per evitare di chiamare setState durante il build
          Future.delayed(Duration.zero, () {
            _showGameResultDialog(context, state);
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Pulsanti di controllo partita in alto
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Timer
                      GameTimer(
                        elapsedSeconds: state.elapsedSeconds,
                        totalGameTimeSeconds: state.totalGameTimeSeconds,
                        isRunning: state.status == GameStatus.inProgress,
                      ),
                      
                      // Controllo partita
                      Row(
                        children: [
                          if (state.status == GameStatus.notStarted || state.status == GameStatus.completed)
                            ElevatedButton(
                              onPressed: () => context.read<GameCubit>().startGame(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppThemes.positiveColor,
                                foregroundColor: textColor,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              child: const Text('INIZIA'),
                            )
                          else if (state.status == GameStatus.inProgress)
                            ElevatedButton(
                              onPressed: () => context.read<GameCubit>().pauseGame(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppThemes.primaryColor,
                                foregroundColor: textColor,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              child: const Text('PAUSA'),
                            )
                          else if (state.status == GameStatus.paused)
                            ElevatedButton(
                              onPressed: () => context.read<GameCubit>().resumeGame(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppThemes.positiveColor,
                                foregroundColor: textColor,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              child: const Text('RIPRENDI'),
                            ),
                            
                          const SizedBox(width: 6),
                          
                          ElevatedButton(
                            onPressed: () => context.read<GameCubit>().resetGame(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppThemes.negativeColor,
                              foregroundColor: textColor,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            child: const Text('RESET'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Life points display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.22,
                    child: Row(
                      children: [
                        // Player 1
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isForPlayer1 = true;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isForPlayer1 
                                  ? AppThemes.primaryColor.withOpacity(0.2)
                                  : cardColor.withOpacity(0.7),
                                border: Border.all(
                                  color: _isForPlayer1 ? AppThemes.primaryColor : accentColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _isForPlayer1 ? [
                                  BoxShadow(
                                    color: AppThemes.primaryColor.withOpacity(0.3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ] : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state.player1.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Animazione del punteggio
                                  AnimatedBuilder(
                                    animation: _player1ScaleController,
                                    builder: (context, child) {
                                      double scale = 1.0 + (_player1ScaleController.value * 0.2);
                                      
                                      // Colore basato sulla direzione del cambiamento
                                      Color valueColor = textColor;
                                      if (_player1ScaleController.value > 0) {
                                        final difference = state.player1.lifePoints - _lastPlayer1LifePoints;
                                        if (difference > 0) {
                                          valueColor = AppThemes.positiveColor; 
                                        } else if (difference < 0) {
                                          valueColor = AppThemes.negativeColor;
                                        }
                                      }
                                      
                                      return TweenAnimationBuilder<int>(
                                        duration: const Duration(milliseconds: 600),
                                        tween: IntTween(
                                          begin: _lastPlayer1LifePoints, 
                                          end: state.player1.lifePoints
                                        ),
                                        builder: (context, value, child) {
                                          return Transform.scale(
                                            scale: scale,
                                            child: Text(
                                              value.toString(),
                                              style: TextStyle(
                                                color: valueColor,
                                                fontSize: value >= 10000 ? 32 : 38,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        },
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
                            onTap: () {
                              setState(() {
                                _isForPlayer1 = false;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                              decoration: BoxDecoration(
                                color: !_isForPlayer1 
                                  ? AppThemes.highlightColor.withOpacity(0.2)
                                  : cardColor.withOpacity(0.7),
                                border: Border.all(
                                  color: !_isForPlayer1 ? AppThemes.highlightColor : accentColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_isForPlayer1 ? [
                                  BoxShadow(
                                    color: AppThemes.highlightColor.withOpacity(0.3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ] : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    state.player2.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Animazione del punteggio
                                  AnimatedBuilder(
                                    animation: _player2ScaleController,
                                    builder: (context, child) {
                                      double scale = 1.0 + (_player2ScaleController.value * 0.2);
                                      
                                      // Colore basato sulla direzione del cambiamento
                                      Color valueColor = textColor;
                                      if (_player2ScaleController.value > 0) {
                                        final difference = state.player2.lifePoints - _lastPlayer2LifePoints;
                                        if (difference > 0) {
                                          valueColor = AppThemes.positiveColor; 
                                        } else if (difference < 0) {
                                          valueColor = AppThemes.negativeColor;
                                        }
                                      }
                                      
                                      return TweenAnimationBuilder<int>(
                                        duration: const Duration(milliseconds: 600),
                                        tween: IntTween(
                                          begin: _lastPlayer2LifePoints, 
                                          end: state.player2.lifePoints
                                        ),
                                        builder: (context, value, child) {
                                          return Transform.scale(
                                            scale: scale,
                                            child: Text(
                                              value.toString(),
                                              style: TextStyle(
                                                color: valueColor,
                                                fontSize: value >= 10000 ? 32 : 38,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        },
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
                ),
                
                // Display input corrente
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accentColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Operazione per: ${_isForPlayer1 ? state.player1.name : state.player2.name}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                          ),
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
                ),
                
                // Pulsanti operazione
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _applyInput(false),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: AppThemes.negativeColor,
                            foregroundColor: textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '-',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _clearInput,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          backgroundColor: AppThemes.neutralColor,
                          foregroundColor: textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('C', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _applyInput(true),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: AppThemes.positiveColor,
                            foregroundColor: textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '+',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Pulsanti per divisione e storico
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final cubit = context.read<GameCubit>();
                            final currentLP = _isForPlayer1 
                                ? cubit.state.player1.lifePoints 
                                : cubit.state.player2.lifePoints;
                            
                            // Divide sempre i life points per 2
                            final result = currentLP ~/ 2;
                            final difference = currentLP - result;
                            
                            // Aggiorna i life points (sottrae la differenza)
                            if (difference != 0) {
                              cubit.updateLifePoints(_isForPlayer1, -difference);
                              
                              // Attiva l'animazione
                              if (_isForPlayer1) {
                                _player1ScaleController.forward();
                              } else {
                                _player2ScaleController.forward();
                              }
                            }
                            
                            _clearInput();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor: AppThemes.neutralColor,
                            foregroundColor: textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.content_cut, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Dimezza',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Mostra un dialog con lo storico delle modifiche
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Storico della partita',
                                  style: TextStyle(color: textColor),
                                ),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      // Intestazione
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'Turno',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                state.player1.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                state.player2.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                      // Storico (in un'implementazione reale, questo verrebbe 
                                      // popolato con dati dal GameState)
                                      if (state.history.isEmpty)
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
                                        ...state.history.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final historyItem = entry.value;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              children: [
                                                // Turno
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (index + 1).toString(),
                                                    style: TextStyle(color: textColor),
                                                  ),
                                                ),
                                                // LP Player 1
                                                Expanded(
                                                  flex: 4,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        historyItem.player1LP.toString(),
                                                        style: TextStyle(color: textColor),
                                                      ),
                                                      if (historyItem.player1Change != 0)
                                                        Text(
                                                          ' (${historyItem.player1Change > 0 ? '+' : ''}${historyItem.player1Change})',
                                                          style: TextStyle(
                                                            color: historyItem.player1Change > 0
                                                                ? AppThemes.positiveColor
                                                                : historyItem.player1Change < 0
                                                                    ? AppThemes.negativeColor
                                                                    : textColor,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                // LP Player 2
                                                Expanded(
                                                  flex: 4,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        historyItem.player2LP.toString(),
                                                        style: TextStyle(color: textColor),
                                                      ),
                                                      if (historyItem.player2Change != 0)
                                                        Text(
                                                          ' (${historyItem.player2Change > 0 ? '+' : ''}${historyItem.player2Change})',
                                                          style: TextStyle(
                                                            color: historyItem.player2Change > 0
                                                                ? AppThemes.positiveColor
                                                                : historyItem.player2Change < 0
                                                                    ? AppThemes.negativeColor
                                                                    : textColor,
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
                                backgroundColor: isDarkMode 
                                    ? AppThemes.darkCardBg 
                                    : AppThemes.lightCardBg,
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Chiudi',
                                      style: TextStyle(
                                        color: AppThemes.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor: AppThemes.primaryColor,
                            foregroundColor: textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Storico',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Tastierino numerico - Aumentato dimensioni dei tasti
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround, // Spazio ridotto tra le righe
                      children: [
                        SizedBox( // Altezza fissa invece di Expanded per ridurre lo spazio
                          height: 58,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 1; i <= 3; i++)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: ElevatedButton(
                                      onPressed: () => _addDigit(i.toString()),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(2),
                                        backgroundColor: AppThemes.primaryColor.withOpacity(0.8),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        i.toString(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox( // Altezza fissa invece di Expanded per ridurre lo spazio
                          height: 58,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 4; i <= 6; i++)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: ElevatedButton(
                                      onPressed: () => _addDigit(i.toString()),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(2),
                                        backgroundColor: AppThemes.primaryColor.withOpacity(0.8),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        i.toString(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox( // Altezza fissa invece di Expanded per ridurre lo spazio
                          height: 58,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 7; i <= 9; i++)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: ElevatedButton(
                                      onPressed: () => _addDigit(i.toString()),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(2),
                                        backgroundColor: AppThemes.primaryColor.withOpacity(0.8),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        i.toString(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox( // Altezza fissa invece di Expanded per ridurre lo spazio
                          height: 58,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: ElevatedButton(
                                    onPressed: () => _addDigit('0'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(2),
                                      backgroundColor: AppThemes.primaryColor.withOpacity(0.8),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      '0',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: ElevatedButton(
                                    onPressed: () => _addDigit('00'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(2),
                                      backgroundColor: AppThemes.primaryColor.withOpacity(0.8),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      '00',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: ElevatedButton(
                                    onPressed: () => _addDigit('000'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(2),
                                      backgroundColor: AppThemes.primaryColor.withOpacity(0.8),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      '000',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} */