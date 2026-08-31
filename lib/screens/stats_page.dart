import 'package:flutter/material.dart';

import '../blocs/timer/timer_state.dart';
import '../data/session_repository.dart';
import '../data/sqlite_session_repository.dart';
import '../models/focus_session.dart';
import '../theme/app_theme.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, this.userId});

  final int? userId;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final SessionRepository _sessions = SqliteSessionRepository();
  List<FocusSession> _thisWeek = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final start = DateTime.now().subtract(const Duration(days: 7));
      final sessions = await _sessions.since(start, userId: widget.userId);
      if (!mounted) return;
      setState(() => _thisWeek = sessions);
    } catch (_) {
      // Ignore load errors — the page renders the empty state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final totalMinutes = _thisWeek.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final totalSessions = _thisWeek.length;

    // Simple daily breakdown for the last 7 days
    final now = DateTime.now();
    final dailyMinutes = List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      return _thisWeek
          .where((s) =>
              s.completedAt.year == day.year &&
              s.completedAt.month == day.month &&
              s.completedAt.day == day.day)
          .fold<int>(0, (sum, s) => sum + s.durationMinutes);
    });
    final maxMinutes = dailyMinutes.reduce((a, b) => a > b ? a : b).clamp(1, 9999);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      // Always render the view (even while loading) so the page never shows an
      // infinite indeterminate spinner that would keep running offstage.
      body: ListView(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: w * 0.04),
              children: [
                _SummaryCards(w: w, totalSessions: totalSessions, totalMinutes: totalMinutes),
                SizedBox(height: w * 0.05),
                Text(
                  'This week',
                  style: TextStyle(
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.muted,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: w * 0.025),
                _BarChart(
                  dailyMinutes: dailyMinutes,
                  maxMinutes: maxMinutes,
                  w: w,
                ),
                SizedBox(height: w * 0.05),
                if (_thisWeek.isNotEmpty) ...[
                  Text(
                    'Sessions breakdown',
                    style: TextStyle(
                      fontSize: w * 0.035,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.muted,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: w * 0.025),
                  _SessionBreakdown(sessions: _thisWeek, w: w),
                ],
                if (_thisWeek.isEmpty) ...[
                  SizedBox(height: w * 0.06),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.bar_chart_rounded, size: w * 0.12, color: AppTheme.muted.withValues(alpha: 0.25)),
                        SizedBox(height: w * 0.03),
                        Text(
                          'No sessions yet this week',
                          style: TextStyle(fontSize: w * 0.038, color: AppTheme.muted),
                        ),
                        SizedBox(height: w * 0.01),
                        Text(
                          'Complete a focus session to see stats here.',
                          style: TextStyle(fontSize: w * 0.032, color: AppTheme.muted.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.w, required this.totalSessions, required this.totalMinutes});

  final double w;
  final int totalSessions;
  final int totalMinutes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Card(
          w: w,
          icon: Icons.timer_rounded,
          value: '$totalSessions',
          label: 'Sessions',
          color: AppTheme.seedColor,
        ),
        SizedBox(width: w * 0.03),
        _Card(
          w: w,
          icon: Icons.schedule_rounded,
          value: '${(totalMinutes / 60).toStringAsFixed(1)}h',
          label: 'Focus time',
          color: const Color(0xFF1565C0),
        ),
        SizedBox(width: w * 0.03),
        _Card(
          w: w,
          icon: Icons.speed_rounded,
          value: totalSessions > 0 ? '${(totalMinutes / totalSessions).round()}' : '0',
          label: 'Avg min',
          color: const Color(0xFF6A1B9A),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.w,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final double w;
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.035),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(w * 0.04),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: w * 0.038, color: color),
            ),
            SizedBox(height: w * 0.02),
            Text(value, style: TextStyle(fontSize: w * 0.044, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            Text(label, style: TextStyle(fontSize: w * 0.025, color: AppTheme.muted)),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.dailyMinutes, required this.maxMinutes, required this.w});

  final List<int> dailyMinutes;
  final int maxMinutes;
  final double w;

  static const _days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
          final minutes = dailyMinutes[i];
          final fraction = (minutes / maxMinutes).clamp(0.0, 1.0);
          final barHeight = (w * 0.25) * fraction;
          final isToday = i == 6;

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (minutes > 0)
                  Text(
                    '$minutes',
                    style: TextStyle(fontSize: w * 0.022, fontWeight: FontWeight.w600, color: AppTheme.muted),
                  ),
                SizedBox(height: w * 0.01),
                Container(
                  width: w * 0.06,
                  height: barHeight < 4 ? (minutes > 0 ? 4.0 : 2.0) : barHeight,
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.seedColor : AppTheme.seedColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: w * 0.015),
                Text(
                  _days[day.weekday - 1],
                  style: TextStyle(
                    fontSize: w * 0.024,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    color: isToday ? AppTheme.seedColor : AppTheme.muted,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SessionBreakdown extends StatelessWidget {
  const _SessionBreakdown({required this.sessions, required this.w});

  final List<FocusSession> sessions;
  final double w;

  @override
  Widget build(BuildContext context) {
    final byMode = <String, int>{};
    for (final s in sessions) {
      byMode[s.mode] = (byMode[s.mode] ?? 0) + 1;
    }
    final entries = byMode.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.04),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: entries.map((e) {
          final fraction = e.value / sessions.length;
          final modeLabel = FocusMode.values
              .where((m) => m.name == e.key)
              .map((m) => m.label)
              .firstOrNull;
          return Padding(
            padding: EdgeInsets.only(bottom: w * 0.025),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(modeLabel ?? e.key, style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.w600, color: AppTheme.ink)),
                    Text(
                      '${e.value} session${e.value == 1 ? '' : 's'}',
                      style: TextStyle(fontSize: w * 0.03, color: AppTheme.muted),
                    ),
                  ],
                ),
                SizedBox(height: w * 0.015),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: AppTheme.seedColor.withValues(alpha: 0.1),
                    color: AppTheme.seedColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}