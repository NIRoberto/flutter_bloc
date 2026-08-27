import 'package:equatable/equatable.dart';

/// Immutable snapshot of the focus timer.
class TimerState extends Equatable {
  const TimerState({
    this.secondsLeft = 0,
    this.isRunning = false,
  });

  /// Total length of a focus session in seconds.
  static const focusLength = 25 * 60;

  /// Seconds remaining in the current session.
  final int secondsLeft;

  /// Whether the countdown is currently running.
  final bool isRunning;

  String get formatted {
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get progress => 1 - secondsLeft / focusLength;

  TimerState copyWith({int? secondsLeft, bool? isRunning}) {
    return TimerState(
      secondsLeft: secondsLeft ?? this.secondsLeft,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  List<Object?> get props => [secondsLeft, isRunning];
}
