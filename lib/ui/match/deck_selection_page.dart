import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/network/service/impl/deck_service_impl.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_event.dart';
import 'package:topdeck_app_flutter/model/entities/match_invitation.dart';

@RoutePage()
/// Pagina per selezionare il mazzo da utilizzare in un match
class DeckSelectionPage extends StatefulWidget {
  /// L'invito al match
  final MatchInvitation invitation;
  
  /// Constructor
  const DeckSelectionPage({
    Key? key,
    required this.invitation,
  }) : super(key: key);

  @override
  State<DeckSelectionPage> createState() => _DeckSelectionPageState();
}

class _DeckSelectionPageState extends State<DeckSelectionPage> with TickerProviderStateMixin {
  final DeckServiceImpl _deckService = DeckServiceImpl();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _userDecks = [];
  String? _selectedDeckId;
  String? _errorMessage;
  bool _isAccepting = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadDecks();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDecks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final format = widget.invitation.format;
      final allDecks = await _deckService.getUserDecks();
      final formatDecks = allDecks.where((deck) => deck['format'] == format).toList();
      
      setState(() {
        _userDecks = formatDecks;
        if (formatDecks.isNotEmpty) {
          _selectedDeckId = formatDecks.first['id'];
        }
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore nel caricamento dei mazzi: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _acceptInvitationWithSelectedDeck() async {
    if (_selectedDeckId == null) return;
    
    setState(() {
      _isAccepting = true;
    });
    
    context.read<InvitationListBloc>().add(
      AcceptInvitationWithDeckEvent(widget.invitation.id, _selectedDeckId!),
    );
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Naviga alla home pulendo lo stack
    context.router.replaceNamed('/home');
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Seleziona deck'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContent(),
            ),
      bottomNavigationBar: _isLoading ? null : _buildBottomActionBar(theme),
    );
  }
  
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Caricamento deck...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    
    if (_userDecks.isEmpty) {
      return _buildEmptyState();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo semplice
          Text(
            'I tuoi deck',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          
          // Lista deck
          Expanded(
            child: ListView.builder(
              itemCount: _userDecks.length,
              itemBuilder: (context, index) {
                return _buildDeckItem(_userDecks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDecks,
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.style_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nessun deck disponibile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Non hai deck per il formato ${widget.invitation.format}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.maybePop(),
            child: const Text('Torna indietro'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeckItem(Map<String, dynamic> deck) {
    final bool isSelected = _selectedDeckId == deck['id'];
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDeckId = deck['id'];
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? theme.primaryColor : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Indicatore selezione
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? theme.primaryColor : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Info deck
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                             Text(
                         deck['name'] ?? 'Deck senza nome',
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w600,
                           color: isSelected 
                               ? (theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor)
                               : theme.textTheme.titleMedium?.color,
                         ),
                       ),
                      const SizedBox(height: 4),
                      Text(
                        deck['format'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomActionBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _userDecks.isEmpty || _isAccepting ? null : _acceptInvitationWithSelectedDeck,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[600],
              elevation: _userDecks.isEmpty ? 0 : 4,
              shadowColor: theme.primaryColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: _isAccepting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Creazione match...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_esports_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Accetta e inizia match',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
} 