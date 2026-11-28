import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/transaction_model.dart';
import '../models/expense.dart';

/// Ruang Khusus Owner (Mas Dicky) - PIN 8888
/// Terpisah 100% dari Layar Kasir:
/// 1. Ringkasan Omzet, Laba Kotor & Laba Bersih
/// 2. Kirim Stok Kelapa ke Cabang (StockTransfers)
/// 3. Kelola 21 Menu, Harga Jual, Harga Modal & Stok
/// 4. Audit Nota Transaksi & Pengeluaran Lapak
class OwnerDashboardScreen extends StatefulWidget {
  final String branchName;

  const OwnerDashboardScreen({
    super.key,
    required this.branchName,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedTab = 0;
  bool _isLoading = true;

  Map<String, dynamic> _summary = {};
  List<Product> _products = [];
  List<Map<String, dynamic>> _transfers = [];
  List<TransactionModel> _transactions = [];
  List<Expense> _expenses = [];

  static const Color _bgCanvas = Color(0xFFF1F5F9);
  static const Color _navyDark = Color(0xFF0F172A);
  static const Color _navyCard = Color(0xFF1E293B);
  static const Color _emerald = Color(0xFF10B981);
  static const Color _emeraldDark = Color(0xFF059669);
  static const Color _amber = Color(0xFFD97706);

  @override
  void initState() {
    super.initState();
    _loadOwnerData();
  }

  Future<void> _loadOwnerData() async {
    setState(() => _isLoading = true);
    try {
      final db = DatabaseHelper.instance;
      final summary = await db.getOwnerProfitSummary();
      final products = await db.getProducts(query: null);
      final transfers = await db.getAllStockTransfers();
      final txs = await db.getTransactions(date: DateTime.now());
      final exps = await db.getExpenses(date: DateTime.now());
      if (mounted) {
        setState(() {
          _summary = summary;
          _products = products;
          _transfers = transfers;
          _transactions = txs;
          _expenses = exps;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _rp(int nominal) {
    final str = nominal.abs().toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buf.write(str[i]);
      c++;
      if (c % 3 == 0 && i > 0) buf.write('.');
    }
    final fmt = buf.toString().split('').reversed.join('');
    return nominal < 0 ? '-Rp $fmt' : 'Rp $fmt';
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Ruang Owner?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Anda akan kembali ke layar pemilihan PIN.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 820;

    return Scaffold(
      backgroundColor: _bgCanvas,
      appBar: AppBar(
        backgroundColor: _navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('👑', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ruang Kontrol Owner • Mas Dicky',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Sarjana Degan Madiun • Mode Pemilik',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadOwnerData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang Data',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFFCA5A5)),
              label: const Text('Keluar', style: TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Navigasi Owner (4 Pilar Kontrol)
          Container(
            color: _navyCard,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildNavTab(0, Icons.analytics_outlined, 'Ringkasan & Laba'),
                  const SizedBox(width: 8),
                  _buildNavTab(1, Icons.local_shipping_outlined, 'Kirim Kelapa'),
                  const SizedBox(width: 8),
                  _buildNavTab(2, Icons.restaurant_menu_rounded, 'Kelola 21 Menu & Harga'),
                  const SizedBox(width: 8),
                  _buildNavTab(3, Icons.receipt_long_outlined, 'Audit Nota & Biaya'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _emeraldDark))
                : RefreshIndicator(
                    onRefresh: _loadOwnerData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isWide ? 24 : 16),
                      child: _buildSelectedBody(isWide),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTab(int index, IconData icon, String label) {
    final active = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _emerald : const Color(0xFF334155),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedBody(bool isWide) {
    switch (_selectedTab) {
      case 0:
        return _buildSummaryTab(isWide);
      case 1:
        return _buildStockTransferTab();
      case 2:
        return _buildManageMenuTab();
      case 3:
        return _buildAuditTab();
      default:
        return _buildSummaryTab(isWide);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: RINGKASAN OMZET, LABA KOTOR & SETORAN
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSummaryTab(bool isWide) {
    final totalRev = _summary['totalRevenue'] as int? ?? 0;
    final cashRev = _summary['cashRevenue'] as int? ?? 0;
    final qrisRev = _summary['qrisRevenue'] as int? ?? 0;
    final totalCogs = _summary['totalCogs'] as int? ?? 0;
    final grossProfit = _summary['grossProfit'] as int? ?? 0;
    final totalExp = _summary['totalExpenses'] as int? ?? 0;
    final netProfit = _summary['netProfit'] as int? ?? 0;
    final depositCash = _summary['depositCash'] as int? ?? 100000;
    final txCount = _summary['transactionCount'] as int? ?? 0;
    final coconutStock = _summary['coconutStock'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Laba Bersih & Omzet
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_navyDark, Color(0xFF065F46)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ESTIMASI LABA BERSIH HARI INI',
                style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8),
              ),
              const SizedBox(height: 6),
              Text(
                _rp(netProfit),
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Omzet ${_rp(totalRev)}  −  Modal HPP ${_rp(totalCogs)}  −  Biaya Lapak ${_rp(totalExp)}',
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grid Metrik Keuangan
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWide ? 2.1 : 1.55,
          children: [
            _metricCard('Total Omzet ($txCount Nota)', _rp(totalRev), 'Tunai + QRIS', Icons.payments_outlined, _emeraldDark),
            _metricCard('Laba Kotor (Margin)', _rp(grossProfit), 'Omzet − Harga Modal', Icons.trending_up_rounded, const Color(0xFF2563EB)),
            _metricCard('Wajib Setor Kasir', _rp(depositCash), 'Modal + Tunai − Biaya', Icons.account_balance_wallet_outlined, _amber),
            _metricCard('Omzet Tunai', _rp(cashRev), 'Masuk Laci Kasir', Icons.money_rounded, _emeraldDark),
            _metricCard('Omzet QRIS', _rp(qrisRev), 'Langsung Rekening', Icons.qr_code_2_rounded, const Color(0xFF7C3AED)),
            _metricCard('Sisa Stok Kelapa', '$coconutStock Butir', 'Siap Jual & Racik', Icons.eco_outlined, const Color(0xFF0D9488)),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(String title, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          Text(sub, style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: KIRIM KELAPA KE CABANG (OWNER ONLY)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStockTransferTab() {
    final coconutProducts = _products.where((p) => p.unit == 'Butir').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Distribusi Stok Kelapa ke Cabang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _navyDark),
            ),
            ElevatedButton.icon(
              onPressed: coconutProducts.isEmpty ? null : () => _showSendStockDialog(coconutProducts),
              style: ElevatedButton.styleFrom(
                backgroundColor: _emeraldDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Kirim Kelapa Baru', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_transfers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text('Belum ada riwayat kiriman kelapa ke cabang.', style: TextStyle(color: Color(0xFF64748B)))),
          )
        else
          ..._transfers.map((t) {
            final status = t['status']?.toString() ?? 'PENDING';
            final isPending = status == 'PENDING';
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                  child: Icon(
                    isPending ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
                    color: isPending ? _amber : _emeraldDark,
                  ),
                ),
                title: Text('${t['productName']} (${t['sentQuantity']} Butir)', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                subtitle: Text('${t['targetOutlet']} • ${t['transferNumber']} • Status: $status', style: const TextStyle(fontSize: 11.5)),
              ),
            );
          }),
      ],
    );
  }

  void _showSendStockDialog(List<Product> coconutProducts) {
    Product selectedProd = coconutProducts.first;
    String selectedOutlet = 'Cabang 1 - Alun-Alun';
    final qtyCtrl = TextEditingController(text: '30');
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Kirim Stok Kelapa ke Cabang', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedOutlet,
                  decoration: const InputDecoration(labelText: 'Cabang Tujuan', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Cabang 1 - Alun-Alun', child: Text('Cabang 1 - Alun-Alun')),
                    DropdownMenuItem(value: 'Cabang 2 - Pasar Besar', child: Text('Cabang 2 - Pasar Besar')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDlg(() => selectedOutlet = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Product>(
                  value: selectedProd,
                  decoration: const InputDecoration(labelText: 'Jenis Kelapa', border: OutlineInputBorder()),
                  items: coconutProducts.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                  onChanged: (v) {
                    if (v != null) setDlg(() => selectedProd = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah Kirim (Butir)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Catatan (Opsional)', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                if (qty <= 0 || selectedProd.id == null) return;
                await DatabaseHelper.instance.createStockTransfer(
                  targetOutlet: selectedOutlet,
                  productId: selectedProd.id!,
                  productName: selectedProd.name,
                  sentQuantity: qty,
                  notes: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _loadOwnerData();
              },
              style: ElevatedButton.styleFrom(backgroundColor: _emeraldDark, foregroundColor: Colors.white),
              child: const Text('Kirim Surat Jalan'),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3: KELOLA 21 MENU, HARGA JUAL, HARGA MODAL & STOK
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildManageMenuTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kelola Harga Jual, Harga Modal & Stok (21 Menu)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _navyDark),
        ),
        const SizedBox(height: 12),
        ..._products.map((p) {
          final margin = p.price - p.costPrice;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: p.imagePath != null
                    ? Image.asset(p.imagePath!, width: 46, height: 46, fit: BoxFit.cover, cacheWidth: 100)
                    : const Icon(Icons.local_drink_rounded, size: 36),
              ),
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
              subtitle: Text(
                'Jual: ${_rp(p.price)} • Modal: ${_rp(p.costPrice)} • Untung: ${_rp(margin)} • Stok: ${p.stock} ${p.unit}',
                style: const TextStyle(fontSize: 11.5),
              ),
              trailing: IconButton(
                onPressed: () => _showEditProductDialog(p),
                icon: const Icon(Icons.edit_rounded, color: _emeraldDark),
                tooltip: 'Ubah Harga & Stok',
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showEditProductDialog(Product prod) {
    final priceCtrl = TextEditingController(text: prod.price.toString());
    final costCtrl = TextEditingController(text: prod.costPrice.toString());
    final stockCtrl = TextEditingController(text: prod.stock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${prod.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Jual (Rp)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga Modal / HPP (Rp)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Stok Saat Ini (${prod.unit})', border: const OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final updated = prod.copyWith(
                price: int.tryParse(priceCtrl.text.trim()) ?? prod.price,
                costPrice: int.tryParse(costCtrl.text.trim()) ?? prod.costPrice,
                stock: int.tryParse(stockCtrl.text.trim()) ?? prod.stock,
              );
              await DatabaseHelper.instance.updateProduct(updated);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadOwnerData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: _emeraldDark, foregroundColor: Colors.white),
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 4: AUDIT NOTA TRANSAKSI & BIAYA LAPAK HARI INI
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAuditTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riwayat Transaksi Hari Ini (${_transactions.length} Nota)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _navyDark)),
        const SizedBox(height: 10),
        if (_transactions.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Belum ada transaksi hari ini.')))
        else
          ..._transactions.map((tx) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(tx.paymentMethod == 'QRIS' ? Icons.qr_code_2 : Icons.payments_outlined, color: _emeraldDark),
                  title: Text('${tx.invoiceNumber} • ${_rp(tx.totalAmount)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  subtitle: Text('${tx.paymentMethod} • ${tx.cashierName}', style: const TextStyle(fontSize: 11.5)),
                ),
              )),
        const SizedBox(height: 20),
        Text('Pengeluaran Kas Kecil Hari Ini (${_expenses.length} Catatan)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _navyDark)),
        const SizedBox(height: 10),
        if (_expenses.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Belum ada pengeluaran kas kecil hari ini.')))
        else
          ..._expenses.map((ex) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.receipt_outlined, color: _amber),
                  title: Text('${ex.category} • -${_rp(ex.amount)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  subtitle: Text(ex.notes ?? '-', style: const TextStyle(fontSize: 11.5)),
                ),
              )),
      ],
    );
  }
}
