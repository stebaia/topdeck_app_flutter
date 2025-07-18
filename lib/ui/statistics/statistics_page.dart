import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:topdeck_app_flutter/state_management/cubit/elo/elo_cubit.dart';
import 'package:topdeck_app_flutter/state_management/cubit/elo/elo_state.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_bloc.dart';
import 'package:topdeck_app_flutter/state_management/blocs/auth/auth_state.dart';
import 'package:topdeck_app_flutter/ui/widgets/loading_indicator.dart';
import 'package:topdeck_app_flutter/ui/widgets/current_user_builder.dart';
import 'package:topdeck_app_flutter/model/entities/user_profile_extended.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    // Try to load user profile, but don't block if it fails
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      print('DEBUG: Auth state type: ${authState.runtimeType}');
      if (authState is AuthenticatedState) {
        print('DEBUG: User ID: ${authState.profile.id}');
        context.read<EloCubit>().loadUserProfile(userId: authState.profile.id);
      } else {
        print('DEBUG: User not authenticated');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: CurrentUserBuilder(
        builder: (context, user) {
          return Consumer<EloCubit>(
            builder: (context, eloCubit, child) {
              final state = eloCubit.state;
              print('DEBUG: ELO state type: ${state.runtimeType}');
              
              if (state is EloLoading) {
                return const Center(child: LoadingIndicator());
              }
              
              if (state is EloError) {
                print('DEBUG: ELO error: ${state.message}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading statistics',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              if (state is EloProfileLoaded) {
                final profile = state.profile;
                print('DEBUG: Profile loaded - formats: ${profile.getPlayedFormats()}');
                print('DEBUG: Profile loaded - total matches: ${profile.overallStats.totalMatches}');
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main ELO Card
                      _buildMainEloCard(context, profile),
                      const SizedBox(height: 24),
                      
                      // Format Statistics
                      _buildFormatStatistics(context, profile),
                      const SizedBox(height: 24),
                      
                      // Match Statistics
                      _buildMatchStatistics(context, profile),
                      const SizedBox(height: 24),
                      
                      // Performance Charts
                      _buildPerformanceSection(context, profile),
                    ],
                  ),
                );
              }
              
              // Show empty state
              print('DEBUG: Showing empty state - state type: ${state.runtimeType}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.chart_bar,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No statistics available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'State: ${state.runtimeType}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMainEloCard(BuildContext context, UserProfileExtended profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.chart_bar_alt_fill,
            size: 48,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(height: 16),
          Text(
            'Current ELO',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${profile.overallStats.peakElo}',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getEloRank(profile.overallStats.peakElo),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatStatistics(BuildContext context, UserProfileExtended profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Format Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        // Build format cards for all formats the user has played
        ...profile.getPlayedFormats().map((format) => [
          _buildFormatCard(context, _formatDisplayName(format), profile.getEloForFormat(format)),
          const SizedBox(height: 12),
        ]).expand((element) => element),
      ],
    );
  }

  Widget _buildFormatCard(BuildContext context, String format, int elo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                format,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getEloRank(elo),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              elo.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStatistics(BuildContext context, UserProfileExtended profile) {
    final wins = profile.overallStats.totalWins;
    final losses = profile.overallStats.totalLosses;
    final totalMatches = profile.overallStats.totalMatches;
    final winRate = profile.overallStats.winRate * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Wins',
                wins.toString(),
                CupertinoIcons.check_mark_circled_solid,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Losses',
                losses.toString(),
                CupertinoIcons.xmark_circle_fill,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Matches',
                totalMatches.toString(),
                CupertinoIcons.game_controller,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Win Rate',
                '${winRate.toStringAsFixed(1)}%',
                CupertinoIcons.percent,
                winRate >= 50 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context, UserProfileExtended profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        // Recent Performance Card
        _buildRecentPerformanceCard(context, profile),
        const SizedBox(height: 16),
        // ELO Progress Card
        _buildEloProgressCard(context, profile),
        const SizedBox(height: 16),
        // Best Achievements Card
        _buildAchievementsCard(context, profile),
      ],
    );
  }






  Widget _buildRecentPerformanceCard(BuildContext context, UserProfileExtended profile) {
    final recentMatches = profile.matchHistory.take(10).toList();
    final wins = recentMatches.where((match) => 
      (match.player1Id == profile.userId && match.winnerId == profile.userId) ||
      (match.player2Id == profile.userId && match.winnerId == profile.userId)
    ).length;
    final losses = recentMatches.length - wins;
    final winRate = recentMatches.isNotEmpty ? (wins / recentMatches.length * 100) : 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar_circle,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Performance (Last 10 matches)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentMatches.isNotEmpty) ...[
            Row(
              children: recentMatches.map((match) {
                final isWin = (match.player1Id == profile.userId && match.winnerId == profile.userId) ||
                             (match.player2Id == profile.userId && match.winnerId == profile.userId);
                return [
                  Expanded(
                    child: _buildMiniStatCard(context, isWin ? 'W' : 'L', isWin ? Colors.green : Colors.red),
                  ),
                  if (recentMatches.indexOf(match) < recentMatches.length - 1) const SizedBox(width: 8),
                ];
              }).expand((element) => element).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              '$wins wins, $losses losses (${winRate.toStringAsFixed(1)}% win rate)',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                'No recent matches',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(BuildContext context, String result, Color color) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          result,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildEloProgressCard(BuildContext context, UserProfileExtended profile) {
    final peakElo = profile.overallStats.peakElo;
    final currentElo = profile.eloRatings.values.isNotEmpty 
        ? profile.eloRatings.values.map((elo) => elo.elo).reduce((a, b) => a > b ? a : b)
        : 1200;
    final monthlyProgress = currentElo - 1200; // Simple calculation, could be more sophisticated
    final progressPercentage = (currentElo / peakElo).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.arrow_up_right,
                size: 24,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              Text(
                'ELO Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${monthlyProgress >= 0 ? '+' : ''}$monthlyProgress ELO',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: monthlyProgress >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Peak ELO',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$peakElo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: progressPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(BuildContext context, UserProfileExtended profile) {
    final tournamentWins = profile.overallStats.tournamentWins;
    final totalTournaments = profile.overallStats.totalTournaments;
    final bestMonthWinRate = profile.overallStats.winRate * 100;
    
    // Calculate win streak from recent matches
    int currentWinStreak = 0;
    final recentMatches = profile.matchHistory.take(20).toList();
    for (final match in recentMatches) {
      final isWin = (match.player1Id == profile.userId && match.winnerId == profile.userId) ||
                   (match.player2Id == profile.userId && match.winnerId == profile.userId);
      if (isWin) {
        currentWinStreak++;
      } else {
        break;
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.star_fill,
                size: 24,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAchievementItem(
                  context,
                  '$currentWinStreak',
                  'Win Streak',
                  CupertinoIcons.flame_fill,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAchievementItem(
                  context,
                  '$totalTournaments',
                  'Tournaments',
                  CupertinoIcons.rosette,
                  Colors.yellow.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAchievementItem(
                  context,
                  '$tournamentWins',
                  'Victories',
                  CupertinoIcons.star_circle_fill,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAchievementItem(
                  context,
                  '${bestMonthWinRate.toStringAsFixed(1)}%',
                  'Win Rate',
                  CupertinoIcons.calendar,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getEloRank(int elo) {
    if (elo >= 2400) return 'Master';
    if (elo >= 2100) return 'Expert';
    if (elo >= 1800) return 'Advanced';
    if (elo >= 1500) return 'Intermediate';
    if (elo >= 1200) return 'Beginner';
    return 'Novice';
  }

  String _formatDisplayName(String format) {
    switch (format.toLowerCase()) {
      case 'advanced':
        return 'Advanced';
      case 'goat':
        return 'GOAT';
      case 'edison':
        return 'Edison';
      case 'hat':
        return 'HAT';
      case 'speed':
        return 'Speed';
      case 'draft':
        return 'Draft';
      case 'sealed':
        return 'Sealed';
      default:
        return format.toUpperCase();
    }
  }
}