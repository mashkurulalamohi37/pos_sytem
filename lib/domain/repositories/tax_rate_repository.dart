import '../entities/tax_rate.dart';

abstract class TaxRateRepository {
  Future<List<TaxRate>> getTaxRates();
  Future<TaxRate?> getTaxRateById(int id);
  Future<TaxRate> createTaxRate(TaxRate taxRate);
  Future<TaxRate> updateTaxRate(TaxRate taxRate);
  Future<void> deleteTaxRate(int id);
}

