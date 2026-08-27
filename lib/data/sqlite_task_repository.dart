import '../models/task.dart';
import 'app_database.dart';
import 'task_repository.dart';

/// SQLite-backed implementation of [TaskRepository].
class SqliteTaskRepository implements TaskRepository {
  @override
  Future<List<Task>> getAll() async {
    final db = await AppDatabase.instance;
    final rows = await db.query('tasks', orderBy: 'id ASC');
    return rows.map(Task.fromMap).toList();
  }

  @override
  Future<int> insert(Task task) async {
    final db = await AppDatabase.instance;
    return db.insert('tasks', task.toMap());
  }

  @override
  Future<void> update(Task task) async {
    final db = await AppDatabase.instance;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await AppDatabase.instance;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
