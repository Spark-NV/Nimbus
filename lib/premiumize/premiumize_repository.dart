import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'premiumize_api_service.dart';
import 'premiumize_transfer.dart';
import 'premiumize_account_info.dart';

part 'premiumize_repository.g.dart';

@riverpod
class PremiumizeRepository extends _$PremiumizeRepository {
  @override
  Future<List<PremiumizeTransfer>> build() async {
    return _fetchTransfers();
  }

  Future<List<PremiumizeTransfer>> _fetchTransfers() async {
    final apiService = ref.read(premiumizeApiServiceProvider);
    return apiService.getTransfers();
  }

  Future<void> refreshTransfers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchTransfers);
  }

  Future<void> deleteTransfer(String id) async {
    final apiService = ref.read(premiumizeApiServiceProvider);
    await apiService.deleteTransfer(id);
  }

  Future<void> clearFinishedTransfers() async {
    final apiService = ref.read(premiumizeApiServiceProvider);
    await apiService.clearFinishedTransfers();
    await refreshTransfers();
  }

  Future<void> createTransfer(String magnetLink) async {
    final apiService = ref.read(premiumizeApiServiceProvider);
    await apiService.createTransfer(magnetLink);
  }
}

@riverpod
class PremiumizeAccountInfoNotifier extends _$PremiumizeAccountInfoNotifier {
  @override
  Future<PremiumizeAccountInfo> build() async {
    return _fetchAccountInfo();
  }

  Future<PremiumizeAccountInfo> _fetchAccountInfo() async {
    final apiService = ref.read(premiumizeApiServiceProvider);
    final response = await apiService.getAccountInfo();
    return PremiumizeAccountInfo.fromJson(response);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchAccountInfo);
  }
} 