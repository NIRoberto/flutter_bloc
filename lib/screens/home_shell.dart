import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/timer/timer_bloc.dart';
import '../blocs/timer/timer_event.dart';
import '../blocs/timer/timer_state.dart';
import '../theme/app_theme.dart';
import 'dashboard_page.dart';
import 'focus_timer_page.dart';
import 'stats_page.dart';
import 'tasks_page.dart';
import 'tips_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // 0=Home, 1=Tasks, 2=Focus(default), 3=Stats, 4=Tips
  int _selectedIndex = 2;

  static const _pages = <Widget>[
    DashboardPage(),
    TasksPage(),
    FocusTimerPage(),
    StatsPage(),
    TipsPage(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.task_alt_rounded, label: 'Tasks'),
    _NavItem(icon: Icons.self_improvement_rounded, label: 'Focus'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Stats'),
    _NavItem(icon: Icons.lightbulb_rounded, label: 'Tips'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _pages),
          // Persistent mini timer — hidden when on the Focus page
          if (_selectedIndex != 2)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 16),
                  child: _MiniTimerBadge(
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: _selectedIndex,
        items: _navItems,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _MiniTimerBadge extends StatelessWidget {
  const _MiniTimerBadge({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final isBreak = state.phase == TimerPhase.breakTime;
        final color = isBreak ? const Color(0xFF1565C0) : AppTheme.seedColor;
        final isRunning = state.isRunning;

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isRunning ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isRunning ? color : Colors.black)
                      .withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: isRunning
                  ? null
                  : Border.all(
                      color: Colors.black.withValues(alpha: 0.07),
                    ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRunning
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  size: 16,
                  color: isRunning ? Colors.white : color,
                ),
                const SizedBox(width: 6),
                Text(
                  state.formatted,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isRunning ? Colors.white : AppTheme.ink,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => context.read<TimerBloc>().add(const ToggleTimer()),
                  child: Icon(
                    isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 18,
                    color: isRunning
                        ? Colors.white.withValues(alpha: 0.8)
                        : color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF2E7D32);
    const inactiveColor = Color(0xFF6B736F);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = i == selectedIndex;
              final isCenter = i == 2;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: isCenter
                      ? Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: selected
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF43A047),
                                        Color(0xFF2E7D32)
                                      ],
                                    )
                                  : null,
                              color: selected
                                  ? null
                                  : const Color(0xFFF0F4F0),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: activeColor
                                            .withValues(alpha: 0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              item.icon,
                              size: 24,
                              color: selected
                                  ? Colors.white
                                  : inactiveColor,
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: selected ? activeColor : inactiveColor,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color:
                                    selected ? activeColor : inactiveColor,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
