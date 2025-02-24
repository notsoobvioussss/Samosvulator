import 'package:hive_flutter/adapters.dart';

import '../../data/models/calculation_model.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CalculationModelAdapter());
  await Hive.openBox<CalculationModel>('calculations');
}