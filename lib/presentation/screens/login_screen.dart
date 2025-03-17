import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Функция валидации email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Введите email";
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return "Введите корректный email";
    }
    return null;
  }

  /// Функция валидации пароля
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Введите пароль";
    }
    if (value.length < 6) {
      return "Пароль должен содержать минимум 6 символов";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Вход"),
        automaticallyImplyLeading: false, // Убираем стрелку назад
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email"),
                validator: _validateEmail,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Пароль"),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 8),

              // Кнопка "Забыли пароль?"
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/forgot-password");
                  },
                  child: const Text("Забыли пароль?"),
                ),
              ),

              const SizedBox(height: 16),

              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushReplacementNamed(context, "/main");
                  } else if (state is AuthFailure) {
                    // Показываем ошибку через SnackBar
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          LoginEvent(
                            username: _emailController.text,
                            // Email вместо username
                            password: _passwordController.text,
                          ),
                        );
                      }
                    },
                    child: const Text("Войти"),
                  );
                },
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/register");
                },
                child: const Text("Нет аккаунта? Зарегистрируйтесь"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
