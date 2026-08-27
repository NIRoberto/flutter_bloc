import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/task.dart';

/// Reusable elevated-style card used across the app for consistent surfaces.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: padding ?? const EdgeInsets.all(20), child: child),
    );
  }
}

/// A clean task row with a checkbox and delete action.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final done = task.isDone;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: done
                ? AppTheme.seedColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Checkbox(
            value: done,
            onChanged: (_) => onToggle(),
            activeColor: AppTheme.seedColor,
          ),
        ),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: done ? AppTheme.muted : AppTheme.ink,
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
          ),
          child: Text(task.title),
        ),
        trailing: IconButton(
          color: AppTheme.muted,
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete task',
        ),
      ),
    );
  }
}

/// A labelled stat value, e.g. total/active/done task counts.
class StatValue extends StatelessWidget {
  const StatValue({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.muted),
        ),
      ],
    );
  }
}
