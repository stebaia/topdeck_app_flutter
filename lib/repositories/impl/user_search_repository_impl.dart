import 'package:topdeck_app_flutter/network/service/impl/user_search_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/user_search_repository.dart';

/// Implementation of the user search repository
class UserSearchRepositoryImpl implements UserSearchRepository {
  /// Constructor
  UserSearchRepositoryImpl(this._userSearchService);
  
  final UserSearchServiceImpl _userSearchService;
  
  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) {
    return _userSearchService.searchUsers(query);
  }
  
  @override
  Future<Map<String, dynamic>?> getUserById(String userId) {
    return _userSearchService.getUserById(userId);
  }
} 