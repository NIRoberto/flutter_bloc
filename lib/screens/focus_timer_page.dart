import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/timer/timer_bloc.dart';
import '../blocs/timer/timer_event.dart';
import '../blocs/timer/timer_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class FocusTimerPage extends StatelessWidget {
  const FocusTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final isBreak = state.phase == TimerPhase.breakTime;
        final accent =
            isBreak ? const Color(0xFF1565C0) : AppTheme.seedColor;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: isBreak
              ? const Color(0xFFF0F4FF)
              : const Color(0xFFF7F9F7),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  _TopBar(state: state, accent: accent),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _PhaseChip(isBreak: isBreak, accent: accent),
                          const SizedBox(height: 28),
                          _Dial(state: state, accent: accent),
                          const SizedBox(height: 28),
                          _SessionTrack(
                            completed: state.sessionsCompleted,
                            goal: state.mode.dailyGoal,
                            accent: accent,
                          ),
                          const SizedBox(height: 32),
                          _Controls(
                              state: state, accent: accent, isBreak: isBreak),
                          if (isBreak) ...[
                            const SizedBox(height: 14),
                            _SkipBreakButton(accent: accent),
                          ],
                          const SizedBox(height: 24),
                          _SoundSelector(accent: accent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state, required this.accent});
  final TimerState state;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: FocusMode.values.map((mode) {
        final selected = mode == state.mode;
        final enabled = !state.isRunning;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: mode != FocusMode.values.last ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: enabled
                  ? () {
                      HapticFeedback.selectionClick();
                      context.read<TimerBloc>().add(SelectMode(mode));
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? accent : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? accent
                        : Colors.black.withValues(alpha: 0.07),
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      mode.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.isBreak, required this.accent});
  final bool isBreak;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: Container(
        key: ValueKey(isBreak),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBreak
                  ? Icons.coffee_rounded
                  : Icons.center_focus_strong_rounded,
              size: 15,
              color: accent,
            ),
            const SizedBox(width: 6),
            Text(
              isBreak ? 'Break Time' : 'Focus Session',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({required this.state, required this.accent});
  final TimerState state;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              // Clamp 0 => tiny positive value: Flutter renders value 0.0 as an
              // indeterminate (infinitely animating) spinner, which breaks
              // pumpAndSettle and looks wrong at the "ready" state.
              value: state.progress <= 0 ? 0.001 : state.progress,
              strokeWidth: 9,
              strokeCap: StrokeCap.round,
              backgroundColor: accent.withValues(alpha: 0.08),
              color: accent,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.formatted,
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      key: ValueKey(state.isRunning),
                      state.progress <= 0
                          ? 'Ready'
                          : state.isRunning
                              ? 'In progress'
                              : 'Paused',
                      style: TextStyle(
                        fontSize: 12,
                        color: state.isRunning ? accent : AppTheme.muted,
                        fontWeight: state.isRunning
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTrack extends StatelessWidget {
  const _SessionTrack({
    required this.completed,
    required this.goal,
    required this.accent,
  });
  final int completed;
  final int goal;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(goal, (i) {
            final done = i < completed;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: done ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: done ? accent : accent.withValues(alpha: 0.15),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '$completed of $goal sessions completed today',
          style: const TextStyle(fontSize: 12, color: AppTheme.muted),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.state,
    required this.accent,
    required this.isBreak,
  });
  final TimerState state;
  final Color accent;
  final bool isBreak;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<TimerBloc>().add(const ResetTimer());
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.refresh_rounded,
                size: 22, color: AppTheme.muted),
          ),
        ),
        const SizedBox(width: 20),
        // Play / Pause
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            context.read<TimerBloc>().add(const ToggleTimer());
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.85),
                  accent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              state.isRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              size: 34,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Placeholder for symmetry
        const SizedBox(width: 52, height: 52),
      ],
    );
  }
}

class _SkipBreakButton extends StatelessWidget {
  const _SkipBreakButton({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<TimerBloc>().add(const ResetTimer());
      },
      child: Text(
        'Skip break',
        style: TextStyle(
          fontSize: 13,
          color: accent.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: accent.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _SoundSelector extends StatefulWidget {
  const _SoundSelector({required this.accent});
  final Color accent;

  @override
  State<_SoundSelector> createState() => _SoundSelectorState();
}

class _SoundSelectorState extends State<_SoundSelector> {
  final _soundService = SoundService.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volume_up_rounded, size: 16, color: widget.accent.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              'Ambient sound',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.accent.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: AmbientSound.values.map((sound) {
            final selected = _soundService.current == sound;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  if (selected) {
                    await _soundService.stop();
                  } else {
                    await _soundService.play(sound);
                  }
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? widget.accent : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? widget.accent
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    sound.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppTheme.muted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
