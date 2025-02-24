import 'package:hive/hive.dart';
import '../models/calculation_model.dart';

class CalculationRepository {
  final box = Hive.box<CalculationModel>('calculations');

  Future<void> addCalculation(CalculationModel calculation) async {
    await box.add(calculation);
  }

  List<CalculationModel> getCalculations() => box.values.toList();
}