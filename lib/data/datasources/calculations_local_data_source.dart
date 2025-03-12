import 'package:hive/hive.dart';
import '../models/calculation_model.dart';

class CalculationsLocalDataSource {
  final Box<CalculationModel> calculationsBox;

  CalculationsLocalDataSource(this.calculationsBox);

  Future<List<CalculationModel>> getCalculations() async {
    return calculationsBox.values.toList();
  }

  Future<void> saveCalculations(List<CalculationModel> calculations) async {
    for (var calculation in calculations) {
      await calculationsBox.put(calculation.id, calculation);
    }
  }

  Future<void> saveCalculation(CalculationModel calculation) async {
    await calculationsBox.add(calculation);
  }
}