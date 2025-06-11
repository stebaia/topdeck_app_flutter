import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/tournament.dart';
import 'package:topdeck_app_flutter/repositories/tournament_participant_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_state.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_operations_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_operations_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_state.dart';
import 'package:topdeck_app_flutter/ui/tournaments/create_tournament_page.dart';
import 'package:topdeck_app_flutter/ui/tournaments/join_tournament_dialog.dart';
import 'package:topdeck_app_flutter/ui/tournaments/tournament_details_page.dart';

/// Page that displays tournaments
class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Add listener to tab controller to load data when switching tabs
    _tabController.addListener(_onTabChanged);
    
    // Load initial data for the first tab (public tournaments)
    context.read<TournamentBloc>().add(LoadPublicTournamentsEvent());
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      // Load data for the selected tab
      if (_tabController.index == 0) {
        // Public tournaments tab
        context.read<TournamentBloc>().add(LoadPublicTournamentsEvent());
      } else {
        // My tournaments tab
        context.read<TournamentBloc>().add(LoadMyTournamentsEvent());
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tornei'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pubblici'),
            Tab(text: 'I miei tornei'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateTournament(context),
            tooltip: 'Crea torneo',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _showJoinTournamentDialog(context),
            tooltip: 'Unisciti con codice',
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen to tournament operations
          BlocListener<TournamentOperationsBloc, TournamentOperationState>(
            listener: (context, state) {
              if (state is TournamentOperationErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is TournamentCreatedState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Torneo creato con successo!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh only the "My Tournaments" tab since that's where the new tournament will appear
                context.read<TournamentBloc>().add(LoadMyTournamentsEvent());
              } else if (state is TournamentJoinedState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ti sei unito al torneo "${state.tournament.name}"!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the current tab
                _refreshCurrentTab();
              } else if (state is InviteCodeGeneratedState) {
                // Show the invite code in a dialog - NO REFRESH NEEDED!
                _showInviteCodeDialog(state.inviteCode);
              }
            },
          ),
          // Listen to tournament list errors
          BlocListener<TournamentBloc, TournamentState>(
            listener: (context, state) {
              if (state is TournamentErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPublicTournamentsTab(),
            _buildMyTournamentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicTournamentsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TournamentBloc>().add(LoadPublicTournamentsEvent());
      },
      child: BlocBuilder<TournamentBloc, TournamentState>(
        buildWhen: (previous, current) {
          // Only rebuild when we have a state that affects the tournaments list
          return current is TournamentLoadingState || 
                 current is PublicTournamentsLoadedState ||
                 current is TournamentErrorState;
        },
        builder: (context, state) {
          if (state is TournamentLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PublicTournamentsLoadedState) {
            if (state.tournaments.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nessun torneo pubblico disponibile',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Crea il primo torneo!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tournaments.length,
              itemBuilder: (context, index) {
                final tournament = state.tournaments[index];
                return _buildTournamentCard(tournament, isPublic: true);
              },
            );
          }
          return const Center(child: Text('Carica i tornei pubblici'));
        },
      ),
    );
  }

  Widget _buildMyTournamentsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TournamentBloc>().add(LoadMyTournamentsEvent());
      },
      child: BlocBuilder<TournamentBloc, TournamentState>(
        buildWhen: (previous, current) {
          // Only rebuild when we have a state that affects the tournaments list
          return current is TournamentLoadingState || 
                 current is MyTournamentsLoadedState ||
                 current is TournamentErrorState;
        },
        builder: (context, state) {
          if (state is TournamentLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MyTournamentsLoadedState) {
            if (state.tournaments.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Accedi per vedere i tuoi tornei',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Effettua il login per gestire i tuoi tornei',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tournaments.length,
              itemBuilder: (context, index) {
                final tournament = state.tournaments[index];
                return _buildTournamentCard(tournament, isPublic: false);
              },
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Accedi per vedere i tuoi tornei',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Effettua il login per gestire i tuoi tornei',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTournamentCard(Tournament tournament, {required bool isPublic}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tournament.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(tournament.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Formato: ${tournament.format}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(
                  tournament.isPublic ? Icons.public : Icons.lock,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  tournament.isPublic ? 'Pubblico' : 'Privato',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (tournament.maxParticipants != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Max partecipanti: ${tournament.maxParticipants}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (tournament.league != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.emoji_events, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Lega: ${tournament.league}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPublic && tournament.status == TournamentStatus.upcoming)
                  FutureBuilder<bool>(
                    future: _isUserAlreadyJoined(tournament.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      
                      final isAlreadyJoined = snapshot.data ?? false;
                      
                      if (isAlreadyJoined) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'Già iscritto',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      
                      return ElevatedButton(
                        onPressed: () => _joinTournament(tournament.id),
                        child: const Text('Unisciti'),
                      );
                    },
                  ),
                if (!isPublic) ...[
                  TextButton(
                    onPressed: () => _generateInviteCode(tournament.id),
                    child: const Text('Condividi'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _viewTournamentDetails(tournament),
                    child: const Text('Gestisci'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(TournamentStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case TournamentStatus.upcoming:
        color = Colors.blue;
        label = 'In arrivo';
        break;
      case TournamentStatus.ongoing:
        color = Colors.green;
        label = 'In corso';
        break;
      case TournamentStatus.completed:
        color = Colors.grey;
        label = 'Completato';
        break;
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _navigateToCreateTournament(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateTournamentPage(),
      ),
    );
  }

  void _showJoinTournamentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const JoinTournamentDialog(),
    );
  }

  void _joinTournament(String tournamentId) {
    context.read<TournamentOperationsBloc>().add(JoinPublicTournamentOperationEvent(tournamentId));
  }

  void _generateInviteCode(String tournamentId) {
    context.read<TournamentOperationsBloc>().add(GenerateInviteCodeOperationEvent(tournamentId));
  }

  void _viewTournamentDetails(Tournament tournament) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TournamentDetailsPage(tournament: tournament),
      ),
    );
  }

  void _refreshCurrentTab() {
    if (_tabController.index == 0) {
      context.read<TournamentBloc>().add(LoadPublicTournamentsEvent());
    } else {
      context.read<TournamentBloc>().add(LoadMyTournamentsEvent());
    }
  }

  Future<bool> _isUserAlreadyJoined(String tournamentId) async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthenticatedState) {
        return false;
      }

      return await context
          .read<TournamentParticipantRepository>()
          .isUserParticipating(tournamentId, authState.profile.id);
    } catch (e) {
      return false;
    }
  }

  void _showInviteCodeDialog(String inviteCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Codice Invito'),
        content: Text('Il codice invito è: $inviteCode'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 