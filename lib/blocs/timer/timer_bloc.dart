import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'timer_event.dart';
import 'timer_state.dart';

/// A focus countdown timer (Pomodoro-style, default 25 minutes).
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc() : super(TimerState(secondsLeft: TimerState.focusLength)) {
    on<ToggleTimer>(_onToggle);
    on<ResetTimer>(_onReset);
    on<TickTimer>(_onTick);
  }

  Timer? _ticker;

  void _onToggle(ToggleTimer event, Emitter<TimerState> emit) {
    if (state.isRunning) {
      _ticker?.cancel();
      _ticker = null;
      emit(state.copyWith(isRunning: false));
    } else {
      _ticker = Timer.periodic(
        const Duration(seconds: 1),
        (_) => add(const TickTimer()),
      );
      emit(state.copyWith(isRunning: true));
    }
  }

  void _onReset(ResetTimer event, Emitter<TimerState> emit) {
    _ticker?.cancel();
    _ticker = null;
    emit(
      TimerState(
        secondsLeft: TimerState.focusLength,
        isRunning: false,
      ),
    );
  }

  void _onTick(TickTimer event, Emitter<TimerState> emit) {
    if (state.secondsLeft <= 1) {
      _ticker?.cancel();
      _ticker = null;
      emit(
        TimerState(
          secondsLeft: TimerState.focusLength,
          isRunning: false,
        ),
      );
    } else {
      emit(state.copyWith(secondsLeft: state.secondsLeft - 1));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _ticker = null;
    return super.close();
  }
}
