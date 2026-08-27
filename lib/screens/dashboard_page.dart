import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Overview screen: today's progress, stats and the next active tasks.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (!state.isLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _Content(
                    state: state,
                    onToggle: (task) =>
                        context.read<TaskBloc>().add(ToggleTask(task)),
                    onDelete: (task) =>
                        context.read<TaskBloc>().add(DeleteTask(task)),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF43A047), AppTheme.seedColor],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.eco, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Focus Leaf',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
            Text(
              'Grow your focus, one task at a time',
              style: TextStyle(fontSize: 13, color: AppTheme.muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.state,
    required this.onToggle,
    required this.onDelete,
  });

  final TaskState state;
  final ValueChanged<Task> onToggle;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    final total = state.tasks.length;
    final progress = total == 0 ? 0.0 : state.completed / total;
    final nextTasks = state.tasks.where((t) => !t.isDone).toList();

    return ListView(
      children: [
        _ProgressCard(progress: progress, completed: state.completed, total: total),
        const SizedBox(height: 16),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatValue(label: 'Total', value: '$total'),
              StatValue(label: 'Active', value: '${state.active}'),
              StatValue(label: 'Done', value: '${state.completed}'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Up next',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
            Text(
              '${nextTasks.length} pending',
              style: const TextStyle(fontSize: 13, color: AppTheme.muted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (nextTasks.isEmpty)
          const _EmptyState()
        else
          for (final task in nextTasks)
            TaskTile(
              task: task,
              onToggle: () => onToggle(task),
              onDelete: () => onDelete(task),
            ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.progress,
    required this.completed,
    required this.total,
  });

  final double progress;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppTheme.seedColor.withValues(alpha: 0.12),
                  color: AppTheme.seedColor,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today’s Progress',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  total == 0
                      ? 'Add a few tasks to start building momentum.'
                      : '$completed of $total tasks completed.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppTheme.muted,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.local_florist, size: 40, color: AppTheme.seedColor.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          const Text(
            'No active tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add tasks from the Tasks tab to start growing.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}
