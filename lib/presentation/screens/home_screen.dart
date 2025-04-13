import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/calculation_model.dart';
import '../../data/repositories/calculation_repository.dart';
import '../../data/datasources/calculations_local_data_source.dart';
import '../../data/datasources/calculations_remote_data_source.dart';
import '../../domain/usecases/calculator.dart';
import 'change_password_screen.dart';

class HomeScreen extends StatefulWidget {
  final DioClient dioClient;

  const HomeScreen({super.key, required this.dioClient});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Контроллеры для текстовых полей
  final excavatorController = TextEditingController();
  final dateController = TextEditingController();
  final shiftTimeController = TextEditingController();
  final loadTimeController = TextEditingController();
  final cycleTimeController = TextEditingController();
  final approachTimeController = TextEditingController();
  final actualTrucksController = TextEditingController();
  final productivityController = TextEditingController();

  // Новые контроллеры для времени
  final baseShiftTimeController = TextEditingController(text: '12');
  final lunchTimeController = TextEditingController();
  final etoTimeController = TextEditingController();
  final shiftChangeTimeController = TextEditingController();
  final otherTimeController = TextEditingController();

  // Остальные переменные
  late final CalculationRepository repo;
  String selectedShift = 'Смена 1';
  CalculatorResult? result;
  String? shortageMessage;
  Timer? _timer;
  int _elapsedSeconds = 0;
  TextEditingController? _activeTimerController;

  @override
  void initState() {
    super.initState();
    repo = CalculationRepository(
      localDataSource: CalculationsLocalDataSource(
        Hive.box<CalculationModel>('calculations'),
      ),
      remoteDataSource: CalculationsRemoteDataSource(widget.dioClient),
    );
    _loadSavedTimes(); // Загружаем сохраненные значения
  }

