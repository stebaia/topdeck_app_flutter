import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/model/entities/profile.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_bloc.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_event.dart';
import 'package:topdeck_app_flutter/state_management/auth/auth_state.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.read<AuthBloc>().add(SignOutEvent());
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UnauthenticatedState) {
            // Navigate to login page when logged out
            context.router.replaceNamed('/login');
          }
        },
        builder: (context, state) {
          if (state is AuthLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AuthenticatedState) {
            return _buildProfileContent(context, state.profile);
          } else {
            // This shouldn't happen as this screen should only be accessible when authenticated
            return const Center(
              child: Text('You are not logged in'),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Profile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: profile.avatarUrl != null
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: profile.avatarUrl == null
                ? Text(
                    profile.username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 24),
          
          // Username
          Text(
            profile.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Full Name
          Text(
            '${profile.nome} ${profile.cognome}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // Profile Information
          _buildInfoCard(
            title: 'Personal Information',
            items: [
              InfoItem(
                icon: Icons.person,
                label: 'Full Name',
                value: '${profile.nome} ${profile.cognome}',
              ),
              InfoItem(
                icon: Icons.calendar_today,
                label: 'Date of Birth',
                value: '${profile.dataDiNascita.day}/${profile.dataDiNascita.month}/${profile.dataDiNascita.year}',
              ),
              InfoItem(
                icon: Icons.location_city,
                label: 'City',
                value: profile.citta,
              ),
              InfoItem(
                icon: Icons.map,
                label: 'Province',
                value: profile.provincia,
              ),
              InfoItem(
                icon: Icons.public,
                label: 'Country',
                value: profile.stato,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Account Information
          _buildInfoCard(
            title: 'Account Information',
            items: [
              InfoItem(
                icon: Icons.person_outline,
                label: 'Username',
                value: profile.username,
              ),
              InfoItem(
                icon: Icons.access_time,
                label: 'Member Since',
                value: profile.createdAt != null
                    ? '${profile.createdAt!.day}/${profile.createdAt!.month}/${profile.createdAt!.year}'
                    : 'Unknown',
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to edit profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile functionality coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<InfoItem> items,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...items.map((item) => _buildInfoRow(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 24,
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Information item for profile details
class InfoItem {
  /// The icon to display
  final IconData icon;
  
  /// The label of the information
  final String label;
  
  /// The value of the information
  final String value;

  /// Constructor
  const InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
} 