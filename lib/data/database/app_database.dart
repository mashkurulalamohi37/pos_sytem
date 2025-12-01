import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Tables
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 1, max: 50)();
  TextColumn get passwordHash => text()();
  TextColumn get role => text()(); // admin, manager, cashier
  TextColumn get fullName => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get remoteId => text().nullable()(); // For cloud sync
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get costPrice => real().withDefault(const Constant(0.0))();
  RealColumn get sellingPrice => real().withDefault(const Constant(0.0))();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(10))();
  TextColumn get unit => text().withDefault(const Constant('pcs'))(); // pcs, kg, etc.
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
}

class Branches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
}

class StockLevels extends Table {
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get branchId => integer().references(Branches, #id)();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {productId, branchId};
}

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get branchId => integer().references(Branches, #id)();
  TextColumn get type => text()(); // sale, purchase, adjustment, transfer
  IntColumn get quantity => integer()(); // positive for in, negative for out
  RealColumn get unitCost => real().nullable()();
  TextColumn get reference => text().nullable()(); // sale_id, purchase_id, etc.
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get userId => integer().references(Users, #id).nullable()();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
}

class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get loyaltyPoints => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
}

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get saleNumber => text().unique()();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get branchId => integer().references(Branches, #id)();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMethod => text()(); // cash, card, etc.
  TextColumn get status => text().withDefault(const Constant('completed'))(); // completed, refunded
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
}

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get productName => text()(); // Snapshot for historical accuracy
  RealColumn get unitPrice => real()();
  IntColumn get quantity => integer()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class CashSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get branchId => integer().references(Branches, #id)();
  RealColumn get openingCash => real().withDefault(const Constant(0.0))();
  RealColumn get expectedCash => real().withDefault(const Constant(0.0))();
  RealColumn get countedCash => real().nullable()();
  RealColumn get difference => real().nullable()();
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))(); // open, closed
  TextColumn get notes => text().nullable()();
  TextColumn get remoteId => text().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [
  Users,
  Categories,
  Products,
  Branches,
  StockLevels,
  StockMovements,
  Customers,
  Sales,
  SaleItems,
  CashSessions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create default admin user
        await _createDefaultData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here
      },
    );
  }

  Future<void> _createDefaultData() async {
    // Create default users for all roles
    // In production, use proper password hashing
    await into(users).insert(UsersCompanion(
      username: const Value('admin'),
      passwordHash: const Value('admin123'), // TODO: Use proper hashing
      role: const Value('admin'),
      fullName: const Value('Administrator'),
    ));
    
    await into(users).insert(UsersCompanion(
      username: const Value('manager'),
      passwordHash: const Value('manager123'), // TODO: Use proper hashing
      role: const Value('manager'),
      fullName: const Value('Manager'),
    ));
    
    await into(users).insert(UsersCompanion(
      username: const Value('cashier'),
      passwordHash: const Value('cashier123'), // TODO: Use proper hashing
      role: const Value('cashier'),
      fullName: const Value('Cashier'),
    ));
    
    // Create default branch
    await into(branches).insert(BranchesCompanion(
      name: const Value('Main Branch'),
    ));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aronium.db'));
    return NativeDatabase(file);
  });
}

