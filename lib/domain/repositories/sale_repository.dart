import '../entities/sale.dart';
import '../entities/sale_item.dart';

abstract class SaleRepository {
  Future<Sale> createSale(Sale sale, List<SaleItem> items);
  Future<List<Sale>> getSales({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    int? branchId,
  });
  Future<Sale?> getSaleById(int id);
  Future<Sale?> getSaleByNumber(String saleNumber);
  Future<List<SaleItem>> getSaleItems(int saleId);
  Future<void> deleteSale(int id);
}

