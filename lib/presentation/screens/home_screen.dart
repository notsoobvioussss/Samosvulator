import 'package:flutter/material.dart';
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
  final shiftController = TextEditingController();
  final shiftTimeController = TextEditingController();
  final loadTimeController = TextEditingController();
  final cycleTimeController = TextEditingController();
  final approachTimeController = TextEditingController();
  final actualTrucksController = TextEditingController();
  final productivityController = TextEditingController();

  CalculatorResult? result;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}.${picked.month}.${picked.year}";
      });
    }
  }

  void calculate() {
    final calculator = Calculator();

    final inputModel = CalculationModel(
      excavatorName: excavatorController.text,
      date: DateTime.now(),
      shift: shiftController.text,
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

    final repo = CalculationRepository();
    repo.addCalculation(calculatedModel);

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
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
            TextField(
              controller: shiftController,
              decoration: const InputDecoration(labelText: 'Смена'),
            ),
            TextField(
              controller: shiftTimeController,
              decoration: const InputDecoration(labelText: 'Время смены (ч.)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: loadTimeController,
              decoration: const InputDecoration(labelText: 'Время загрузки А/С (мин.)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: cycleTimeController,
              decoration: const InputDecoration(labelText: 'Время рейса (Цикла) А/С (мин.)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: approachTimeController,
              decoration: const InputDecoration(labelText: 'Время подъезда под 1 ковш. (сек.)'),
              keyboardType: TextInputType.number,
            ),
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
            ],
          ],
        ),
      ),
    );
  }
}
