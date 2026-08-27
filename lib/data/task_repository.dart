import '../models/task.dart';

/// Abstraction over task persistence so the UI/bloc can be tested in isolation.
abstract class TaskRepository {
  Future<List<Task>> getAll();
  Future<int> insert(Task task);
  Future<void> update(Task task);
  Future<void> delete(int id);
}
