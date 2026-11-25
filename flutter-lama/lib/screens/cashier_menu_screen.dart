import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/transaction_model.dart';
import '../database/database_helper.dart';
import 'cashier_pos_screen.dart';

/// Layar Menu Kasir Modern - Sarjana Degan POS Madiun
/// TAHAP 1: Terhubung ke Database SQLite (Stok Real, Keranjang Belanja, Filter & Cari)
class CashierMenuScreen extends StatefulWidget {
  final String branchName;
  final String shiftName;
  final bool isOwner;

  const CashierMenuScreen({
    super.key,
    required this.branchName,
    required this.shiftName,
    this.isOwner = false,
  });

  @override
  State<CashierMenuScreen> createState() => _CashierMenuScreenState();
}

class _CashierMenuScreenState extends State<CashierMenuScreen> {
  int _selectedNavIndex = 0;
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  // State Data dari SQLite
  bool _isLoading = true;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  Map<String, int> _dailySummary = {
    'totalRevenue': 0,
    'transactionCount': 0,
    'totalExpenses': 0,
    'netCash': 0,
  };
  List<TransactionModel> _recentTransactions = [];

  // Keranjang Belanja Aktif: Map<productId, quantity>
  final Map<int, int> _cart = {};
  final Map<int, Product> _cartProducts = {};

  // Kategori Menu Template Netral
  final List<_CategoryDef> _categoryDefs = const [
    _CategoryDef('Semua', Icons.apps_rounded, Color(0xFF15803D)),
    _CategoryDef('Kategori A', Icons.category_outlined, Color(0xFF059669)),
    _CategoryDef('Kategori B', Icons.widgets_outlined, Color(0xFF0284C7)),
  ];

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Memuat Template Produk Netral (Nama & Harga Kosong)
  Future<void> _loadDataFromDatabase() async {
    setState(() => _isLoading = true);

    try {
      final summary = await DatabaseHelper.instance.getDailySummary(DateTime.now());
      final transactions = await DatabaseHelper.instance.getTransactions(date: DateTime.now());

      if (mounted) {
        setState(() {
          _allProducts = _getNeutralTemplateProducts();
          _dailySummary = summary;
          _recentTransactions = transactions;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _allProducts = _getNeutralTemplateProducts();
          _applyFilter();
          _isLoading = false;
        });
      }
    }
  }

