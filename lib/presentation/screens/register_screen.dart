import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Логин"),
                  validator: (value) =>
                  value!.isEmpty ? "Введите логин" : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Пароль"),
                  obscureText: true,
                  validator: (value) =>
                  value!.isEmpty ? "Введите пароль" : null,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Имя"),
                ),
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: "Фамилия"),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(RegisterEvent(
                            username: _usernameController.text,
                            password: _passwordController.text,
                            name: _nameController.text,
                            surname: _surnameController.text,
                            company: _companyController.text,
                            section: _sectionController.text,
                            jobTitle: _jobTitleController.text,
                          ));
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