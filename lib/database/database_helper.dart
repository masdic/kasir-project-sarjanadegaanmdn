import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
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
        final baseDir = Platform.environment['APPDATA'] ??
            Platform.environment['HOME'] ??
            Directory.current.path;
        path = join(baseDir, 'SarjanaDegan', filePath);
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
    } else if (kIsWeb) {
      path = inMemoryDatabasePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

    // Pastikan tabel SupplierDeliveries selalu tersedia
    await db.execute('''
      CREATE TABLE IF NOT EXISTS SupplierDeliveries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deliveryDate TEXT NOT NULL,
        outletCode TEXT NOT NULL,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        supplierName TEXT,
        notes TEXT
      )
    ''');

    // Tabel Distribusi Stok Terpusat (Pilihan 3: Owner Kirim ➔ Kasir Verifikasi)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS StockTransfers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transferNumber TEXT UNIQUE NOT NULL,
        transferDate TEXT NOT NULL,
        source TEXT NOT NULL DEFAULT 'Gudang Pusat (Owner)',
        targetOutlet TEXT NOT NULL,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        sentQuantity INTEGER NOT NULL,
        receivedQuantity INTEGER,
        status TEXT NOT NULL DEFAULT 'PENDING',
        notes TEXT,
        discrepancyReason TEXT,
        receivedDate TEXT,
        receivedBy TEXT
      )
    ''');

    // Tabel AppSettings (Penyimpanan permanen preferensi notifikasi & nada dering)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS AppSettings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Pastikan kolom imagePath tersedia pada tabel Products (migrasi aman)
    try {
      await db.execute('ALTER TABLE Products ADD COLUMN imagePath TEXT');
    } catch (_) {}

    // Sinkronkan 21 menu resmi Sarjana Degan dari papan menu
    await _syncOfficialMenu(db);

    return db;
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
        isActive INTEGER DEFAULT 1,
        imagePath TEXT
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

  static const List<Map<String, dynamic>> officialMenuCatalog = [
    {'productCode': 'SD-001', 'name': 'Es Degan Gula Merah', 'category': 'Es Degan Cup', 'price': 6000, 'costPrice': 2500, 'stock': 50, 'unit': 'Cup', 'isActive': 1, 'imagePath': 'assets/images/menu/es_degan_gula_merah.jpg'},
    {'productCode': 'SD-002', 'name': 'Es Degan Gula Putih', 'category': 'Es Degan Cup', 'price': 6000, 'costPrice': 2500, 'stock': 50, 'unit': 'Cup', 'isActive': 1, 'imagePath': 'assets/images/menu/es_degan_gula_putih.jpg'},
    {'productCode': 'SD-003', 'name': 'Es Degan Original', 'category': 'Es Degan Cup', 'price': 6000, 'costPrice': 2000, 'stock': 50, 'unit': 'Cup', 'isActive': 1, 'imagePath': 'assets/images/menu/es_degan_original.jpg'},
    {'productCode': 'SD-004', 'name': 'Es Degan Melon', 'category': 'Es Degan Cup', 'price': 9000, 'costPrice': 3500, 'stock': 40, 'unit': 'Cup', 'isActive': 1, 'imagePath': 'assets/images/menu/es_degan_melon.jpg'},
    {'productCode': 'SD-005', 'name': 'Es Degan Vanila', 'category': 'Es Degan Cup', 'price': 9000, 'costPrice': 3500, 'stock': 40, 'unit': 'Cup', 'isActive': 1, 'imagePath': 'assets/images/menu/es_degan_vanila.jpg'},
    {'productCode': 'SD-006', 'name': 'Air Kelapa 500ml', 'category': 'Air Kelapa & Morong', 'price': 8000, 'costPrice': 4000, 'stock': 30, 'unit': 'Botol', 'isActive': 1, 'imagePath': 'assets/images/menu/air_kelapa_500ml.jpg'},
    {'productCode': 'SD-007', 'name': 'Air Kelapa 1L', 'category': 'Air Kelapa & Morong', 'price': 15000, 'costPrice': 7500, 'stock': 25, 'unit': 'Botol', 'isActive': 1, 'imagePath': 'assets/images/menu/air_kelapa_1l.jpg'},
    {'productCode': 'SD-008', 'name': 'Es Degan Jeruk', 'category': 'Es Degan Cup', 'price': 8000, 'costPrice': 3500, 'stock': 40, 'unit': 'Cup', 'isActive': 1, 'imagePath': 'assets/images/menu/es_degan_jeruk.jpg'},
    {'productCode': 'SD-009', 'name': 'Es Teller Sarjana', 'category': 'Es Degan Cup', 'price': 10000, 'costPrice': 4500, 'stock': 35, 'unit': 'Cup', 'isActive': 1, 'imagePath': 'assets/images/menu/es_teller_sarjana.jpg'},
    {'productCode': 'SD-010', 'name': 'Es Degan Susu', 'category': 'Es Degan Cup', 'price': 9000, 'costPrice': 3500, 'stock': 40, 'unit': 'Cup', 'isActive': 1, 'imagePath': 'assets/images/menu/es_degan_susu.jpg'},
    {'productCode': 'SD-011', 'name': 'Es Degan Tropical', 'category': 'Es Degan Cup', 'price': 8000, 'costPrice': 3500, 'stock': 35, 'unit': 'Cup', 'isActive': 1, 'imagePath': 'assets/images/menu/es_degan_tropical.jpg'},
    {'productCode': 'SD-012', 'name': 'Degan Utuh Besar', 'category': 'Degan Utuh & Kupas', 'price': 15000, 'costPrice': 9500, 'stock': 48, 'unit': 'Butir', 'isActive': 1, 'imagePath': 'assets/images/menu/degan_utuh_besar.jpg'},
    {'productCode': 'SD-013', 'name': 'Degan Utuh Kecil', 'category': 'Degan Utuh & Kupas', 'price': 12000, 'costPrice': 7500, 'stock': 40, 'unit': 'Butir', 'isActive': 1, 'imagePath': 'assets/images/menu/degan_utuh_kecil.jpg'},
    {'productCode': 'SD-014', 'name': 'Kelapa Sereh/Ijo', 'category': 'Degan Utuh & Kupas', 'price': 22000, 'costPrice': 14000, 'stock': 20, 'unit': 'Butir', 'isActive': 1, 'imagePath': 'assets/images/menu/kelapa_sereh_ijo.jpg'},
    {'productCode': 'SD-015', 'name': 'Es Degan Cocopandan', 'category': 'Es Degan Cup', 'price': 9000, 'costPrice': 3500, 'stock': 40, 'unit': 'Cup', 'isActive': 1, 'imagePath': 'assets/images/menu/es_degan_cocopandan.jpg'},
    {'productCode': 'SD-016', 'name': 'Es Degan Satu Morong', 'category': 'Air Kelapa & Morong', 'price': 15000, 'costPrice': 6500, 'stock': 20, 'unit': 'Morong', 'isActive': 1, 'imagePath': 'assets/images/menu/es_degan_satu_morong.jpg'},
    {'productCode': 'SD-017', 'name': 'Es Teller Satu Morong', 'category': 'Air Kelapa & Morong', 'price': 25000, 'costPrice': 11000, 'stock': 15, 'unit': 'Morong', 'isActive': 1, 'imagePath': 'assets/images/menu/es_teller_satu_morong.jpg'},
    {'productCode': 'SD-018', 'name': 'Degan Kupas', 'category': 'Degan Utuh & Kupas', 'price': 13000, 'costPrice': 8000, 'stock': 30, 'unit': 'Butir', 'isActive': 1, 'imagePath': 'assets/images/menu/degan_kupas.jpg'},
    {'productCode': 'SD-019', 'name': 'Degan Jelly Ori', 'category': 'Menu Spesial', 'price': 15000, 'costPrice': 7000, 'stock': 20, 'unit': 'Porsi', 'isActive': 1, 'imagePath': 'assets/images/menu/degan_jelly_ori.jpg'},
    {'productCode': 'SD-020', 'name': 'Degan Jelly Buah', 'category': 'Menu Spesial', 'price': 25000, 'costPrice': 12000, 'stock': 15, 'unit': 'Porsi', 'isActive': 1, 'imagePath': 'assets/images/menu/degan_jelly_buah.jpg'},
    {'productCode': 'SD-021', 'name': 'Es Teler Kelapa Muda', 'category': 'Menu Spesial', 'price': 20000, 'costPrice': 9500, 'stock': 15, 'unit': 'Porsi', 'isActive': 1, 'imagePath': 'assets/images/menu/es_teler_kelapa_muda.jpg'},
  ];

  Future<void> _syncOfficialMenu(Database db) async {
    final existing = await db.query('Products', where: 'productCode = ?', whereArgs: ['SD-001'], limit: 1);
    if (existing.isEmpty) {
      // Nonaktifkan produk sample lama (PRD-001..PRD-007) agar kasir langsung melihat 21 menu resmi
      await db.update('Products', {'isActive': 0}, where: 'productCode LIKE ?', whereArgs: ['PRD-%']);
      for (final prod in officialMenuCatalog) {
        await db.insert('Products', prod, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
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

    // 2. 21 Menu Resmi Papan Sarjana Degan
    for (final prod in officialMenuCatalog) {
      await db.insert('Products', prod);
    }
  }

  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final rows = await db.query('AppSettings', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'AppSettings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
  Future<String> generateInvoiceNumber([String outletCode = 'SD01']) async {
    final db = await instance.database;
    final now = DateTime.now();
    final yyyymmdd = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final prefix = 'TRX-$outletCode-$yyyymmdd-';

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

  // ==========================================
  // HITUNG KAS & SETORAN FISIK KE MAS DICKY (FASE 6)
  // Rumus: Modal Awal + Omzet Tunai - Pengeluaran Lapak
  // ==========================================
  Future<Map<String, dynamic>> getShiftCashSettlement({
    DateTime? date,
    int initialCash = 100000,
  }) async {
    final db = await instance.database;
    final targetDate = date ?? DateTime.now();
    final ymd = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

    // 1. Penjualan Tunai
    final cashResult = await db.rawQuery('''
      SELECT SUM(totalAmount) as totalCash, COUNT(id) as countCash 
      FROM Transactions 
      WHERE transactionDate LIKE ? AND paymentMethod = 'Tunai'
    ''', ['$ymd%']);

    final totalCash = (cashResult.first['totalCash'] as num?)?.toInt() ?? 0;
    final countCash = (cashResult.first['countCash'] as num?)?.toInt() ?? 0;

    // 2. Penjualan QRIS (Non-Tunai / Langsung Rekening Mas Dicky)
    final qrisResult = await db.rawQuery('''
      SELECT SUM(totalAmount) as totalQris, COUNT(id) as countQris 
      FROM Transactions 
      WHERE transactionDate LIKE ? AND paymentMethod = 'QRIS'
    ''', ['$ymd%']);

    final totalQris = (qrisResult.first['totalQris'] as num?)?.toInt() ?? 0;
    final countQris = (qrisResult.first['countQris'] as num?)?.toInt() ?? 0;

    // 3. Total Pengeluaran Kas Kecil Lapak
    final expResult = await db.rawQuery('''
      SELECT SUM(amount) as totalExp 
      FROM Expenses 
      WHERE expenseDate LIKE ?
    ''', ['$ymd%']);

    final totalExp = (expResult.first['totalExp'] as num?)?.toInt() ?? 0;

    // 4. Hitung Setoran Uang Fisik Sesuai Rumus Resmi Mas Dicky:
    // Uang Fisik Wajib Setor = Modal Awal + Omzet Tunai - Pengeluaran Lapak
    final physicalCashToDeposit = initialCash + totalCash - totalExp;

    // 5. Total Omzet Gabungan
    final totalRevenue = totalCash + totalQris;
    final totalTransactions = countCash + countQris;

    // 6. Cek Sisa Stok Kelapa & Konversi Es Cup
    final stockResult = await db.rawQuery('''
      SELECT SUM(stock) as coconutStock 
      FROM Products 
      WHERE unit = 'Butir' AND isActive = 1
    ''');
    final coconutStock = (stockResult.first['coconutStock'] as num?)?.toInt() ?? 0;

    return {
      'date': ymd,
      'initialCash': initialCash,
      'cashRevenue': totalCash,
      'cashTxCount': countCash,
      'qrisRevenue': totalQris,
      'qrisTxCount': countQris,
      'totalExpenses': totalExp,
      'totalRevenue': totalRevenue,
      'transactionCount': totalTransactions,
      'depositCash': physicalCashToDeposit,
      'coconutStock': coconutStock,
    };
  }

  /// Ringkasan Keuangan & Estimasi Laba Kotor Khusus Owner
  Future<Map<String, dynamic>> getOwnerProfitSummary({DateTime? date}) async {
    final db = await instance.database;
    final targetDate = date ?? DateTime.now();
    final ymd =
        '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

    final settlement = await getShiftCashSettlement(date: targetDate);

    // Hitung total HPP (Cost of Goods Sold) dari item terjual hari ini
    final cogsResult = await db.rawQuery('''
      SELECT SUM(ti.quantity * COALESCE(p.costPrice, 0)) as totalCogs
      FROM TransactionItems ti
      INNER JOIN Transactions t ON ti.transactionId = t.id
      LEFT JOIN Products p ON ti.productId = p.id
      WHERE t.transactionDate LIKE ?
    ''', ['$ymd%']);

    final totalCogs = (cogsResult.first['totalCogs'] as num?)?.toInt() ?? 0;
    final totalRevenue = settlement['totalRevenue'] as int? ?? 0;
    final totalExpenses = settlement['totalExpenses'] as int? ?? 0;
    final grossProfit = totalRevenue - totalCogs;
    final netProfit = grossProfit - totalExpenses;

    return {
      ...settlement,
      'totalCogs': totalCogs,
      'grossProfit': grossProfit,
      'netProfit': netProfit,
    };
  }

  // ==========================================
  // OPERASI STOK KELAPA MASUK DARI SUPPLIER
  // ==========================================
  Future<void> recordSupplierDelivery({
    required String outletCode,
    required int productId,
    required String productName,
    required int quantity,
    String? supplierName,
    String? notes,
  }) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // 1. Simpan riwayat kiriman supplier
      await txn.insert('SupplierDeliveries', {
        'deliveryDate': DateTime.now().toIso8601String(),
        'outletCode': outletCode,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'supplierName': supplierName ?? 'Supplier Langganan',
        'notes': notes,
      });

      // 2. Tambah stok produk secara otomatis
      await txn.rawUpdate('''
        UPDATE Products SET stock = stock + ? WHERE id = ?
      ''', [quantity, productId]);
    });
  }

  Future<List<Map<String, dynamic>>> getSupplierDeliveries({String? outletCode}) async {
    final db = await instance.database;
    String? whereClause;
    List<dynamic>? whereArgs;
    if (outletCode != null) {
      whereClause = 'outletCode = ?';
      whereArgs = [outletCode];
    }
    return await db.query(
      'SupplierDeliveries',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'id DESC',
    );
  }

  // ==========================================
  // OPERASI DISTRIBUSI STOK OWNER (PILIHAN 3)
  // ==========================================
  Future<String> generateTransferNumber() async {
    final db = await instance.database;
    final now = DateTime.now();
    final ymd = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final prefix = 'TRF-$ymd-';

    final result = await db.rawQuery('''
      SELECT transferNumber FROM StockTransfers 
      WHERE transferNumber LIKE ? 
      ORDER BY id DESC LIMIT 1
    ''', ['$prefix%']);

    int nextNum = 1;
    if (result.isNotEmpty) {
      final lastNum = result.first['transferNumber'] as String? ?? '';
      final parts = lastNum.split('-');
      if (parts.length >= 3) {
        nextNum = (int.tryParse(parts.last) ?? 0) + 1;
      }
    }
    return '$prefix${nextNum.toString().padLeft(3, '0')}';
  }

  Future<int> createStockTransfer({
    required String targetOutlet,
    required int productId,
    required String productName,
    required int sentQuantity,
    String? notes,
  }) async {
    final db = await instance.database;
    final trfNumber = await generateTransferNumber();

    return await db.insert('StockTransfers', {
      'transferNumber': trfNumber,
      'transferDate': DateTime.now().toIso8601String(),
      'source': 'Gudang Pusat (Owner)',
      'targetOutlet': targetOutlet,
      'productId': productId,
      'productName': productName,
      'sentQuantity': sentQuantity,
      'status': 'PENDING',
      'notes': notes ?? 'Kiriman resmi Owner',
    });
  }

  Future<List<Map<String, dynamic>>> getPendingTransfers(String targetOutlet) async {
    final db = await instance.database;
    // Cari yang match targetOutlet atau alias (misal 'Cabang 1' vs 'SD01')
    return await db.query(
      'StockTransfers',
      where: "(targetOutlet = ? OR targetOutlet LIKE ?) AND status = 'PENDING'",
      whereArgs: [targetOutlet, '%$targetOutlet%'],
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllStockTransfers() async {
    final db = await instance.database;
    return await db.query('StockTransfers', orderBy: 'id DESC');
  }

  Future<void> confirmStockTransfer({
    required int transferId,
    required int productId,
    required int receivedQuantity,
    required String receivedBy,
    String? discrepancyReason,
  }) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // 1. Ambil data transfer lama untuk cek selisih
      final maps = await txn.query('StockTransfers', where: 'id = ?', whereArgs: [transferId], limit: 1);
      final sentQty = maps.isNotEmpty ? (maps.first['sentQuantity'] as int? ?? receivedQuantity) : receivedQuantity;
      final finalStatus = receivedQuantity == sentQty ? 'DITERIMA' : 'DITERIMA_SELISIH';

      // 2. Update status transfer
      await txn.update(
        'StockTransfers',
        {
          'receivedQuantity': receivedQuantity,
          'status': finalStatus,
          'receivedDate': DateTime.now().toIso8601String(),
          'receivedBy': receivedBy,
          'discrepancyReason': discrepancyReason,
        },
        where: 'id = ?',
        whereArgs: [transferId],
      );

      // 3. Tambah stok produk di cabang sesuai jumlah fisik yang benar-benar diterima
      await txn.rawUpdate('''
        UPDATE Products SET stock = stock + ? WHERE id = ?
      ''', [receivedQuantity, productId]);
    });
  }
}
