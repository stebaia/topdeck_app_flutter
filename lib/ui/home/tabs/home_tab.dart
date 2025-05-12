import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/model/user.dart';
import 'package:topdeck_app_flutter/ui/home/widgets/user_search_widget.dart';

@RoutePage(name: 'HomeTabRoute')
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topdeck'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: UserSearchWidget(
                onUserSelected: (UserProfile user) {
                  // Show a snackbar when a user is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected user: ${user.username}'),
                      action: SnackBarAction(
                        label: 'Send Request',
                        onPressed: () {
                          // Here you would call the friendService to send a friend request
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Friend request sent to ${user.username}'),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 