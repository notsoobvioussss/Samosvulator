import '../../data/models/calculation_model.dart';

class CalculatorResult {
  final double requiredTrucks, planVolume, forecastVolume, downtime;

  CalculatorResult({
    required this.requiredTrucks,
    required this.planVolume,
    required this.forecastVolume,
    required this.downtime,
  });
}

class Calculator {
  CalculatorResult calculate(CalculationModel model) {
    final requiredTrucks = model.cycleTime / (model.loadTime + model.approachTime / 60);
    final planVolume = model.productivity * model.shiftTime;
    final forecastVolume = planVolume * (model.actualTrucks / requiredTrucks);
    final downtime = ((model.actualTrucks - requiredTrucks) * model.loadTime * (60 / model.cycleTime * model.shiftTime)) / 60;

    return CalculatorResult(
      requiredTrucks: double.parse(requiredTrucks.toStringAsFixed(1)),
      planVolume: double.parse(planVolume.toStringAsFixed(1)),
      forecastVolume: double.parse(forecastVolume.toStringAsFixed(1)),
      downtime: double.parse(downtime.toStringAsFixed(1)),
    );
  }
}