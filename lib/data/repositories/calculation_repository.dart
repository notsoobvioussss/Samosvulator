import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../datasources/calculations_local_data_source.dart';
import '../datasources/calculations_remote_data_source.dart';
import '../models/calculation_model.dart';

class CalculationRepository {
  final CalculationsLocalDataSource localDataSource;
  final CalculationsRemoteDataSource remoteDataSource;
  Timer? _syncTimer;

  CalculationRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  }) {
    startAutoSync();
  }

  /// 🔹 Получаем токен пользователя
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// 🔹 Получаем ID пользователя
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  /// 🔹 Преобразуем дату к формату сервера (ISO 8601 UTC)
  String _formatDate(DateTime date) {
    String formattedDate = "${date.toUtc().toIso8601String().substring(0, 23)}Z";
    print("Date current$formattedDate");
    return formattedDate;
  }

  /// 🔹 Получаем **объединённые данные** (локальные + серверные)
  Future<List<CalculationModel>> getCalculations() async {
    print("📥 Загрузка данных...");
    final localData = await localDataSource.getCalculations();
    print("📌 Локальные записи: ${localData.length}");

    final userId = await _getUserId();
    final token = await _getToken();

    if (userId == null || token == null) {
      print("⚠ Нет user_id или токена, работаем с локальными данными");
      return localData;
    }

    if (await InternetConnectionChecker.createInstance().hasConnection) {
      print("🌍 Интернет доступен, загружаем данные с сервера...");
      try {
        final serverData = await remoteDataSource.getCalculations(userId, token);
        print("✅ Получено с сервера: ${serverData.length} записей");

        // 🔹 Фильтруем **новые записи** с сервера, приводя `date` к единому формату
        final newRecords = serverData.where((serverCalc) =>
        !localData.any((localCalc) =>
        _formatDate(localCalc.date) == _formatDate(serverCalc.date) &&
            localCalc.excavatorName == serverCalc.excavatorName)
        ).toList();

        if (newRecords.isNotEmpty) {

          print("📥 Добавляем ${newRecords.length} новых записей в локальное хранилище");
          await localDataSource.saveCalculations(newRecords);
        }

        return localData;
      } catch (e) {
        print("❌ Ошибка загрузки с сервера: $e");
        return localData;
      }
    } else {
      print("🚫 Нет интернета, загружаем только локальные данные");
      return localData;
    }
  }

  /// 🔹 Добавляем запись (локально + сервер)
  Future<void> addCalculation(CalculationModel calculation) async {
    print("➕ Добавляем расчёт: ${calculation.excavatorName} - ${calculation.date}");

    final token = await _getToken();

    // Приводим дату к стандартному формату перед сохранением
    final formattedCalculation = CalculationModel(
      id: calculation.id,
      excavatorName: calculation.excavatorName,
      date: DateTime.parse(_formatDate(calculation.date)), // Преобразуем в ISO 8601 UTC
      shift: calculation.shift,
      shiftTime: calculation.shiftTime,
      loadTime: calculation.loadTime,
      cycleTime: calculation.cycleTime,
      approachTime: calculation.approachTime,
      actualTrucks: calculation.actualTrucks,
      productivity: calculation.productivity,
      requiredTrucks: calculation.requiredTrucks,
      planVolume: calculation.planVolume,
      forecastVolume: calculation.forecastVolume,
      downtime: calculation.downtime,
      userId: calculation.userId,
    );

    // Сохраняем **локально**
    await localDataSource.saveCalculation(formattedCalculation);
    print("✅ Расчёт сохранён в локальном хранилище");
  }

  /// 🔹 **Двусторонняя синхронизация**
  Future<void> syncCalculations() async {
    print("🔄 Запускаем синхронизацию...");

    final userId = await _getUserId();
    final token = await _getToken();

    if (userId == null || token == null) {
      print("⚠ Нет user_id или токена, синхронизация невозможна");
      return;
    }

    if (await InternetConnectionChecker.createInstance().hasConnection) {
      print("🌍 Интернет доступен, синхронизируем данные...");

      final localData = await localDataSource.getCalculations();
      final serverData = await remoteDataSource.getCalculations(userId, token);

      print("📌 Локальных записей: ${localData.length}");
      print("📌 Записей на сервере: ${serverData.length}");

      final localToSend = localData.where((localCalc) =>
      !serverData.any((serverCalc) =>
      _formatDate(localCalc.date) == _formatDate(serverCalc.date) &&
          localCalc.excavatorName == serverCalc.excavatorName)).toList();

      if (localToSend.isNotEmpty) {
        print("📤 Отправляем ${localToSend.length} записей на сервер...");
        for (var calculation in localToSend) {
          await remoteDataSource.uploadCalculation(calculation, token);
        }
        print("✅ Новые локальные записи загружены на сервер");
      } else {
        print("✅ Все локальные записи уже есть на сервере");
      }

      // 🔹 **2. Загружаем новые серверные данные в локальное хранилище**
      final newServerData = serverData.where((serverCalc) =>
      !localData.any((localCalc) =>
      _formatDate(localCalc.date) == _formatDate(serverCalc.date) &&
          localCalc.excavatorName == serverCalc.excavatorName)).toList();

      if (newServerData.isNotEmpty) {
        print("📥 Добавляем ${newServerData.length} новых записей в локальное хранилище");
        await localDataSource.saveCalculations(newServerData);
      } else {
        print("✅ Все серверные записи уже есть локально");
      }
    } else {
      print("🚫 Нет интернета, синхронизация невозможна");
    }
  }

  /// 🔹 **Фоновая синхронизация раз в час**
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      await syncCalculations();
    });
  }
}