import 'package:samosvulator/data/datasources/auth_remote_data_source.dart';
import 'package:samosvulator/domain/entities/user.dart';
import 'package:samosvulator/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login(String username, String password) async {
    final response = await remoteDataSource.login(username, password);

    final userData = response['user']; // Достаём объект user из ответа
    final token = response['token'] ?? ''; // Достаём токен

    return User(
      id: userData['id'] ?? 0,  // Должно быть userData, а не userModel
      username: userData['username'] ?? '',
      name: userData['name'] ?? '',
      surname: userData['surname'] ?? '',
      company: userData['company'] ?? '',
      section: userData['section'] ?? '',
      jobTitle: userData['job_title'] ?? '',
      token: token, // Теперь токен берётся из response, а не userData
    );
  }

  @override
  Future<void> register({required User user, required String password}) async {
    await remoteDataSource.register({
      "username": user.username,
      "password": password, // Передаем пароль
      "name": user.name,
      "surname": user.surname,
      "company": user.company,
      "section": user.section,
      "job_title": user.jobTitle,
    });
  }
}