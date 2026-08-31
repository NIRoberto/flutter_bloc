import 'package:equatable/equatable.dart';

enum FocusMode { pomodoro, deepWork, ultradian }

enum TimerPhase { focus, breakTime }

extension FocusModeX on FocusMode {
  String get label => switch (this) {
        FocusMode.pomodoro => 'Pomodoro',
        FocusMode.deepWork => 'Deep Work',
        FocusMode.ultradian => 'Ultradian',
      };

  String get description => switch (this) {
        FocusMode.pomodoro => '25 min focus · 5 min break',
        FocusMode.deepWork => '60 min focus · 15 min break',
        FocusMode.ultradian => '90 min focus · 20 min break',
      };

  int get focusSeconds => switch (this) {
        FocusMode.pomodoro => 25 * 60,
        FocusMode.deepWork => 60 * 60,
        FocusMode.ultradian => 90 * 60,
      };

  int get breakSeconds => switch (this) {
        FocusMode.pomodoro => 5 * 60,
        FocusMode.deepWork => 15 * 60,
        FocusMode.ultradian => 20 * 60,
      };

  int get dailyGoal => switch (this) {
        FocusMode.pomodoro => 8,
        FocusMode.deepWork => 5,
        FocusMode.ultradian => 4,
      };
}

class TimerState extends Equatable {
  const TimerState({
    this.mode = FocusMode.pomodoro,
    this.phase = TimerPhase.focus,
    this.secondsLeft = 25 * 60,
    this.isRunning = false,
    this.sessionsCompleted = 0,
  });

  final FocusMode mode;
  final TimerPhase phase;
  final int secondsLeft;
  final bool isRunning;
  final int sessionsCompleted;

  int get totalSeconds =>
      phase == TimerPhase.focus ? mode.focusSeconds : mode.breakSeconds;

  double get progress => 1 - secondsLeft / totalSeconds;

  String get formatted {
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  TimerState copyWith({
    FocusMode? mode,
    TimerPhase? phase,
    int? secondsLeft,
    bool? isRunning,
    int? sessionsCompleted,
  }) {
    return TimerState(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      isRunning: isRunning ?? this.isRunning,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
    );
  }

  @override
  List<Object?> get props =>
      [mode, phase, secondsLeft, isRunning, sessionsCompleted];
}
