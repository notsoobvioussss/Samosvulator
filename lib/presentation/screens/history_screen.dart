import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/calculations_local_data_source.dart';
import '../../data/datasources/calculations_remote_data_source.dart';
import '../../data/repositories/calculation_repository.dart';
import '../../data/models/calculation_model.dart';

class HistoryScreen extends StatefulWidget {
  final DioClient dioClient;

  const HistoryScreen({super.key, required this.dioClient});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final CalculationRepository repo;
  late Future<List<CalculationModel>> _calculationsFuture;

  @override
  void initState() {
    super.initState();
    repo = CalculationRepository(
      localDataSource: CalculationsLocalDataSource(
        Hive.box<CalculationModel>('calculations'),
      ),
      remoteDataSource: CalculationsRemoteDataSource(widget.dioClient),
    );

    _calculationsFuture = _loadData();
  }

  Future<List<CalculationModel>> _loadData() async {
    await repo.syncCalculations(); // 🔹 Синхронизируем данные
    return repo.getCalculations(); // 🔹 Возвращаем данные для FutureBuilder
  }

  /// **Функция выхода с проверкой интернета, синхронизацией и очисткой базы**
  Future<void> _logout() async {
    bool hasInternet = await InternetConnectionChecker.createInstance().hasConnection;

    if (!hasInternet) {
      _showMessage("Нет подключения к интернету! Выход запрещен.");
      return;
    }

    // 🔄 Синхронизируем перед выходом
    _showLoadingDialog("Синхронизация отчетов...");
    try {
      await repo.syncCalculations();
      Navigator.pop(context); // Закрываем загрузочный диалог
    } catch (e) {
      Navigator.pop(context); // Закрываем загрузочный диалог
      _showMessage("Ошибка при синхронизации: $e");
      return;
    }

    // 🗑 Очищаем локальную базу данных
    await Hive.box<CalculationModel>('calculations').clear();

    // 🔑 Очищаем SharedPreferences (токен и ID пользователя)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 🚪 Выход в логин-экран
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// **Показ диалога загрузки**
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// **Показ Snackbar с сообщением**
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: const Text('История расчётов'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<List<CalculationModel>>(
        future: _calculationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final calculations = snapshot.data ?? [];

          if (calculations.isEmpty) {
            return const Center(child: Text('Нет сохранённых расчётов'));
          }

          return ListView.builder(
            itemCount: calculations.length,
            itemBuilder: (context, index) {
              final calc = calculations[index];
              final formattedDate = dateFormat.format(calc.date.toLocal());

              return Card(
                child: ListTile(
                  title: Text('Расчёт от $formattedDate'),
                  subtitle: Text('Экскаватор: ${calc.excavatorName}'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Расчёт от $formattedDate'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('''
Название экскаватора: ${calc.excavatorName}
Дата: ${formattedDate}
Смена: ${calc.shift}
Время смены (ч.): ${calc.shiftTime}
Время загрузки А/С (мин.): ${calc.loadTime}
Время рейса (Цикла) А/С (мин.): ${calc.cycleTime}
Время подъезда под 1 ковш. (сек.): ${calc.approachTime}
Фактическое количество машин (ед.): ${calc.actualTrucks}
Плановая производительность экскаватора в час (м³/час.): ${calc.productivity}
Потребность А/С (ед.): ${calc.requiredTrucks}
Плановый объем в смену (м³.): ${calc.planVolume}
Прогнозный объем экскаватора (м³.): ${calc.forecastVolume}
${calc.downtime >= 0 ? "Прогнозное время простоя парка А/С под экскаватором (ч.)" : "Прогнозное время простоя экскаватора, в ожидании автосамосвалов (ч.)"}: ${calc.downtime}
                            '''),
                            if (calc.downtime < 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "⚠ НЕХВАТКА САМОСВАЛОВ",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Закрыть'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}