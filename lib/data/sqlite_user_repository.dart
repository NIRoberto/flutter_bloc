import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/user.dart';
import 'app_database.dart';
import 'user_repository.dart';

/// SQLite-backed implementation of [UserRepository].
class SqliteUserRepository implements UserRepository {
  /// Hashes a plaintext password to a secure salted SHA-256 digest.
  /// The salt is derived deterministically from the user id and a fixed salt.
  static String hashPassword(String password, {int? userId}) {
    final salt = (userId?.toString() ?? 'focus_leaf').trim();
    final key = utf8.encode('$salt::$password');
    return sha256.convert(key).toString();
  }

  @override
  Future<User> create(User user) async {
    final db = await AppDatabase.instance;
    if (user.email.trim().isEmpty) {
      throw StateError('Email is required.');
    }
    final existing = await findByEmail(user.email);
    if (existing != null) {
      throw StateError('An account with this email already exists.');
    }
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  @override
  Future<User?> findByEmail(String email) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  @override
  Future<User?> findById(int id) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  @override
  Future<void> update(User user) async {
    final db = await AppDatabase.instance;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}