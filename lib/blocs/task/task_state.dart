import 'package:equatable/equatable.dart';

import '../../models/task.dart';

/// Immutable snapshot of the task list.
class TaskState extends Equatable {
  const TaskState({this.tasks = const [], this.isLoaded = false});

  final List<Task> tasks;

  /// Whether tasks have been loaded from the database yet.
  final bool isLoaded;

  int get completed => tasks.where((t) => t.isDone).length;
  int get active => tasks.length - completed;
  bool get isEmpty => tasks.isEmpty;

  TaskState copyWith({List<Task>? tasks, bool? isLoaded}) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [tasks, isLoaded];
}
