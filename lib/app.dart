import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/task/task_bloc.dart';
import 'blocs/task/task_event.dart';
import 'blocs/timer/timer_bloc.dart';
import 'data/task_repository.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

/// Root widget of the application.
///
/// Wires up all the app-level blocs before showing the [HomeShell].
class FocusLeafApp extends StatelessWidget {
  const FocusLeafApp({super.key, this.taskRepository});

  /// Optional repository override, used by tests to inject an in-memory store.
  final TaskRepository? taskRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(
          create: (_) => TaskBloc(repository: taskRepository)
            ..add(const LoadTasks()),
        ),
        BlocProvider(create: (_) => TimerBloc()),
      ],
      child: MaterialApp(
        title: 'Focus Leaf',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        home: const HomeShell(),
      ),
    );
  }
}
