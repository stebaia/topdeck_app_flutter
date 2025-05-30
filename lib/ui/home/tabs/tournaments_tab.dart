import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/ui/tournaments/tournaments_page.dart';

@RoutePage(name: 'TournamentsTabRoute')
class TournamentsTab extends StatelessWidget {
  const TournamentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const TournamentsPage();
  }
} 