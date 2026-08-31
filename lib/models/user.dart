/// A registered user account, stored locally on-device.
class User {
  User({
    this.id,
    required this.name,
    required this.email,
    this.passwordHash,
    this.createdAt,
  });

  final int? id;
  final String name;
  final String email;

  /// SHA-256 hash of the user's password. `null` when constructing a fresh
  /// user before the hash is computed, or for read models that omit it.
  final String? passwordHash;
  final DateTime? createdAt;

  /// First name for personalised greetings (everything before the first space).
  String get firstName => name.trim().isEmpty ? 'there' : name.trim().split(' ').first;

  User copyWith({int? id, String? name, String? email, String? passwordHash, DateTime? createdAt}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Builds a [User] from a SQLite row map.
  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String?,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// Converts this user into a map that can be stored in SQLite.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (createdAt != null) 'created_at': createdAt!.millisecondsSinceEpoch,
    };
  }
}