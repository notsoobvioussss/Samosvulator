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

    // 🔹 Вход в систему
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase.call(event.username, event.password);

        if (user.token.isEmpty) {
          throw Exception("Неправильный логин или пароль");
        }

        await LocalStorage.saveToken(user.token);
        await LocalStorage.saveUserId(user.id);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(_mapErrorToMessage(e.toString())));
      }
    });

    // 🔹 Регистрация нового пользователя
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

        await registerUseCase(user: user, password: event.password);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(_mapErrorToMessage(e.toString())));
      }
    });

    // 🔹 Проверка токена (авто-разлогин если токен невалиден)
    on<CheckAuthEvent>((event, emit) async {
      final token = await LocalStorage.getToken();
      if (token == null || token.isEmpty) {
        emit(AuthInitial());
      } else {
        emit(AuthSuccess());
      }
    });
  }

  /// 🔹 Обрабатываем ошибки сервера и API
  String _mapErrorToMessage(String error) {
    if (error.contains("401")) {
      return "Неправильный логин или пароль";
    } else if (error.contains("409")) {
      return "Такой пользователь уже существует";
    } else if (error.contains("500")) {
      return "Ошибка сервера. Попробуйте позже";
    }
    return "Произошла ошибка. Попробуйте ещё раз";
  }
}

/// 🔹 События (Events)
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


/// 🔹 Событие проверки токена (авто-разлогин)
class CheckAuthEvent extends AuthEvent {}

/// 🔹 Состояния (States)
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}