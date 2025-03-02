import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../../data/models/calculation_model.dart';
import '../../data/repositories/calculation_repository.dart';
import '../../domain/usecases/calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  String selectedShift = 'Смена 1';
  CalculatorResult? result;
  String? shortageMessage;

  Timer? _timer;
  int _elapsedSeconds = 0;
  TextEditingController? _activeTimerController;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('dd.MM.yyyy HH:mm:ss').format(picked);
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

  void calculate() {
    final calculator = Calculator();
    final repo = CalculationRepository();

    final inputModel = CalculationModel(
      excavatorName: excavatorController.text,
      date: DateTime.now(),
      shift: selectedShift,
      shiftTime: int.parse(shiftTimeController.text),
      loadTime: double.parse(loadTimeController.text),
      cycleTime: int.parse(cycleTimeController.text),
      approachTime: int.parse(approachTimeController.text),
      actualTrucks: double.parse(actualTrucksController.text),
      productivity: int.parse(productivityController.text),
      requiredTrucks: 0,
      planVolume: 0,
      forecastVolume: 0,
      downtime: 0,
    );

    final calculatedResult = calculator.calculate(inputModel);

    shortageMessage =
    calculatedResult.downtime < 0 ? "⚠ НЕХВАТКА САМОСВАЛОВ" : null;

    final calculatedModel = CalculationModel(
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
    );

    repo.addCalculation(calculatedModel);

    setState(() {
      result = calculatedResult;
    });
  }

  Widget buildTimeField(String label, TextEditingController controller) {
    return Row(
      children: [
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
            TextField(
              controller: shiftTimeController,
              decoration: const InputDecoration(labelText: 'Время смены (ч.)'),
              keyboardType: TextInputType.number,
            ),
            buildTimeField('Время загрузки А/С (мин.)', loadTimeController),
            buildTimeField('Время рейса (Цикла) А/С (мин.)', cycleTimeController),
            buildTimeField('Время подъезда под 1 ковш. (сек.)', approachTimeController),
            TextField(
              controller: actualTrucksController,
              decoration: const InputDecoration(labelText: 'Фактическое количество машин (ед.)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: productivityController,
              decoration: const InputDecoration(labelText: 'Плановая производительность экскаватора в смену (м³/час.)'),
              keyboardType: TextInputType.number,
            ),
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