import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// The task management screen: add, toggle and delete tasks.
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final bloc = context.read<TaskBloc>();
    bloc.add(AddTask(_controller.text));
    _controller.clear();
  }

  void _toggle(Task task) => context.read<TaskBloc>().add(ToggleTask(task));
  void _delete(Task task) => context.read<TaskBloc>().add(DeleteTask(task));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              'Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _add(),
              decoration: InputDecoration(
                hintText: 'Add a task…',
                prefixIcon: const Icon(Icons.add_task,
                    color: AppTheme.seedColor),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: IconButton.filled(
                    onPressed: _add,
                    icon: const Icon(Icons.arrow_forward),
                    tooltip: 'Add task',
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (!state.isLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.isEmpty) {
                  return _EmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: state.tasks.length,
                  itemBuilder: (context, i) {
                    final task = state.tasks[i];
                    return TaskTile(
                      task: task,
                      onToggle: () => _toggle(task),
                      onDelete: () => _delete(task),
                    );
                  },
                );
              },
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rounded,
              size: 56, color: AppTheme.seedColor.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Type a task above to begin focusing on what matters.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}
