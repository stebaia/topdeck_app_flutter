import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/repositories/friend_repository.dart';
import 'package:topdeck_app_flutter/repositories/user_search_repository.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_event.dart';
import 'package:topdeck_app_flutter/state_management/blocs/user_search/user_search_state.dart';

/// BLoC for user search functionality
class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  /// Constructor
  UserSearchBloc(this._userSearchRepository, this._friendRepository) : super(const UserSearchInitial()) {
    on<SearchUsers>(_onSearchUsers);
    on<ClearSearch>(_onClearSearch);
    on<GetAllMyFriends>(_onGetAllMyFriends);
  }
  
  final UserSearchRepository _userSearchRepository;
  final FriendRepository _friendRepository;
  

  void getAllMyFriends() => add(const GetAllMyFriends());

  Future<void> _onGetAllMyFriends(
    GetAllMyFriends event,
    Emitter<UserSearchState> emit,
  ) async {
    emit(const TryToGetAllMyFriendsState());
    try {
      final friends = await _userSearchRepository.getAllMyFriends();
      emit(SuccessGetAllMyFriendsState(friends));
    } catch (e) {
      emit(ErrorGetAllMyFriendsState(e.toString()));
    } 
  }


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
      final allUsers = results.map((userJson) => UserProfile.fromJson(userJson)).toList();
      
      // Filtra gli utenti che sono già amici o con richieste pendenti
      final filteredUsers = <UserProfile>[];
      for (final user in allUsers) {
        final isAlreadyFriend = await _friendRepository.isFriendOrPending(user.id);
        if (!isAlreadyFriend) {
          filteredUsers.add(user);
        }
      }
      
      emit(UserSearchSuccess(filteredUsers));
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