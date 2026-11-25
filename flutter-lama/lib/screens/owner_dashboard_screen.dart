import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/transaction_model.dart';
import '../database/database_helper.dart';
import 'cashier_pos_screen.dart';

/// Layar Dashboard 1 Pintu Khusus Owner (Mas Dicky - PIN 8888)
/// Memantau Omzet Gabungan, Sisa Stok per Cabang, & Distribusi Kelapa
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  // Filter Cabang Aktif: 'Semua', 'SD01', 'SD02'
  String _selectedOutletFilter = 'Semua';

  bool _isLoading = true;
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  // Data Konsolidasi
  Map<String, int> _activeSummary = {
    'totalRevenue': 0,
    'transactionCount': 0,
    'totalCash': 0,
    'totalQris': 0,
    'totalExpenses': 0,
    'netCash': 0,
  };

  // Data Per Cabang Spesifik (Untuk Perbandingan)
  Map<String, int> _sd01Summary = {};
  Map<String, int> _sd02Summary = {};

  List<Product> _products = [];
  List<TransactionModel> _recentTransactions = [];
  List<Map<String, dynamic>> _stockTransfers = [];

  @override
  void initState() {
    super.initState();
    _loadAllOwnerData();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _loadAllOwnerData() async {
    setState(() => _isLoading = true);

    try {
      final summary = await DatabaseHelper.instance.getDailySummary(
        DateTime.now(),
        outletCode: _selectedOutletFilter,
      );
      final sd01 = await DatabaseHelper.instance.getDailySummary(
        DateTime.now(),
        outletCode: 'SD01',
      );
      final sd02 = await DatabaseHelper.instance.getDailySummary(
        DateTime.now(),
        outletCode: 'SD02',
      );
      final products = await DatabaseHelper.instance.getProducts();
      final transactions = await DatabaseHelper.instance.getTransactions(
        date: DateTime.now(),
        outletCode: _selectedOutletFilter,
      );
      final transfers = await DatabaseHelper.instance.getAllStockTransfers();

      if (mounted) {
        setState(() {
          _activeSummary = summary;
          _sd01Summary = sd01;
          _sd02Summary = sd02;
          _products = products;
          _recentTransactions = transactions;
          _stockTransfers = transfers;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) buffer.write('.');
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s WIB';
  }

  String _formatDate(DateTime dt) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFF15803D), size: 22),
            SizedBox(width: 8),
            Text('Kunci Konsol Owner?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Anda akan keluar dari sesi Pemilik Usaha dan kembali ke layar PIN.',
          style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Kunci Layar'),
          ),
        ],
      ),
    );
  }

  int _calculateOutletStock(String outletKeyword) {
    return _stockTransfers
        .where((t) =>
            (t['targetOutlet'] as String? ?? '').contains(outletKeyword) &&
            (t['status'] == 'DITERIMA' || t['status'] == 'DITERIMA_SELISIH'))
        .fold(0, (sum, t) => sum + ((t['receivedQuantity'] as int?) ?? (t['sentQuantity'] as int? ?? 0)));
  }

  int _countPendingOutlet(String outletKeyword) {
    return _stockTransfers
        .where((t) =>
            (t['targetOutlet'] as String? ?? '').contains(outletKeyword) &&
            t['status'] == 'PENDING')
        .length;
  }

  void _openSendTransferModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OwnerQuickTransferModal(
        products: _products.where((p) => p.category == 'Kelapa').toList(),
        onTransferCreated: () {
          _loadAllOwnerData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildExecutiveHeader(),
            _buildFilterTabs(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF15803D)))
                  : RefreshIndicator(
                      color: const Color(0xFF15803D),
                      onRefresh: _loadAllOwnerData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Kartu Metrik Finansial Utama ───────────────────────
                            _buildPrimaryRevenueCard(),
                            const SizedBox(height: 14),

                            // ── Perbandingan Omzet Antar Cabang ───────────────────
                            if (_selectedOutletFilter == 'Semua') ...[
                              _buildBranchComparisonSection(),
                              const SizedBox(height: 14),
                            ],

                            // ── Pemantauan Stok Master & Kiriman ──────────────────
                            _buildStockAndDistributionSection(),
                            const SizedBox(height: 14),

                            // ── Transaksi Terbaru Lintas Cabang ────────────────────
                            _buildRecentTransactionsSection(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildOwnerBottomBar(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  EXECUTIVE HEADER — Nuansa Royal Emerald Khusus Mas Dicky
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildExecutiveHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF14532D),
        boxShadow: [
          BoxShadow(color: Color(0x20000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
            ),
            child: const Center(child: Text('👑', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'KONSOL OWNER 1 PINTU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF86EFAC),
                  letterSpacing: 1.1,
                ),
              ),
              const Text(
                'Dicky • Sarjana Degan Madiun',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                '${_formatDate(_now)} • ${_formatTime(_now)}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFFD1FAE5), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Spacer(),
          // Tombol Kunci Layar
          IconButton(
            tooltip: 'Kunci Layar',
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SEGMENTED FILTER 1 PINTU — Semua / Cabang 1 / Cabang 2
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterSegment('Semua', 'Semua Cabang (Konsolidasi)', Icons.hub_outlined),
          const SizedBox(width: 8),
          _buildFilterSegment('SD01', 'Cabang 1 (Alun-Alun)', Icons.location_on_outlined),
          const SizedBox(width: 8),
          _buildFilterSegment('SD02', 'Cabang 2 (Pasar Besar)', Icons.store_outlined),
        ],
      ),
    );
  }

  Widget _buildFilterSegment(String code, String label, IconData icon) {
    final isSelected = _selectedOutletFilter == code;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (_selectedOutletFilter != code) {
            setState(() => _selectedOutletFilter = code);
            _loadAllOwnerData();
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF15803D) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF15803D) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: isSelected ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(height: 2),
              Text(
                code == 'Semua' ? 'Konsolidasi' : (code == 'SD01' ? 'Cabang 1' : 'Cabang 2'),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  KARTU METRIK UTAMA — Omzet & Pemisahan Tunai vs QRIS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPrimaryRevenueCard() {
    final totalRev = _activeSummary['totalRevenue'] ?? 0;
    final totalCash = _activeSummary['totalCash'] ?? 0;
    final totalQris = _activeSummary['totalQris'] ?? 0;
    final totalTx = _activeSummary['transactionCount'] ?? 0;

    String filterTitle = 'Total Omzet Gabungan Seluruh Outlet';
    if (_selectedOutletFilter == 'SD01') filterTitle = 'Omzet Cabang 1 (Alun-Alun Madiun)';
    if (_selectedOutletFilter == 'SD02') filterTitle = 'Omzet Cabang 2 (Pasar Besar Madiun)';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF15803D), Color(0xFF166534)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x2415803D), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  filterTitle.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFA7F3D0), letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
                child: Text('$totalTx Nota', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(totalRev),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0x33FFFFFF)),
          const SizedBox(height: 12),
          // Pemisahan Kas Fisik Tunai vs QRIS
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.payments_outlined, size: 14, color: Color(0xFF86EFAC)),
                          SizedBox(width: 4),
                          Text('Kas Fisik (Tunai)', style: TextStyle(fontSize: 10, color: Color(0xFFD1FAE5), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(totalCash),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const Text('Wajib disetor kasir', style: TextStyle(fontSize: 9, color: Color(0xFFA7F3D0))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.qr_code_scanner, size: 14, color: Color(0xFF93C5FD)),
                          SizedBox(width: 4),
                          Text('QRIS / Transfer', style: TextStyle(fontSize: 10, color: Color(0xFFDBEAFE), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(totalQris),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const Text('Masuk rekening bank', style: TextStyle(fontSize: 9, color: Color(0xFFBFDBFE))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PERBANDINGAN OMZET ANTAR CABANG (Cabang 1 vs Cabang 2)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBranchComparisonSection() {
    final c1Rev = _sd01Summary['totalRevenue'] ?? 0;
    final c1Tx = _sd01Summary['transactionCount'] ?? 0;
    final c2Rev = _sd02Summary['totalRevenue'] ?? 0;
    final c2Tx = _sd02Summary['transactionCount'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perbandingan Kinerja Antar Cabang',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildBranchCard(
                'Cabang 1 - Alun-Alun',
                'SD-01',
                c1Rev,
                c1Tx,
                const Color(0xFF15803D),
                const Color(0xFFDCFCE7),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBranchCard(
                'Cabang 2 - Pasar Besar',
                'SD-02',
                c2Rev,
                c2Tx,
                const Color(0xFF0284C7),
                const Color(0xFFE0F2FE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBranchCard(String title, String code, int rev, int tx, Color accentColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
                child: Text(code, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: accentColor)),
              ),
              const Spacer(),
              Text('$tx Trx', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatRupiah(rev),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: accentColor),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PEMANTAUAN STOK MASTER & HISTORI KIRIMAN KELAPA
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStockAndDistributionSection() {
    final pendingTransfers = _stockTransfers.where((t) => t['status'] == 'PENDING').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Stok Master & Distribusi Kelapa',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const Spacer(),
            InkWell(
              onTap: _openSendTransferModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_shipping_outlined, size: 13, color: Color(0xFF1D4ED8)),
                    SizedBox(width: 4),
                    Text('+ Kirim Kelapa', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Banner Kiriman Pending jika ada
        if (pendingTransfers.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top_rounded, size: 16, color: Color(0xFFB45309)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ada ${pendingTransfers.length} surat jalan kelapa sedang dikirim (menunggu verifikasi fisik kasir).',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Ringkasan Alokasi Stok Kelapa ke Cabang
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stok Masuk Cabang 1', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                    const SizedBox(height: 4),
                    Text(
                      '${_calculateOutletStock('Cabang 1')} Butir',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                    ),
                    Text(
                      '${_countPendingOutlet('Cabang 1')} pengiriman pending',
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF15803D)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stok Masuk Cabang 2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF075985))),
                    const SizedBox(height: 4),
                    Text(
                      '${_calculateOutletStock('Cabang 2')} Butir',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0284C7)),
                    ),
                    Text(
                      '${_countPendingOutlet('Cabang 2')} pengiriman pending',
                      style: const TextStyle(fontSize: 9.5, color: Color(0xFF0284C7)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Grid Stok Ringkas Produk
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: _products.map((p) {
              final isKelapa = p.category == 'Kelapa';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(isKelapa ? Icons.eco_outlined : Icons.local_drink_outlined, size: 16, color: isKelapa ? const Color(0xFF15803D) : const Color(0xFF0284C7)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(p.name, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    ),
                    Text(
                      _formatRupiah(p.price),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: p.stock <= 5 ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${p.stock} ${p.unit}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: p.stock <= 5 ? const Color(0xFFDC2626) : const Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TRANSAKSI TERBARU LINTAS CABANG
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Transaksi Masuk Hari Ini',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        if (_recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text('Belum ada transaksi di cabang yang dipilih.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
            ),
          )
        else
          ..._recentTransactions.take(6).map((tx) {
            final isSd01 = tx.invoiceNumber.contains('SD01');
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSd01 ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isSd01 ? 'Cabang 1' : 'Cabang 2',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isSd01 ? const Color(0xFF15803D) : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx.invoiceNumber, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                        Text('${tx.paymentMethod} • ${tx.items.length} item', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Text(
                    _formatRupiah(tx.totalAmount),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BOTTOM BAR KHUSUS OWNER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildOwnerBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CashierPosScreen(
                      branchName: 'Cabang 1',
                      shiftName: 'Pagi',
                      isOwner: true,
                    ),
                  ),
                ).then((_) => _loadAllOwnerData());
              },
              icon: const Icon(Icons.point_of_sale_rounded, size: 16, color: Color(0xFF15803D)),
              label: const Text('Buka Kasir POS', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF86EFAC)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _openSendTransferModal,
              icon: const Icon(Icons.share_location_outlined, size: 16),
              label: const Text('Kirim Kelapa', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  MODAL CEPAT OWNER KIRIM KELAPA KE CABANG
// ══════════════════════════════════════════════════════════════════════════
class _OwnerQuickTransferModal extends StatefulWidget {
  final List<Product> products;
  final VoidCallback onTransferCreated;

  const _OwnerQuickTransferModal({
    required this.products,
    required this.onTransferCreated,
  });

  @override
  State<_OwnerQuickTransferModal> createState() => _OwnerQuickTransferModalState();
}

class _OwnerQuickTransferModalState extends State<_OwnerQuickTransferModal> {
  String _targetOutlet = 'Cabang 1 (Alun-Alun)';
  int? _selectedProductId;
  int _quantity = 50;
  final TextEditingController _notesController = TextEditingController(text: 'Kiriman rutin pick-up');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.products.isNotEmpty) {
      _selectedProductId = widget.products.first.id;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitTransfer() async {
    if (_selectedProductId == null || _quantity <= 0) return;

    setState(() => _isSaving = true);

    try {
      final selectedProd = widget.products.firstWhere((p) => p.id == _selectedProductId);
      await DatabaseHelper.instance.createStockTransfer(
        targetOutlet: _targetOutlet,
        productId: selectedProd.id!,
        productName: selectedProd.name,
        sentQuantity: _quantity,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onTransferCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Surat jalan dikirim: $_quantity butir ke $_targetOutlet (Menunggu verifikasi kasir).'),
            backgroundColor: const Color(0xFF15803D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: Color(0xFF15803D), size: 22),
              const SizedBox(width: 8),
              const Text('Kirim Kelapa ke Cabang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 18)),
            ],
          ),
          const SizedBox(height: 12),
          // Pilih Cabang Tujuan
          const Text('Cabang Tujuan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Cabang 1 (Alun-Alun)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  selected: _targetOutlet.contains('Cabang 1'),
                  selectedColor: const Color(0xFFDCFCE7),
                  onSelected: (_) => setState(() => _targetOutlet = 'Cabang 1 (Alun-Alun)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Cabang 2 (Pasar Besar)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  selected: _targetOutlet.contains('Cabang 2'),
                  selectedColor: const Color(0xFFDCFCE7),
                  onSelected: (_) => setState(() => _targetOutlet = 'Cabang 2 (Pasar Besar)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Jumlah Butir
          const Text('Jumlah Butir Kelapa:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildQtyButton(20),
              const SizedBox(width: 6),
              _buildQtyButton(30),
              const SizedBox(width: 6),
              _buildQtyButton(50),
              const SizedBox(width: 6),
              _buildQtyButton(100),
              const Spacer(),
              Text('$_quantity Butir', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF15803D))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submitTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Buat Surat Jalan Kirim', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(int val) {
    final isSelected = _quantity == val;
    return InkWell(
      onTap: () => setState(() => _quantity = val),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF15803D) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '+$val',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

