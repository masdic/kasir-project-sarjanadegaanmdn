import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/store_profile.dart';
import '../models/product.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item.dart';
import '../models/production_log.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sarjana_degan_pos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Desktop initialization (Windows / Linux)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        path = join(appDocDir.path, 'SarjanaDegan', filePath);
        final dir = Directory(dirname(path));
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } catch (_) {
        // Fallback saat unit testing atau lingkungan headless
        path = join(Directory.current.path, '.db', filePath);
        final dir = Directory(dirname(path));
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabel StoreProfile
    await db.execute('''
      CREATE TABLE StoreProfile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        storeName TEXT NOT NULL,
        branchName TEXT NOT NULL,
        address TEXT,
        phone TEXT,
        receiptFooter TEXT
      )
    ''');

    // 2. Tabel Products
    await db.execute('''
      CREATE TABLE Products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productCode TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price INTEGER NOT NULL,
        costPrice INTEGER DEFAULT 0,
        stock INTEGER NOT NULL DEFAULT 0,
        unit TEXT DEFAULT 'Pcs',
        isActive INTEGER DEFAULT 1
      )
    ''');

    // 3. Tabel Transactions
    await db.execute('''
      CREATE TABLE Transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceNumber TEXT UNIQUE NOT NULL,
        transactionDate TEXT NOT NULL,
        totalAmount INTEGER NOT NULL,
        paidAmount INTEGER NOT NULL,
        changeAmount INTEGER NOT NULL DEFAULT 0,
        paymentMethod TEXT NOT NULL,
        cashierName TEXT DEFAULT 'Staf Kasir',
        notes TEXT
      )
    ''');

    // 4. Tabel TransactionItems
    await db.execute('''
      CREATE TABLE TransactionItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        priceAtSale INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        FOREIGN KEY (transactionId) REFERENCES Transactions (id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES Products (id)
      )
    ''');

    // 5. Tabel ProductionLogs (Formula 1 Butir Kelapa = 3 Cup Es)
    await db.execute('''
      CREATE TABLE ProductionLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productionDate TEXT NOT NULL,
        coconutUsed INTEGER NOT NULL,
        cupProduced INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    // 6. Tabel Expenses (Kas Kecil Lapak)
    await db.execute('''
      CREATE TABLE Expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expenseDate TEXT NOT NULL,
        category TEXT NOT NULL,
        amount INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    // Seed Data Awal Toko & Produk Sarjana Degan
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // 1. Identitas Default Cabang 1
    await db.insert('StoreProfile', {
      'storeName': 'Sarjana Degan',
      'branchName': 'Cabang 1 - Alun-Alun Madiun',
      'address': 'Jl. Pahlawan No. 12, Madiun',
      'phone': '0812-3456-7890',
      'receiptFooter': 'Terima Kasih! Segarnya Kelapa Alami Tanpa Pemanis Buatan.',
    });

    // 2. Sample Master Produk
    final initialProducts = [
      {
        'productCode': 'PRD-001',
        'name': 'Kelapa Muda Ijo Utuh',
        'category': 'Kelapa',
        'price': 12000,
        'costPrice': 8000,
        'stock': 50,
        'unit': 'Butir',
        'isActive': 1,
      },
      {
        'productCode': 'PRD-002',
        'name': 'Kelapa Muda Wulung',
        'category': 'Kelapa',
        'price': 15000,
        'costPrice': 10000,
        'stock': 30,
        'unit': 'Butir',
        'isActive': 1,
      },
      {
        'productCode': 'PRD-003',
        'name': 'Kelapa Kupas Siap Minum',
        'category': 'Kelapa',
        'price': 14000,
        'costPrice': 8500,
        'stock': 25,
        'unit': 'Butir',
        'isActive': 1,
      },
      {
        'productCode': 'PRD-004',
        'name': 'Es Degan Gula Jawa',
        'category': 'Es Cup',
        'price': 6000,
        'costPrice': 2500,
        'stock': 60,
        'unit': 'Cup',
        'isActive': 1,
      },
      {
        'productCode': 'PRD-005',
        'name': 'Es Degan Sirup Merah',
        'category': 'Es Cup',
        'price': 6000,
        'costPrice': 2500,
        'stock': 40,
        'unit': 'Cup',
        'isActive': 1,
      },
      {
        'productCode': 'PRD-006',
        'name': 'Es Degan Original Murni',
        'category': 'Es Cup',
        'price': 5000,
        'costPrice': 2000,
        'stock': 30,
        'unit': 'Cup',
        'isActive': 1,
      },
      {
        'productCode': 'PRD-007',
        'name': 'Es Degan Susu',
        'category': 'Es Cup',
        'price': 7000,
        'costPrice': 3000,
        'stock': 20,
        'unit': 'Cup',
        'isActive': 1,
      },
    ];

    for (final prod in initialProducts) {
      await db.insert('Products', prod);
    }
  }

  // ==========================================
  // OPERASI STORE PROFILE
  // ==========================================
  Future<StoreProfile> getStoreProfile() async {
    final db = await instance.database;
    final maps = await db.query('StoreProfile', limit: 1);
    if (maps.isNotEmpty) {
      return StoreProfile.fromMap(maps.first);
    }
    return StoreProfile(branchName: 'Cabang 1 - Madiun');
  }

  Future<int> updateStoreProfile(StoreProfile profile) async {
    final db = await instance.database;
    return await db.update(
      'StoreProfile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id ?? 1],
    );
  }

  // ==========================================
  // OPERASI PRODUK (MASTER & STOK)
  // ==========================================
  Future<List<Product>> getProducts({String? category, String? query}) async {
    final db = await instance.database;
    String whereClause = 'isActive = 1';
    List<dynamic> whereArgs = [];

    if (category != null && category.isNotEmpty && category != 'Semua') {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    if (query != null && query.trim().isNotEmpty) {
      whereClause += ' AND (name LIKE ? OR productCode LIKE ?)';
      whereArgs.add('%$query%');
      whereArgs.add('%$query%');
    }

    final result = await db.query(
      'Products',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'category ASC, name ASC',
    );

    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    return await db.insert('Products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return await db.update(
      'Products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    // Soft delete agar histori transaksi tidak rusak
    return await db.update(
      'Products',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateProductStock(int productId, int delta) async {
    final db = await instance.database;
    await db.rawUpdate('''
      UPDATE Products SET stock = stock + ? WHERE id = ?
    ''', [delta, productId]);
  }

  // ==========================================
  // OPERASI TRANSAKSI (INVOICE & KASIR)
  // ==========================================
  Future<String> generateInvoiceNumber() async {
    final db = await instance.database;
    final now = DateTime.now();
    final yyyymmdd = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final prefix = 'TRX-$yyyymmdd-';

    final result = await db.rawQuery('''
      SELECT invoiceNumber FROM Transactions 
      WHERE invoiceNumber LIKE ? 
      ORDER BY id DESC LIMIT 1
    ''', ['$prefix%']);

    int nextNum = 1;
    if (result.isNotEmpty) {
      final lastInvoice = result.first['invoiceNumber'] as String? ?? '';
      final parts = lastInvoice.split('-');
      if (parts.length >= 3) {
        final lastSeq = int.tryParse(parts.last) ?? 0;
        nextNum = lastSeq + 1;
      }
    }

    return '$prefix${nextNum.toString().padLeft(3, '0')}';
  }

  Future<int> createTransaction(TransactionModel tx) async {
    final db = await instance.database;

    return await db.transaction((txn) async {
      // 1. Insert header Transaksi
      final txId = await txn.insert('Transactions', tx.toMap());

      // 2. Insert items & potong stok
      for (final item in tx.items) {
        final itemMap = item.toMap();
        itemMap['transactionId'] = txId;
        await txn.insert('TransactionItems', itemMap);

        // Potong stok produk otomatis
        await txn.rawUpdate('''
          UPDATE Products SET stock = stock - ? WHERE id = ?
        ''', [item.quantity, item.productId]);
      }

      return txId;
    });
  }

  Future<List<TransactionModel>> getTransactions({DateTime? date}) async {
    final db = await instance.database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (date != null) {
      final ymd = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      whereClause = "transactionDate LIKE ?";
      whereArgs = ['$ymd%'];
    }

    final txRows = await db.query(
      'Transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'id DESC',
    );

    List<TransactionModel> transactions = [];
    for (final row in txRows) {
      final txId = row['id'] as int;
      final itemRows = await db.query(
        'TransactionItems',
        where: 'transactionId = ?',
        whereArgs: [txId],
      );
      final items = itemRows.map((m) => TransactionItem.fromMap(m)).toList();
      transactions.add(TransactionModel.fromMap(row, items: items));
    }

    return transactions;
  }

  // ==========================================
  // OPERASI PRODUKSI ES CUP (FORMULA 1 : 3)
  // ==========================================
  Future<void> recordProduction({
    required int coconutId,
    required int coconutUsed,
    required int targetEsCupId,
    String? notes,
  }) async {
    final db = await instance.database;
    final cupsProduced = coconutUsed * 3; // 1 Butir Kelapa = 3 Cup Es

    await db.transaction((txn) async {
      // 1. Potong stok kelapa butir
      await txn.rawUpdate('''
        UPDATE Products SET stock = stock - ? WHERE id = ?
      ''', [coconutUsed, coconutId]);

      // 2. Tambah stok es cup
      await txn.rawUpdate('''
        UPDATE Products SET stock = stock + ? WHERE id = ?
      ''', [cupsProduced, targetEsCupId]);

      // 3. Catat di ProductionLogs
      await txn.insert('ProductionLogs', {
        'productionDate': DateTime.now().toIso8601String(),
        'coconutUsed': coconutUsed,
        'cupProduced': cupsProduced,
        'notes': notes ?? 'Produksi otomatis 1 kelapa = 3 cup es',
      });
    });
  }

  Future<List<ProductionLog>> getProductionLogs() async {
    final db = await instance.database;
    final maps = await db.query('ProductionLogs', orderBy: 'id DESC');
    return maps.map((m) => ProductionLog.fromMap(m)).toList();
  }

  // ==========================================
  // OPERASI EXPENSES (KAS OPERASIONAL)
  // ==========================================
  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('Expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses({DateTime? date}) async {
    final db = await instance.database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (date != null) {
      final ymd = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      whereClause = "expenseDate LIKE ?";
      whereArgs = ['$ymd%'];
    }

    final maps = await db.query(
      'Expenses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'id DESC',
    );
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete('Expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // RINGKASAN HARIAN (OMZET, PENGELUARAN, KAS BERSIH)
  // ==========================================
  Future<Map<String, int>> getDailySummary(DateTime date) async {
    final db = await instance.database;
    final ymd = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Total Omzet
    final txResult = await db.rawQuery('''
      SELECT SUM(totalAmount) as totalRev, COUNT(id) as totalTx 
      FROM Transactions 
      WHERE transactionDate LIKE ?
    ''', ['$ymd%']);

    final totalRev = (txResult.first['totalRev'] as num?)?.toInt() ?? 0;
    final totalTx = (txResult.first['totalTx'] as num?)?.toInt() ?? 0;

    // Total Pengeluaran
    final expResult = await db.rawQuery('''
      SELECT SUM(amount) as totalExp 
      FROM Expenses 
      WHERE expenseDate LIKE ?
    ''', ['$ymd%']);

    final totalExp = (expResult.first['totalExp'] as num?)?.toInt() ?? 0;
    final netCash = totalRev - totalExp;

    return {
      'totalRevenue': totalRev,
      'transactionCount': totalTx,
      'totalExpenses': totalExp,
      'netCash': netCash,
    };
  }
}
