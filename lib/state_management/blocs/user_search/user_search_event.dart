import 'package:equatable/equatable.dart';

/// Events for the user search bloc
abstract class UserSearchEvent extends Equatable {
  /// Constructor
  const UserSearchEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event to search for users
class SearchUsers extends UserSearchEvent {
  /// Constructor
  const SearchUsers(this.query);
  
  /// Search query
  final String query;
  
  @override
  List<Object?> get props => [query];
}

/// Event to clear the search results
class ClearSearch extends UserSearchEvent {
  /// Constructor
  const ClearSearch();
} 