import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focus_leaf/app.dart';
import 'package:focus_leaf/data/task_repository.dart';
import 'package:focus_leaf/models/task.dart';

/// A simple in-memory repository so widget tests avoid real SQLite IO.
class InMemoryTaskRepository implements TaskRepository {
  final Map<int, Task> _store = {};
  int _nextId = 1;

  @override
  Future<List<Task>> getAll() async => _store.values.toList();

  @override
  Future<int> insert(Task task) async {
    final id = _nextId++;
    _store[id] = task.copyWith(id: id);
    return id;
  }

  @override
  Future<void> update(Task task) async {
    if (task.id != null) _store[task.id!] = task;
  }

  @override
  Future<void> delete(int id) async {
    _store.remove(id);
  }
}

void main() {
  testWidgets('Focus Leaf shows title and navigation', (WidgetTester tester) async {
    await tester.pumpWidget(FocusLeafApp(taskRepository: InMemoryTaskRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Focus Leaf'), findsOneWidget);
    expect(find.text('Today’s Progress'), findsOneWidget);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('Task list'), findsNothing);

    await tester.tap(find.text('Focus'));
    await tester.pumpAndSettle();
    expect(find.text('Focus Timer'), findsOneWidget);
  });

  testWidgets('Adding a task works', (WidgetTester tester) async {
    await tester.pumpWidget(FocusLeafApp(taskRepository: InMemoryTaskRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Read a book');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text('Read a book'), findsOneWidget);
  });
}
