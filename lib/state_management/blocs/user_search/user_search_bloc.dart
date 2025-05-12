import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/repositories/user_search_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_state.dart';

/// BLoC for user search functionality
class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  /// Constructor
  UserSearchBloc(this._userSearchRepository) : super(const UserSearchInitial()) {
    on<SearchUsers>(_onSearchUsers);
    on<ClearSearch>(_onClearSearch);
  }
  
  final UserSearchRepository _userSearchRepository;
  
  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<UserSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(const UserSearchInitial());
      return;
    }
    
    emit(const UserSearchLoading());
    
    try {
      final results = await _userSearchRepository.searchUsers(event.query);
      
      // Convert the JSON maps to UserProfile objects
      final users = results.map((userJson) => UserProfile.fromJson(userJson)).toList();
      
      emit(UserSearchSuccess(users));
    } catch (e) {
      emit(UserSearchError(e.toString()));
    }
  }
  
  void _onClearSearch(
    ClearSearch event,
    Emitter<UserSearchState> emit,
  ) {
    emit(const UserSearchInitial());
  }
} 