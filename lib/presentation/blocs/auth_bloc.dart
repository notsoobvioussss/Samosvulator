import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../core/storage/local_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({required this.loginUseCase, required this.registerUseCase})
      : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase.call(event.username, event.password);

        await LocalStorage.saveToken(user.token);
        await LocalStorage.saveUserId(user.id);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = User(
          id: 0,
          username: event.username,
          name: event.name,
          surname: event.surname,
          company: event.company,
          section: event.section,
          jobTitle: event.jobTitle,
          token: '',
        );
        await registerUseCase(user: user, password: event.password); // Исправленный вызов
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent({required this.username, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String password;
  final String name;
  final String surname;
  final String company;
  final String section;
  final String jobTitle;

  RegisterEvent({
    required this.username,
    required this.password,
    required this.name,
    required this.surname,
    required this.company,
    required this.section,
    required this.jobTitle,
  });
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}