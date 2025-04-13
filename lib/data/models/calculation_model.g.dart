// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalculationModelAdapter extends TypeAdapter<CalculationModel> {
  @override
  final int typeId = 0;

  @override
  CalculationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalculationModel(
      id: fields[0] as int?,
      excavatorName: fields[1] as String,
      date: fields[2] as DateTime,
      shift: fields[3] as String,
      shiftTime: fields[4] as double,
      loadTime: fields[5] as double,
      cycleTime: fields[6] as double,
      approachTime: fields[7] as double,
      actualTrucks: fields[8] as double,
      productivity: fields[9] as double,
      requiredTrucks: fields[10] as double,
      planVolume: fields[11] as double,
      forecastVolume: fields[12] as double,
      downtime: fields[13] as double,
      userId: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CalculationModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.excavatorName)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.shift)
      ..writeByte(4)
      ..write(obj.shiftTime)
      ..writeByte(5)
      ..write(obj.loadTime)
      ..writeByte(6)
      ..write(obj.cycleTime)
      ..writeByte(7)
      ..write(obj.approachTime)
      ..writeByte(8)
      ..write(obj.actualTrucks)
      ..writeByte(9)
      ..write(obj.productivity)
      ..writeByte(10)
      ..write(obj.requiredTrucks)
      ..writeByte(11)
      ..write(obj.planVolume)
      ..writeByte(12)
      ..write(obj.forecastVolume)
      ..writeByte(13)
      ..write(obj.downtime)
      ..writeByte(14)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculationModel _$CalculationModelFromJson(Map<String, dynamic> json) =>
    CalculationModel(
      id: (json['id'] as num?)?.toInt(),
      excavatorName: json['excavator_name'] as String,
      date: CalculationModel._fromJson(json['date'] as String),
      shift: json['shift'] as String,
      shiftTime: (json['shift_time'] as num).toDouble(),
      loadTime: (json['load_time'] as num).toDouble(),
      cycleTime: (json['cycle_time'] as num).toDouble(),
      approachTime: (json['approach_time'] as num).toDouble(),
      actualTrucks: (json['actual_trucks'] as num).toDouble(),
      productivity: (json['productivity'] as num).toDouble(),
      requiredTrucks: (json['required_trucks'] as num).toDouble(),
      planVolume: (json['plan_volume'] as num).toDouble(),
      forecastVolume: (json['forecast_volume'] as num).toDouble(),
      downtime: (json['downtime'] as num).toDouble(),
      userId: (json['user_id'] as num).toInt(),
    );

Map<String, dynamic> _$CalculationModelToJson(CalculationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'excavator_name': instance.excavatorName,
      'date': CalculationModel._toJson(instance.date),
      'shift': instance.shift,
      'shift_time': instance.shiftTime,
      'load_time': instance.loadTime,
      'cycle_time': instance.cycleTime,
      'approach_time': instance.approachTime,
      'actual_trucks': instance.actualTrucks,
      'productivity': instance.productivity,
      'required_trucks': instance.requiredTrucks,
      'plan_volume': instance.planVolume,
      'forecast_volume': instance.forecastVolume,
      'downtime': instance.downtime,
      'user_id': instance.userId,
    };
