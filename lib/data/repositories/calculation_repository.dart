import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/calculations_local_data_source.dart';
import '../datasources/calculations_remote_data_source.dart';
import '../models/calculation_model.dart';

class CalculationRepository {
  final CalculationsLocalDataSource localDataSource;
  final CalculationsRemoteDataSource remoteDataSource;

  CalculationRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  /// 🔹 Получаем токен пользователя
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    print("🔑 Полученный токен: $token");
    return token;
  }

  /// 🔹 Получаем ID пользователя
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    print("🆔 Полученный user_id: $userId");
    return userId;
  }

  /// 🔹 Загружаем локальные + серверные данные
  Future<List<CalculationModel>> getCalculations() async {
    print("📥 Загрузка данных...");

    final localData = await localDataSource.getCalculations();
    print("📌 Локальные данные: ${localData.length} записей");

    final userId = await _getUserId();
    final token = await _getToken();

    if (userId == null || token == null) {
      print("⚠ Не удалось получить user_id или токен, работаем только с локальными данными");
      return localData;
    }

    if (await InternetConnectionChecker().hasConnection) {
      print("🌍 Интернет доступен, загружаем данные с сервера...");
      try {
        final serverData = await remoteDataSource.getCalculations(userId, token);
        print("✅ Получено ${serverData.length} записей с сервера");

        // 🔹 Добавляем в локальное хранилище **только новые** данные
        final newServerData = serverData.where((serverCalc) =>
        !localData.any((localCalc) => localCalc.id == serverCalc.id)).toList();

        if (newServerData.isNotEmpty) {
          print("📥 Добавляем в локальное хранилище ${newServerData.length} новых записей");
          await localDataSource.saveCalculations(newServerData);
        } else {
          print("✅ Все записи уже есть в локальном хранилище");
        }

        return [...localData, ...newServerData];
      } catch (e) {
        print("❌ Ошибка при загрузке данных с сервера: $e");
        return localData;
      }
    } else {
      print("🚫 Нет интернета, загружаем только локальные данные");
      return localData;
    }
  }

  /// 🔹 Добавляем расчёт (локально + сервер)
  Future<void> addCalculation(CalculationModel calculation) async {
    print("➕ Добавляем новый расчёт: ${calculation.id}");

    final token = await _getToken();

    // Сохраняем локально
    await localDataSource.saveCalculation(calculation);
    print("✅ Расчёт сохранён в локальное хранилище");

    // Если есть интернет → отправляем на сервер
    if (token != null && await InternetConnectionChecker().hasConnection) {
      try {
        await remoteDataSource.uploadCalculation(calculation, token);
        print("✅ Расчёт отправлен на сервер");
      } catch (e) {
        print("❌ Ошибка при отправке на сервер: $e");
      }
    } else {
      print("🚫 Нет интернета, расчёт будет отправлен при синхронизации");
    }
  }

  /// 🔹 **Двусторонняя синхронизация данных**
  Future<void> syncCalculations() async {
    print("🔄 Начинаем синхронизацию данных...");

    final userId = await _getUserId();
    final token = await _getToken();

    if (userId == null || token == null) {
      print("⚠ Не удалось получить user_id или токен, синхронизация невозможна");
      return;
    }

    if (await InternetConnectionChecker().hasConnection) {
      print("🌍 Интернет доступен, синхронизируем данные...");

      final localData = await localDataSource.getCalculations();
      final serverData = await remoteDataSource.getCalculations(userId, token);

      print("📌 Локальных записей: ${localData.length}");
      print("📌 Записей на сервере: ${serverData.length}");

      // 🔹 1. Отправляем **только новые** данные с устройства на сервер
      final localToSend = localData.where((localCalc) =>
      !serverData.any((serverCalc) => serverCalc.id == localCalc.id)).toList();
      if (localToSend.isNotEmpty) {
        print("📤 Отправляем ${localToSend.length} новых записей на сервер...");
        for (var calculation in localToSend) {
          await remoteDataSource.uploadCalculation(calculation, token);
        }
        print("✅ Все новые локальные записи отправлены на сервер");
      } else {
        print("✅ Все локальные записи уже есть на сервере");
      }

      // 🔹 2. Загружаем **только новые** данные с сервера в локальное хранилище
      final newServerData = serverData.where((serverCalc) =>
      !localData.any((localCalc) => localCalc.id == serverCalc.id)).toList();
      if (newServerData.isNotEmpty) {
        print("📥 Добавляем ${newServerData.length} новых записей из сервера в локальное хранилище");
        await localDataSource.saveCalculations(newServerData);
      } else {
        print("✅ Все серверные записи уже есть локально");
      }
    } else {
      print("🚫 Нет интернета, синхронизация невозможна");
    }
  }
}