
import '../../core/network/dio_client.dart';
import '../models/calculation_model.dart';

class CalculationsRemoteDataSource {
  final DioClient dioClient;

  CalculationsRemoteDataSource(this.dioClient);

  Future<List<CalculationModel>> getCalculations(int userId, String token) async {
    try {
      final response = await dioClient.get(
        '/authorized/records-by-user-id',
       token: token,
      );

      return (response.data as List)
          .map((json) => CalculationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Ошибка при получении данных: $e");
    }
  }

  Future<void> uploadCalculation(CalculationModel calculation, String token) async {
    print("📤 Отправляем данные на сервер: ${calculation.toJson()}");
    final jsonData = calculation.toJson();
    jsonData["date"] = calculation.date.toUtc().toIso8601String();
    try {
      await dioClient.post(
        '/authorized/create-record',
        data: jsonData,
        token: token,
      );
    } catch (e) {
      throw Exception("Ошибка при отправке данных: $e");
    }
  }
}