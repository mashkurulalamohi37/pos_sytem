import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/repositories/sale_repository.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

class SaleState {
  final List<Sale> sales;
  final bool isLoading;
  final DateTime? startDate;
  final DateTime? endDate;

  SaleState({
    this.sales = const [],
    this.isLoading = false,
    this.startDate,
    this.endDate,
  });

  SaleState copyWith({
    List<Sale>? sales,
    bool? isLoading,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return SaleState(
      sales: sales ?? this.sales,
      isLoading: isLoading ?? this.isLoading,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class SaleNotifier extends StateNotifier<SaleState> {
  final SaleRepository _saleRepository;

  SaleNotifier(this._saleRepository) : super(SaleState()) {
    // Don't load sales here - wait for screen to provide date range
  }

  Future<void> loadSales({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final sales = await _saleRepository.getSales(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(
        sales: sales,
        isLoading: false,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Log error for debugging
      print('Error loading sales: $e');
      rethrow; // Re-throw to allow UI to handle
    }
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    return await _saleRepository.getSaleItems(saleId);
  }

  Future<void> deleteSale(int id) async {
    try {
      await _saleRepository.deleteSale(id);
      await loadSales(
        startDate: state.startDate,
        endDate: state.endDate,
      );
    } catch (e) {
      rethrow;
    }
  }
}

final saleProvider = StateNotifierProvider<SaleNotifier, SaleState>((ref) {
  final saleRepo = ref.watch(saleRepositoryProvider);
  return SaleNotifier(saleRepo);
});

