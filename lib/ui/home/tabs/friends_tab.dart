import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage(name: 'FriendsTabRoute')
class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Friends Tab'),
      ),
    );
  }
} 