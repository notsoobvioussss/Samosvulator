import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:samosvulator/presentation/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:samosvulator/presentation/screens/register_screen.dart';
import 'package:samosvulator/presentation/screens/login_screen.dart';
import 'package:samosvulator/presentation/screens/home_screen.dart';
import 'package:samosvulator/presentation/blocs/auth_bloc.dart';
import 'package:samosvulator/domain/usecases/login_usecase.dart';
import 'package:samosvulator/domain/usecases/register_usecase.dart';
import 'package:samosvulator/data/repositories/auth_repository_impl.dart';
import 'package:samosvulator/data/datasources/auth_remote_data_source.dart';

import 'core/network/dio_client.dart';
import 'core/utils/hive_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ 1. Инициализируем Hive
  await initHive();
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("token");

  // Инициализируем Dio
  final dio = Dio();
  final dioClient = DioClient(dio); // Создаём DioClient

  // Создаем удаленный источник данных
  final authRemoteDataSource = AuthRemoteDataSource(dio: dio);

  // Создаем репозиторий
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create:
              (context) => AuthBloc(
                loginUseCase: LoginUseCase(repository: authRepository),
                registerUseCase: RegisterUseCase(repository: authRepository),
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: isLoggedIn ? "/main" : "/login",
        routes: {
          "/login": (context) => LoginScreen(),
          "/register": (context) => RegisterScreen(),
          "/main": (context) => MainScreen(dioClient: dioClient), // ✅ Теперь `MainScreen`
        },
      ),
    );
  }
}
