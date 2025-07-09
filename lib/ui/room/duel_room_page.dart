import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/life_point.dart';
import 'package:topdeck_app_flutter/state_management/blocs/room/room_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/room/room_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/room/room_state.dart';

/// Esempio di pagina che mostra come usare BlocBuilder per gestire gli stream delle room
class DuelRoomPage extends StatefulWidget {
  final String roomId;

  const DuelRoomPage({
    super.key,
    required this.roomId,
  });

  @override
  State<DuelRoomPage> createState() => _DuelRoomPageState();
}

class _DuelRoomPageState extends State<DuelRoomPage> {
  @override
  void initState() {
    super.initState();
    // Carica la room e sottoscrivi agli aggiornamenti dei life points
    context.read<RoomBloc>().add(LoadDuelRoomEvent(widget.roomId));
    context.read<RoomBloc>().add(SubscribeToLifePointsEvent(widget.roomId));
  }

  @override
  void dispose() {
    // Annulla la sottoscrizione quando la pagina viene chiusa
    context.read<RoomBloc>().add(UnsubscribeFromLifePointsEvent(widget.roomId));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Duel Room ${widget.roomId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<RoomBloc>().add(LoadDuelRoomEvent(widget.roomId));
            },
          ),
        ],
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          // Gestisci i diversi stati usando il BlocBuilder
          if (state is RoomLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is RoomErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Errore: ${state.message}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RoomBloc>().add(LoadDuelRoomEvent(widget.roomId));
                    },
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          } else if (state is DuelRoomLoadedState) {
            // Mostra i dettagli della room quando è caricata
            final room = state.duelRoom;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dettagli Stanza',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('Room ID: ${room.roomId}'),
                          Text('Giocatore 1: ${room.player1Id}'),
                          Text('Giocatore 2: ${room.player2Id}'),
                          Text('Attiva: ${room.isActive ? "Sì" : "No"}'),
                          Text('Creata: ${room.createdAt}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Life Points in tempo reale:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aspettando aggiornamenti dai life points...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          } else if (state is LifePointsStreamActiveState || 
                     state is LifePointsUpdatedState) {
            // Gestisci gli aggiornamenti dei life points in tempo reale
            final lifePoints = state is LifePointsUpdatedState 
                ? state.lifePoints 
                : (state as LifePointsStreamActiveState).lifePoints;
            
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Life Points Live Stream',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (lifePoints.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Nessun life point disponibile'),
                      ),
                    )
                  else
                    ...lifePoints.map((lifePoint) => _buildLifePointCard(context, lifePoint)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 12,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stream attivo - aggiornamenti in tempo reale',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Stato non riconosciuto'),
          );
        },
      ),
    );
  }

  Widget _buildLifePointCard(BuildContext context, LifePoint lifePoint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giocatore: ${lifePoint.playerId}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Room: ${lifePoint.roomId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (lifePoint.updatedAt != null)
                  Text(
                    'Aggiornato: ${lifePoint.updatedAt}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: lifePoint.life > 4000 
                    ? Colors.green.withOpacity(0.2)
                    : lifePoint.life > 2000
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${lifePoint.life} LP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: lifePoint.life > 4000 
                      ? Colors.green.shade700
                      : lifePoint.life > 2000
                          ? Colors.orange.shade700
                          : Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 