import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/ui/statistics/statistics_page.dart';

@RoutePage(name: 'StatisticsTabRoute')
class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatisticsPage();
  }
}