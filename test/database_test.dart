import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:kasir_pos/database/database_helper.dart';
import 'package:kasir_pos/models/transaction_model.dart';
import 'package:kasir_pos/models/transaction_item.dart';
import 'package:kasir_pos/models/expense.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper SQLite Offline-First Tests', () {
    final dbHelper = DatabaseHelper.instance;

    test('1. Database Inisialisasi & Seed Data Toko', () async {
      final profile = await dbHelper.getStoreProfile();
      expect(profile.storeName, 'Sarjana Degan');
      expect(profile.branchName.contains('Cabang 1'), true);
    });

    test('2. Query Master Produk Awal', () async {
      final products = await dbHelper.getProducts();
      expect(products.isNotEmpty, true);
      final kelapaIjo = products.firstWhere((p) => p.productCode == 'PRD-001');
      expect(kelapaIjo.name, 'Kelapa Muda Ijo Utuh');
      expect(kelapaIjo.stock, 50);
    });

    test('3. Transaksi Penjualan Memotong Stok Otomatis', () async {
      final products = await dbHelper.getProducts();
      final kelapa = products.firstWhere((p) => p.productCode == 'PRD-001');
      final initialStock = kelapa.stock;

      final invoice = await dbHelper.generateInvoiceNumber();
      expect(invoice.startsWith('TRX-'), true);

      final tx = TransactionModel(
        invoiceNumber: invoice,
        transactionDate: DateTime.now(),
        totalAmount: kelapa.price * 2,
        paidAmount: 50000,
        changeAmount: 50000 - (kelapa.price * 2),
        paymentMethod: 'TUNAI',
        items: [
          TransactionItem(
            productId: kelapa.id!,
            productName: kelapa.name,
            priceAtSale: kelapa.price,
            quantity: 2,
            subtotal: kelapa.price * 2,
          ),
        ],
      );

      final txId = await dbHelper.createTransaction(tx);
      expect(txId > 0, true);

      // Cek stok terpotong 2 butir
      final updatedProducts = await dbHelper.getProducts();
      final updatedKelapa = updatedProducts.firstWhere((p) => p.id == kelapa.id);
      expect(updatedKelapa.stock, initialStock - 2);
    });

    test('4. Formula Produksi Es Cup (1 Butir = 3 Cup) Atomic', () async {
      final products = await dbHelper.getProducts();
      final kelapa = products.firstWhere((p) => p.category == 'Kelapa');
      final esCup = products.firstWhere((p) => p.category == 'Es Cup');

      final initialKelapaStock = kelapa.stock;
      final initialEsStock = esCup.stock;

      // Konversi 5 butir kelapa -> 15 cup es
      await dbHelper.recordProduction(
        coconutId: kelapa.id!,
        coconutUsed: 5,
        targetEsCupId: esCup.id!,
        notes: 'Uji formula produksi otomatis',
      );

      final updatedProducts = await dbHelper.getProducts();
      final updatedKelapa = updatedProducts.firstWhere((p) => p.id == kelapa.id);
      final updatedEs = updatedProducts.firstWhere((p) => p.id == esCup.id);

      expect(updatedKelapa.stock, initialKelapaStock - 5);
      expect(updatedEs.stock, initialEsStock + 15);
    });

    test('5. Pencatatan Pengeluaran Kas & Ringkasan Kas Bersih', () async {
      await dbHelper.insertExpense(Expense(
        expenseDate: DateTime.now(),
        category: 'Es Batu',
        amount: 10000,
        notes: 'Beli es batu kristal 2 bal',
      ));

      final summary = await dbHelper.getDailySummary(DateTime.now());
      expect(summary['totalExpenses']! >= 10000, true);
      expect(summary['netCash'], summary['totalRevenue']! - summary['totalExpenses']!);
    });
  });
}

