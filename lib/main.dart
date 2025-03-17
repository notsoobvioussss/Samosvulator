import 'dart:async';
import 'dart:io'; // Проверка платформы
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:samosvulator/presentation/screens/change_password_screen.dart';
import 'package:samosvulator/presentation/screens/forgot_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:background_fetch/background_fetch.dart';

import 'package:samosvulator/presentation/screens/main_screen.dart';
import 'package:samosvulator/presentation/screens/register_screen.dart';
import 'package:samosvulator/presentation/screens/login_screen.dart';
import 'package:samosvulator/presentation/blocs/auth_bloc.dart';

import 'package:samosvulator/domain/usecases/login_usecase.dart';
import 'package:samosvulator/domain/usecases/register_usecase.dart';
import 'package:samosvulator/data/repositories/auth_repository_impl.dart';
import 'package:samosvulator/data/datasources/auth_remote_data_source.dart';

import 'core/network/dio_client.dart';
import 'core/utils/hive_init.dart';

import 'package:samosvulator/data/repositories/calculation_repository.dart';
import 'package:samosvulator/data/datasources/calculations_local_data_source.dart';
import 'package:samosvulator/data/datasources/calculations_remote_data_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("token");

  final dio = Dio();
  final dioClient = DioClient(dio);

  final authRemoteDataSource = AuthRemoteDataSource(dio: dio);
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  // ✅ Фоновая синхронизация
  initBackgroundFetch();

  runApp(
    MyApp(
      isLoggedIn: token != null,
      authRepository: authRepository,
      dioClient: dioClient,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final AuthRepositoryImpl authRepository;
  final DioClient dioClient;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.authRepository,
    required this.dioClient,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        loginUseCase: LoginUseCase(repository: authRepository),
        registerUseCase: RegisterUseCase(repository: authRepository),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: isLoggedIn ? "/main" : "/login",
        routes: {
          "/login": (context) => LoginScreen(),
          "/register": (context) => RegisterScreen(),
          "/main": (context) => MainScreen(dioClient: dioClient),
          "/forgot-password": (context) => ForgotPasswordScreen(),
          "/change-password": (context) => ChangePasswordScreen(dioClient: dioClient),
        },
      ),
    );
  }
}

/// 🔹 Инициализация Background Fetch
void initBackgroundFetch() {
  BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 30, // Интервал в минутах
      stopOnTerminate: false,   // Работает после закрытия
      enableHeadless: true,     // Работает в фоне
      startOnBoot: true,        // Запуск после перезагрузки устройства
      requiredNetworkType: NetworkType.ANY,
    ), (String taskId) async {
    print("⚡ Background fetch запущен: $taskId");

    final dio = Dio();
    final dioClient = DioClient(dio);
    final localDataSource = CalculationsLocalDataSource(Hive.box("calculations"));
    final remoteDataSource = CalculationsRemoteDataSource(dioClient);
    final calculationRepository = CalculationRepository(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    await calculationRepository.syncCalculations();

    BackgroundFetch.finish(taskId);
  },
        (String taskId) async {
      print("❌ Background fetch ошибка: $taskId");
      BackgroundFetch.finish(taskId);
    },
  );
}