  List<Product> _getNeutralTemplateProducts() {
    return [
      Product(
        id: 1,
        productCode: 'PRD-001',
        name: 'Menu 1',
        category: 'Kategori A',
        price: 0,
        stock: 50,
        unit: 'Pcs',
      ),
      Product(
        id: 2,
        productCode: 'PRD-002',
        name: 'Menu 2',
        category: 'Kategori A',
        price: 0,
        stock: 30,
        unit: 'Pcs',
      ),
      Product(
        id: 3,
        productCode: 'PRD-003',
        name: 'Menu 3',
        category: 'Kategori A',
        price: 0,
        stock: 25,
        unit: 'Pcs',
      ),
      Product(
        id: 4,
        productCode: 'PRD-004',
        name: 'Menu 4',
        category: 'Kategori B',
        price: 0,
        stock: 40,
        unit: 'Pcs',
      ),
      Product(
        id: 5,
        productCode: 'PRD-005',
        name: 'Menu 5',
        category: 'Kategori B',
        price: 0,
        stock: 35,
        unit: 'Pcs',
      ),
      Product(
        id: 6,
        productCode: 'PRD-006',
        name: 'Menu 6',
        category: 'Kategori B',
        price: 0,
        stock: 20,
        unit: 'Pcs',
      ),
    ];
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final matchCategory =
            _selectedCategory == 'Semua' || p.category == _selectedCategory;
        final matchQuery = query.isEmpty ||
            p.name.toLowerCase().contains(query) ||
            p.productCode.toLowerCase().contains(query);
        return matchCategory && matchQuery;
      }).toList();
    });
  }

  // ==========================================
  // OPERASI KERANJANG BELANJA (CART)
  // ==========================================
  void _addToCart(Product product) {
    final pid = product.id ?? product.productCode.hashCode;
    final currentQty = _cart[pid] ?? 0;

    // Proteksi sisa stok fisik
    if (product.stock <= 0) {
      _showStockWarning('Stok ${product.name} telah habis!');
      return;
    }
    if (currentQty >= product.stock) {
      _showStockWarning('Jumlah melebihi stok yang ada (${product.stock} ${product.unit})!');
      return;
    }

    setState(() {
      _cart[pid] = currentQty + 1;
      _cartProducts[pid] = product;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${product.name} (+1) masuk keranjang',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF15803D),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }

  void _showStockWarning(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(msg, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }

  int get _totalItems => _cart.values.fold(0, (sum, q) => sum + q);

  int get _totalPrice {
    int total = 0;
    _cart.forEach((pid, qty) {
      final prod = _cartProducts[pid];
      if (prod != null) {
        total += prod.price * qty;
      }
    });
    return total;
  }

  int get _totalAvailableStock =>
      _allProducts.fold(0, (sum, p) => sum + p.stock);

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
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

  void _navigateToCashierPos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashierPosScreen(
          branchName: widget.branchName,
          shiftName: widget.shiftName,
          isOwner: widget.isOwner,
        ),
      ),
    ).then((_) {
      // Refresh stok dan ringkasan saat kembali dari layar Kasir
      _loadDataFromDatabase();
    });
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
            Text('Kunci Layar Kasir?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Anda akan keluar dari sesi ini dan kembali ke layar PIN.',
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

  // ══════════════════════════════════════════════════════════════════════════
  //  ROOT BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildDateTimeBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF15803D)),
                    )
                  : LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isWide = constraints.maxWidth >= 720;
                        return isWide ? _buildWideLayout() : _buildMobileLayout();
                      },
                    ),
            ),
            // Floating Bar Keranjang jika ada barang
            if (_totalItems > 0) _buildFloatingCartBar(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TOP BAR — Logo + Branch + Search Box + Avatar Kunci
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Logo Toko
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF15803D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          // Brand & Lokasi Cabang
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sarjana Degan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF15803D),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                widget.branchName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Kolom Pencarian Menu Aktif
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _applyFilter(),
                style: const TextStyle(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'Cari menu / produk...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 14),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilter();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFF15803D), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Tombol Role & Kunci Sesi
          Tooltip(
            message: 'Kunci Layar Kasir',
            child: InkWell(
              onTap: _handleLogout,
              borderRadius: BorderRadius.circular(10),
              child: _buildRoleAvatar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleAvatar() {
    final isOwner = widget.isOwner;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isOwner ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOwner ? const Color(0xFFF59E0B) : const Color(0xFF86EFAC),
        ),
      ),
      child: Center(
        child: Text(
          isOwner ? '👑' : '👤',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DATE-TIME BAR — Tanggal + Jam WIB Realtime
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDateTimeBar() {
    return Container(
      color: const Color(0xFF15803D),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFFA7F3D0)),
          const SizedBox(width: 6),
          Text(
            _formatDate(_now),
            style: const TextStyle(fontSize: 11.5, color: Color(0xFFD1FAE5), fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const Icon(Icons.access_time, size: 13, color: Color(0xFFA7F3D0)),
          const SizedBox(width: 4),
          Text(
            _formatTime(_now),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Shift ${widget.shiftName}',
              style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  MOBILE LAYOUT (< 720px) — Scroll Vertikal
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return RefreshIndicator(
      color: const Color(0xFF15803D),
      onRefresh: _loadDataFromDatabase,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 3 Kartu Statistik Real-time ───────────────────────────────
            _buildStatsRow(),
            // ── Kategori Filter ───────────────────────────────────────────
            _buildSectionHeader('Kategori Menu', null),
            _buildCategoryRow(),
            // ── Grid Menu Produk ───────────────────────────────────────────
            _buildSectionHeader(
              _selectedCategory == 'Semua' ? 'Katalog Menu' : 'Kategori: $_selectedCategory',
              '${_filteredProducts.length} Produk',
            ),
            _buildProductsGrid(),
            // ── Transaksi Terakhir Hari Ini ───────────────────────────────
            _buildSectionHeader('Transaksi Terakhir Hari Ini', null),
            _buildLastOrderList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  WIDE LAYOUT (>= 720px) — Split View Tablet / Desktop
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Panel Kiri: Katalog & Filter
        Expanded(
          flex: 62,
          child: RefreshIndicator(
            color: const Color(0xFF15803D),
            onRefresh: _loadDataFromDatabase,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  _buildSectionHeader('Kategori Menu', null),
                  _buildCategoryRow(),
                  _buildSectionHeader(
                    _selectedCategory == 'Semua' ? 'Katalog Menu' : 'Kategori: $_selectedCategory',
                    '${_filteredProducts.length} Produk',
                  ),
                  _buildProductsGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        Container(width: 1, color: const Color(0xFFE2E8F0)),
        // Panel Kanan: Riwayat Transaksi Hari Ini
        SizedBox(
          width: 290,
          child: Column(
            children: [
              _buildSectionHeader('Transaksi Hari Ini', null, padding: const EdgeInsets.fromLTRB(16, 16, 16, 8)),
              Expanded(child: _buildLastOrderList()),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STATS CARDS ROW — Menampilkan Data Nyata SQLite
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStatsRow() {
    final rev = _dailySummary['totalRevenue'] ?? 0;
    final txCount = _dailySummary['transactionCount'] ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Omzet Hari Ini',
              _formatRupiah(rev),
              Icons.trending_up_rounded,
              const Color(0xFF15803D),
              const Color(0xFFDCFCE7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              'Stok Tersedia',
              '$_totalAvailableStock Item',
              Icons.inventory_2_outlined,
              const Color(0xFF0284C7),
              const Color(0xFFE0F2FE),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              'Transaksi',
              '$txCount Nota',
              Icons.receipt_long_outlined,
              const Color(0xFF7C3AED),
              const Color(0xFFF3E8FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: iconColor),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SECTION HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title, String? action, {EdgeInsets? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          if (action != null)
            Text(
              action,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF15803D),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  KATEGORI ROW — Chip Horizontal Interaktif
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCategoryRow() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categoryDefs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final cat = _categoryDefs[i];
          final isSelected = _selectedCategory == cat.name;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat.name;
                _applyFilter();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 80,
              decoration: BoxDecoration(
                color: isSelected ? cat.color.withOpacity(0.12) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? cat.color : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 19),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? cat.color : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  GRID PRODUK — Menampilkan Stok Real & Tombol [+] Tambah Keranjang
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildProductsGrid() {
    if (_filteredProducts.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'Tidak ada produk yang sesuai kriteria.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (ctx, i) => _buildProductCard(_filteredProducts[i]),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final pid = product.id ?? product.productCode.hashCode;
    final inCartQty = _cart[pid] ?? 0;
    final isCategoryA = product.category == 'Kategori A';
    final cardBgColor = isCategoryA ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE);
    final accentColor = isCategoryA ? const Color(0xFF059669) : const Color(0xFF0284C7);
    final isOutOfStock = product.stock <= 0;
    final priceDisplay = product.price > 0 ? _formatRupiah(product.price) : 'Rp —';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: inCartQty > 0
            ? Border.all(color: const Color(0xFF15803D), width: 1.5)
            : Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar / Ikon Produk + Badge Sisa Stok Real
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    isCategoryA ? Icons.category_outlined : Icons.widgets_outlined,
                    size: 44,
                    color: accentColor,
                  ),
                  // Badge Sisa Stok
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? const Color(0xFFEF4444)
                            : (product.stock <= 5 ? const Color(0xFFF59E0B) : Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOutOfStock ? 'Habis' : '${product.stock} ${product.unit}',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isOutOfStock
                              ? Colors.white
                              : (product.stock <= 5 ? Colors.white : const Color(0xFF1E293B)),
                        ),
                      ),
                    ),
                  ),
                  // Indikator Berapa Item di Keranjang
                  if (inCartQty > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF15803D),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$inCartQty',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Info Produk & Tombol [+] Tambah Belanja
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        priceDisplay,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                        ),
                      ),
                      const Spacer(),
                      // Tombol [+] Tambah
                      InkWell(
                        onTap: isOutOfStock ? null : () => _addToCart(product),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isOutOfStock ? const Color(0xFFCBD5E1) : accentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  LIST TRANSAKSI TERAKHIR HARI INI DARI SQLITE
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildLastOrderList() {
    if (_recentTransactions.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'Belum ada transaksi hari ini.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _recentTransactions.take(5).length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (ctx, i) {
        final tx = _recentTransactions[i];
        final itemsDesc = tx.items.map((it) => '${it.productName} ×${it.quantity}').join(', ');

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_outlined, color: Color(0xFF15803D), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.invoiceNumber,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      itemsDesc,
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                _formatRupiah(tx.totalAmount),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FLOATING CART BAR — Ringkasan Belanja Cepat
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFloatingCartBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF15803D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_totalItems Item Belanja',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                _totalPrice > 0 ? _formatRupiah(_totalPrice) : 'Rp —',
                style: const TextStyle(color: Color(0xFF86EFAC), fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _navigateToCashierPos,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Buka Kasir', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BOTTOM NAVIGATION BAR — 5 Tab Navigasi
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.home_rounded, 'Beranda'),
      _NavItem(Icons.point_of_sale_rounded, 'Kasir'),
      _NavItem(Icons.inventory_2_outlined, 'Stok'),
      _NavItem(Icons.receipt_long_outlined, 'Riwayat'),
      _NavItem(Icons.settings_outlined, 'Pengaturan'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = _selectedNavIndex == i;
              final isKasirTab = i == 1;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedNavIndex = i);
                  if (isKasirTab) {
                    _navigateToCashierPos();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFDCFCE7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            items[i].icon,
                            size: 20,
                            color: isActive ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                              color: isActive ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      // Badge Keranjang pada Tab Kasir
                      if (isKasirTab && _totalItems > 0)
                        Positioned(
                          top: -4,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC2626),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$_totalItems',
                              style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _CategoryDef {
  final String name;
  final IconData icon;
  final Color color;
  const _CategoryDef(this.name, this.icon, this.color);
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
