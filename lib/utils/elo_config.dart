/// Import for math functions
import 'dart:math' as math;

/// Configuration constants for the ELO system
class EloConfig {
  /// Starting ELO for new users in any format
  static const int startingElo = 1200;
  
  /// K-factor for players with less than 30 matches (calibration period)
  static const int kFactorCalibration = 40;
  
  /// K-factor for tournament matches
  static const int kFactorTournament = 20;
  
  /// K-factor for friendly matches
  static const int kFactorFriendly = 10;
  
  /// ELO bonus for tournament winner
  static const int tournamentWinnerBonus = 50;
  
  /// ELO bonus for top 4 finish
  static const int top4Bonus = 25;
  
  /// Matches needed to exit calibration period
  static const int calibrationMatches = 30;
  
  /// Supported game formats
  static const List<String> supportedFormats = [
    'Advanced',
    'Edison',
    'GOAT',
    'Traditional',
    'Speed Duel',
  ];
  
  /// Format display names
  static const Map<String, String> formatDisplayNames = {
    'Advanced': 'Advanced',
    'Edison': 'Edison Format',
    'GOAT': 'GOAT Format',
    'Traditional': 'Traditional',
    'Speed Duel': 'Speed Duel',
  };
  
  /// Get display name for a format
  static String getFormatDisplayName(String format) {
    return formatDisplayNames[format] ?? format;
  }
  
  /// Check if format is supported
  static bool isFormatSupported(String format) {
    return supportedFormats.contains(format);
  }
}

/// ELO calculation utilities
class EloCalculator {
  /// Calculate expected score for player A vs player B
  static double calculateExpectedScore(int ratingA, int ratingB) {
    return 1.0 / (1.0 + math.pow(10, (ratingB - ratingA) / 400.0));
  }
  
  /// Calculate new rating after a match
  static int calculateNewRating({
    required int currentRating,
    required double actualScore, // 1.0 for win, 0.5 for draw, 0.0 for loss
    required double expectedScore,
    required int kFactor,
  }) {
    final newRating = currentRating + (kFactor * (actualScore - expectedScore)).round();
    return math.max(0, newRating); // ELO can't go below 0
  }
  
  /// Determine K-factor based on match type and player experience
  static int determineKFactor({
    required bool isFriendly,
    required bool isTournament,
    required int matchesPlayed,
  }) {
    // Calibration period - higher K-factor for first 30 matches
    if (matchesPlayed < EloConfig.calibrationMatches) {
      return EloConfig.kFactorCalibration;
    }
    
    // Tournament matches have higher K-factor than friendly
    if (isTournament) {
      return EloConfig.kFactorTournament;
    }
    
    return EloConfig.kFactorFriendly;
  }
  
  /// Get rank suffix (1st, 2nd, 3rd, etc.)
  static String getRankSuffix(int rank) {
    if (rank <= 0) return '';
    
    final lastDigit = rank % 10;
    final lastTwoDigits = rank % 100;
    
    if (lastTwoDigits >= 11 && lastTwoDigits <= 13) {
      return '${rank}th';
    }
    
    switch (lastDigit) {
      case 1:
        return '${rank}st';
      case 2:
        return '${rank}nd';
      case 3:
        return '${rank}rd';
      default:
        return '${rank}th';
    }
  }
  
  /// Format ELO change for display (+50, -25, etc.)
  static String formatEloChange(int change) {
    if (change > 0) {
      return '+$change';
    } else if (change < 0) {
      return '$change'; // Already has minus sign
    } else {
      return '±0';
    }
  }
  
  /// Get ELO tier name based on rating
  static String getEloTier(int elo) {
    if (elo >= 2400) return 'Legendary';
    if (elo >= 2200) return 'Master';
    if (elo >= 2000) return 'Diamond';
    if (elo >= 1800) return 'Platinum';
    if (elo >= 1600) return 'Gold';
    if (elo >= 1400) return 'Silver';
    if (elo >= 1200) return 'Bronze';
    return 'Unranked';
  }
  
  /// Get color for ELO tier
  static int getEloTierColor(int elo) {
    if (elo >= 2400) return 0xFFFFD700; // Gold
    if (elo >= 2200) return 0xFFE25822; // Orange Red
    if (elo >= 2000) return 0xFFB57EDC; // Medium Orchid
    if (elo >= 1800) return 0xFF00FFFF; // Cyan
    if (elo >= 1600) return 0xFFFFD700; // Gold
    if (elo >= 1400) return 0xFFC0C0C0; // Silver
    if (elo >= 1200) return 0xFFCD7F32; // Bronze
    return 0xFF808080; // Gray
  }
} 