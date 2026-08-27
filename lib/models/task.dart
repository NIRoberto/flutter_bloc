/// A single task in the user's todo list.
class Task {
  Task({this.id, required this.title, this.isDone = false});

  final int? id;
  final String title;
  bool isDone;

  Task copyWith({int? id, String? title, bool? isDone}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  /// Builds a [Task] from a SQLite row map.
  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      isDone: (map['is_done'] as int? ?? 0) == 1,
    );
  }

  /// Converts this task into a map that can be stored in SQLite.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'is_done': isDone ? 1 : 0,
    };
  }
}
