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
      excavatorName: fields[1] as String,
      date: fields[2] as DateTime,
      shift: fields[3] as String,
      shiftTime: fields[4] as int,
      loadTime: fields[5] as double,
      cycleTime: fields[6] as int,
      approachTime: fields[7] as int,
      actualTrucks: fields[8] as double,
      productivity: fields[9] as int,
      requiredTrucks: fields[10] as double,
      planVolume: fields[11] as double,
      forecastVolume: fields[12] as double,
      downtime: fields[13] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CalculationModel obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.downtime);
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
