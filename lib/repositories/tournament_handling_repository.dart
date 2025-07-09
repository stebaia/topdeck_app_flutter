import 'package:logger/logger.dart';
import 'package:topdeck_app_flutter/model/entities/tournament_match.dart';
import 'package:topdeck_app_flutter/network/service/impl/swiss_pairing_service_impl.dart';

class TournamentHandlingRepository {
  final Logger logger;
  final SwissPairingServiceImpl swissPairingService;

  TournamentHandlingRepository({required this.swissPairingService, required this.logger});
  
  Future<List<TournamentMatch>> generateSwissPairings(String tournamentId, int roundNumber) async {
    try {
      final List<TournamentMatch> mathces = await swissPairingService.generateSwissPairings(tournamentId: tournamentId, roundNumber: roundNumber);
      return mathces;
    } catch (e) {
      logger.e('Error generating Swiss pairings: $e');
      rethrow;
    }
  }


  Future<bool> advanceToNextRound(String tournamentId, int roundNumber) async {
    try {
      final bool success = await swissPairingService.advanceToNextRound(tournamentId: tournamentId, completedRound: roundNumber);
      return success;
    } catch (e) {
      logger.e('Error advancing to next round: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTournamentStandings(String tournamentId) async {
    try {
      final List<Map<String, dynamic>> standings = await swissPairingService.getTournamentStandings(tournamentId);
      return standings;
    } catch (e) {
      logger.e('Error getting tournament standings: $e');
      rethrow;
    }
  }

  
 

}