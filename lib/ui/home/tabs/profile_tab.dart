import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topdeck_app_flutter/model/entities/user_elo.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/state_management/cubit/elo/elo_cubit.dart';
import 'package:topdeck_app_flutter/state_management/cubit/elo/elo_state.dart';
import 'package:topdeck_app_flutter/utils/elo_config.dart';
import 'package:topdeck_app_flutter/ui/widgets/theme_bottom_sheet.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';

@RoutePage(name: 'ProfileTabRoute')
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: user == null 
          ? _buildUnauthenticatedView()
          : _buildAuthenticatedView(),
    );
  }
  
  Widget _buildUnauthenticatedView() {
    return const Center(
      child: Text('Please sign in to view your profile'),
    );
  }
  
  Widget _buildAuthenticatedView() {
    final user = supabase.auth.currentUser;
    final textTheme = Theme.of(context).textTheme;
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh ELO data
        if (user != null) {
          context.read<EloCubit>().loadUserProfile(
            userId: user.id,
            includeMatches: false,
            includeTournaments: false,
          );
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text(
                          'Profile',
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'No email available',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey.shade400,
                    child: Text(
                      _getInitials(user?.email ?? 'User'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // ELO Ratings Section
            if (user != null) _buildEloSection(user.id),
            

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Manage your account',
                style: textTheme.headlineSmall,
              ),
            ),
            _buildMenuGrid(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Recommended reads',
                style: textTheme.headlineSmall,
              ),
            ),
            _buildRecommendedCard(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEloSection(String userId) {
    return BlocProvider(
      create: (context) => context.read<EloCubit>()..loadUserProfile(
        userId: userId,
        includeMatches: false,
        includeTournaments: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ELO Ratings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
              ],
            ),
          ),
          BlocBuilder<EloCubit, EloState>(
            builder: (context, state) {
              if (state is EloLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is EloProfileLoaded) {
                return _buildEloCards(state.profile.eloRatings);
              } else {
                // Se non ci sono dati ELO o errore, mostra i valori di default
                return _buildDefaultEloCards();
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildEloCards(Map<String, UserElo> eloRatings) {
    if (eloRatings.isEmpty) {
      return _buildDefaultEloCards();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: eloRatings.length,
        itemBuilder: (context, index) {
          final format = eloRatings.keys.elementAt(index);
          final userElo = eloRatings[format]!;
          
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      _getShortFormatName(format),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${userElo.elo}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(EloCalculator.getEloTierColor(userElo.elo)),
                      ),
                    ),
                    Text(
                      EloCalculator.getEloTier(userElo.elo),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${(userElo.winRate * 100).toStringAsFixed(0)}% • ${userElo.matchesPlayed}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDefaultEloCards() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: EloConfig.supportedFormats.length,
        itemBuilder: (context, index) {
          final format = EloConfig.supportedFormats[index];
          
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      _getShortFormatName(format),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '1200',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(EloCalculator.getEloTierColor(1200)),
                      ),
                    ),
                    Text(
                      EloCalculator.getEloTier(1200),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '0% • 0',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// Get short name for format to fit in cards
  String _getShortFormatName(String format) {
    switch (format.toLowerCase()) {
      case 'advanced':
        return 'Advanced';
      case 'edison format':
      case 'edison':
        return 'Edison';
      case 'goat format':
      case 'goat':
        return 'GOAT';
      case 'traditional':
        return 'Traditional';
      case 'speed duel':
        return 'Speed Duel';
      default:
        return format;
    }
  }
  
  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMenuTile(
          'Your details',
          Icons.person_search_outlined,
          Colors.blue,
          () {
            // Navigate to details page
          },
        ),
        _buildMenuTile(
          'Your decks',
          Icons.menu_book,
          Colors.blue,
          () {
            _navigateToDecksPage();
          },
        ),
        _buildMenuTile(
          'ELO Stats',
          Icons.bar_chart,
          Colors.purple,
          () {
            _navigateToEloStatsPage();
          },
        ),
        _buildMenuTile(
          'Life Counter',
          Icons.favorite,
          Colors.red,
          () {
            _navigateToLifeCounter();
          },
        ),
        _buildMenuTile(
          'Tema',
          Icons.palette_outlined,
          Colors.deepPurple,
          () {
            ThemeBottomSheet.show(context);
          },
        ),
        _buildMenuTile(
          'Support',
          Icons.help_outline,
          Colors.blue,
          () {
            // Navigate to support page
          },
        ),
        _buildMenuTile(
          'Logout',
          Icons.logout,
          Colors.red,
          () {
            _showLogoutConfirmation();
          },
        ),
      ],
    );
  }
  
  Widget _buildMenuTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getIllustrationForTile(title),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _getIllustrationForTile(String title) {
    // Use default icons since custom images might not be available yet
    switch (title) {
      case 'Your details':
        return Icon(
          Icons.person_search_outlined,
          size: 60,
          color: Colors.blue,
        );
      case 'Your decks':
        return Icon(
          Icons.menu_book,
          size: 60,
          color: Colors.blue,
        );
      case 'ELO Stats':
        return Icon(
          Icons.bar_chart,
          size: 60,
          color: Colors.purple,
        );
      case 'Tema':
        return Icon(
          Icons.palette_outlined,
          size: 60,
          color: Colors.deepPurple,
        );
      case 'Support':
        return Icon(
          Icons.help_outline,
          size: 60,
          color: Colors.blue,
        );
      case 'Life Counter':
        return Icon(
          Icons.favorite,
          size: 60,
          color: Colors.red,
        );
      case 'Logout':
        return Icon(
          Icons.logout,
          size: 60,
          color: Colors.red,
        );
      default:
        return Icon(
          Icons.circle,
          size: 60,
          color: Colors.grey,
        );
    }
  }
  
  Widget _buildRecommendedCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why choose us?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn about the benefits of using our app for your card collection.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                Icons.person,
                size: 80,
                color: Colors.blue.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToDecksPage() {
    context.router.pushNamed('/decks');
  }
  
  void _navigateToLifeCounter() {
    context.router.push(const OfflineLifeCounterPageRoute());
  }
  
  void _navigateToEloStatsPage() {
    // TODO: Navigate to ELO stats page when it's implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ELO Stats page coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Sei sicuro di voler effettuare il logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await supabase.auth.signOut();
              if (mounted) {
                context.router.replaceNamed('/login');
              }
            },
            child: const Text('Logout'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    String firstNameInitial = nameSplit[0][0];
    
    if (nameSplit.length > 1) {
      return "${firstNameInitial.toUpperCase()}${nameSplit[1][0].toUpperCase()}";
    }
    
    return firstNameInitial.toUpperCase() + (nameSplit[0].length > 1 ? nameSplit[0][1].toUpperCase() : "");
  }
} 