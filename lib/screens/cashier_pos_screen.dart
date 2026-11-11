import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item.dart';
import '../database/database_helper.dart';

/// Layar Utama Kasir POS Sarjana Degan Madiun
/// Desain Responsif: Split-Screen untuk Tablet / Desktop & Fallback Mobile
class CashierPosScreen extends StatefulWidget {
  final String branchName;
  final String shiftName;
  final bool isOwner;

  const CashierPosScreen({
    super.key,
    required this.branchName,
    required this.shiftName,
    this.isOwner = false,
  });

  @override
  State<CashierPosScreen> createState() => _CashierPosScreenState();
}

class _CashierPosScreenState extends State<CashierPosScreen> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  // Keranjang: Map<productId, quantity>
  final Map<int, int> _cart = {};
  // Cache data produk di keranjang agar tidak hilang saat filter aktif
  final Map<int, Product> _cartProducts = {};

  late Timer _clockTimer;
  DateTime _currentDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentDateTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Memuat data produk dari SQLite lokal (dengan fallback aman jika database belum terisi)
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await DatabaseHelper.instance.getProducts();
      if (products.isNotEmpty) {
        if (mounted) {
          setState(() {
            _allProducts = products;
            _applyFilter();
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {
      // Fallback jika database belum ada atau berjalan di web sandbox
    }

    // Default Fallback Produk Resmi Sarjana Degan Madiun
    final defaultProducts = [
      Product(
        id: 1,
        productCode: 'PRD-001',
        name: 'Kelapa Muda Ijo Utuh',
        category: 'Kelapa',
        price: 12000,
        stock: 50,
        unit: 'Butir',
      ),
      Product(
        id: 2,
        productCode: 'PRD-002',
        name: 'Kelapa Muda Wulung',
        category: 'Kelapa',
        price: 15000,
        stock: 30,
        unit: 'Butir',
      ),
      Product(
        id: 3,
        productCode: 'PRD-003',
        name: 'Kelapa Kupas Siap Minum',
        category: 'Kelapa',
        price: 14000,
        stock: 25,
        unit: 'Butir',
      ),
      Product(
        id: 4,
        productCode: 'PRD-004',
        name: 'Es Degan Gula Jawa',
        category: 'Es Cup',
        price: 6000,
        stock: 60,
        unit: 'Cup',
      ),
      Product(
        id: 5,
        productCode: 'PRD-005',
        name: 'Es Degan Sirup Merah',
        category: 'Es Cup',
        price: 6000,
        stock: 40,
        unit: 'Cup',
      ),
      Product(
        id: 6,
        productCode: 'PRD-006',
        name: 'Es Degan Original Murni',
        category: 'Es Cup',
        price: 5000,
        stock: 30,
        unit: 'Cup',
      ),
      Product(
        id: 7,
        productCode: 'PRD-007',
        name: 'Es Degan Susu',
        category: 'Es Cup',
        price: 7000,
        stock: 20,
        unit: 'Cup',
      ),
    ];

    if (mounted) {
      setState(() {
        _allProducts = defaultProducts;
        _applyFilter();
        _isLoading = false;
      });
    }
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
    setState(() {
      _cart[pid] = (_cart[pid] ?? 0) + 1;
      _cartProducts[pid] = product;
    });
  }

  void _decrementCart(int productId) {
    if (!_cart.containsKey(productId)) return;
    setState(() {
      final current = _cart[productId]!;
      if (current > 1) {
        _cart[productId] = current - 1;
      } else {
        _cart.remove(productId);
        _cartProducts.remove(productId);
      }
    });
  }

  void _removeFromCart(int productId) {
    setState(() {
      _cart.remove(productId);
      _cartProducts.remove(productId);
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _cartProducts.clear();
    });
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

  String _formatDateTime(DateTime dt) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final dayName = days[dt.weekday - 1];
    final day = dt.day.toString();
    final monthName = months[dt.month - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$dayName, $day $monthName • $hour:$minute:$second WIB';
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
            Text(
              'Kunci Layar Kasir?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Anda akan keluar dari sesi ini dan kembali ke layar pengisian PIN kasir.',
          style: TextStyle(fontSize: 13.5, color: Color(0xFF4B5563)),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Logo & Judul
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: Color(0xFF15803D),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sarjana Degan POS',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Madiun',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Sesi Kasir & Shift Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Color(0xFF15803D)),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.branchName} • Shift ${widget.shiftName}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Jam Realtime
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 13, color: Color(0xFF059669)),
                        const SizedBox(width: 6),
                        Text(
                          _formatDateTime(_currentDateTime),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Logout / Kunci
                  IconButton(
                    tooltip: 'Kunci Layar Kasir',
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout, size: 20, color: Color(0xFF64748B)),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTabletOrDesktop = constraints.maxWidth >= 720;

          if (isTabletOrDesktop) {
            // Mode Split-Screen: Kiri Katalog (62%), Kanan Struk (38%)
            return Row(
              children: [
                Expanded(
                  flex: 62,
                  child: _buildCatalogPanel(),
                ),
                Container(
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                ),
                Expanded(
                  flex: 38,
                  child: _buildCartPanel(),
                ),
              ],
            );
          } else {
            // Mode Fallback Layar Ponsel: Katalog Penuh dengan Sticky Cart Bar di Bawah
            return Column(
              children: [
                Expanded(child: _buildCatalogPanel()),
                _buildMobileCartSummaryBar(),
              ],
            );
          }
        },
      ),
    );
  }

  // ==========================================
  // PANEL KATALOG MENU PRODUK (KIRI)
  // ==========================================
  Widget _buildCatalogPanel() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Kategori & Pencarian
          Row(
            children: [
              // Kategori Pills
              _buildCategoryPill('Semua'),
              const SizedBox(width: 8),
              _buildCategoryPill('Kelapa'),
              const SizedBox(width: 8),
              _buildCategoryPill('Es Cup'),
              const Spacer(),
              // Kolom Pencarian Cepat
              SizedBox(
                width: 220,
                height: 38,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilter(),
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: 'Cari menu...',
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
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
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
            ],
          ),
          const SizedBox(height: 16),
          // Grid Kartu Produk
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF15803D)),
                  )
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 40, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 8),
                            const Text(
                              'Menu tidak ditemukan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _selectedCategory = 'Semua');
                                _applyFilter();
                              },
                              child: const Text('Reset Pencarian', style: TextStyle(color: Color(0xFF15803D))),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (ctx, gridConstraints) {
                          int crossAxisCount = 2;
                          if (gridConstraints.maxWidth > 880) {
                            crossAxisCount = 4;
                          } else if (gridConstraints.maxWidth > 580) {
                            crossAxisCount = 3;
                          }

                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.15,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (ctx, index) {
                              final product = _filteredProducts[index];
                              return _buildProductCard(product);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String title) {
    final isSelected = _selectedCategory == title;
    return InkWell(
      onTap: () {
        setState(() => _selectedCategory = title);
        _applyFilter();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF15803D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF15803D) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF15803D).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final pid = product.id ?? product.productCode.hashCode;
    final inCartQty = _cart[pid] ?? 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: inCartQty > 0 ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: inCartQty > 0 ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () => _addToCart(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag Kategori & Stok
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: product.category == 'Kelapa'
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: product.category == 'Kelapa'
                            ? const Color(0xFFB45309)
                            : const Color(0xFF0369A1),
                      ),
                    ),
                  ),
                  // Indikator Dalam Keranjang
                  if (inCartQty > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF15803D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$inCartQty x',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Stok: ${product.stock}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                ],
              ),
              const Spacer(),
              // Nama Produk
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              // Harga Satuan & Tombol Tambah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatRupiah(product.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15803D),
                        ),
                      ),
                      Text(
                        '/${product.unit}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, size: 16, color: Color(0xFF15803D)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PANEL KERANJANG STRUK BELANJA (KANAN)
  // ==========================================
  Widget _buildCartPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Struk
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pesanan Aktif',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Struk Transaksi Pembeli',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              if (_cart.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearCart,
                  icon: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFEF4444)),
                  label: const Text(
                    'Kosongkan',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          // Daftar Item Keranjang
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 28,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Keranjang Masih Kosong',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Sentuh kartu produk di sebelah kiri untuk memasukkan ke keranjang belanja.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _cart.length,
                    separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF8FAFC)),
                    itemBuilder: (ctx, index) {
                      final pid = _cart.keys.elementAt(index);
                      final qty = _cart[pid]!;
                      final product = _cartProducts[pid];
                      if (product == null) return const SizedBox.shrink();

                      final subtotal = product.price * qty;

                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          children: [
                            // Info Nama & Harga Satuan
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_formatRupiah(product.price)} x $qty',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Stepper Kuantitas
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => _decrementCart(pid),
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Icon(Icons.remove, size: 14, color: Color(0xFF475569)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      '$qty',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _addToCart(product),
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Icon(Icons.add, size: 14, color: Color(0xFF15803D)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Subtotal Nominal
                            SizedBox(
                              width: 80,
                              child: Text(
                                _formatRupiah(subtotal),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Hapus Baris
                            InkWell(
                              onTap: () => _removeFromCart(pid),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.close, size: 14, color: Color(0xFF94A3B8)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const Divider(height: 24, color: Color(0xFFE2E8F0)),

          // Ringkasan Pembayaran & Tombol Bayar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Belanja',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '$_totalItems item pesanan',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatRupiah(_totalPrice),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF15803D),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Tombol BAYAR Utama
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _totalPrice > 0 ? () => _openPaymentModal(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    elevation: _totalPrice > 0 ? 3 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _totalPrice > 0
                            ? 'BAYAR  •  ${_formatRupiah(_totalPrice)}'
                            : 'PILIH MENU DULU',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
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

  // Fallback Mobile Bar jika dibuka di layar kecil (HP)
  Widget _buildMobileCartSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_totalItems item dipilih',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                Text(
                  _formatRupiah(_totalPrice),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _totalPrice > 0
                  ? () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => SizedBox(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: _buildCartPanel(),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buka Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String get _outletCode {
    if (widget.branchName.contains('2')) return 'SD02';
    return 'SD01';
  }

  void _openPaymentModal(BuildContext context) {
    if (_totalPrice <= 0 || _cart.isEmpty) return;

    // Jika sedang di dalam modal mobile cart, tutup dulu agar bersih
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    showModalBottomSheet(
      context: this.context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _PaymentModalSheet(
          totalPrice: _totalPrice,
          totalItems: _totalItems,
          cart: Map.from(_cart),
          cartProducts: Map.from(_cartProducts),
          outletCode: _outletCode,
          branchName: widget.branchName,
          shiftName: widget.shiftName,
          formatRupiah: _formatRupiah,
          onSuccess: (TransactionModel tx) {
            // Refresh stok dari database SQLite lokal
            _loadProducts();
            // Kosongkan keranjang belanja
            setState(() {
              _cart.clear();
              _cartProducts.clear();
            });
            // Tampilkan struk nota digital sukses
            _showReceiptDialog(tx);
          },
        );
      },
    );
  }

  void _showReceiptDialog(TransactionModel tx) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 36),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TRANSAKSI BERHASIL!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx.invoiceNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tx.cashierName} • ${_formatDateTimeShort(tx.transactionDate)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE2E8F0), thickness: 1),
                  const SizedBox(height: 8),

                  // Daftar Item Belanja
                  ...tx.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} x${item.quantity}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                          ),
                          Text(
                            _formatRupiah(item.subtotal),
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE2E8F0), thickness: 1),
                  const SizedBox(height: 8),

                  // Rincian Keuangan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Belanja', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      Text(
                        _formatRupiah(tx.totalAmount),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Metode (${tx.paymentMethod})', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      Text(
                        _formatRupiah(tx.paidAmount),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kembalian', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                      Text(
                        _formatRupiah(tx.changeAmount),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Text(
                      'Stok produk di database otomatis berkurang.\nTerima kasih atas kunjungan Anda! 🥥✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SELESAI / TRANSAKSI BARU',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTimeShort(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute WIB';
  }
}

/// Modal Lembar Pembayaran Kasir (Quick Pay Sheet)
class _PaymentModalSheet extends StatefulWidget {
  final int totalPrice;
  final int totalItems;
  final Map<int, int> cart;
  final Map<int, Product> cartProducts;
  final String outletCode;
  final String branchName;
  final String shiftName;
  final String Function(int) formatRupiah;
  final void Function(TransactionModel tx) onSuccess;

  const _PaymentModalSheet({
    required this.totalPrice,
    required this.totalItems,
    required this.cart,
    required this.cartProducts,
    required this.outletCode,
    required this.branchName,
    required this.shiftName,
    required this.formatRupiah,
    required this.onSuccess,
  });

  @override
  State<_PaymentModalSheet> createState() => _PaymentModalSheetState();
}

class _PaymentModalSheetState extends State<_PaymentModalSheet> {
  String _paymentMethod = 'TUNAI'; // 'TUNAI' atau 'QRIS'
  late int _nominalBayar;
  bool _isProcessing = false;
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nominalBayar = widget.totalPrice; // Default uang pas
    _customAmountController.text = widget.totalPrice.toString();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _selectNominal(int amount) {
    setState(() {
      _nominalBayar = amount;
      _customAmountController.text = amount.toString();
    });
  }

  Future<void> _processPayment() async {
    if (_paymentMethod == 'TUNAI' && _nominalBayar < widget.totalPrice) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final invoice = await DatabaseHelper.instance.generateInvoiceNumber(widget.outletCode);

      List<TransactionItem> items = [];
      widget.cart.forEach((productId, qty) {
        final product = widget.cartProducts[productId];
        if (product != null && qty > 0) {
          items.add(TransactionItem(
            productId: product.id ?? productId,
            productName: product.name,
            priceAtSale: product.price,
            quantity: qty,
            subtotal: product.price * qty,
          ));
        }
      });

      final tx = TransactionModel(
        invoiceNumber: invoice,
        transactionDate: DateTime.now(),
        totalAmount: widget.totalPrice,
        paidAmount: _paymentMethod == 'QRIS' ? widget.totalPrice : _nominalBayar,
        changeAmount: _paymentMethod == 'QRIS'
            ? 0
            : (_nominalBayar >= widget.totalPrice ? _nominalBayar - widget.totalPrice : 0),
        paymentMethod: _paymentMethod,
        cashierName: '${widget.branchName} • Shift ${widget.shiftName}',
        notes: 'Outlet: ${widget.outletCode}',
        items: items,
      );

      // Simpan transaksi & potong stok otomatis di SQLite
      await DatabaseHelper.instance.createTransaction(tx);

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSuccess(tx);
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses transaksi: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kembalian = _nominalBayar - widget.totalPrice;
    final isKurang = _paymentMethod == 'TUNAI' && kembalian < 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pembayaran Kasir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${widget.outletCode} • ${widget.totalItems} Item Pesanan',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Box Total Tagihan Besar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL TAGIHAN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF166534),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      widget.formatRupiah(widget.totalPrice),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tab Pilihan Metode Pembayaran
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _paymentMethod = 'TUNAI'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _paymentMethod == 'TUNAI' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _paymentMethod == 'TUNAI'
                                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.money_rounded,
                                size: 18,
                                color: _paymentMethod == 'TUNAI' ? const Color(0xFF15803D) : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'TUNAI (CASH)',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: _paymentMethod == 'TUNAI' ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _paymentMethod = 'QRIS';
                          _nominalBayar = widget.totalPrice;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _paymentMethod == 'QRIS' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _paymentMethod == 'QRIS'
                                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 18,
                                color: _paymentMethod == 'QRIS' ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'QRIS / TRANSFER',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: _paymentMethod == 'QRIS' ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Konten Berdasarkan Metode
              if (_paymentMethod == 'TUNAI') ...[
                const Text(
                  'Uang Diterima dari Pelanggan:',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 8),

                // Tombol Cepat Pecahan Uang
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPillButton(
                      label: 'Uang Pas (${widget.formatRupiah(widget.totalPrice)})',
                      isSelected: _nominalBayar == widget.totalPrice,
                      onTap: () => _selectNominal(widget.totalPrice),
                    ),
                    _buildPillButton(
                      label: 'Rp 10.000',
                      isSelected: _nominalBayar == 10000,
                      onTap: () => _selectNominal(10000),
                    ),
                    _buildPillButton(
                      label: 'Rp 20.000',
                      isSelected: _nominalBayar == 20000,
                      onTap: () => _selectNominal(20000),
                    ),
                    _buildPillButton(
                      label: 'Rp 50.000',
                      isSelected: _nominalBayar == 50000,
                      onTap: () => _selectNominal(50000),
                    ),
                    _buildPillButton(
                      label: 'Rp 100.000',
                      isSelected: _nominalBayar == 100000,
                      onTap: () => _selectNominal(100000),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Input Nominal Bebas
                TextField(
                  controller: _customAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Input Nominal Uang Tunai Lainnya (Rp)',
                    labelStyle: const TextStyle(fontSize: 12),
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) {
                    final cleanVal = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    setState(() {
                      _nominalBayar = cleanVal;
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Indikator Kembalian Real-time
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isKurang ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isKurang ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isKurang ? 'UANG KURANG:' : 'KEMBALIAN:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isKurang ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
                        ),
                      ),
                      Text(
                        isKurang
                            ? widget.formatRupiah(widget.totalPrice - _nominalBayar)
                            : widget.formatRupiah(kembalian),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isKurang ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Banner Petunjuk QRIS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, size: 36, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Scan Barcode QRIS Lapak',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nominal Pas: ${widget.formatRupiah(widget.totalPrice)}\nPastikan notifikasi dana masuk sudah tampil di HP sebelum menyelesaikan.',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Tombol Proses Selesaikan Transaksi
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: (_isProcessing || isKurang) ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isKurang
                              ? 'UANG BELUM CUKUP'
                              : 'PROSES & SELESAIKAN (${_paymentMethod})',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.3),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF15803D) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF15803D) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

