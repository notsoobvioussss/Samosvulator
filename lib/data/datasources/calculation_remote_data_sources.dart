import '../../core/network/dio_client.dart';
import '../models/calculation_model.dart';

class CalculationsRemoteDataSource {
  final DioClient dioClient;

  CalculationsRemoteDataSource(this.dioClient);

  /// ✅ Создание расчёта в API
  Future<void> createCalculation(CalculationModel calculation, String token) async {
    await dioClient.post("/authorized/create", data: calculation.toJson(), token: token);
  }

  /// ✅ Получение всех расчётов по user_id
  Future<List<CalculationModel>> fetchCalculations(int userId, String token) async {
    final response = await dioClient.get("/record/by-user-id", token: token);
    return (response.data as List).map((json) => CalculationModel.fromJson(json)).toList();
  }
}