import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/sqlite_task_repository.dart';
import '../../data/task_repository.dart';
import '../../models/task.dart';
import 'task_event.dart';
import 'task_state.dart';

/// Manages the list of tasks, persisting changes through a [TaskRepository].
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({TaskRepository? repository})
      : _repository = repository ?? SqliteTaskRepository(),
        super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<ToggleTask>(_onToggleTask);
    on<DeleteTask>(_onDeleteTask);
  }

  final TaskRepository _repository;

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    if (state.isLoaded) return;
    final tasks = await _repository.getAll();
    emit(TaskState(tasks: tasks, isLoaded: true));
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    final title = event.title.trim();
    if (title.isEmpty) return;
    final id = await _repository.insert(Task(title: title));
    emit(
      state.copyWith(
        tasks: [...state.tasks, Task(id: id, title: title)],
        isLoaded: true,
      ),
    );
  }

  Future<void> _onToggleTask(
    ToggleTask event,
    Emitter<TaskState> emit,
  ) async {
    final updated = event.task.copyWith(isDone: !event.task.isDone);
    await _repository.update(updated);
    emit(
      state.copyWith(
        tasks: state.tasks
            .map((t) => t.id == updated.id ? updated : t)
            .toList(),
        isLoaded: true,
      ),
    );
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TaskState> emit,
  ) async {
    if (event.task.id != null) {
      await _repository.delete(event.task.id!);
    }
    emit(
      state.copyWith(
        tasks: state.tasks.where((t) => t.id != event.task.id).toList(),
        isLoaded: true,
      ),
    );
  }
}
