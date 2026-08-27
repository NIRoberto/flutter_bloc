import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'focus_timer_page.dart';
import 'tasks_page.dart';
import 'tips_page.dart';

/// The main scaffold hosting the bottom navigation and feature pages.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    DashboardPage(),
    TasksPage(),
    FocusTimerPage(),
    TipsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.eco), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Focus'),
          NavigationDestination(icon: Icon(Icons.spa), label: 'Tips'),
        ],
      ),
    );
  }
}
