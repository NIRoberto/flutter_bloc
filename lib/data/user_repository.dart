import '../models/user.dart';

/// Abstraction over user persistence so the auth bloc can be tested in isolation.
abstract class UserRepository {
  /// Creates a new user account. Returns the new user (with its id).
  ///
  /// Throws a [StateError] if the email is already registered.
  Future<User> create(User user);

  /// Looks up a user by email. Returns null when not found.
  Future<User?> findByEmail(String email);

  /// Looks up a user by id. Returns null when not found.
  Future<User?> findById(int id);

  /// Updates the given user's details (used for profile edits).
  Future<void> update(User user);
}