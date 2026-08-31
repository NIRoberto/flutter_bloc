import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showDone = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<TaskBloc>().add(AddTask(text));
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            showDone: _showDone,
            onToggleDone: () => setState(() => _showDone = !_showDone),
          ),
          const SizedBox(height: 14),
          _AddTaskBar(
            controller: _controller,
            focusNode: _focusNode,
            onAdd: _add,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (!state.isLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final active = state.tasks.where((t) => !t.isDone).toList();
                final done = state.tasks.where((t) => t.isDone).toList();

                if (state.isEmpty) return const _EmptyState();

                final sections = <Widget>[];

                if (active.isNotEmpty) {
                  sections.add(_SectionHeader(
                    label: 'To do',
                    count: active.length,
                    color: const Color(0xFFE65100),
                  ));
                  for (final task in active) {
                    sections.add(_TaskRow(
                      key: ValueKey(task.id),
                      task: task,
                      onToggle: () =>
                          context.read<TaskBloc>().add(ToggleTask(task)),
                      onDelete: () =>
                          context.read<TaskBloc>().add(DeleteTask(task)),
                    ));
                  }
                }

                if (done.isNotEmpty) {
                  sections.add(GestureDetector(
                    onTap: () => setState(() => _showDone = !_showDone),
                    child: _SectionHeader(
                      label: 'Completed',
                      count: done.length,
                      color: AppTheme.seedColor,
                      trailing: Icon(
                        _showDone
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppTheme.muted,
                      ),
                    ),
                  ));
                  if (_showDone) {
                    for (final task in done) {
                      sections.add(_TaskRow(
                        key: ValueKey(task.id),
                        task: task,
                        onToggle: () =>
                            context.read<TaskBloc>().add(ToggleTask(task)),
                        onDelete: () =>
                            context.read<TaskBloc>().add(DeleteTask(task)),
                      ));
                    }
                  }
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                  itemCount: sections.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => sections[i],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.showDone, required this.onToggleDone});
  final bool showDone;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.seedColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.task_alt_rounded,
                color: AppTheme.seedColor, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Tasks',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Capture what needs to get done',
                  style: TextStyle(fontSize: 11, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTaskBar extends StatefulWidget {
  const _AddTaskBar({
    required this.controller,
    required this.focusNode,
    required this.onAdd,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;

  @override
  State<_AddTaskBar> createState() => _AddTaskBarState();
}

class _AddTaskBarState extends State<_AddTaskBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final has = widget.controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => widget.onAdd(),
              style: const TextStyle(fontSize: 15, color: AppTheme.ink),
              decoration: InputDecoration(
                hintText: 'Add a new task...',
                prefixIcon: const Icon(
                  Icons.add_rounded,
                  color: AppTheme.seedColor,
                  size: 22,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: widget.onAdd,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: _hasText
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                        )
                      : null,
                  color: _hasText ? null : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _hasText
                      ? [
                          BoxShadow(
                            color: AppTheme.seedColor.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: _hasText ? Colors.white : AppTheme.muted,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
    this.trailing,
  });
  final String label;
  final int count;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
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
    return Dismissible(
      key: ValueKey('dismiss_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_rounded, color: Colors.red.shade400, size: 20),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onToggle();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: done
                ? AppTheme.seedColor.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: done
                  ? AppTheme.seedColor.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppTheme.seedColor : Colors.transparent,
                  border: Border.all(
                    color: done
                        ? AppTheme.seedColor
                        : Colors.black.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: done ? AppTheme.muted : AppTheme.ink,
                    decoration:
                        done ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
              Icon(
                Icons.drag_handle_rounded,
                size: 18,
                color: Colors.black.withValues(alpha: 0.12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.seedColor.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.playlist_add_check_rounded,
                size: 44,
                color: AppTheme.seedColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Type a task above and tap the arrow to add it.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.5, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
