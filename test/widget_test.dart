import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:focus_leaf/app.dart';
import 'package:focus_leaf/data/app_database.dart';
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

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(FocusLeafApp(taskRepository: InMemoryTaskRepository()));
  // Give the timer/DB blocs a moment to settle without blocking on the
  // offstage stats page's native DB query.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.overrideFactory = databaseFactoryFfi;
  });

  testWidgets('App opens on the Focus timer and navigates between tabs',
      (WidgetTester tester) async {
    await pumpApp(tester);

    // The app starts on the Focus tab (default) showing the timer dial.
    expect(find.text('Focus Session'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);

    // Navigate to the Home tab and check the dashboard appears.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text("Today's Progress"), findsOneWidget);

    // Navigate to Tasks.
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('My Tasks'), findsOneWidget);

    // Stats tab.
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('This week'), findsOneWidget);

    // Back to Focus (the centre tab is icon-only, no text label).
    await tester.tap(find.byIcon(Icons.self_improvement_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Focus Session'), findsOneWidget);
  });

  testWidgets('Adding a task works', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Read a book');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Read a book'), findsOneWidget);
  });
}