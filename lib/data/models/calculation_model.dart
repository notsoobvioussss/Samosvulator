import 'package:hive/hive.dart';
part 'calculation_model.g.dart';

@HiveType(typeId: 0)
class CalculationModel extends HiveObject {
  @HiveField(0) final String excavatorName;
  @HiveField(1) final DateTime date;
  @HiveField(2) final String shift;
  @HiveField(3) final int shiftTime;
  @HiveField(4) final double loadTime;
  @HiveField(5) final int cycleTime;
  @HiveField(6) final int approachTime;
  @HiveField(7) final double actualTrucks;
  @HiveField(8) final int productivity;
  @HiveField(9) final double requiredTrucks;
  @HiveField(10) final double planVolume;
  @HiveField(11) final double forecastVolume;
  @HiveField(12) final double downtime;

  CalculationModel({
    required this.excavatorName,
    required this.date,
    required this.shift,
    required this.shiftTime,
    required this.loadTime,
    required this.cycleTime,
    required this.approachTime,
    required this.actualTrucks,
    required this.productivity,
    required this.requiredTrucks,
    required this.planVolume,
    required this.forecastVolume,
    required this.downtime,
  });
}