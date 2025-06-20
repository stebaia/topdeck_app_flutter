import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/model/entities/match.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_wizard/match_wizard_state.dart';

@RoutePage()
class MatchResultsPage extends StatefulWidget {
  final DeckFormat format;
  final String playerDeckId;
  final String opponentId;
  
  const MatchResultsPage({
    super.key,
    required this.format,
    required this.playerDeckId,
    required this.opponentId,
  });

  @override
  State<MatchResultsPage> createState() => _MatchResultsPageState();
}

class _MatchResultsPageState extends State<MatchResultsPage> with TickerProviderStateMixin {
  String? _opponentDeckId;
  String? _winnerId;
  late AnimationController _battleController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _battleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Battle scene animations
    _battleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _battleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _battleController,
      curve: Curves.easeInOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _battleController.forward();
    _pulseController.repeat(reverse: true);
    _sparkleController.repeat();
    
    // Load opponent decks when the page is initialized
    context.read<MatchWizardBloc>().add(LoadOpponentDecksEvent(widget.opponentId));
  }
  
  @override
  void dispose() {
    _battleController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFF1A1A2E),
      body: SafeArea(
        child: BlocConsumer<MatchWizardBloc, MatchWizardState>(
          listener: (context, state) {
            if (state is MatchSavedState) {
              _showVictoryExplosion(context);
              Future.delayed(const Duration(milliseconds: 3000), () {
                context.router.popUntilRoot();
              });
            } else if (state is MatchWizardErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.errorMessage)),
                    ],
                  ),
                  backgroundColor: const Color(0xFFE53E3E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is MatchWizardLoadingState || state is SavingMatchState) {
              return _buildBattleLoadingState();
            } else if (state is MatchWizardErrorState) {
              return _buildErrorState(state);
            } else if (state is OpponentDecksLoadedState) {
              return _buildBattleArena(state.decks);
            } else {
              return _buildInitialLoadingState();
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildBattleLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          colors: [
            Color(0xFF4C1D95),
            Color(0xFF1E1B4B),
            Color(0xFF0F0A1E),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.purple.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Pulsing circle
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              '⚔️ SALVANDO BATTAGLIA ⚔️',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Registrando i risultati del combattimento...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInitialLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3730A3),
            Color(0xFF581C87),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _sparkleAnimation,
              child: const Icon(
                Icons.shield,
                color: Colors.amber,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PREPARANDO L\'ARENA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(MatchWizardErrorState state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF991B1B), Color(0xFF7F1D1D)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                '💀 BATTAGLIA INTERROTTA 💀',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<MatchWizardBloc>().add(LoadOpponentDecksEvent(widget.opponentId));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('RITENTA LA BATTAGLIA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBattleArena(List<Map<String, dynamic>> opponentDecks) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background stars/sparkles
          ...List.generate(15, (index) => _buildFloatingParticle(index)),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Battle header
                _buildBattleHeader(),
                
                // Battle content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Deck selection battle station
                        _buildDeckBattleStation(opponentDecks),
                        
                        const SizedBox(height: 40),
                        
                        // Victory declaration arena
                        _buildVictoryArena(),
                        
                        const SizedBox(height: 40),
                        
                        // Battle commit button
                        _buildBattleCommitButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloatingParticle(int index) {
    final random = (index * 17) % 100;
    final left = (random * 3.0) % 100;
    final top = (random * 7.0) % 100;
    final delay = (random * 50) % 3000;
    
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _sparkleAnimation,
        builder: (context, child) {
          final delayedAnimation = ((_sparkleAnimation.value * 3000) - delay) / 3000;
          final clampedAnimation = delayedAnimation.clamp(0.0, 1.0);
          
          return Opacity(
            opacity: (clampedAnimation * (1 - clampedAnimation) * 4).clamp(0.0, 0.6),
            child: Icon(
              index % 3 == 0 ? Icons.star : (index % 3 == 1 ? Icons.auto_awesome : Icons.blur_on),
              color: Colors.white,
              size: 4 + (index % 3) * 2,
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBattleHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7C3AED),
            Color(0xFF8B5CF6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF7C3AED),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.router.maybePop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚔️ ARENA DI BATTAGLIA ⚔️',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Text(
                  'Chi emergerà vittorioso?',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.military_tech,
            color: Colors.amber,
            size: 32,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeckBattleStation(List<Map<String, dynamic>> opponentDecks) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F2937),
            Color(0xFF374151),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.style,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🃏 ARSENALE NEMICO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Scegli il deck del tuo avversario',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            opponentDecks.isEmpty
                ? _buildNoDeckWarning()
                : _buildDeckSelector(opponentDecks),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoDeckWarning() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[900]?.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NESSUN ARSENALE DISPONIBILE',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Il tuo avversario non ha deck disponibili',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeckSelector(List<Map<String, dynamic>> decks) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _opponentDeckId != null ? Colors.green : Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _opponentDeckId,
        decoration: const InputDecoration(
          hintText: '🔥 Seleziona l\'arma del nemico...',
          hintStyle: TextStyle(color: Colors.white60),
          prefixIcon: Icon(Icons.military_tech, color: Colors.amber),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        dropdownColor: const Color(0xFF111827),
        style: const TextStyle(color: Colors.white),
        items: decks.map((deck) {
          return DropdownMenuItem<String>(
            value: deck['id'],
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '⚡ ${deck['name']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _opponentDeckId = value;
          });
        },
      ),
    );
  }
  
  Widget _buildVictoryArena() {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[900]?.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 16),
            Text(
              'ERRORE: Guerriero non identificato',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF065F46),
            Color(0xFF047857),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏆 PROCLAMA IL VINCITORE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Chi ha conquistato la gloria?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Victory options
            _buildVictoryOption(
              currentUser.id,
              '👑 VITTORIA!',
              'Hai trionfato in battaglia!',
              const Color(0xFF10B981),
              Icons.military_tech,
            ),
            
            const SizedBox(height: 20),
            
            _buildVictoryOption(
              widget.opponentId,
              '💀 SCONFITTA',
              'Il nemico ha prevalso...',
              const Color(0xFFEF4444),
              Icons.sentiment_dissatisfied,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVictoryOption(
    String value,
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    final isSelected = _winnerId == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _winnerId = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isSelected ? null : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
              ),
              child: Icon(
                isSelected ? Icons.check_circle : icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? color : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              ScaleTransition(
                scale: _pulseAnimation,
                child: Icon(
                  Icons.auto_awesome,
                  color: color,
                  size: 32,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBattleCommitButton() {
    final canSave = _canSave();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        gradient: canSave
            ? const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF8B5CF6),
                  Color(0xFFA855F7),
                ],
              )
            : null,
        color: canSave ? null : Colors.grey[800],
        borderRadius: BorderRadius.circular(24),
        boxShadow: canSave
            ? [
                const BoxShadow(
                  color: Color(0xFF7C3AED),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canSave ? _saveMatch : null,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.send,
                  color: canSave ? Colors.white : Colors.grey[600],
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  '⚡ CONFERMA BATTAGLIA ⚡',
                  style: TextStyle(
                    color: canSave ? Colors.white : Colors.grey[600],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  bool _canSave() {
    return _opponentDeckId != null && _winnerId != null;
  }
  
  void _saveMatch() {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Errore: Guerriero non identificato'),
            ],
          ),
          backgroundColor: const Color(0xFFE53E3E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }
    
    context.read<MatchWizardBloc>().add(
      SaveMatchResultEvent(
        playerId: currentUser.id,
        opponentId: widget.opponentId,
        playerDeckId: widget.playerDeckId,
        opponentDeckId: _opponentDeckId!,
        format: widget.format,
        winnerId: _winnerId!,
      ),
    );
  }
  
  void _showVictoryExplosion(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const VictoryExplosionDialog(),
    );
  }
}

class VictoryExplosionDialog extends StatefulWidget {
  const VictoryExplosionDialog({super.key});

  @override
  State<VictoryExplosionDialog> createState() => _VictoryExplosionDialogState();
}

class _VictoryExplosionDialogState extends State<VictoryExplosionDialog> 
    with TickerProviderStateMixin {
  late AnimationController _explosionController;
  late AnimationController _rotationController;
  late Animation<double> _explosionAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _explosionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _explosionController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 4 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
    
    _explosionController.forward();
    _rotationController.forward();
  }

  @override
  void dispose() {
    _explosionController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _explosionAnimation,
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF8B5CF6),
                Color(0xFFA855F7),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.6),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _rotationAnimation,
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 100,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '🎊 BATTAGLIA SALVATA! 🎊',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'I risultati della tua epica battaglia\nsono stati registrati negli annali!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 