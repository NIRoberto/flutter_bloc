import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/sqlite_user_repository.dart';
import '../../data/user_repository.dart';
import '../../models/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Manages local user authentication (sign-up, login, logout, profile edit).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({UserRepository? repository})
      : _repository = repository ?? SqliteUserRepository(),
        super(const AuthInitial()) {
    on<SignUp>(_onSignUp);
    on<LogIn>(_onLogIn);
    on<LogOut>(_onLogOut);
    on<UpdateProfile>(_onUpdateProfile);
  }

  final UserRepository _repository;

  /// The currently signed-in user, or `null` when browsing anonymously.
  User? get currentUser => switch (state) {
        Authenticated(:final user) => user,
        _ => null,
      };

  Future<void> _onSignUp(SignUp event, Emitter<AuthState> emit) async {
    try {
      final now = DateTime.now();
      final pending = User(
        name: event.name.trim(),
        email: event.email.trim().toLowerCase(),
        createdAt: now,
      );
      final created = await _repository.create(pending);
      final hashed = SqliteUserRepository.hashPassword(event.password, userId: created.id);
      final userWithHash = created.copyWith(passwordHash: hashed, createdAt: now);
      await _repository.update(userWithHash);
      emit(Authenticated(userWithHash));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogIn(LogIn event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthInitial());
      final user = await _repository.findByEmail(event.email);
      if (user == null) {
        emit(const AuthError('No account found with that email address.'));
        return;
      }
      final expected = SqliteUserRepository.hashPassword(event.password, userId: user.id);
      if (user.passwordHash != expected) {
        emit(const AuthError('Incorrect password. Please try again.'));
        return;
      }
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogOut(LogOut event, Emitter<AuthState> emit) {
    emit(const Unauthenticated());
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<AuthState> emit) async {
    try {
      final user = currentUser;
      if (user == null) return;
      final updated = user.copyWith(name: event.name.trim());
      await _repository.update(updated);
      emit(Authenticated(updated));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}