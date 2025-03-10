import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'calculation_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class CalculationModel {
  @HiveField(0)
  int? id;

  @HiveField(1)
  @JsonKey(name: 'excavator_name') // ✅ Соответствует API
  final String excavatorName;

  @HiveField(2)
  @JsonKey(fromJson: _fromJson, toJson: _toJson) // ✅ Преобразование даты
  final DateTime date;

  @HiveField(3)
  final String shift;

  @HiveField(4)
  @JsonKey(name: 'shift_time') // ✅ Соответствует API
  final int shiftTime;

  @HiveField(5)
  @JsonKey(name: 'load_time') // ✅ Соответствует API
  final double loadTime;

  @HiveField(6)
  @JsonKey(name: 'cycle_time') // ✅ Соответствует API
  final int cycleTime;

  @HiveField(7)
  @JsonKey(name: 'approach_time') // ✅ Соответствует API
  final int approachTime;

  @HiveField(8)
  @JsonKey(name: 'actual_trucks') // ✅ Соответствует API
  final double actualTrucks;

  @HiveField(9)
  final int productivity;

  @HiveField(10)
  @JsonKey(name: 'required_trucks') // ✅ Соответствует API
  final double requiredTrucks;

  @HiveField(11)
  @JsonKey(name: 'plan_volume') // ✅ Соответствует API
  final double planVolume;

  @HiveField(12)
  @JsonKey(name: 'forecast_volume') // ✅ Соответствует API
  final double forecastVolume;

  @HiveField(13)
  final double downtime;

  @HiveField(14)
  @JsonKey(name: 'user_id') // ✅ Добавлено в модель
  final int userId;

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
    required this.userId, // ✅ Добавили в модель
  });

  /// **Функции для конвертации `DateTime` ⇄ `String`**
  static DateTime _fromJson(String date) => DateTime.parse(date);
  static String _toJson(DateTime date) => date.toIso8601String();

  /// **Генерируемый метод `fromJson`**
  factory CalculationModel.fromJson(Map<String, dynamic> json) => _$CalculationModelFromJson(json);

  /// **Генерируемый метод `toJson`**
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "excavator_name": excavatorName,
      "date": date.toIso8601String(),
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

    // ❌ Удаляем id, если он null (чтобы вообще не отправлять)
    data.removeWhere((key, value) => value == null);

    return data;
  }
}