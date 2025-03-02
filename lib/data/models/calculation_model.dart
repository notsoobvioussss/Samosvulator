import 'package:hive/hive.dart';
part 'calculation_model.g.dart';

@HiveType(typeId: 0)
class CalculationModel extends HiveObject {
  @HiveField(1) final String excavatorName;
  @HiveField(2) final DateTime date;
  @HiveField(3) final String shift;
  @HiveField(4) final int shiftTime;
  @HiveField(5) final double loadTime;
  @HiveField(6) final int cycleTime;
  @HiveField(7) final int approachTime;
  @HiveField(8) final double actualTrucks;
  @HiveField(9) final int productivity;
  @HiveField(10) final double requiredTrucks;
  @HiveField(11) final double planVolume;
  @HiveField(12) final double forecastVolume;
  @HiveField(13) final double downtime;

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
