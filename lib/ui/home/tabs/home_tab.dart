import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_state.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/received_invitation_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/sent_invitation_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_state.dart';
import 'package:topdeck_app_flutter/ui/common/error_view.dart';
import 'package:topdeck_app_flutter/ui/common/shimmer_loading.dart';
import 'package:topdeck_app_flutter/ui/match/match_detail_page.dart';
import 'package:topdeck_app_flutter/ui/match/match_invitation_detail.dart';

@RoutePage(name: 'HomeTabRoute')
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // Carica i dati all'avvio
    context.read<MatchListBloc>().add(LoadMatchesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topdeck'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh di tutti i dati
          context.read<MatchListBloc>().add(RefreshMatchesEvent());
          
          // Inviti ricevuti
          context.read<ReceivedInvitationListBloc>().add(RefreshInvitationsEvent());
          
          // Inviti inviati
          context.read<SentInvitationListBloc>().add(RefreshSentInvitationsEvent());
          
          // Attendi un po' per permettere alle richieste di completarsi
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sezione 1: Le tue partite
                _buildSectionTitle('Le tue partite', Icons.sports_esports),
                const SizedBox(height: 8),
                _buildMatchesSection(),
                
                const SizedBox(height: 24),
                
                // Sezione 2: Inviti
                _buildSectionTitle('Inviti', Icons.mail),
                const SizedBox(height: 8),
                _buildInvitationsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
  
  Widget _buildMatchesSection() {
    return SizedBox(
      height: 180,
      child: BlocBuilder<MatchListBloc, MatchListState>(
        builder: (context, state) {
          if (state is MatchListLoadingState) {
            return _buildHorizontalShimmerLoading();
          } else if (state is MatchListErrorState) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<MatchListBloc>().add(LoadMatchesEvent()),
            );
          } else if (state is MatchListLoadedState) {
            if (state.matches.isEmpty) {
              return const Center(
                child: Text('Non hai ancora partite. Crea la tua prima partita!'),
              );
            }
            
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.matches.length,
              itemBuilder: (context, index) {
                final match = state.matches[index];
                return _buildMatchCard(match);
              },
            );
          }
          
          return const Center(child: Text('Carica le tue partite'));
        },
      ),
    );
  }
  
  Widget _buildInvitationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inviti ricevuti
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Inviti ricevuti',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        _buildReceivedInvitations(),
        
        const SizedBox(height: 16),
        
        // Inviti inviati
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Inviti inviati',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        _buildSentInvitations(),
      ],
    );
  }
  
  Widget _buildReceivedInvitations() {
    return SizedBox(
      height: 180,
      child: BlocBuilder<ReceivedInvitationListBloc, InvitationListState>(
        bloc: context.read<ReceivedInvitationListBloc>(),
        builder: (context, state) {
          if (state is InvitationListLoadingState) {
            return _buildHorizontalShimmerLoading();
          } else if (state is InvitationListErrorState && !state.forSentInvitations) {
            return ErrorView(
              message: state.error,
              onRetry: () => context.read<ReceivedInvitationListBloc>().add(LoadInvitationsEvent()),
            );
          } else if (state is InvitationListLoadedState && !state.areSentInvitations) {
            if (state.invitations.isEmpty) {
              return const Center(
                child: Text('Non hai inviti ricevuti'),
              );
            }
            
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.invitations.length,
              itemBuilder: (context, index) {
                final invitation = state.invitations[index];
                return _buildInvitationCard(invitation, isReceived: true);
              },
            );
          }
          
          return const Center(child: Text('Caricamento inviti ricevuti...'));
        },
      ),
    );
  }
  
  Widget _buildSentInvitations() {
    return SizedBox(
      height: 180,
      child: BlocBuilder<SentInvitationListBloc, InvitationListState>(
        bloc: context.read<SentInvitationListBloc>(),
        builder: (context, state) {
          if (state is SentInvitationsLoadingState || state is InvitationListLoadingState) {
            return _buildHorizontalShimmerLoading();
          } else if (state is InvitationListErrorState && state.forSentInvitations) {
            return ErrorView(
              message: state.error,
              onRetry: () => context.read<SentInvitationListBloc>().add(LoadSentInvitationsEvent()),
            );
          } else if (state is InvitationListLoadedState && state.areSentInvitations) {
            if (state.invitations.isEmpty) {
              return const Center(
                child: Text('Non hai inviato inviti'),
              );
            }
            
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.invitations.length,
              itemBuilder: (context, index) {
                final invitation = state.invitations[index];
                return _buildInvitationCard(invitation, isReceived: false);
              },
            );
          }
          
          return const Center(child: Text('Caricamento inviti inviati...'));
        },
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final String player1Name = match['player1']?['username'] ?? 'Unknown';
    final String player2Name = match['player2']?['username'] ?? 'Unknown';
    final String matchDate = match['date'] != null 
      ? DateTime.parse(match['date']).toString().substring(0, 10)
      : 'Data sconosciuta';
    final String winnerName = match['winner_id'] == match['player1_id'] 
      ? player1Name 
      : (match['winner_id'] == match['player2_id'] ? player2Name : 'In corso');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailPage(match: match),
          ),
        ).then((value) {
          // Se ricevi 'true', aggiorna la lista partite
          if (value == true) {
            context.read<MatchListBloc>().add(RefreshMatchesEvent());
          }
        });
      },
      child: Card(
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$player1Name vs $player2Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      match['format'] ?? 'Standard',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        matchDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Vincitore:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        winnerName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: winnerName == 'In corso' 
                            ? Colors.orange 
                            : Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Vedi dettagli',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvitationCard(Map<String, dynamic> invitation, {required bool isReceived}) {
    final String opponentName = isReceived 
      ? (invitation['sender']?['username'] ?? 'Sconosciuto')
      : (invitation['receiver']?['username'] ?? 'Sconosciuto');
    
    final String status = invitation['status'] ?? 'pending';
    
    Color statusColor;
    switch (status) {
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'declined':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () {
        context.pushRoute(MatchInvitationDetailPageRoute(invitation: invitation, isReceived: isReceived));
      },
      child: Card(
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isReceived ? 'Da: $opponentName' : 'A: $opponentName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.substring(0, 1).toUpperCase() + status.substring(1),
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Formato: ${invitation['format'] ?? 'Standard'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Data invito: ${invitation['created_at'] != null 
                  ? DateTime.parse(invitation['created_at']).toString().substring(0, 10)
                  : 'Sconosciuta'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              if (isReceived && status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ReceivedInvitationListBloc>().add(AcceptInvitationEvent(invitation['id']));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 36),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Accetta'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<ReceivedInvitationListBloc>().add(DeclineInvitationEvent(invitation['id']));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 36),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Rifiuta',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Vedi dettagli',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHorizontalShimmerLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(right: 12, bottom: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  child: Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLoading(
                      child: Container(
                        height: 16,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    ShimmerLoading(
                      child: Container(
                        height: 16,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ShimmerLoading(
                  child: Container(
                    height: 32,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
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
} 