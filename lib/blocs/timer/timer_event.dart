import 'package:equatable/equatable.dart';

/// Events that drive the focus timer.
sealed class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

/// Starts or pauses the countdown.
final class ToggleTimer extends TimerEvent {
  const ToggleTimer();
}

/// Resets the countdown to its initial length.
final class ResetTimer extends TimerEvent {
  const ResetTimer();
}

/// Advances the countdown by one second.
final class TickTimer extends TimerEvent {
  const TickTimer();
}
