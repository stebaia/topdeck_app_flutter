import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/match_list/match_list_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/invitation_list/invitation_list_state.dart';
import 'package:topdeck_app_flutter/ui/home/widgets/match_invitation_dashboard_widget.dart';
import 'package:topdeck_app_flutter/ui/home/widgets/deck_performance_widget.dart';
import 'package:topdeck_app_flutter/ui/home/widgets/active_matches_dashboard_widget.dart';
import 'package:topdeck_app_flutter/ui/widgets/current_user_builder.dart';

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
    context.read<InvitationListBloc>().loadInvitations();
    context.read<MatchListBloc>().add(LoadMatchesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final myUser = CurrentUserHelper.getCurrentUser(context);

    // Se l'utente non è autenticato, non mostrare la pagina
    if (myUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Utente non autenticato'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topdeck'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh di tutti i dati
          context.read<MatchListBloc>().add(RefreshMatchesEvent());
          context.read<InvitationListBloc>().loadInvitations();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // BOTTONE TEMPORANEO PER TEST REAL-TIME
                
                
                const ActiveMatchesDashboardWidget(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text('Inviti',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      Row(
                        children: [
                          Text('vedi tutti',
                              style: Theme.of(context).textTheme.titleMedium),
                          Icon(Icons.chevron_right,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Sezione 1: Le tue partite
                BlocConsumer<InvitationListBloc, InvitationListState>(
                  listener: (context, state) {
                    // Quando un invito viene cancellato, ricarica la lista
                    if (state is InvitationCancelledState) {
                      context.read<InvitationListBloc>().loadInvitations();
                    }
                  },
                  builder: (context, state) {
                    switch (state) {
                      case InvitationListInitialState():
                        return const SizedBox.shrink();
                      case InvitationListLoadingState():
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case InvitationCancelledLoadingState():
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case InvitationListLoadedState():
                        // Se non ci sono inviti, mostra un messaggio
                        if (state.invitations.isEmpty) {
                          return GestureDetector(
                            onTap: () {
                                      context.router.push(
                                          const FormatSelectionPageRoute()).then((value) {
                                            context.read<InvitationListBloc>().loadInvitations();
                                          });
                                    },
                            child: Container(
                              height: 180,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add,
                                        size: 48,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                            Text('Invita per un match',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium)
                                    
                                    
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return Container(
                          height: 210,
                          width: double.infinity,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: state.invitations.length,
                            itemBuilder: (context, index) {
                              return MatchInvitationDashboardWidget(
                                matchInvitation: state.invitations[index],
                                myUser: myUser,
                              );
                            },
                          ),
                        );
                      case InvitationListErrorState():
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Errore nel caricamento inviti',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  state.error,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      case InvitationCancelledErrorState():
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Errore durante la cancellazione',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  state.error,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Sezione Match Attivi

                // Widget per i match attivi

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text('Statistiche',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      Row(
                        children: [
                          Text('vedi tutti',
                              style: Theme.of(context).textTheme.titleMedium),
                          Icon(Icons.chevron_right,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Sezione 2: Deck Performance
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: DeckPerformanceWidget(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
