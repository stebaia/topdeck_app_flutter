import 'package:topdeck_app_flutter/model/entities/profile.dart';
import 'package:topdeck_app_flutter/network/service/impl/profile_service_impl.dart';
import 'package:topdeck_app_flutter/repositories/profile_repository.dart';

/// Implementation of the ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  /// The profile service
  final ProfileServiceImpl _service;

  /// Constructor
  ProfileRepositoryImpl(this._service);

  @override
  Future<Profile> create(Profile entity) async {
    final json = await _service.insert(entity.toJson());
    return Profile.fromJson(json);
  }

  @override
  Future<void> delete(String id) async {
    await _service.delete(id);
  }

  @override
  Future<Profile?> findByUsername(String username) async {
    final json = await _service.findByUsername(username);
    if (json == null) return null;
    return Profile.fromJson(json);
  }

  @override
  Future<Profile?> get(String id) async {
    final json = await _service.getById(id);
    if (json == null) return null;
    return Profile.fromJson(json);
  }

  @override
  Future<List<Profile>> getAll() async {
    final jsonList = await _service.getAll();
    return jsonList.map((json) => Profile.fromJson(json)).toList();
  }

  @override
  Future<Profile?> getCurrentUserProfile() async {
    final json = await _service.getCurrentUserProfile();
    if (json == null) return null;
    return Profile.fromJson(json);
  }

  @override
  Future<Profile> update(Profile entity) async {
    final json = await _service.update(entity.id, entity.toJson());
    return Profile.fromJson(json);
  }

  @override
  Future<Profile> updateAvatar(String id, String avatarUrl) async {
    final json = await _service.updateAvatar(id, avatarUrl);
    return Profile.fromJson(json);
  }
} 