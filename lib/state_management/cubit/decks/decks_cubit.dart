import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/state_management/cubit/decks/decks_state.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/repositories/deck_repository.dart';

/// Cubit for managing decks
class DecksCubit extends Cubit<DecksState> {
  final DeckRepository _deckRepository;

  /// Constructor
  DecksCubit(this._deckRepository) : super(DecksInitial());

  /// Load all decks
  Future<void> loadDecks() async {
    try {
      emit(DecksLoading());
      final decks = await _deckRepository.getAll();
      emit(DecksLoaded(decks));
    } catch (e) {
      emit(DecksError('Error loading decks: $e'));
    }
  }

  /// Create a new deck
  Future<void> createDeck({
    required String userId,
    required String name,
    required DeckFormat format,
    required bool shared,
  }) async {
    try {
      emit(DecksLoading());
      final newDeck = Deck.create(
        userId: userId,
        name: name,
        format: format,
        shared: shared,
      );
      
      await _deckRepository.create(newDeck);
      
      // Reload the decks to include the new one
      final decks = await _deckRepository.getAll();
      emit(DecksLoaded(decks));
    } catch (e) {
      emit(DecksError('Error creating deck: $e'));
    }
  }
} 