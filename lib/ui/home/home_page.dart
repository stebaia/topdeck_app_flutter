import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:topdeck_app_flutter/routers/app_router.gr.dart';
import 'package:topdeck_app_flutter/ui/screens/match_wizard/format_selection_page.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AutoTabsRouter(
        routes: const [
          HomeTabRoute(),
          StatisticsTabRoute(),
          FriendsTabRoute(),
          ProfileTabRoute(),
        ],
        transitionBuilder: (context, child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);
          return Scaffold(
            body: child,
            floatingActionButton: FloatingActionButton.extended(
              label: const Text('Crea partita'),
              onPressed: () {
                // Navigate to the first step of the match creation wizard
                context.router.push(const FormatSelectionPageRoute());
              },
              icon: const Icon(CupertinoIcons.plus),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.house),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.chart_bar),
                  label: 'Statistics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person_2),
                  label: 'Friends',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
