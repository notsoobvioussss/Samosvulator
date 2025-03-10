import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource({required this.dio}) {
    dio.options.baseUrl = "https://api.tomikartemik.ru"; // Указываем базовый URL
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await dio.post(
        "/user/sign-in",
        data: {
          "username": username,
          "password": password,
        },
      );
      print("Login Response: ${response.data}"); // ✅ Логируем ответ
      return response.data;
    } catch (e) {
      print("Login Error: $e"); // ✅ Логируем ошибку
      throw Exception("Ошибка при входе: $e");
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post(
        "/user/sign-up",
        data: userData,
      );
      print("Register Response: ${response.data}"); // ✅ Логируем ответ
    } catch (e) {
      print("Register Error: $e"); // ✅ Логируем ошибку
      throw Exception("Ошибка при регистрации: $e");
    }
  }
}