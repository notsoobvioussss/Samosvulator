import 'package:flutter/material.dart';
import '../../data/repositories/calculation_repository.dart';
import "package:intl/intl.dart";

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculations = CalculationRepository().getCalculations();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

    return Scaffold(
      appBar: AppBar(title: const Text('История расчётов')),
      body: ListView.builder(
        itemCount: calculations.length,
        itemBuilder: (context, index) {
          final calc = calculations[index];
          final formattedDate = dateFormat.format(calc.date);
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
Плановая производительность экскаватора в смену (м³/час.): ${calc.productivity}
Потребность А/С (ед.): ${calc.requiredTrucks}
Плановый объем в смену (м³.): ${calc.planVolume}
Прогнозный объем экскаватора (м³.): ${calc.forecastVolume}
Прогнозное время простоя парка А/С под экскаватором (ч.): ${calc.downtime}
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
      ),
    );
  }
}
