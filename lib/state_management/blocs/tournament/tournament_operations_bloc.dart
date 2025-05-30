import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/tournament.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/repositories/tournament_repository.dart';
import 'package:topdeck_app_flutter/repositories/tournament_participant_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_operations_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/tournament/tournament_state.dart';

/// BLoC for managing tournament operations (create, join, generate codes)
class TournamentOperationsBloc extends Bloc<TournamentOperationsEvent, TournamentOperationState> {
  final TournamentRepository _tournamentRepository;
  final TournamentParticipantRepository _participantRepository;

  /// Constructor
  TournamentOperationsBloc({
    required TournamentRepository tournamentRepository,
    required TournamentParticipantRepository participantRepository,
  }) : 
    _tournamentRepository = tournamentRepository,
    _participantRepository = participantRepository,
    super(TournamentOperationInitialState()) {
    on<CreateTournamentOperationEvent>(_onCreateTournament);
    on<JoinTournamentByCodeOperationEvent>(_onJoinTournamentByCode);
    on<JoinPublicTournamentOperationEvent>(_onJoinPublicTournament);
    on<GenerateInviteCodeOperationEvent>(_onGenerateInviteCode);
  }

  Future<void> _onCreateTournament(
    CreateTournamentOperationEvent event,
    Emitter<TournamentOperationState> emit,
  ) async {
    // Verifica l'autenticazione prima di procedere
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      emit(TournamentOperationErrorState('Non sei autenticato. Accedi per creare un torneo.'));
      return;
    }

    emit(CreatingTournamentState());

    try {
      final tournament = await _tournamentRepository.create(
        Tournament.create(
          name: event.name,
          format: event.format,
          createdBy: currentUser.id,
          isPublic: event.isPublic,
          maxParticipants: event.maxParticipants,
          league: event.league,
        ),
      );
      
      emit(TournamentCreatedState(tournament));
    } catch (e) {
      emit(TournamentOperationErrorState('Error creating tournament: $e'));
    }
  }

  Future<void> _onJoinTournamentByCode(
    JoinTournamentByCodeOperationEvent event,
    Emitter<TournamentOperationState> emit,
  ) async {
    // Verifica l'autenticazione prima di procedere
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      emit(TournamentOperationErrorState('Non sei autenticato. Accedi per unirti a un torneo.'));
      return;
    }

    emit(JoiningTournamentState());

    try {
      // Find tournament by invite code
      final tournament = await _tournamentRepository.findByInviteCode(event.inviteCode);
      
      if (tournament == null) {
        emit(TournamentOperationErrorState('Codice invito non valido o torneo non trovato.'));
        return;
      }

      // Check if user is already participating
      final isAlreadyParticipating = await _participantRepository.isUserParticipating(
        tournament.id, 
        currentUser.id,
      );
      
      if (isAlreadyParticipating) {
        emit(TournamentOperationErrorState('Sei già iscritto a questo torneo.'));
        return;
      }

      // Check if tournament has available spots
      final hasSpots = await _tournamentRepository.hasAvailableSpots(tournament.id);
      if (!hasSpots) {
        emit(TournamentOperationErrorState('Il torneo è al completo.'));
        return;
      }

      // Join the tournament
      await _participantRepository.joinTournament(tournament.id, currentUser.id);
      emit(TournamentJoinedState(tournament));
    } catch (e) {
      emit(TournamentOperationErrorState('Error joining tournament: $e'));
    }
  }

  Future<void> _onJoinPublicTournament(
    JoinPublicTournamentOperationEvent event,
    Emitter<TournamentOperationState> emit,
  ) async {
    // Verifica l'autenticazione prima di procedere
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      emit(TournamentOperationErrorState('Non sei autenticato. Accedi per unirti a un torneo.'));
      return;
    }

    emit(JoiningTournamentState());

    try {
      // Get tournament details
      final tournament = await _tournamentRepository.get(event.tournamentId);
      
      if (tournament == null) {
        emit(TournamentOperationErrorState('Torneo non trovato.'));
        return;
      }

      // Check if user is already participating
      final isAlreadyParticipating = await _participantRepository.isUserParticipating(
        tournament.id, 
        currentUser.id,
      );
      
      if (isAlreadyParticipating) {
        emit(TournamentOperationErrorState('Sei già iscritto a questo torneo.'));
        return;
      }

      // Check if tournament has available spots
      final hasSpots = await _tournamentRepository.hasAvailableSpots(tournament.id);
      if (!hasSpots) {
        emit(TournamentOperationErrorState('Il torneo è al completo.'));
        return;
      }

      // Join the tournament
      await _participantRepository.joinTournament(tournament.id, currentUser.id);
      emit(TournamentJoinedState(tournament));
    } catch (e) {
      emit(TournamentOperationErrorState('Error joining tournament: $e'));
    }
  }

  Future<void> _onGenerateInviteCode(
    GenerateInviteCodeOperationEvent event,
    Emitter<TournamentOperationState> emit,
  ) async {
    emit(GeneratingInviteCodeState());

    try {
      final inviteCode = await _tournamentRepository.generateInviteCode(event.tournamentId);
      emit(InviteCodeGeneratedState(event.tournamentId, inviteCode));
    } catch (e) {
      emit(TournamentOperationErrorState('Error generating invite code: $e'));
    }
  }
}

/// Initial state for tournament operations
class TournamentOperationInitialState extends TournamentOperationState {}

/// Error state for tournament operations
class TournamentOperationErrorState extends TournamentOperationState {
  final String errorMessage;
  
  TournamentOperationErrorState(this.errorMessage);
  
  @override
  List<Object?> get props => [errorMessage];
} 