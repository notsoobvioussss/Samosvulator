import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Вход"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Логин"),
                validator: (value) => value!.isEmpty ? "Введите логин" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Пароль"),
                obscureText: true,
                validator: (value) => value!.isEmpty ? "Введите пароль" : null,
              ),
              const SizedBox(height: 16),

              // Оборачиваем в BlocBuilder для правильного рендеринга
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Отправляем событие в AuthBloc
                        context.read<AuthBloc>().add(
                          LoginEvent(
                            username: _usernameController.text,
                            password: _passwordController.text,
                          ),
                        );
                      }
                    },
                    child: const Text("Войти"),
                  );
                },
              ),

              // Обрабатываем ошибки через BlocListener
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushReplacementNamed(context, "/main");
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                child: const SizedBox(),
              ),

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
