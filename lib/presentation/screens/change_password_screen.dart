import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/dio_client.dart';

class ChangePasswordScreen extends StatefulWidget {
  final DioClient dioClient;

  const ChangePasswordScreen({super.key, required this.dioClient});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _showMessage(
          "Ошибка авторизации. Войдите в систему снова.",
          Colors.red,
        );
        return;
      }

      final response = await widget.dioClient.post(
        "/authorized/change-password",
        data: {
          "password": _currentPasswordController.text,
          "new_password": _newPasswordController.text,
        },
        token: token,
      );

      if (response.data == "Password Changed Successfully!") {
        _showMessage("✅ Пароль успешно изменён!", Colors.green);

        // Очищаем сохранённый токен и отправляем на логин
        await prefs.remove("token");
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, "/login");
        });
      } else {
        _showMessage("Ошибка: ${response.data}", Colors.red);
      }
    } catch (e) {
      _showMessage("❌ Ошибка при смене пароля.", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
        title: const Text("Смена пароля"),
        automaticallyImplyLeading: false,
      ),
      // Убираем стрелку назад),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(labelText: "Текущий пароль"),
                obscureText: true,
                validator:
                    (value) => value!.isEmpty ? "Введите текущий пароль" : null,
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: "Новый пароль"),
                obscureText: true,
                validator:
                    (value) =>
                        value!.length < 6
                            ? "Пароль должен быть не менее 6 символов"
                            : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text("Сменить пароль"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
