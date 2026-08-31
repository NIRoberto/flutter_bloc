/// A record of one completed focus session (timer finished a focus phase).
class FocusSession {
  FocusSession({
    this.id,
    this.userId,
    required this.mode,
    required this.durationMinutes,
    required this.completedAt,
  });

  final int? id;

  /// Id of the user who completed the session, or null for anonymous sessions.
  final int? userId;

  /// The focus mode this session used (matches [FocusMode])
  final String mode;
  final int durationMinutes;
  final DateTime completedAt;

  /// Builds a [FocusSession] from a SQLite row map.
  factory FocusSession.fromMap(Map<String, Object?> map) {
    return FocusSession(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      mode: map['mode'] as String,
      durationMinutes: map['duration_minutes'] as int,
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int),
    );
  }

  /// Converts this session into a map that can be stored in SQLite.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'mode': mode,
      'duration_minutes': durationMinutes,
      'completed_at': completedAt.millisecondsSinceEpoch,
    };
  }
}