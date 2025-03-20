import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  /// **Функция восстановления пароля**
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://samosvulator.sytes.net/user/change-password',
        queryParameters: {'username': _emailController.text},
      );

      if (response.data == "OK!") {
        _showMessage(
          "✅ Проверьте вашу почту и папку спам, затем смените пароль в профиле.",
          Colors.green,
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, "/login");
          }
        });
      } else {
        _showMessage("❌ Ошибка: ${response.data}", Colors.red);
      }
    } catch (e) {
      _showMessage("❌ Не удалось отправить запрос: $e", Colors.red);
    }

    setState(() => _isLoading = false);
  }

  /// **Показ Snackbar с сообщением**
  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Восстановление пароля"),
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
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Введите email";
                  }
                  if (!RegExp(
                    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                  ).hasMatch(value)) {
                    return "Некорректный email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _resetPassword,
                    child: const Text("Отправить запрос"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
