import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'calculation_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class CalculationModel {
  @HiveField(0)
  int? id; // Оставляем int, так как это идентификатор

  @HiveField(1)
  @JsonKey(name: 'excavator_name')
  final String excavatorName;

  @HiveField(2)
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime date;

  @HiveField(3)
  final String shift;

  @HiveField(4)
  @JsonKey(name: 'shift_time')
  final double shiftTime; // Изменено с int на double

  @HiveField(5)
  @JsonKey(name: 'load_time')
  final double loadTime;

  @HiveField(6)
  @JsonKey(name: 'cycle_time')
  final double cycleTime; // Изменено с int на double

  @HiveField(7)
  @JsonKey(name: 'approach_time')
  final double approachTime; // Изменено с int на double

  @HiveField(8)
  @JsonKey(name: 'actual_trucks')
  final double actualTrucks;

  @HiveField(9)
  final double productivity; // Изменено с int на double

  @HiveField(10)
  @JsonKey(name: 'required_trucks')
  final double requiredTrucks;

  @HiveField(11)
  @JsonKey(name: 'plan_volume')
  final double planVolume;

  @HiveField(12)
  @JsonKey(name: 'forecast_volume')
  final double forecastVolume;

  @HiveField(13)
  final double downtime;

  @HiveField(14)
  @JsonKey(name: 'user_id')
  final int userId; // Оставляем int, так как это идентификатор пользователя

  CalculationModel({
    this.id,
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
    required this.userId,
  });

  static DateTime _fromJson(String date) => DateTime.parse(date);
  static String _toJson(DateTime date) => date.toIso8601String();

  factory CalculationModel.fromJson(Map<String, dynamic> json) =>
      _$CalculationModelFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "excavator_name": excavatorName,
      "date": date.toUtc().toIso8601String(),
      "shift": shift,
      "shift_time": shiftTime,
      "load_time": loadTime,
      "cycle_time": cycleTime,
      "approach_time": approachTime,
      "actual_trucks": actualTrucks,
      "productivity": productivity,
      "required_trucks": requiredTrucks,
      "plan_volume": planVolume,
      "forecast_volume": forecastVolume,
      "downtime": downtime,
      "user_id": userId,
    };

    data.removeWhere((key, value) => value == null);
    return data;
  }
}