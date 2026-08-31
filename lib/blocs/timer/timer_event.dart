import 'package:equatable/equatable.dart';

import 'timer_state.dart';

sealed class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

final class ToggleTimer extends TimerEvent {
  const ToggleTimer();
}

final class ResetTimer extends TimerEvent {
  const ResetTimer();
}

final class TickTimer extends TimerEvent {
  const TickTimer();
}

final class SelectMode extends TimerEvent {
  const SelectMode(this.mode);
  final FocusMode mode;

  @override
  List<Object?> get props => [mode];
}

final class LoadTimer extends TimerEvent {
  const LoadTimer();
}
