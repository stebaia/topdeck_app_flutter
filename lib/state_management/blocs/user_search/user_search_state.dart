import 'package:equatable/equatable.dart';
import 'package:topdeck_app_flutter/model/user.dart';

/// States for the user search bloc
abstract class UserSearchState extends Equatable {
  /// Constructor
  const UserSearchState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class UserSearchInitial extends UserSearchState {
  /// Constructor
  const UserSearchInitial();
}

/// Loading state
class UserSearchLoading extends UserSearchState {
  /// Constructor
  const UserSearchLoading();
}

/// Success state with results
class UserSearchSuccess extends UserSearchState {
  /// Constructor
  const UserSearchSuccess(this.users);
  
  /// List of found users
  final List<UserProfile> users;
  
  @override
  List<Object?> get props => [users];
}

/// Error state
class UserSearchError extends UserSearchState {
  /// Constructor
  const UserSearchError(this.message);
  
  /// Error message
  final String message;
  
  @override
  List<Object?> get props => [message];
} 