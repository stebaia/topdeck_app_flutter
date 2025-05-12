import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(name: 'ProfileTabRoute')
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Profile Tab'),
      ),
    );
  }
} 