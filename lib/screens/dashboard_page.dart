import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../blocs/timer/timer_bloc.dart';
import '../blocs/timer/timer_state.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _dateLabel() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final hp = h * 0.012; // base vertical unit
    final hp2 = MediaQuery.paddingOf(context);

    final authState = context.watch<AuthBloc>().state;
    final userName = authState is Authenticated ? authState.user.firstName : null;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(w * 0.05, hp * 1.6, w * 0.05, 0),
            sliver: SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
                child: _GreetingHeader(
                  greeting: _greeting(),
                  date: _dateLabel(),
                  userName: userName,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: hp * 1.6)),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            sliver: SliverToBoxAdapter(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, taskState) =>
                    BlocBuilder<TimerBloc, TimerState>(
                  builder: (context, timerState) {
                    final total = taskState.tasks.length;
                    final progress = total == 0 ? 0.0 : taskState.completed / total;
                    return _HeroCard(
                      progress: progress,
                      completed: taskState.completed,
                      total: total,
                      sessions: timerState.sessionsCompleted,
                      goal: timerState.mode.dailyGoal,
                      isRunning: timerState.isRunning,
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: hp)),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            sliver: SliverToBoxAdapter(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, taskState) =>
                    BlocBuilder<TimerBloc, TimerState>(
                  builder: (context, timerState) => _StatsRow(
                    active: taskState.active,
                    done: taskState.completed,
                    sessions: timerState.sessionsCompleted,
                    goal: timerState.mode.dailyGoal,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: hp * 2)),
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              final nextTasks = state.tasks.where((t) => !t.isDone).toList();
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Up next',
                        style: TextStyle(
                          fontSize: w * 0.044,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                      if (nextTasks.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.seedColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${nextTasks.length} pending',
                            style: TextStyle(
                              fontSize: w * 0.028,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.seedColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: hp * 0.8)),
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (!state.isLoaded) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final nextTasks = state.tasks.where((t) => !t.isDone).toList();
              if (nextTasks.isEmpty) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                  sliver: const SliverToBoxAdapter(child: _EmptyTasksCard()),
                );
              }
              return SliverList.separated(
                itemCount: nextTasks.length,
                separatorBuilder: (_, _) => SizedBox(height: hp * 0.65),
                itemBuilder: (context, i) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                  child: _DashTaskCard(
                    task: nextTasks[i],
                    onToggle: () => context.read<TaskBloc>().add(ToggleTask(nextTasks[i])),
                    onDelete: () => context.read<TaskBloc>().add(DeleteTask(nextTasks[i])),
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: hp2.bottom + 90)),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.greeting, required this.date, this.userName});
  final String greeting;
  final String date;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final displayName = userName != null ? '$greeting, $userName' : greeting;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: w * 0.03,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: w * 0.065,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: w * 0.115,
          height: w * 0.115,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(w * 0.035),
            boxShadow: [
              BoxShadow(
                color: AppTheme.seedColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.eco_rounded, color: Colors.white, size: w * 0.055),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.progress,
    required this.completed,
    required this.total,
    required this.sessions,
    required this.goal,
    required this.isRunning,
  });

  final double progress;
  final int completed;
  final int total;
  final int sessions;
  final int goal;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final ringSize = w * 0.22;

    return Container(
      padding: EdgeInsets.all(w * 0.055),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF388E3C), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(w * 0.06),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: w * 0.018,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  color: Colors.white,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: w * 0.05,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'done',
                        style: TextStyle(
                          fontSize: w * 0.025,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: w * 0.045),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Progress",
                  style: TextStyle(
                    fontSize: w * 0.038,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: w * 0.01),
                Text(
                  total == 0
                      ? 'Add tasks to get started.'
                      : '$completed of $total tasks done.',
                  style: TextStyle(
                    fontSize: w * 0.03,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: w * 0.025),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: w * 0.025),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: w * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRunning ? Icons.radio_button_on_rounded : Icons.self_improvement_rounded,
                        size: w * 0.028,
                        color: isRunning ? const Color(0xFF69F0AE) : Colors.white.withValues(alpha: 0.8),
                      ),
                      SizedBox(width: w * 0.01),
                      Text(
                        isRunning ? 'Timer running' : '$sessions/$goal sessions',
                        style: TextStyle(
                          fontSize: w * 0.028,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.active,
    required this.done,
    required this.sessions,
    required this.goal,
  });

  final int active;
  final int done;
  final int sessions;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(icon: Icons.pending_actions_rounded, label: 'Active', value: '$active', color: const Color(0xFFE65100)),
        const SizedBox(width: 10),
        _StatTile(icon: Icons.check_circle_rounded, label: 'Completed', value: '$done', color: AppTheme.seedColor),
        const SizedBox(width: 10),
        _StatTile(icon: Icons.bolt_rounded, label: 'Sessions', value: '$sessions/$goal', color: const Color(0xFF6A1B9A)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
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
            Text(
              value,
              style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w800, color: AppTheme.ink),
            ),
            Text(
              label,
              style: TextStyle(fontSize: w * 0.025, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashTaskCard extends StatelessWidget {
  const _DashTaskCard({required this.task, required this.onToggle, required this.onDelete});

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(w * 0.04),
        ),
        child: Icon(Icons.delete_rounded, color: Colors.red.shade400, size: w * 0.055),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.035),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(w * 0.04),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: w * 0.06,
                height: w * 0.06,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? AppTheme.seedColor : Colors.transparent,
                  border: Border.all(
                    color: task.isDone ? AppTheme.seedColor : Colors.black.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: task.isDone
                    ? Icon(Icons.check_rounded, size: w * 0.035, color: Colors.white)
                    : null,
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: w * 0.036,
                    fontWeight: FontWeight.w500,
                    color: task.isDone ? AppTheme.muted : AppTheme.ink,
                    decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: w * 0.045, color: Colors.black.withValues(alpha: 0.15)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTasksCard extends StatelessWidget {
  const _EmptyTasksCard();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Container(
      padding: EdgeInsets.symmetric(vertical: w * 0.08, horizontal: w * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.05),
        border: Border.all(color: AppTheme.seedColor.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(
              color: AppTheme.seedColor.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.forest_rounded, size: w * 0.085, color: AppTheme.seedColor.withValues(alpha: 0.6)),
          ),
          SizedBox(height: w * 0.035),
          Text('All clear!', style: TextStyle(fontSize: w * 0.04, fontWeight: FontWeight.w700, color: AppTheme.ink)),
          SizedBox(height: w * 0.015),
          Text(
            'No pending tasks.\nHead to Tasks to add some.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: w * 0.033, height: 1.5, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}
