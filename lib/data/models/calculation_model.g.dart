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
      excavatorName: fields[0] as String,
      date: fields[1] as DateTime,
      shift: fields[2] as String,
      shiftTime: fields[3] as int,
      loadTime: fields[4] as double,
      cycleTime: fields[5] as int,
      approachTime: fields[6] as int,
      actualTrucks: fields[7] as double,
      productivity: fields[8] as int,
      requiredTrucks: fields[9] as double,
      planVolume: fields[10] as double,
      forecastVolume: fields[11] as double,
      downtime: fields[12] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CalculationModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.excavatorName)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.shift)
      ..writeByte(3)
      ..write(obj.shiftTime)
      ..writeByte(4)
      ..write(obj.loadTime)
      ..writeByte(5)
      ..write(obj.cycleTime)
      ..writeByte(6)
      ..write(obj.approachTime)
      ..writeByte(7)
      ..write(obj.actualTrucks)
      ..writeByte(8)
      ..write(obj.productivity)
      ..writeByte(9)
      ..write(obj.requiredTrucks)
      ..writeByte(10)
      ..write(obj.planVolume)
      ..writeByte(11)
      ..write(obj.forecastVolume)
      ..writeByte(12)
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
