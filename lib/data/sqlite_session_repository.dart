import '../models/focus_session.dart';
import 'session_repository.dart';
import 'app_database.dart';

/// SQLite-backed implementation of [SessionRepository].
class SqliteSessionRepository implements SessionRepository {
  @override
  Future<void> add(FocusSession session) async {
    final db = await AppDatabase.instance;
    await db.insert('focus_sessions', session.toMap());
  }

  @override
  Future<List<FocusSession>> all({int? userId}) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'focus_sessions',
      where: userId == null ? null : 'user_id = ?',
      whereArgs: userId == null ? null : [userId],
      orderBy: 'completed_at DESC',
    );
    return rows.map(FocusSession.fromMap).toList();
  }

  @override
  Future<List<FocusSession>> since(DateTime start, {int? userId}) async {
    final db = await AppDatabase.instance;
    final args = <Object?>[];
    final where = <String>['completed_at >= ?'];
    args.add(start.millisecondsSinceEpoch);
    if (userId != null) {
      where.add('user_id = ?');
      args.add(userId);
    }
    final rows = await db.query(
      'focus_sessions',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'completed_at ASC',
    );
    return rows.map(FocusSession.fromMap).toList();
  }
}