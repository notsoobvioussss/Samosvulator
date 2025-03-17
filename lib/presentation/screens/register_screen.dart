import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
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
        title: const Text("Регистрация"),
        automaticallyImplyLeading: false, // Убираем стрелку назад
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
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
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Имя"),
                  validator: (value) => value!.isEmpty ? "Введите имя" : null,
                ),
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: "Фамилия"),
                  validator:
                      (value) => value!.isEmpty ? "Введите фамилию" : null,
                ),
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: "Компания"),
                ),
                TextFormField(
                  controller: _sectionController,
                  decoration: const InputDecoration(labelText: "Отдел"),
                ),
                TextFormField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(labelText: "Должность"),
                ),
                const SizedBox(height: 16),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      Navigator.pushReplacementNamed(context, "/login");
                    } else if (state is AuthFailure) {
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
                            RegisterEvent(
                              username: _emailController.text,
                              // Email вместо username
                              password: _passwordController.text,
                              name: _nameController.text,
                              surname: _surnameController.text,
                              company: _companyController.text,
                              section: _sectionController.text,
                              jobTitle: _jobTitleController.text,
                            ),
                          );
                        }
                      },
                      child: const Text("Зарегистрироваться"),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
