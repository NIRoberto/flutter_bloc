import 'package:equatable/equatable.dart';

import '../../models/task.dart';

/// Events that mutate the task list.
sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the persisted tasks from the database.
final class LoadTasks extends TaskEvent {
  const LoadTasks();

  @override
  List<Object?> get props => [];
}

/// Adds a new task with the given [title].
final class AddTask extends TaskEvent {
  const AddTask(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

/// Toggles the completion state of [task].
final class ToggleTask extends TaskEvent {
  const ToggleTask(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

/// Removes [task] from the list.
final class DeleteTask extends TaskEvent {
  const DeleteTask(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}
