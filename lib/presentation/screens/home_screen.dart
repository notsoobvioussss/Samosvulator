import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/local_storage.dart';
import '../../data/models/calculation_model.dart';
import '../../data/repositories/calculation_repository.dart';
import '../../data/datasources/calculations_local_data_source.dart';
import '../../data/datasources/calculations_remote_data_source.dart';
import '../../domain/usecases/calculator.dart';

class HomeScreen extends StatefulWidget {
  final DioClient dioClient;

  const HomeScreen({super.key, required this.dioClient});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final excavatorController = TextEditingController();
  final dateController = TextEditingController();
  final shiftTimeController = TextEditingController();
  final loadTimeController = TextEditingController();
  final cycleTimeController = TextEditingController();
  final approachTimeController = TextEditingController();
  final actualTrucksController = TextEditingController();
  final productivityController = TextEditingController();

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
      localDataSource: CalculationsLocalDataSource(Hive.box<CalculationModel>('calculations')),
      remoteDataSource: CalculationsRemoteDataSource(widget.dioClient),
    );
  }

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

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  Future<void> calculate() async {
    final calculator = Calculator();

    final userId = await getUserId(); // Получаем user_id

    final inputModel = CalculationModel(
      excavatorName: excavatorController.text,
      date: DateTime.now(),
      shift: selectedShift,
      shiftTime: int.tryParse(shiftTimeController.text) ?? 0,
      loadTime: double.tryParse(loadTimeController.text) ?? 0.0,
      cycleTime: int.tryParse(cycleTimeController.text) ?? 0,
      approachTime: int.tryParse(approachTimeController.text) ?? 0,
      actualTrucks: double.tryParse(actualTrucksController.text) ?? 0.0,
      productivity: int.tryParse(productivityController.text) ?? 0,
      requiredTrucks: 0,
      planVolume: 0,
      forecastVolume: 0,
      downtime: 0,
      userId: userId!,
    );

    final calculatedResult = calculator.calculate(inputModel);

    shortageMessage =
    calculatedResult.downtime < 0 ? "⚠ НЕХВАТКА САМОСВАЛОВ" : null;


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
      userId: userId!,
    );

    await repo.addCalculation(calculatedModel);

    setState(() {
      result = calculatedResult;
    });
  }

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

  Widget buildTimeField(String label, String hint, TextEditingController controller) {
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
            keyboardType: TextInputType.number,
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

  Widget buildInfoField(String label, String hint, TextEditingController controller) {
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
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Самосвулятор')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: excavatorController,
              decoration: const InputDecoration(labelText: 'Название экскаватора'),
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
              items: ['Смена 1', 'Смена 2', 'Смена 3', 'Смена 4']
                  .map((shift) => DropdownMenuItem(
                value: shift,
                child: Text(shift),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedShift = value!;
                });
              },
            ),
            buildInfoField('Время смены (ч.)', 'С учетом КТГ и КИО (плановые)\n1 час - обед\n30 мин. ЕТО\n30 мин. пересменка', shiftTimeController),
            buildTimeField('Время загрузки А/С (мин.)', 'Замер производится на месте выполнения работ', loadTimeController),
            buildTimeField('Время рейса (Цикла) А/С (мин.)', 'Замер производится на месте выполнения работ', cycleTimeController),
            buildTimeField('Время подъезда под 1 ковш. (сек.)', 'Замер производится на месте выполнения работ', approachTimeController),
            TextField(
              controller: actualTrucksController,
              decoration: const InputDecoration(labelText: 'Фактическое количество машин (ед.)'),
              keyboardType: TextInputType.number,
            ),
            buildInfoField('Плановая производительность экскаватора в смену (м³/час.)', 'Берется из производственной программы', productivityController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculate,
              child: const Text('Рассчитать'),
            ),
            if (result != null) ...[
              const SizedBox(height: 20),
              resultCard('Потребность А/С', '${result!.requiredTrucks} ед.'),
              resultCard('Плановый объем в смену', '${result!.planVolume} м³'),
              resultCard('Прогнозный объем экскаватора', '${result!.forecastVolume} м³'),
              resultCard('Прогнозное время простоя парка А/С под экскаватором', '${result!.downtime} ч'),
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
    );
  }
}