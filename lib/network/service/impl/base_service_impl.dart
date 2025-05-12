import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/network/service/base_service.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';

/// Base implementation of BaseService
class BaseServiceImpl implements BaseService {
  @override
  String get tableName => throw UnimplementedError('Subclasses must implement this');

  /// The Supabase client
  final SupabaseClient client = supabase;

  @override
  Future<void> delete(String id) async {
    await client.from(tableName).delete().eq('id', id);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await client.from(tableName).select();
    return response;
  }

  @override
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await client.from(tableName).select().eq('id', id).maybeSingle();
    return response;
  }

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await client.from(tableName).insert(data).select().single();
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    final response = await client.from(tableName).update(data).eq('id', id).select().single();
    return response;
  }
} 