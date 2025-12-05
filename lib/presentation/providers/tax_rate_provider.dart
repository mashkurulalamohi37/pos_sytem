import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/tax_rate.dart';
import '../../domain/repositories/tax_rate_repository.dart';
import 'repository_providers.dart';

class TaxRateState {
  final List<TaxRate> taxRates;
  final bool isLoading;

  TaxRateState({
    this.taxRates = const [],
    this.isLoading = false,
  });

  TaxRateState copyWith({
    List<TaxRate>? taxRates,
    bool? isLoading,
  }) {
    return TaxRateState(
      taxRates: taxRates ?? this.taxRates,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TaxRateNotifier extends StateNotifier<TaxRateState> {
  final TaxRateRepository _taxRateRepository;

  TaxRateNotifier(this._taxRateRepository) : super(TaxRateState()) {
    loadTaxRates();
  }

  Future<void> loadTaxRates() async {
    print('DEBUG TaxRateProvider: Loading tax rates');
    state = state.copyWith(isLoading: true);
    try {
      final taxRates = await _taxRateRepository.getTaxRates();
      print('DEBUG TaxRateProvider: Loaded ${taxRates.length} tax rates');
      
      // Print details of each tax rate
      for (final rate in taxRates) {
        print('DEBUG TaxRateProvider: Tax rate ID: ${rate.id}, Name: ${rate.name}, Rate: ${rate.rate}%');
      }
      
      state = state.copyWith(
        taxRates: taxRates,
        isLoading: false,
      );
    } catch (e) {
      // Log error for debugging
      print('DEBUG TaxRateProvider: Error loading tax rates: $e');
      state = state.copyWith(
        taxRates: [],
        isLoading: false,
      );
    }
  }

  Future<TaxRate> createTaxRate(TaxRate taxRate) async {
    try {
      final created = await _taxRateRepository.createTaxRate(taxRate);
      await loadTaxRates();
      return created;
    } catch (e) {
      print('Error in createTaxRate: $e');
      rethrow;
    }
  }

  Future<TaxRate> updateTaxRate(TaxRate taxRate) async {
    final updated = await _taxRateRepository.updateTaxRate(taxRate);
    await loadTaxRates();
    return updated;
  }

  Future<void> deleteTaxRate(int id) async {
    await _taxRateRepository.deleteTaxRate(id);
    await loadTaxRates();
  }
}

final taxRateProvider = StateNotifierProvider<TaxRateNotifier, TaxRateState>((ref) {
  final taxRateRepo = ref.watch(taxRateRepositoryProvider);
  return TaxRateNotifier(taxRateRepo);
});

