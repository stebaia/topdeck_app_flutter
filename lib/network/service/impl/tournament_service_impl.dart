import 'package:topdeck_app_flutter/model/entities/tournament.dart';
import 'package:topdeck_app_flutter/network/service/impl/base_service_impl.dart';

/// Service implementation for the tournaments table
class TournamentServiceImpl extends BaseServiceImpl {
  @override
  String get tableName => 'tournaments';
  
  /// Finds tournaments by creator ID
  Future<List<Map<String, dynamic>>> findByCreator(String creatorId) async {
    final response = await client.from(tableName)
        .select()
        .eq('created_by', creatorId);
    return response;
  }
  
  /// Finds tournaments by status
  Future<List<Map<String, dynamic>>> findByStatus(TournamentStatus status) async {
    final response = await client.from(tableName)
        .select()
        .eq('status', status.name);
    return response;
  }
  
  /// Finds tournaments by format
  Future<List<Map<String, dynamic>>> findByFormat(String format) async {
    final response = await client.from(tableName)
        .select()
        .eq('format', format);
    return response;
  }
  
  /// Updates the status of a tournament
  Future<Map<String, dynamic>> updateStatus(String id, TournamentStatus status) async {
    final response = await client.from(tableName)
        .update({'status': status.name})
        .eq('id', id)
        .select()
        .single();
    return response;
  }
} 