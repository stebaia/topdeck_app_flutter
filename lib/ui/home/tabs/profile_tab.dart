import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topdeck_app_flutter/model/entities/deck.dart';
import 'package:topdeck_app_flutter/network/supabase_config.dart';
import 'package:topdeck_app_flutter/repositories/deck_repository.dart';
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
    
    return SingleChildScrollView(
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
    );
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
          'Settings',
          Icons.settings_outlined,
          Colors.teal,
          () {
            // Navigate to settings page
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
      case 'Settings':
        return Icon(
          Icons.settings_outlined,
          size: 60,
          color: Colors.teal,
        );
      case 'Support':
        return Icon(
          Icons.help_outline,
          size: 60,
          color: Colors.blue,
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