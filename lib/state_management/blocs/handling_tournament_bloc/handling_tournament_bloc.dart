import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/entities/tournament_match.dart';

part 'handling_tournament_event.dart';
part 'handling_tournament_state.dart';

class HandlingTournamentBloc extends Bloc<HandlingTournamentEvent, HandlingTournamentState> {
  HandlingTournamentBloc() : super(HandlingTournamentInitial()) {
    on<HandlingTournamentEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
