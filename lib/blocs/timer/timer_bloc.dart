import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sqflite/sqflite.dart';

import '../../data/app_database.dart';
import '../../data/sqlite_session_repository.dart';
import '../../models/focus_session.dart';
import '../../services/notification_service.dart';
import 'timer_event.dart';
import 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc() : super(const TimerState()) {
    on<LoadTimer>(_onLoad);
    on<SelectMode>(_onSelectMode);
    on<ToggleTimer>(_onToggle);
    on<ResetTimer>(_onReset);
    on<TickTimer>(_onTick);
    add(const LoadTimer());
  }

  Timer? _ticker;
  final _sessionRepo = SqliteSessionRepository();
  final _notifications = NotificationService.instance;

  static const _keyMode = 'timer_mode';
  static const _keySessions = 'timer_sessions';
  static const _keyDate = 'timer_date';

  Future<String?> _get(String key) async {
    final db = await AppDatabase.instance;
    final rows = await db.query('timer_prefs', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> _set(String key, String value) async {
    final db = await AppDatabase.instance;
    await db.insert(
      'timer_prefs',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> _onLoad(LoadTimer event, Emitter<TimerState> emit) async {
    final today = _todayKey();
    final savedDate = await _get(_keyDate) ?? '';
    final sessions = savedDate == today ? int.tryParse(await _get(_keySessions) ?? '0') ?? 0 : 0;

    if (savedDate != today) {
      await _set(_keyDate, today);
      await _set(_keySessions, '0');
    }

    final modeIndex = int.tryParse(await _get(_keyMode) ?? '0') ?? 0;
    final mode = FocusMode.values[modeIndex.clamp(0, FocusMode.values.length - 1)];

    emit(TimerState(mode: mode, secondsLeft: mode.focusSeconds, sessionsCompleted: sessions));
  }

  void _onSelectMode(SelectMode event, Emitter<TimerState> emit) {
    _ticker?.cancel();
    _ticker = null;
    _set(_keyMode, event.mode.index.toString());
    emit(TimerState(
      mode: event.mode,
      secondsLeft: event.mode.focusSeconds,
      sessionsCompleted: state.sessionsCompleted,
    ));
  }

  void _onToggle(ToggleTimer event, Emitter<TimerState> emit) {
    if (state.isRunning) {
      _ticker?.cancel();
      _ticker = null;
      emit(state.copyWith(isRunning: false));
    } else {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => add(const TickTimer()));
      emit(state.copyWith(isRunning: true));
    }
  }

  void _onReset(ResetTimer event, Emitter<TimerState> emit) {
    _ticker?.cancel();
    _ticker = null;
    emit(TimerState(
      mode: state.mode,
      phase: TimerPhase.focus,
      secondsLeft: state.mode.focusSeconds,
      isRunning: false,
      sessionsCompleted: state.sessionsCompleted,
    ));
  }

  void _onTick(TickTimer event, Emitter<TimerState> emit) {
    if (state.secondsLeft <= 1) {
      _ticker?.cancel();
      _ticker = null;

      final wasFocus = state.phase == TimerPhase.focus;
      final newSessions = wasFocus ? state.sessionsCompleted + 1 : state.sessionsCompleted;
      final nextPhase = wasFocus ? TimerPhase.breakTime : TimerPhase.focus;
      final nextSeconds = wasFocus ? state.mode.breakSeconds : state.mode.focusSeconds;

      if (wasFocus) {
        _set(_keySessions, newSessions.toString());
        _set(_keyDate, _todayKey());

        // Record the completed focus session in the database.
        _sessionRepo.add(FocusSession(
          mode: state.mode.name,
          durationMinutes: state.mode.focusSeconds ~/ 60,
          completedAt: DateTime.now(),
        ));

        // Notify the user.
        _notifications.showFocusComplete(
          title: 'Focus session complete!',
          body: 'Great work! Time for a ${state.mode.breakSeconds ~/ 60}-minute break.',
        );
      } else {
        // Break finished — notify the user to return.
        _notifications.showFocusComplete(
          title: 'Break is over',
          body: 'Ready for another ${state.mode.focusSeconds ~/ 60}-minute focus session?',
        );
      }

      emit(state.copyWith(
        phase: nextPhase,
        secondsLeft: nextSeconds,
        isRunning: false,
        sessionsCompleted: newSessions,
      ));
    } else {
      emit(state.copyWith(secondsLeft: state.secondsLeft - 1));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
