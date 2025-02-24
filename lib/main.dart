import 'package:flutter/material.dart';
import 'core/utils/hive_init.dart';
import 'presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(const MaterialApp(home: MainScreen()));
}