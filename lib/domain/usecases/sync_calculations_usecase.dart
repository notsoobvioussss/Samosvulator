
import '../../data/repositories/calculation_repository.dart';


class SyncCalculationsUseCase {
  final CalculationRepository repository;

  SyncCalculationsUseCase({required this.repository});

  Future<void> sync() async {
    await repository.syncCalculations();
  }
}