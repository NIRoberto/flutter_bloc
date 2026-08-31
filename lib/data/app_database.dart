import 'package:sqflite/sqflite.dart';

/// Owns the SQLite database connection and schema.
///
/// Uses the global sqflite factory by default, so tests can swap in an
/// in-memory factory via [overrideFactory] before first access.
class AppDatabase {
  AppDatabase._();

  static const _databaseName = 'focus_leaf.db';
  static const _databaseVersion = 3;

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
        onUpgrade: _onUpgrade,
      ),
    );
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createTimerPrefs(db);
    if (oldVersion < 3) {
      await _createUsers(db);
      await _createFocusSessions(db);
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await _createTimerPrefs(db);
    await _createUsers(db);
    await _createFocusSessions(db);
  }

  static Future<void> _createTimerPrefs(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS timer_prefs (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createUsers(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createFocusSessions(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS focus_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        mode TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        completed_at INTEGER NOT NULL
      )
    ''');
  }
}
