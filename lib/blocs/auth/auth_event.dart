import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class SignUp extends AuthEvent {
  const SignUp({required this.name, required this.email, required this.password});

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

final class LogIn extends AuthEvent {
  const LogIn({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class LogOut extends AuthEvent {
  const LogOut();
}

final class UpdateProfile extends AuthEvent {
  const UpdateProfile({required this.name});

  final String name;

  @override
  List<Object?> get props => [name];
}