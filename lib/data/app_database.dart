import 'package:sqflite/sqflite.dart';

/// Owns the SQLite database connection and schema.
///
/// Uses the global sqflite factory by default, so tests can swap in an
/// in-memory factory via [overrideFactory] before first access.
class AppDatabase {
  AppDatabase._();

  static const _databaseName = 'focus_leaf.db';
  static const _databaseVersion = 1;

  static DatabaseFactory? _factoryOverride;

  /// Overrides the database factory (used by tests to provide an in-memory DB).
  static set overrideFactory(DatabaseFactory value) => _factoryOverride = value;

  static Database? _database;

  /// Returns the singleton database instance, creating it if needed.
  static Future<Database> get instance async {
    _database ??= await _open();
    return _database!;
  }

  static DatabaseFactory get _factory => _factoryOverride ?? databaseFactory;

  static Future<Database> _open() async {
    final factory = _factory;
    final dbPath = await factory.getDatabasesPath();
    final path = '$dbPath/$_databaseName';
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
      ),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