  // Загрузка сохраненных значений времени
  Future<void> _loadSavedTimes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lunchTimeController.text = prefs.getString('lunchTime') ?? '';
      etoTimeController.text = prefs.getString('etoTime') ?? '';
      shiftChangeTimeController.text = prefs.getString('shiftChangeTime') ?? '';
      otherTimeController.text = prefs.getString('otherTime') ?? '';
    });
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(dioClient: widget.dioClient),
      ),
    );
  }

  // Сохранение значений времени
  Future<void> _saveTimes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lunchTime', lunchTimeController.text);
    await prefs.setString('etoTime', etoTimeController.text);
    await prefs.setString('shiftChangeTime', shiftChangeTimeController.text);
    await prefs.setString('otherTime', otherTimeController.text);
  }

  // Выбор даты
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  // Запуск/остановка таймера для минут
  void _startStopwatch(TextEditingController controller) {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      controller.text = (_elapsedSeconds / 60).toStringAsFixed(2);
      setState(() {
        _elapsedSeconds = 0;
        _activeTimerController = null;
      });
    } else {
      setState(() {
        _elapsedSeconds = 0;
        _activeTimerController = controller;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
          controller.text = (_elapsedSeconds / 60).toStringAsFixed(2);
        });
      });
    }
  }

  // Запуск/остановка таймера для секунд
  void _startStopwatchSeconds(TextEditingController controller) {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      controller.text = '$_elapsedSeconds';
      setState(() {
        _elapsedSeconds = 0;
        _activeTimerController = null;
      });
    } else {
      setState(() {
        _elapsedSeconds = 0;
        _activeTimerController = controller;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
          controller.text = '$_elapsedSeconds';
        });
      });
    }
  }

  // Получение user_id
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  // Расчет
  Future<void> calculate() async {
    final calculator = Calculator();
    final userId = await getUserId();

    if (userId == null) {
      _showErrorMessage("Ошибка: Не удалось получить ID пользователя.");
      return;
    }

    // Расчёт времени смены
    final baseShiftTime = double.tryParse(baseShiftTimeController.text) ?? 12.0;
    final lunchTime = double.tryParse(lunchTimeController.text) ?? 0.0;
    final etoTime = double.tryParse(etoTimeController.text) ?? 0.0;
    final shiftChangeTime = double.tryParse(shiftChangeTimeController.text) ?? 0.0;
    final otherTime = double.tryParse(otherTimeController.text) ?? 0.0;
    final shiftTime = (baseShiftTime - lunchTime - etoTime - shiftChangeTime - otherTime);

    final inputModel = CalculationModel(
      excavatorName: excavatorController.text,
      date: DateTime.now(),
      shift: selectedShift,
      shiftTime: shiftTime,
      loadTime: double.tryParse(loadTimeController.text) ?? 0.0,
      cycleTime: double.tryParse(cycleTimeController.text) ?? 0.0,
      approachTime: double.tryParse(approachTimeController.text) ?? 0.0,
      actualTrucks: double.tryParse(actualTrucksController.text) ?? 0.0,
      productivity: double.tryParse(productivityController.text) ?? 0.0,
      requiredTrucks: 0,
      planVolume: 0,
      forecastVolume: 0,
      downtime: 0,
      userId: userId,
    );

    final calculatedResult = calculator.calculate(inputModel);

    // 🔹 Проверка валидности результата перед сохранением
    if (!isValidCalculationResult(calculatedResult)) {
      _showErrorMessage("Ошибка: Расчёт содержит некорректные значения.");
      return;
    }

    shortageMessage = calculatedResult.downtime < 0 ? "⚠ НЕХВАТКА САМОСВАЛОВ" : null;

    final calculatedModel = CalculationModel(
      id: inputModel.id,
      excavatorName: inputModel.excavatorName,
      date: inputModel.date,
      shift: inputModel.shift,
      shiftTime: inputModel.shiftTime,
      loadTime: inputModel.loadTime,
      cycleTime: inputModel.cycleTime,
      approachTime: inputModel.approachTime,
      actualTrucks: inputModel.actualTrucks,
      productivity: inputModel.productivity,
      requiredTrucks: calculatedResult.requiredTrucks,
      planVolume: calculatedResult.planVolume,
      forecastVolume: calculatedResult.forecastVolume,
      downtime: calculatedResult.downtime,
      userId: userId,
    );

    await repo.addCalculation(calculatedModel);
    await _saveTimes(); // Сохраняем значения времени

    setState(() {
      result = calculatedResult;
    });
  }

  // Виджет для отображения карточки результата
  Widget resultCard(String title, String value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Показать подсказку
  void _showHint(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
  }

  // Виджет для поля ввода времени с таймером
  Widget buildTimeField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.blue),
          onPressed: () => _showHint(hint),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {
                controller.text = value.replaceAll(',', '.');
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(
            (_activeTimerController == controller) ? Icons.stop : Icons.timer,
            color: Colors.blue,
          ),
          onPressed: () => _startStopwatch(controller),
        ),
      ],
    );
  }

  // Виджет для поля ввода времени с таймером (секунды)
  Widget buildTimeFieldSecond(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.blue),
          onPressed: () => _showHint(hint),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        IconButton(
          icon: Icon(
            (_activeTimerController == controller) ? Icons.stop : Icons.timer,
            color: Colors.blue,
          ),
          onPressed: () => _startStopwatchSeconds(controller),
        ),
      ],
    );
  }

  // Виджет для поля ввода с подсказкой
  Widget buildInfoField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.blue),
          onPressed: () => _showHint(hint),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Самосвулятор'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.lock_outline), // Иконка смены пароля
              onPressed: _navigateToChangePassword,
              tooltip: "Сменить пароль",
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: excavatorController,
                decoration: const InputDecoration(
                  labelText: 'Название экскаватора',
                ),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Дата'),
                onTap: _pickDate,
                readOnly: true,
              ),
              DropdownButtonFormField<String>(
                value: selectedShift,
                decoration: const InputDecoration(labelText: 'Смена'),
                items:
                    ['Смена 1', 'Смена 2', 'Смена 3', 'Смена 4']
                        .map(
                          (shift) => DropdownMenuItem(
                            value: shift,
                            child: Text(shift),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedShift = value!;
                  });
                },
              ),
              TextField(
                controller: baseShiftTimeController,
                decoration: const InputDecoration(
                  labelText: 'Базовое время смены (ч.)',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    baseShiftTimeController.text = value.replaceAll(',', '.');
                    baseShiftTimeController
                        .selection = TextSelection.fromPosition(
                      TextPosition(offset: baseShiftTimeController.text.length),
                    );
                  });
                },
              ),

              TextField(
                controller: lunchTimeController,
                decoration: const InputDecoration(
                  labelText: 'Время на обед (ч.)',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    lunchTimeController.text = value.replaceAll(',', '.');
                    lunchTimeController.selection = TextSelection.fromPosition(
                      TextPosition(offset: lunchTimeController.text.length),
                    );
                  });
                },
              ),

              TextField(
                controller: etoTimeController,
                decoration: const InputDecoration(labelText: 'ЕТО (ч.)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    etoTimeController.text = value.replaceAll(',', '.');
                    etoTimeController.selection = TextSelection.fromPosition(
                      TextPosition(offset: etoTimeController.text.length),
                    );
                  });
                },
              ),

              TextField(
                controller: shiftChangeTimeController,
                decoration: const InputDecoration(labelText: 'Пересменка (ч.)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    shiftChangeTimeController.text = value.replaceAll(',', '.');
                    shiftChangeTimeController
                        .selection = TextSelection.fromPosition(
                      TextPosition(
                        offset: shiftChangeTimeController.text.length,
                      ),
                    );
                  });
                },
              ),

              TextField(
                controller: otherTimeController,
                decoration: const InputDecoration(labelText: 'Другое (ч.)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    otherTimeController.text = value.replaceAll(',', '.');
                    otherTimeController.selection = TextSelection.fromPosition(
                      TextPosition(offset: otherTimeController.text.length),
                    );
                  });
                },
              ),
              buildTimeField(
                'Время загрузки А/С (мин.)',
                'Замер производится на месте выполнения работ',
                loadTimeController,
              ),
              buildTimeField(
                'Время рейса (Цикла) А/С (мин.)',
                'Замер производится на месте выполнения работ',
                cycleTimeController,
              ),
              buildTimeFieldSecond(
                'Время подъезда под 1 ковш. (сек.)',
                'Замер производится на месте выполнения работ',
                approachTimeController,
              ),
              TextField(
                controller: actualTrucksController,
                decoration: const InputDecoration(
                  labelText: 'Фактическое количество машин (ед.)',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    actualTrucksController.text = value.replaceAll(',', '.');
                    actualTrucksController
                        .selection = TextSelection.fromPosition(
                      TextPosition(offset: actualTrucksController.text.length),
                    );
                  });
                },
              ),
              buildInfoField(
                'Плановая производительность экскаватора в час (м³/час.)',
                'Берется из производственной программы',
                productivityController,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: calculate,
                child: const Text('Рассчитать'),
              ),
              if (result != null) ...[
                const SizedBox(height: 20),
                resultCard('Потребность А/С', '${result!.requiredTrucks} ед.'),
                resultCard(
                  'Плановый объем в смену',
                  '${result!.planVolume} м³',
                ),
                resultCard(
                  'Прогнозный объем экскаватора',
                  '${result!.forecastVolume} м³',
                ),
                resultCard('Время смены', '${result!.shiftTime} ч'),
                resultCard(
                  result!.downtime >= 0
                      ? 'Прогнозное время простоя парка А/С под экскаватором'
                      : 'Прогнозное время простоя экскаватора, в ожидании автосамосвалов',
                  '${result!.downtime} ч',
                ),
                if (shortageMessage != null)
                  Text(
                    shortageMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool isValidCalculationResult(CalculatorResult result) {
    return result.requiredTrucks != null &&
        result.requiredTrucks > 0 &&
        result.planVolume != null &&
        result.planVolume > 0 &&
        result.forecastVolume != null &&
        result.forecastVolume > 0 &&
        result.downtime != null &&
        !result.downtime.isNaN;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }
}
