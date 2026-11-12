import 'dart:async';
import 'package:flutter/material.dart';

/// Layar Menu Kasir - Sarjana Degan POS Madiun
/// Inspirasi: Grocery Dashboard UI - Adaptasi Mobile Portrait
/// STATUS: UI SHELL ONLY (data statis placeholder, belum terhubung DB)
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
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  // ── Kategori Produk (placeholder) ──────────────────────────────────────────
  final List<_CategoryItem> _categories = const [
    _CategoryItem('Semua',    Icons.apps_rounded,            Color(0xFF15803D)),
    _CategoryItem('Kelapa',   Icons.eco_outlined,            Color(0xFF059669)),
    _CategoryItem('Es Cup',   Icons.local_drink_outlined,    Color(0xFF0284C7)),
    _CategoryItem('Promo',    Icons.local_offer_outlined,    Color(0xFFD97706)),
    _CategoryItem('Paket',    Icons.card_giftcard_outlined,  Color(0xFF7C3AED)),
  ];

  // ── Produk Populer (placeholder) ───────────────────────────────────────────
  final List<_ProductItem> _popularProducts = const [
    _ProductItem('Kelapa Muda Ijo',   'Rp 12.000', '50 butir',  Color(0xFFDCFCE7), Color(0xFF15803D)),
    _ProductItem('Kelapa Wulung',     'Rp 15.000', '30 butir',  Color(0xFFFEF9C3), Color(0xFFB45309)),
    _ProductItem('Kelapa Kupas',      'Rp 14.000', '25 butir',  Color(0xFFE0F2FE), Color(0xFF0284C7)),
    _ProductItem('Es Degan Gula Jawa','Rp 6.000',  '60 cup',    Color(0xFFFCE7F3), Color(0xFFBE185D)),
  ];

  // ── Transaksi Terakhir (placeholder) ───────────────────────────────────────
  final List<_LastOrderItem> _lastOrders = const [
    _LastOrderItem('Kelapa Muda Ijo × 3', 'Rp 36.000',  Color(0xFF15803D)),
    _LastOrderItem('Es Degan Sirup × 5',  'Rp 30.000',  Color(0xFF0284C7)),
    _LastOrderItem('Kelapa Wulung × 2',   'Rp 30.000',  Color(0xFFD97706)),
    _LastOrderItem('Paket Hemat A',       'Rp 25.000',  Color(0xFF7C3AED)),
  ];

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatDate(DateTime dt) {
    const days   = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
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
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  return isWide
                      ? _buildWideLayout()
                      : _buildMobileLayout();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TOP BAR — Logo + Branch + Search + Avatar
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo tile
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
          // Brand + Branch
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
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Search bar
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 12),
                  Icon(Icons.search, size: 16, color: Color(0xFF94A3B8)),
                  SizedBox(width: 8),
                  Text(
                    'Cari menu, kelapa...',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar / role badge
          _buildRoleAvatar(),
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
  //  DATE-TIME BAR — Tanggal + Jam + Shift badge
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDateTimeBar() {
    return Container(
      color: const Color(0xFF15803D),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFFA7F3D0)),
          const SizedBox(width: 6),
          Text(
            _formatDate(_now),
            style: const TextStyle(fontSize: 12, color: Color(0xFFD1FAE5), fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const Icon(Icons.access_time, size: 13, color: Color(0xFFA7F3D0)),
          const SizedBox(width: 4),
          Text(
            _formatTime(_now),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Shift ${widget.shiftName}',
              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  MOBILE LAYOUT (< 720px) — Scroll vertikal
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats Cards Row ─────────────────────────────────────────────
          _buildStatsRow(),
          // ── Kategori ────────────────────────────────────────────────────
          _buildSectionHeader('Kategori', null),
          _buildCategoryRow(),
          // ── Produk Populer ───────────────────────────────────────────────
          _buildSectionHeader('Menu Populer Hari Ini', 'Lihat Semua'),
          _buildPopularProductsGrid(),
          // ── Transaksi Terakhir ───────────────────────────────────────────
          _buildSectionHeader('Transaksi Terakhir', 'Riwayat'),
          _buildLastOrderList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  WIDE LAYOUT (>= 720px) — Side-by-side
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left main content
        Expanded(
          flex: 62,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsRow(),
                _buildSectionHeader('Kategori', null),
                _buildCategoryRow(),
                _buildSectionHeader('Menu Populer Hari Ini', 'Lihat Semua'),
                _buildPopularProductsGrid(),
              ],
            ),
          ),
        ),
        // Right panel — Last orders
        Container(width: 1, color: const Color(0xFFE2E8F0)),
        SizedBox(
          width: 260,
          child: Column(
            children: [
              _buildSectionHeader('Transaksi Terakhir', 'Semua', padding: const EdgeInsets.fromLTRB(16, 16, 16, 8)),
              Expanded(child: _buildLastOrderList()),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STATS ROW — 3 kartu ringkas di atas
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Penjualan Hari Ini', 'Rp —', Icons.trending_up_rounded, const Color(0xFF15803D), const Color(0xFFDCFCE7))),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard('Stok Tersedia', '— Butir', Icons.inventory_2_outlined, const Color(0xFF0284C7), const Color(0xFFE0F2FE))),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard('Transaksi', '— Trx', Icons.receipt_long_outlined, const Color(0xFF7C3AED), const Color(0xFFF3E8FF))),
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
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: iconColor)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SECTION HEADER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title, String? action, {EdgeInsets? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              )),
          const Spacer(),
          if (action != null)
            Text(action,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                )),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  KATEGORI ROW — Horizontal scroll chips dengan ikon
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCategoryRow() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory == cat.name;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 72,
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? cat.color : const Color(0xFF475569),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
  //  GRID PRODUK POPULER — 2 kolom
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPopularProductsGrid() {
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
        itemCount: _popularProducts.length,
        itemBuilder: (ctx, i) => _buildProductCard(_popularProducts[i]),
      ),
    );
  }

  Widget _buildProductCard(_ProductItem product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar placeholder
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: product.bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_outlined, size: 48, color: product.accentColor),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.stock,
                      style: TextStyle(fontSize: 10, color: product.accentColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info + tombol tambah
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        product.price,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: product.accentColor),
                      ),
                      const Spacer(),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: product.accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
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
  //  LIST TRANSAKSI TERAKHIR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildLastOrderList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _lastOrders.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (ctx, i) {
        final item = _lastOrders[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // Dot warna
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_outlined, color: item.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                    const Text('—',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              Text(item.total,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: item.color)),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BOTTOM NAVIGATION BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.home_rounded,          'Beranda'),
      _NavItem(Icons.point_of_sale_rounded, 'Kasir'),
      _NavItem(Icons.inventory_2_outlined,  'Stok'),
      _NavItem(Icons.receipt_long_outlined, 'Riwayat'),
      _NavItem(Icons.settings_outlined,     'Pengaturan'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = _selectedNavIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFDCFCE7) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].icon,
                        size: 22,
                        color: isActive ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
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

// ══════════════════════════════════════════════════════════════════════════
//  DATA MODELS PLACEHOLDER
// ══════════════════════════════════════════════════════════════════════════

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  const _CategoryItem(this.name, this.icon, this.color);
}

class _ProductItem {
  final String name;
  final String price;
  final String stock;
  final Color bgColor;
  final Color accentColor;
  const _ProductItem(this.name, this.price, this.stock, this.bgColor, this.accentColor);
}

class _LastOrderItem {
  final String name;
  final String total;
  final Color color;
  const _LastOrderItem(this.name, this.total, this.color);
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
